	TITLE	'CP/M DEBUGGER (DEMON) 1/80'
;	CP/M DEBUGGER VERSION 2.2
;
;	COPYRIGHT (C) 1980
;	DIGITAL RESEARCH
;	BOX 579 PACIFIC GROVE
;	CALIFORNIA 93950
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
DEBUG	EQU	FALSE	;TRUE IF DEBUGGING
RELOC	EQU	TRUE	;TRUE IF RELOCATING
	IF	DEBUG
	ORG	1000H
	ELSE
	IF	RELOC
	ORG	0000H
	ELSE
	ORG	0D000H	;TESTING IN 64K
	ENDIF
	ENDIF
;
MODBAS	EQU	$	;BASE OF ASSEM/DISASSEM MODULE
	DS	680H		;SIZE OF ASSEM/DISASSEM
DEMON	EQU	$		;BASE OF DEMON MODULE
DISIN	EQU	MODBAS+3
BDOS	EQU	$+1006H
BDOSE	EQU	5H	;ENTRY POINT TO DOS FROM USER PROGRAMS
PCBASE	EQU	100H	;DEFAULT PC
SPBASE	EQU	100H	;DEFAULT SP
DISEN	EQU	DISIN+3		;DISASSEMBLER ENTRY POINT
ASSEM	EQU	DISEN+3	;ASSEMBLER ENTRY POINT
DISPC	EQU	ASSEM+3		;DISASSEMBLER PC VALUE
DISPM	EQU	DISPC+2		;DISASSEMBLER PC MAX VALUE
DISPG	EQU	DISPM+2		;DISASSEMBLER PAGE MODE IF NON ZERO
PSIZE	EQU	12		;NUMBER OF ASSEMBLY LINES TO LIST WITH 'L'
CSIZE	EQU	32		;COMMAND BUFFER SIZE
SSIZE	EQU	50		;LOCAL STACK SIZE
;
;	BASIC DISK OPERATING SYSTEM CONSTANTS
CIF	EQU	1
COF	EQU	2
RIF	EQU	3
POF	EQU	4
LOF	EQU	5
;
IDS	EQU	7
GETF	EQU	10	;FILL BUFFER FROM CONSOLE
CHKIO	EQU	11	;CHECK IO STATUS
LIFT	EQU	12	;LIFT HEAD ON DISK
OPF	EQU	15	;DISK FILE OPEN
RDF	EQU	20	;READ DISK FILE
DMAF	EQU	26	;SET DMA ADDRESS
;
DBP	EQU	5BH	;DISK BUFFER POINTER
DBF	EQU	80H	;DISK BUFFER ADDRESS
DFCB	EQU	5CH	;DISK FILE CONTROL BLOCK
FCB	EQU	DFCB
FDN	EQU	0	;DISK NAME
FFN	EQU	1	;FILE NAME
FFT	EQU	9	;FILE TYPE
FRL	EQU	12	;REEL NUMBER
FRC	EQU	15	;RECORD COUNT
FCR	EQU	32	;CURRENT RECORD
FLN	EQU	33	;FCB LENGTH
;
DEOF	EQU	1AH	;CONTROL-Z (EOF)
CR	EQU	0DH
LF	EQU	0AH
;
	IF	DEBUG
RSTNUM	EQU	6	;USE 6 IF DEBUGGING
	ELSE
RSTNUM	EQU	7	;RESTART NUMBER
	ENDIF
RSTLOC	EQU	RSTNUM*8	;RESTART LOCATION
RSTIN	EQU	0C7H OR (RSTNUM SHL 3)	;RESTART INSTRUCTION
;
;	TEMPLATE FOR PROGRAMMED BREAKPOINTS
;		---------
;		PCH : PCL
;		HLH : HLL
;		SPH : SPL
;		RA  : FLG
;		B   : C
;		D   : E
;		---------
;	FLG FIELD:  MZ0I0E1C (MINUS,ZERO,IDC,EVEN,CARRY)
;
AVAL	EQU	5	;A REGISTER COUNT IN HEADER
BVAL	EQU	6
DVAL	EQU	7
HVAL	EQU	8
SVAL	EQU	9
PVAL	EQU	10
;
;
;	DEMON ENTRY POINTS
	JMP	TRAPAD	;TRAP ADDRESS FOR RETURN IN CASE INTERRUPT
	JMP	BEGIN
BREAKA:
	JMP	BREAKP
;	USEFUL ENTRY POINTS FOR PROGRAMS RUNNING WITH DDT
	JMP	GETBUFF	;GET ANOTHER BUFFER FULL
	JMP	GNC	;GET NEXT CHARACTER
	JMP	PCHAR	;PRINT A CHARACTER FROM A
	JMP	PBYTE	;PRINT BYTE IN REGISTER A
	JMP	PADDX	;PRINT ADDRESS IN REGISTERS D,E
	JMP	SCANEXP	;SCAN 0,1,2, OR 3 EXPRESSIONS
	JMP	GETVAL	;GET VALUE TO H,L
	JMP	BREAK	;CHECK BREAK KEY
	RET		;TAKES PLACE OF PRLABEL IN SID
;
;
TRAPAD:	;GET THE RETURN ADDRESS FOR THIS JUMP TO BDOS IN CASE OF
;	A SOFT INTERRUPT DURING BDOS PROCESSING.
	XTHL	;PC TO HL
	SHLD	RETLOC	;MAY NOT NEED IT
	XTHL
TRAPJMP:	;ADDRESS FILLED AT "BEGIN"
	JMP	0000H
;
BEGIN:
;
	LHLD	BDOSE+1
	SHLD	TRAPJMP+1	;FILL JUMP TO BDOS
	LXI	H,TRAPAD
	SHLD	MODBAS+1	;ADDRESS FIELD CHANGED
	LXI	H,MODBAS
	SHLD	BDOSE+1		;NOW INCLUDES ASSEM/DISASSEM
;
	XRA	A	;ZERO TO ACCUM
	STA	BREAKS	;CLEARS BREAK POINT COUNT
;
	LXI	H,PCBASE
	SHLD	DISPC		;INITIAL VALUE FOR DISASSEMBLER PC
	SHLD	DISLOC		;INITIAL VALUE FOR DISPLAY
	SHLD	MLOAD		;MAX LOAD LOCATION
;
;	SETUP RESTART TEMPLATE
	SHLD	PLOC
	LXI	H,SPBASE
	LXI	SP,STACK-4
	PUSH	H	;INITIAL SP
	LXI	H,10B	;INITIAL PSW
	PUSH	H
	DCX	H
	DCX	H	;CLEARED
	SHLD	HLOC	;H,L CLEARED
	PUSH	H	;B,C CLEARED
	PUSH	H	;D,E CLEARED
	SHLD	TRACER	;CLEAR TRACE FLAG
;
	MVI	A,0C3H	;(JMP RESTART)
	STA	RSTLOC
	LXI	H,BREAKA	;BREAK POINT SUBROUTINE
	SHLD	RSTLOC+1	;RESTART LOCATION ADDRESS FIELD
;
;	CHECK FOR FILE NAME PASSED TO DEMON, AND LOAD IF PRESENT
	LDA	FCB+FFN	;BLANK IF NO NAME PASSED
	CPI	' '
	JZ	START
;
;	PUSH A ZERO, AND READ
	LXI	H,0
	PUSH	H
	JMP	RINIT
;
;
;	MAIN COMMAND LOOP
;
START:
	LXI	SP,STACK-12	;INITIALIZE SP IN CASE OF ERROR
;	CHECK FOR DISASSEMBLER OVERLOAD
	CALL	CHKDIS
	JC	DISASMOK
;
;	DISASSEMBLER NOT PRESENT, SET BDOS JMP
	LXI	H,DEMON
	SHLD	BDOSE+1	;(RE)SET JMP ADDRESS
DISASMOK:
	CALL	CRLF	;INITIAL CRLF
	IF	DEBUG
	MVI	A,':'
	ELSE
	MVI	A,'-'
	ENDIF
	CALL	PCHAR	;OUTPUT PROMPT
;
;	GET INPUT BUFFER
	CALL	GETBUFF	;FILL COMMAND BUFFER
;
	CALL	GNC	;GET CHARACTER
	CPI	CR
	JZ	START
	SUI	'A'	;LEGAL CHARACTER?
	JC	CERROR	;COMMAND ERROR
	CPI	'Z'-'A'+1
	JNC	CERROR
;	CHARACTER IN REGISTER A IS COMMAND, MUST BE IN THE RANGE A-Z
	MOV	E,A	;INDEX TO E
	MVI	D,0	;DOUBLE PRECISION INDEX
	LXI	H,JMPTAB;BASE OF TABLE
	DAD	D
	DAD	D	;INDEXED
	MOV	E,M	;LO BYTE
	INX	H
	MOV	D,M	;HO BYTE
	XCHG		;TO H,L
	PCHL	;GONE...
;
JMPTAB:	;JUMP TABLE TO SUBROUTINES
	DW	ASSM	;A ENTER ASSEMBLER LANGUAGE
	DW	CERROR	;B
	DW	CERROR	;C
	DW	DISPLAY	;D DISPLAY RAM MEMORY
	DW	CERROR	;E
	DW	FILL	;F FILL MEMORY
	DW	GOTO	;G GO TO MEMORY ADDRESS
	DW	HEXARI	;H HEXADECIMAL SUM AND DIFFERENCE
	DW	INFCB	;I FILL INPUT FILE CONTROL BLOCK
	DW	CERROR	;J
	DW	CERROR	;K
	DW	LASSM	;L LIST ASSEMBLY LANGUAGE
	DW	MOVE	;M MOVE MEMORY
	DW	CERROR	;N
	DW	CERROR	;O
	DW	CERROR	;P
	DW	CERROR	;Q
	DW	READ	;R READ HEXADECIMAL FILE
	DW	SETMEM	;S SET MEMORY COMMAND
	DW	TRACE	;T
	DW	UNTRACE	;U
	DW	CERROR	;V
	DW	CERROR	;W
	DW	EXAMINE	;X EXAMINE AND MODIFY REGISTERS
	DW	CERROR	;Y
	DW	CERROR	;Z
;
;
OPN:	;FILE OPEN ROUTINE.  THIS SUBROUTINE OPENS THE DISK INPUT
	PUSH	H
	PUSH	D
	PUSH	B
	XRA	A
	STA	DBP	;CLEAR BUFFER POINTER
	MVI	C,OPF
	LXI	D,DFCB
	CALL	TRAPAD	;TO BDS
	POP	B
	POP	D
	POP	H
	RET
;
ASSM:	;ASSEMBLER LANGUAGE INPUT
;	CHECK FOR ASSM PRESENT
	CALL	CHKDIS	;ASSM/DISASSM PRESENT
	JNC	CERROR	;NOT THERE
;
	CALL	SCANEXP	;SCAN THE EXPRESSIONS WHICH FOLLOW
	DCR	A	;ONE EXPRESSION EXPECTED
	JNZ	CERROR
	CALL	GETVAL	;GET EXPRESSION TO H,L
	SHLD	DISPC
	CALL	ASSEM
	JMP	START
;
LASSM:	;ASSEMBLER LANGUAGE OUTPUT LISTING
;	L<CR> LISTS FROM CURRENT DISASSM PC FOR SEVERAL LINES
;	L<NUMBER><CR> LISTS FROM <NUMBER> FOR SEVERAL LINES
;	L<NUMBER>,<NUMBER> LISTS BETWEEN LOCATIONS
	CALL	CHKDIS	;DISASSM PRESENT?
	JNC	CERROR
;
	CALL	SCANEXP	;SCAN EXPRESSIONS WHICH FOLLOW
	JZ	SPAGE	;BRANCH IF NOT EXPRESSIONS
	CALL	GETVAL	;EXP1 TO H,L
	SHLD	DISPC	;SETS BASE PC FOR LIST
	DCR	A	;ONLY EXPRESSION?
	JZ	SPAGE	;SETS SINGLE PAGE MODE
;
;	ANOTHER EXPRESSION FOLLOWS
	CALL	GETVAL
	SHLD	DISPM	;SETS MAX VALUE
	DCR	A
	JNZ	CERROR	;ERROR IF MORE EXPN'S
	XRA	A	;CLEAR PAGE MODE
	JMP	SPAG0
;
SPAGE:	MVI	A,PSIZE	;SCREEN SIZE FOR LIST
SPAG0:	STA	DISPG
	CALL	DISEN	;CALL DISASSEMBLER
	JMP	START	;FOR ANOTHER COMMAND
;
;	DISPLAY MEMORY, FORMS ARE
;	D		DISPLAY FROM CURRENT DISPLAY LINE
;	DNNN		SET DISPLAY LINE AND ASSUME D
;	DNNN,MMM	DISPLAY NNN TO MMM
;	NEW DISPLAY LINE IS SET TO NEXT TO DISPLAY
;
DISPLAY:
	CALL	SCANEXP	;GET 0,1,OR 2 EXPNS
	JZ	DISP1	;ASSUME CURRENT DISLOC
	CALL	GETVAL	;GET VALUE TO H,L
	JC	DISP0	;CARRY SET IF ,B FORM
	SHLD	DISLOC	;OTHERWISE DISPC ALREADY SET
DISP0:	;GET NEXT VALUE
	ANI	7FH	;IN CASE ,B
	DCR	A
	JZ	DISP1	;SET HALF PAGE MODE
	CALL	GETVAL
	DCR	A	;A,B,C NOT ALLOWED
	JNZ	CERROR
	JMP	DISP2
;
DISP1:	;0 OR 1 EXPN, DISPLAY HALF SCREEN
	LHLD	DISLOC
	MOV	A,L
	ANI	0F0H	;NORMALIZE TO LINE START
	MOV	L,A
	LXI	D,PSIZE*16-1
	DAD	D
DISP2:	SHLD	DISMAX
;	DISPLAY MEMORY FROM DISLOC TO DISMAX
DISP3:	CALL	CRLF
	CALL	BREAK	;BREAK KEY?
	JNZ	START	;STOP CURRENT EXPANSION
	LHLD	DISLOC
	SHLD	TDISP
	CALL	PADDR	;PRINT LINE ADDRESS
DISP4:	CALL	BLANK
	MOV	A,M	;GET NEXT DATA BYTE
	CALL	PBYTE	;PRINT BYTE
	INX	H
	CALL	DISCOM	;COMPARE H,L WITH DISMAX
	JC	DISCH	;CARRY SET IF H,L > DISMAX
	MOV	A,L	;CHECK FOR LINE OVERFLOW
	ANI	0FH
	JNZ	DISP4	;JUMP FOR ANOTHER BYTE
;
DISCH:	;DISPLAY AREA IN CHARACTER FORM
	SHLD	DISLOC	;UPDATE FOR NEXT WRITE
	LHLD	TDISP
	XCHG
	CALL	BLANK
;
DISCH0:	LDAX	D	;GET BYTE
	CALL	PGRAPH	;PRINT IF GRAPHIC CHARACTER
	INX	D
	LHLD	DISLOC	;COMPARE FOR END OF LINE
	MOV	A,L
	SUB	E
	JNZ	DISCH0
	MOV	A,H
	SUB	D
	JNZ	DISCH0
;
;	DROP THRU AT END OF CHARACTERS
	LHLD	DISLOC
	CALL	DISCOM	;END OF DISPLAY?
	JC	START
;
;	NO, CONTINUE WITH NEXT LINE
	JMP	DISP3
;
;
;	FILL MEMORY AREA WITH FIXED DATA ELEMENT
;
SCAN3:	;SCAN THREE EXPN'S FOR FILL AND MOVE
	CALL	SCANEXP
	CPI	3
	JNZ	CERROR
	CALL	GETVAL
	PUSH	H
	CALL	GETVAL
	PUSH	H
	CALL	GETVAL
	POP	D
	POP	B	;BC,DE,HL
	RET
;
BCDE:	;COMPARE BC > DE (CARRY GEN'D IF TRUE)
	MOV	A,E
	SUB	C
	MOV	A,D
	SBB	B
	RET
;
FILL:
	CALL	SCAN3	;EXPRESSIONS SCANNED BC , DE , HL
	MOV	A,H	;MUST BE ZERO
	ORA	A
	JNZ	CERROR
FILL0:	CALL	BCDE	;END OF FILL?
	JC	START
	MOV	A,L	;DATA
	STAX	B	;TO MEMORY
	INX	B	;NEXT TO FILL
	JMP	FILL0
;
;	GO COMMAND WITH OPTIONAL BREAKPOINTS
;
GOTO:
	CALL	CRLF	;READY FOR GO.
	CALL	SCANEXP	;0,1, OR 2 EXPS
	CALL	GETVAL
	PUSH	H	;START ADDRESS
	CALL	GETVAL
	PUSH	H	;BKPT1
	CALL	GETVAL
	MOV	B,H	;BKPT2
	MOV	C,L
	POP	D	;BKPT1
	POP	H	;GOTO ADDRESS
;
GOPR:
	DI
	JZ	GOP1	;NO BREAK POINTS
	JC	GOP0
;	SET PC
	SHLD	PLOC	;INTO MACHINE STATE
GOP0:	;SET BREAKS
	ANI	7FH	;CLEAR , BIT
	DCR	A	;IF 1 THEN SKIP (2,3 IF BREAKPOINTS)
	JZ	GOP1
	CALL	SETBK	;BREAK POINT FROM D,E
	DCR	A
	JZ	GOP1
;	SECOND BREAK POINT
	MOV	E,C
	MOV	D,B	;TO D,E
	CALL	SETBK	;SECOND BREAK POINT SET
;
GOP1:	;RESTORE MACHINE STATE AND START IT
	LXI	SP,STACK-12
	POP	D
	POP	B
	POP	PSW
	POP	H	;SP IN HL
	SPHL
	LHLD	PLOC	;PC IN HL
	PUSH	H	;INTO USER'S STACK
	LHLD	HLOC	;HL RESTORED
	EI
	RET
;
SETBK:	;SET BREAK POINT AT LOCATION D,E
	PUSH	PSW
	PUSH	B
	LXI	H,BREAKS	;NUMBER OF BREAKS SET SO FAR
	MOV	A,M
	INR	M	;COUNT BREAKS UP
	ORA	A	;ONE SET ALREADY?
	JZ	SETBK0
;	ALREADY SET, MOVE PAST ADDR,DATA FIELDS
	INX	H
	MOV	A,M	;CHECK = ADDRESSES
	INX	H
	MOV	B,M	;CHECK HO ADDRESS
	INX	H
;	DON'T SET TWO BREAKPOINTS IF EQUAL
	CMP	E	;LOW =?
	JNZ	SETBK0
	MOV	A,B
	CMP	D	;HIGH =?
	JNZ	SETBK0
;	EQUAL ADDRESSES, REPLACE REAL DATA
	MOV	A,M	;GET DATA BYTE
	STAX	D	;PUT BACK INTO CODE
SETBK0:	INX	H	;ADDRESS FIELD
	MOV	M,E	;LSB
	INX	H
	MOV	M,D	;MSB
	INX	H	;DATA FIELD
	LDAX	D	;GET BYTE FROM PROGRAM
	MOV	M,A	;TO BREAKS VECTOR
	MVI	A,RSTIN	;RESTART INSTRUCTION
	STAX	D	;TO CODE
	POP	B
	POP	PSW
	RET
;
;
;	HEXADECIMAL ARITHMETIC
;
HEXARI:
	CALL	SCANEXP
	CPI	2
	JNZ	CERROR
	CALL	GETVAL	;FIRST VALUE TO H,L
	PUSH	H
	CALL	GETVAL	;SECOND VALUE TO H,L
	POP	D	;FIRST VALUE TO D,E
	PUSH	H	;SAVE A COPY OF SECOND VAALUE
	CALL	CRLF	;NEW LINE
	DAD	D	;SUM IN H,L
	CALL	PADDR
	CALL	BLANK
	POP	H	;RESTORE SECOND VALUE
	XRA	A	;CLEAR ACCUM FOR SUBTRACTION
	SUB	L
	MOV	L,A	;BACK TO L
	MVI	A,0	;CLEAR IT AGAIN
	SBB	H
	MOV	H,A
	DAD	D	;DIFFERENCE IN HL
	CALL	PADDR
	JMP	START
;
; SET INPUT FILE CONTROL BLOCK (AT 5CH) TO SIMULATE CONSOLE COMMAND
INFCB:
;	FILL FCB AT 5CH
	XRA	A
	STA	FCB+FCR	;CLEAR CURRENT RECORD
	STA	FCB	;CLEAR DISK NUMBER
	CALL	GNC	;CHARACTER IN A
	MVI	C,9	;FILE NAME LENGTH+1
	LXI	H,FCB+FFN	;START OF NAME
;
FLP:	;FILL NAME
	MOV	M,A
	INX	H
	DCR	C
	JZ	CERROR	;FILE NAME TOO LONG.
;
	CALL	GNC	;READ NEXT CHAR
	CPI	'.'
	JZ	FLB	;FOUND ., BLANK OUT
;	NOT ., MAY BE CR
	CPI	CR
	JNZ	FLP	;FOR ANOTHER STORE
;
;	NAME FILLED, EXTEND WITH BLANKS
FLB:	DCR	C
	JZ	TFT
	MVI	M,' '
	INX	H
	JMP	FLB
;
;	BLANKS FILLED, SCAN FILE TYPE IF '.' FOUND
TFT:	MVI	C,4
	CPI	'.'	;ENDED WITH . OR CR
	JNZ	FLB1	;FILL REMAINDER WITH BLANKS
;
;	SCAN FILE TYPE
	LXI	H,FCB+FFT
;
FLP1:	CALL	GNC
	CPI	CR
	JZ	FLB1
	MOV	M,A
	INX	H
	DCR	C
	JZ	CERROR	;TOO LONG
	JMP	FLP1
;
;	FILL WITH BLANKS
FLB1:	DCR	C
	JZ	FLZ
	MVI	M,' '
	INX	H
	JMP	FLB1
;
;	ZERO THE EXTENT
FLZ:	MVI	M,0
	JMP	START
;
;	MOVE MEMORY
MOVE:
	CALL	SCAN3	;BC,DE,HL
MOVE0:	;HAS B,C PASSED D,E?
	CALL	BCDE
	JC	START	;END OF MOVE
	LDAX	B	;CHAR TO ACCUM
	INX	B	;NEXT TO GET
	MOV	M,A	;MOVE IT TO MEMORY
	INX	H
	JMP	MOVE0	;FOR ANOTHER
;
;	READ FILES (HEX OR COM)
;
QHEX:	;HEX FILE IF ZERO AT END
	LXI	H,FCB+FFT
	MOV	A,M
	ANI	07FH	;MASK HIGH ORDER BIT
	CPI	'H'
	RNZ
	INX	H
	MOV	A,M
	ANI	07FH	;MASK HIGH ORDER BIT
	CPI	'E'
	RNZ
	INX	H
	MOV	A,M
	ANI	07FH	;MASK HIGH ORDER BIT
	CPI	'X'
	RET
;
COMLOAD:	;COMPARE HL > MLOAD
	XCHG	;H,L TO D,E
	LHLD	MLOAD	;MLOAD TO H,L
	MOV	A,L	;MLOAD LSB
	SUB	E
	MOV	A,H
	SBB	D	;MLOAD-OLDHL GENS CARRY IF HL>MLOAD
	XCHG
	RET
;
CKMLOAD:	;CHECK FOR HL > MLOAD AND SET MLOAD IF SO
	CALL	COMLOAD	;CARRY IF HL>MLOAD
	RNC
	SHLD	MLOAD	;CHANGE IT
	RET
;
CHKDIS:	;CHECK FOR DISASSM PRESENT
	PUSH	H
	LXI	H,MODBAS	;ENTRY POINT
	CALL	COMLOAD
	POP	H
	RET
;
READ:
	CALL	SCANEXP
	LXI	H,0
	JZ	READN
	DCR	A	;ONE EXPRESSION?
	JNZ	CERROR
	CALL	GETVAL	;EXPRESSION TO H,L
READN:	PUSH	H	;SAVE IT FOR BELOW
RINIT:	CALL	OPN	;OPEN INPUT FILE
	CPI	255
	JZ	CERROR
;	CONTINUE IF FILE OPEN WENT OK
;	DISK FILE OPENED AND INITIALIZED
;
;	CHECK FOR 'HEX' FILE AND LOAD DIRECT TIL EOF
	CALL	QHEX	;LOOK FOR 'HEX'
	JZ	HREAD
;
;	COM FILE, LOAD WITH OFFSET GIVEN BY PUSHED REGISTER H
	POP	H
	LXI	D,100H	;BASE OF TRANSIENT AREA
	DAD	D
;	REG H HOLDS LOAD ADDRESS
LCOM0:	;LOAD COM FILE
	PUSH	H	;SAVE DMA ADDRESS
	LXI	D,DFCB
	MVI	C,RDF	;READ SECTOR
	CALL	TRAPAD
	POP	H
	ORA	A	;SET FLAGS TO CHECK RETURN CODE
	JNZ	RLIFT
;	MOVE FROM 80H TO LOAD ADDRESS IN H,L
	LXI	D,DBF
	MVI	C,80H	;BUFFER SIZE
LCOM1:	LDAX	D	;LOAD NEXT BYTE
	INX	D
	MOV	M,A	;STORE NEXT BYTE
	INX	H
	DCR	C
	JNZ	LCOM1
;	LOADED, CHECK ADDRESS AGAINST MLOAD
	CALL	CKMLOAD
	JMP	LCOM0
;
;
;	OTHERWISE ASSUME HEX FILE IS BEING LOADED
HREAD:	CALL	DISKR	;NEXT CHAR TO ACCUM
	CPI	DEOF	;PAST END OF TAPE?
	JZ	CERROR	;FOR ANOTHER COMMAND
	SBI	':'
	JNZ	HREAD	;LOOKING FOR START OF RECORD
;
;	START FOUND, CLEAR CHECKSUM
	MOV	D,A
	POP	H
	PUSH	H
	CALL	RBYTE
	MOV	E,A	;SAVE LENGTH
	CALL	RBYTE	;HIGH ORDER ADDR
	PUSH	PSW
	CALL	RBYTE	;LOW ORDER ADDR
	POP	B
	MOV	C,A
	DAD	B	;BIASED ADDR IN H
	MOV	A,E	;CHECK FOR LAST RECORD
	ORA	A
	JNZ	RDTYPE
;	END OF TAPE, SET LOAD ADDRESS
	MOV	H,B
	MOV	L,C
	SHLD	PLOC	;SET PC VALUE
	JMP	RLIFT	;FOR ANOTHER COMMAND
;
RDTYPE:
	CALL	RBYTE	;RECORD TYPE = 0
;
;	LOAD RECORD
RED1:	CALL	RBYTE
	MOV	M,A
	INX	H
	DCR	E
	JNZ	RED1	;FOR ANOTHER BYTE
;	OTHERWISE AT END OF RECORD - CHECKSUM
	CALL	RBYTE
	PUSH	PSW	;FOR CHECKSUM CHECK
	CALL	CKMLOAD	;CHECK AGAINST MLOAD
	POP	PSW
	JNZ	CERROR	;CHECKSUM ERROR
	JMP	HREAD	;FOR ANOTHER RECORD
;
RBYTE:	;READ ONE BYTE FROM BUFF AT WBP TO REG-A
;	COMPUTE CHECKSUM IN REG-D
	PUSH	B
	PUSH	H
	PUSH	D
;
	CALL	DISKR	;GET ONE MORE CHARACTER
	CALL	HEXCON	;CONVERT TO HEX (OR ERROR)
;
;	SHIFT LEFT AND MASK
	RLC
	RLC
	RLC
	RLC
	ANI	0F0H
	PUSH	PSW	;SAVE FOR A FEW STEPS
	CALL	DISKR
	CALL	HEXCON
;
;	OTHERWISE SECOND NIBBLE OK, SO MERGE
	POP	B	;PREVIOUS NIBBLE TO REG-B
	ORA	B
	MOV	B,A	;VALUE IS NOW IN B TEMPORARILY
	POP	D	;CHECKSUM
	ADD	D	;ACCUMULATING
	MOV	D,A	;BACK TO CS
;	ZERO FLAG REMAINS SET
	MOV	A,B	;BRING BYTE BACK TO ACCUMULATOR
	POP	H
	POP	B	;BACK TO INITIAL STATE WITH ACCUM SET
	RET
RLIFT:	;LIFT HEAD ON DISK BEFORE RETURNING
	MVI	C,LIFT
	CALL	TRAPAD
;	'NEXT' ' PC'
	LXI	H,LMSG	;LOAD MESSAGE
RLI0:	MOV	A,M
	ORA	A	;LAST CHAR?
	JZ	RLI1
	CALL	PCHAR
	INX	H	;NEXT CHAR
	JMP	RLI0
RLI1:	CALL	CRLF
	LHLD	MLOAD
	CALL	PADDR
	CALL	BLANK
	LHLD	PLOC
	CALL	PADDR
	JMP	START
LMSG:	DB	CR,LF,'NEXT  PC',0
;
;	SET MEMORY COMMAND
;
SETMEM:	;ONE EXPRESSION EXPECTED
	CALL	SCANEXP	;SETS FLAGS
	DCR	A	;ONE EXPRESSION ONLY
	JNZ	CERROR
	CALL	GETVAL	;START ADDRESS IS IN H,L
SETM0:	CALL	CRLF	;NEW LINE
	PUSH	H	;SAVE CURRENT ADDRESS
	CALL	PADDR	;PRINTED
	CALL	BLANK	;SEPARATOR
	POP	H	;GET DATA
	MOV	A,M
	PUSH	H	;SAVE ADDRESS TO FILL
	CALL	PBYTE	;PRINT BYTE
	CALL	BLANK	;ANOTHER SEPARATOR
	CALL	GETBUFF	;FILL INPUT BUFFER
	CALL	GNC	;MAY BE EMPTY (NO CHANGE)
	POP	H	;RESTORE ADDRESS TO FILL
	CPI	CR
	JZ	SETM1
	CPI	'.'
	JZ	START
;	DATA IS BEING CHANGED
	PUSH	H	;SAVE ADDR TO FILL
	CALL	SCANEX	;FIRST CHARACTER ALREADY SCANNED
	DCR	A	;ONE ITEM?
	JNZ	CERROR	;MORE THAN ONE
	CALL	GETVAL	;VALUE TO H,L
	MOV	A,H
	ORA	A	;HO ZERO?
	JNZ	CERROR	;DATA IS IN L
	MOV	A,L
	POP	H	;RESTORE DATA VALUE
	MOV	M,A
SETM1:	INX	H	;NEXT ADDRESS READY
	JMP	SETM0
;
;	UNTRACE MODE
UNTRACE:
	XRA	A	;CLEAR TRACE MODE FLAG
	JMP	ETRACE
;
;	START TRACE
TRACE:	MVI	A,0FFH	;SET TRACE MODE FLAG
ETRACE:
	STA	TMODE
	CALL	SCANEXP
	LXI	H,0
	JZ	TRAC0
;	MUST BE T OR TN (N NOT 0)
	DCR	A	;COUNT MUST BE ONE
	JNZ	CERROR
	CALL	GETVAL	;GET VALUE TO HL
	MOV	A,L	;CHECK FOR ZERO
	ORA	H
	JZ	CERROR
	DCX	H	;TRACE VALUE - 1
TRAC0:	SHLD	TRACER
	CALL	DSTATE	;STARTING STATE IS DISPLAYED
	JMP	GOPR	;SETS BREAKPOINTS AND STARTS EXECUTION
;
; EXAMINE AND MODIFY CPU REGISTERS.
EXAMINE:
	CALL	GNC	;CR?
	CPI	CR
	JNZ	EXAM0
	CALL	DSTATE	;DISPLAY CPU STATE
	JMP	START
;
EXAM0:	;REGISTER CHANGE OPERATION
	LXI	B,PVAL+1	;B=0,C=PVAL (MAX REGISTER NUMBER)
;	LOOK FOR REGISTER MATCH IN RVECT
	LXI	H,RVECT
EXAM1:	CMP	M	;MATCH IN RVECT?
	JZ	EXAM2
	INX	H	;NEXT RVECT
	INR	B	;INCREMENT COUNT
	DCR	C	;END OF RVECT?
	JNZ	EXAM1
;	NO MATCH
	JMP	CERROR
;
EXAM2:	;MATCH IN RVECT, B HAS REGISTER NUMBER
	CALL	GNC
	CPI	CR	;ONLY CHARACTER?
	JNZ	CERROR
;
;	WRITE CONTENTS, AND GET ANOTHER BUFFER
	PUSH	B	;SAVE COUNT
	CALL	CRLF	;NEW LINE FOR ELEMENT
	CALL	DELT	;ELEMENT WRITTEN
	CALL	BLANK
	CALL	GETBUFF	;FILL COMMAND BUFFER
	CALL	SCANEXP	;GET INPUT EXPRESSION
	ORA	A	;NONE?
	JZ	START
	DCR	A	;MUST BE ONLY ONE
	JNZ	CERROR
	CALL	GETVAL	;VALUE IS IN H,L
	POP	B	;RECALL REGISTER NUMBER
;	CHECK CASES FOR FLAGS, REG-A, OR DOUBLE REGISTER
	MOV	A,B
	CPI	AVAL
	JNC	EXAM4
;	SETTING FLAGS, MUST BE ZERO OR ONE
	MOV	A,H
	ORA	A
	JNZ	CERROR
	MOV	A,L
	CPI	2
	JNC	CERROR
;	0 OR 1 IN H,L REGISTERS - GET CURRENT FLAGS AND MASK POSITION
	CALL	FLGSHF
;	SHIFT COUNT IN C, D,E ADDRESS FLAG POSITION
	MOV	H,A	;FLAGS TO H
	MOV	B,C	;SHIFT COUNT TO B
	MVI	A,0FEH	;111111110 IN ACCUM TO ROTATE
	CALL	LROTATE	;ROTATE REG-A LEFT
	ANA	H	;MASK ALL BUT ALTERED BIT
	MOV	B,C	;RESTORE SHIFT COUNT TO B
	MOV	H,A	;SAVE MASKED FLAGS
	MOV	A,L	;0/1 TO LSB OF ACCUM
	CALL	LROTATE	;ROTATED TO CHANGED POSITION
	ORA	H	;RESTORE ALL OTHER FLAGS
	STAX	D	;BACK TO MACHINE STATE
	JMP	START	;FOR ANOTHER COMMAND
;
LROTATE:	;LEFT ROTATE FOR FLAG SETTING
;	PATTERN IS IN REGISTER A, COUNT IN REGISTER B
	DCR	B
	RZ	;ROTATE COMPLETE
	RLC	;END-AROUND ROTATE
	JMP	LROTATE
;
EXAM4:	;MAY BE ACCUMULATOR CHANGE
	JNZ	EXAM5
;	MUST BE BYTE VALUE
	MOV	A,H
	ORA	A
	JNZ	CERROR
	MOV	A,L	;GET BYTE TO STORE
	LXI	H,ALOC	;A REG LOCATION IN MACHINE STATE
	MOV	M,A	;STORE IT AWAY
	JMP	START
;
EXAM5:	;MUST BE DOUBLE REGISTER PAIR
	PUSH	H	;SAVE VALUE
	CALL	GETDBA	;DOUBLE ADDRESS TO HL
	POP	D	;VALUE TO D,E
	MOV	M,E
	INX	H
	MOV	M,D	;ALTERED MACHINE STATE
	JMP	START
;
DISKR:	;DISK READ
	PUSH	H
	PUSH	D
	PUSH	B
;
RDI:	;READ DISK INPUT
	LDA	DBP
	ANI	7FH
	JZ	NDI	;GET NEXT DISK INPUT RECORD
;
;	READ CHARACTER
RDC:
	MVI	D,0
	MOV	E,A
	LXI	H,DBF
	DAD	D
	MOV	A,M
	CPI	DEOF
	JZ	DEF	;END OF FILE
	LXI	H,DBP
	INR	M
	ORA	A
	JMP	RRET
;
NDI:	;NEXT BUFFER IN
	MVI	C,RDF
	LXI	D,DFCB
	CALL	TRAPAD
	ORA	A
	JNZ	DEF
;
;	BUFFER READ OK
	STA	DBP	;STORE 00H
	JMP	RDC
;
DEF:	;SET CARRY AND RETURN (END FILE)
	STC
RRET:
	POP	B
	POP	D
	POP	H
	RET
;
CERROR:	;ERROR IN COMMAND
	CALL	CRLF
	MVI	A,'?'
	CALL	PCHAR
	JMP	START
;
; SUBROUTINES
GETBUFF:	;FILL COMMAND BUFFER AND SET POINTERS
	MVI	C,GETF	;GET BUFFER FUNCTION
	LXI	D,COMLEN;START OF COMMAND BUFFER
	CALL	TRAPAD	;FILL BUFFER
	LXI	H,COMBUF;NEXT TO GET
	SHLD	NEXTCOM
	RET
;
BLANK:
	MVI	A,' '
;
PCHAR:	;PRINT CHARACTER TO CONSOLE
	PUSH	H
	PUSH	D
	PUSH	B
	MOV	E,A
	MVI	C,COF
	CALL	TRAPAD
	POP	B
	POP	D
	POP	H
	RET
;
TRANS:
;	TRANSLATE TO UPPER CASE
	CPI	7FH	;RUBOUT?
	RZ
	CPI	('A' OR 0100000B)	;UPPER CASE A
	RC
	ANI	1011111B	;CLEAR UPPER CASE BIT
	RET
;
GNC:
;	GET NEXT BUFFER CHARACTER FROM CONSOLE
	PUSH	H	;SAVE FOR REUSE LOCALLY
	LXI	H,CURLEN
	MOV	A,M
	ORA	A	;ZERO?
	MVI	A,CR
	JZ	GNCRET	;RETURN WITH CR IF EXHAUSTED
	DCR	M	;CURLEN=CURLEN-1
	LHLD	NEXTCOM
	MOV	A,M	;GET NEXT CHARACTER
	INX	H	;NEXTCOM=NEXTCOM+1
	SHLD	NEXTCOM	;UPDATED
	CALL	TRANS
GNCRET:	POP	H	;RESTORE ENVIRONMENT
	RET
;
PNIB:	;PRINT NIBBLE IN LO ACCUM
	CPI	10
	JNC	PNIBH	;JUMP IF A-F
	ADI	'0'
	JMP	PCHAR	;RET THRU PCHAR
PNIBH:	ADI	'A'-10
	JMP	PCHAR
;
PBYTE:	PUSH	PSW	;SAVE A COPY FOR LO NIBBLE
	RAR
	RAR
	RAR
	RAR
	ANI	0FH	;MASK HO NIBBLE TO LO NIBBLE
	CALL	PNIB
	POP	PSW	;RECALL BYTE
	ANI	0FH
	JMP	PNIB
;
CRLF:	;CARRIAGE RETURN LINE FEED
	MVI	A,CR
	CALL	PCHAR
	MVI	A,LF
	JMP	PCHAR
;
BREAK:	;CHECK FOR BREAK KEY
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,CHKIO
	CALL	TRAPAD
	ANI	1B
	POP	H
	POP	D
	POP	B
	RET
;
PADDX:	;SAME AS PADDR, EXCEPT PRINT VALUE IN D,E
	XCHG
;
PADDR:	;PRINT THE ADDRESS VALUE IN H,L
	MOV	A,H
	CALL	PBYTE
	MOV	A,L
	JMP	PBYTE
;
PGRAPH:	;PRINT GRAPHIC CHARACTER IN REG-A OR '.' IF NOT
	CPI	7FH
	JNC	PPERIOD
	CPI	' '
	JNC	PCHAR
PPERIOD:
	MVI	A,'.'
	JMP	PCHAR
;
DISCOM:	;COMPARE H,L AGAINST DISMAX.  CARRY SET IF HL > DISMAX AND
	XCHG
	LHLD	DISMAX
	MOV	A,L
	SUB	E
	MOV	L,A	;REPLACE FOR ZERO TESTS LATER
	MOV	A,H
	SBB	D
	XCHG
	RET
;
DELIM:	;CHECK FOR DELIMITER CHARACTER
	CPI	CR
	RZ
	CPI	','
	RZ
	CPI	' '
	RET
;
HEXCON:	;CONVERT ACCUMULATOR TO PURE BINARY FROM EXTERNAL HEX
	SUI	'0'
	CPI	10
	RC		;MUST BE 0-9
	ADI	('0'-'A'+10) AND 0FFH
	CPI	16
	RC		;MUST BE 0-15
	JMP	CERROR	;BAD HEX DIGIT
;
GETVAL:	;GET NEXT EXPRESSION VALUE TO H,L (POINTER IN D,E ASSUMED)
	XCHG
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	XCHG
	RET
;
GETEXP:	;GET HEX VALUE TO D,E
	XCHG
	LXI	H,0
GETEXP0:
	CALL	HEXCON
	DAD	H	;*2
	DAD	H	;*4
	DAD	H	;*8
	DAD	H	;*16
	ORA	L	;HL=HL+HEX
	MOV	L,A
	CALL	GNC
	CALL	DELIM	;DELIMITER?
	JNZ	GETEXP0
	XCHG
	RET
;
SCSTORE:	;STORE D,E TO H,L AND INCREMENT ADDRESS
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	PUSH	H
	LXI	H,EXPLIST
	INR	M	;COUNT NUMBER OF EXPN'S
	POP	H
	RET
;
SCANEXP:	;SCAN EXPRESSIONS - CARRY SET IF ,B
;	ZERO SET IF NO EXPRESSIONS, A SET TO NUMBER OF EXPRESSIONS
;	HI ORDER BIT SET IF ,B ALSO
	CALL	GNC
SCANEX:	;ENTER HERE IF CHARACTER ALREADY SCANNED
	LXI	H,EXPLIST
	MVI	M,0	;ZERO EXPRESSIONS
	INX	H	;READY TO FILL EXPRESSION LIST
	CPI	CR	;END OF LINE?
	JZ	SCANRET
;
;	NOT CR, MUST BE DIGIT OR COMMA
	CPI	','
	JNZ	SCANE0
;	MARK AS COMMA
	MVI	A,80H
	STA	EXPLIST
	LXI	D,0
	JMP	SCANE1
;
SCANE0:	;NOT CR OR COMMA
	CALL	GETEXP	;EXPRESSION TO D,E
SCANE1:	CALL	SCSTORE	;STORE THE EXPRESSION AND INCREMENT H,L
	CPI	CR
	JZ	SCANRET
	CALL	GNC
	CALL	GETEXP
	CALL	SCSTORE
;	SECOND DIGIT SCANNED
	CPI	CR
	JZ	SCANRET
	CALL	GNC
	CALL	GETEXP
	CALL	SCSTORE
	CPI	CR
	JNZ	CERROR
SCANRET:
	LXI	D,EXPLIST	;LOOK AT COUNT
	LDAX	D		;LOAD COUNT TO ACC
	CPI	81H		;, WITHOUT B?
	JZ	CERROR
	INX	D		;READY TO EXTRACT EXPN'S
	ORA	A	;ZERO FLAG MAY BE SET
	RLC
	RRC		;SET CARRY IF HO BIT SET (,B)
	RET			;WITH FLAGS SET
;
;
;	SUBROUTINES FOR CPU STATE DISPLAY
FLGSHF:	;SHIFT COMPUTATION FOR FLAG GIVEN BY REG-B
;	REG A CONTAINS FLAG UPON EXIT (UNSHIFTED)
;	REG C CONTAINS NUMBER OF SHIFTS REQUIRED+1
;	REGS D,E CONTAIN ADDRESS OF FLAGS IN TEMPLATE
	PUSH	H
	LXI	H,FLGTAB	;SHIFT TABLE
	MOV	E,B
	MVI	D,0
	DAD	D
	MOV	C,M		;SHIFT COUNT TO C
	LXI	H,FLOC		;ADDRESS OF FLAGS
	MOV	A,M		;TO REG A
	XCHG			;SAVE ADDRESS
	POP	H
	RET
;
GETFLG:	;GET FLAG GIVEN BY REG-B TO REG-A AND MASK
	CALL	FLGSHF	;BITS TO SHIFT IN REG-A
GETFL0:	DCR	C
	JZ	GETFL1
	RAR
	JMP	GETFL0
GETFL1:	ANI	1B
	RET
;
GETDBA:	;GET DOUBLE BYTE ADDRESS CORRESPONDING TO REG-A TO HL
	SUI	BVAL	;NORMALIZE TO 0,1,...
	LXI	H,RINX	;INDEX TO STACKED VALUES
	MOV	E,A	;INDEX TO E
	MVI	D,0	;DOUBLE PRECISION
	DAD	D	;INDEXED INTO VECTOR
	MOV	E,M	;OFFSET TO E
	MVI	D,0FFH	;-1
	LXI	H,STACK
	DAD	D	;HL HAS BASE ADDRESS
	RET
;
GETDBL:	;GET DOUBLE BYTE CORRESPONDING TO REG-A TO HL
	CALL	GETDBA	;ADDRESS OF ELT IN HL
	MOV	E,M	;LSB
	INX	H
	MOV	D,M	;MSB
	XCHG		;BACK TO HL
	RET
;
DELT:	;DISPLAY CPU ELEMENT GIVEN BY COUNT IN REG-B, ADDRESS IN H,L
	MOV	A,M	;GET CHARACTER
	CALL	PCHAR	;PRINT IT
	MOV	A,B	;GET COUNT
	CPI	AVAL	;PAST A?
	JNC	DELT0	;JMP IF NOT FLAG
;
;	DISPLAY FLAG
	CALL	GETFLG	;FLAG TO REG-A
	CALL	PNIB
	RET
;
DELT0:	;NOT FLAG, DISPLAY = AND DATA
	PUSH	PSW
	MVI	A,'='
	CALL	PCHAR
	POP	PSW
	JNZ	DELT1	;JUMP IF NOT REG-A
;
;	REGISTER A, DISPLAY BYTE VALUE
	LXI	H,ALOC
	MOV	A,M
	CALL	PBYTE
	RET
;
DELT1:	;DOUBLE BYTE DISPLAY
	CALL	GETDBL	;TO H,L
	CALL	PADDR	;PRINTED
	RET
;
DSTATE:	;DISPLAY CPU STATE
	LXI	H,RVECT	;REGISTER VECTOR
	MVI	B,0	;REGISTER COUNT
	CALL	CRLF
DSTA0:	PUSH	B
	PUSH	H
	CALL	DELT	;ELEMENT DISPLAYED
	POP	H	;RVECT ADDRESS RESTORED
	POP	B	;COUNT RESTORED
	INR	B	;NEXT COUNT
	INX	H	;NEXT REGISTER
	MOV	A,B	;LAST COUNT?
	CPI	PVAL+1
	JNC	DSTA1	;JMP IF PAST END
	CPI	AVAL	;BLANK AFTER?
	JC	DSTA0
;	YES, BLANK AND GO AGAIN
	CALL	BLANK
	JMP	DSTA0
;
;	READY TO SEND DECODED INSTRUCTION
DSTA1:
	CALL	BLANK
	CALL	NBRK	;COMPUTE BREAKPOINTS IN CASE OF TRACE
	PUSH	PSW	;SAVE EXPRESSION COUNT - B,C AND D,E HAVE BPTS
	PUSH	D	;SAVE BP ADDRESS
	PUSH	B	;SAVE AUX BREAKPOINT
	CALL	CHKDIS	;CHECK TO SEE IF DISASSEMBER IS HERE
	JNC	DCHEX	;DISPLAY HEX IF NOT
;	DISASSEMBLE CODE
	LHLD	PLOC	;GET CURRENT PC
	SHLD	DISPC	;SET DISASSM PC
	LXI	H,DISPG;PAGE MODE = 0FFH TO TRACE
	MVI	M,0FFH
	CALL	DISEN
	JMP	DSTRET
;
DCHEX:	;DISPLAY HEX
	DCX	H	;POINT TO LAST TO WRITE
	SHLD	DISMAX	;SAVE FOR COMPARE BELOW
	LHLD	PLOC	;START ADDRESS OF TRACE
	MOV	A,M	;GET OPCODE
	CALL	PBYTE
	INX	H	;READY FOR NEXT BYTE
	CALL	DISCOM	;ZERO SET IF ONE BYTE TO PRINT, CARRY IF NO MORE
	JC	DSTRET
	PUSH	PSW	;SAVE RESULT OF ZERO TEST
	CALL	BLANK	;SEPARATOR
	POP	PSW	;RECALL ZERO TEST
	ORA	E	;ZERO TEST
	JZ	DSTA2
;	DISPLAY DOUBLE BYTE
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	CALL	PADDR	;PRINT ADDRESS
	JMP	DSTRET
;
DSTA2:	;PRINT BYTE VALUE
	MOV	A,M
	CALL	PBYTE
DSTRET:
	POP	B	;AUX BREAKPOINT
	POP	D	;RESTORE BREAKPOINT
	POP	PSW	;RESTORE COUNT
	RET
;
;	DATA VECTORS FOR CPU DISPLAY
RVECT:	DB	'CZMEIABDHSP'
RINX:	DB	(BLOC-STACK) AND 0FFH	;LOCATION OF BC
	DB	(DLOC-STACK) AND 0FFH	;LOCATION OF DE
	DB	(HLOC-STACK) AND 0FFH	;LOCATION OF HL
	DB	(SLOC-STACK) AND 0FFH	;LOCATION OF SP
	DB	(PLOC-STACK) AND 0FFH	;LOCATION OF PC
;	FLGTAB ELEMENTS DETERMINE SHIFT COUNT TO SET/EXTRACT FLAGS
FLGTAB:	DB	1,7,8,3,5	;CY, ZER, SIGN, PAR, IDCY
;
CLRTRACE:	;CLEAR THE TRACE FLAG
	LXI	H,0
	SHLD	TRACER
	RET
;
BREAKP:	;ARRIVE HERE WHEN PROGRAMMED BREAK OCCURS
	DI
	SHLD	HLOC	;HL SAVED
	POP	H	;RECALL RETURN ADDRESS
	DCX	H	;DECREMENT FOR RESTART
	SHLD	PLOC
;	DAD SP BELOW DESTROYS CY, SO SAVE AND RECALL
	PUSH	PSW	;INTO USER'S STACK
	LXI	H,2	;BIAS SP BY 2 BECAUSE OF PUSH
	DAD	SP	;SP IN HL
	POP	PSW	;RESTORE CY AND FLAGS
	LXI	SP,STACK-4;LOCAL STACK
	PUSH	H	;SP SAVED
	PUSH	PSW
	PUSH	B
	PUSH	D
;	MACHINE STATE SAVED, CLEAR BREAK POINTS
	LHLD	PLOC	;CHECK FOR RST INSTRUCTION
	MOV	A,M	;OPCODE TO A
	CPI	RSTIN
;	SAVE CONDITION CODES FOR LATER TEST
	PUSH	PSW
;	SAVE PLOC FOR LATER INCREMENT OR DECREMENT
	PUSH	H
;
;	CLEAR BREAKPOINTS WHICH ARE PENDING
	LXI	H,BREAKS
	MOV	A,M
	MVI	M,0	;SET TO ZERO BREAKS
CLER0:	ORA	A	;ANY MORE?
	JZ	CLER1
	DCR	A
	MOV	B,A	;SAVE COUNT
	INX	H	;ADDRESS OF BREAK
	MOV	E,M	;LOW ADDR
	INX	H
	MOV	D,M	;HIGH ADDR
	INX	H
	MOV	A,M	;INSTRUCTION
	STAX	D	;BACK TO PROGRAM
	MOV	A,B	;RESTORE COUNT
	JMP	CLER0
;
CLER1:	;CLEARED, CONTINUE TRACING, OR STOP EXECUTION
	POP	H	;RESTORE PLOC
	POP	PSW	;RESTORE CONDITION FLAGS
	JZ	BREAK0	;BRANCH IF PROGRAMMED INTERRUPT
;
;	MUST BE FRONT PANEL INTERRUPT, CHECK IF IN BDOS
	INX	H	;DON'T DECREMENT ON PANEL INTERRUPT
	SHLD	PLOC	;RESTORE TO NEXT LOGICAL INSTRUCTION
	XCHG		;TO D,E FOR COMPARE
	LXI	H,TRAPJMP+1
	MOV	C,M	;LOW BDOS ADDR
	INX	H
	MOV	B,M	;HIGH BDOS ADDR
	CALL	BCDE	;CY IF BDOS>PLOC
	JC	BREAK0	;BRANCH IF PLOC <= BDOS
;
;	IN THE BDOS, DON'T BREAK UNTIL THE RETURN OCCURS
	CALL	CLRTRACE;CLEAR TRACE FLAGS
	LHLD	RETLOC	;TRAPPED RETLOC ON ENTRY TO DOS
	XCHG		;TO D,E READY FOR BREAKPOINT
	MVI	A,82H	;LOOKS LIKE G,BBBB
	ORA	A	;SETS FLAGS
	STC		;SUBSEQUENT TEST FOR CY
	JMP	GOPR	;START PROGRAM EXECUTION, WITH BREAKPOINT
;
BREAK0:	;NORMAL BREAKPOINT
	EI
	LHLD	TRACER
	MOV	A,H
	ORA	L
	JZ	STOPEX
;
;	TRACE IS ON
	DCX	H
	SHLD	TRACER
	CALL	BREAK	;BREAK KEY DEPRESSED?
	JNZ	STOPEX
	LDA	TMODE	;TRACE MODE T IF 0FFH
	ORA	A
	JNZ	BREAK1
;	NOT TRACING, BUT MONITORING, SO SET BREAKPOINTS
	CALL	NBRK
	JMP	GOPR
;
BREAK1:	;TRACING AND MONITORING
	CALL	DSTATE	;STATE DISPLAYED, CHECK FOR BREAKPOINTS
	JMP	GOPR	;STARTS EXECUTION
;
STOPEX:
	CALL	CLRTRACE	;TRACE FLAGS GO TO ZERO
	MVI	A,'*'
	CALL	PCHAR
	LHLD	PLOC
;	CHECK TO ENSURE DISASSEMBLER IS PRESENT
	CALL	CHKDIS
	JNC	STOP0
	SHLD	DISPC
STOP0:	CALL	PADDR
	LHLD	HLOC
	SHLD	DISLOC
	JMP	START
;
CAT:	;DETERMINE OPCODE CATEGORY - CODE IN REGISTER B
;	D,E CONTAIN DOUBLE PRECISION CATEGORY NUMBER ON RETURN
	LXI	D,OPMAX	;D=0,E=OPMAX
	LXI	H,OPLIST
CAT0:	MOV	A,M		;MASK TO A
	ANA	B	;MASK OPCODE FROM B
	INX	H	;READY FOR COMPARE
	CMP	M	;SAME AFTER MASK?
	INX	H	;READY FOR NEXT COMPARE
	JZ	CAT1	;EXIT IF COMPARED OK
	INR	D	;UP COUNT IF NOT MATCHED
	DCR	E	;FINISHED?
	JNZ	CAT0
CAT1:	MOV	E,D	;E IS CATEGORY NUMBER
	MVI	D,0	;DOUBLE PRECISION
	RET
;
NBRK:	;FIND NEXT BREAK POINT ADDRESS
;	UPON RETURN, REGISTER A IS SETUP AS IF USER TYPED G,B1,B2 OR
;	G,B1 DEPENDING UPON OPERATOR CATEGORY.  B,C CONTAINS SECOND BP,
;	D,E CONTAINS PRIMARY BP.  HL ADDRESS NEXT OPCODE BYTE
	LHLD	PLOC
	MOV	B,M	;GET OPERATOR
	INX	H	;HL ADDRESS BYTE FOLLOWING OPCODE
	PUSH	H	;SAVE IT FOR LATER
	CALL	CAT	;DETERMINE OPERATOR CATEGORY
	LXI	H,CATNO	;SAVE CATEGORY NUMBER
	MOV	M,E
	LXI	H,CATTAB;CATEGORY TABLE BASE
	DAD	D	;INXED
	DAD	D	;INXED*2
	MOV	E,M	;LOW BYTE TO E 
	INX	H
	MOV	D,M	;HIGH BYTE TO D
	XCHG
	PCHL		;JUMP INTO TABLE
CATTAB:	DW	JMPOP	;JUMP OPERATOR
	DW	CCOP	;JUMP CONDITIONAL
	DW	JMPOP	;CALL OPERATOR (TREATED AS JMP)
	DW	CCOP	;CALL CONDITIONAL
	DW	RETOP	;RETURN FROM SUBROUTINE
	DW	RSTOP	;RESTART
	DW	PCOP	;PCHL
	DW	IMOP	;SINGLE PRECISION IMMEDIATE (2 BYTE)
	DW	IMOP	;ADI ... CPI
	DW	DIMOP	;DOUBLE PRECISION IMMEDIATE (3 BYTES)
	DW	DIMOP	;LHLD ... STA
	DW	RCOND	;RETURN CONDITIONAL
	DW	IMOP	;IN/OUT
;	NEXT DW MUST BE THE LAST IN THE SEQUENCE
	DW	SIMOP	;SIMPLE OPERATOR (1 BYTE)
;
JMPOP:	;GET OPERAND FIELD, CHECK FOR BDOS
	CALL	GETOPA	;GET OPERAND ADDRESS TO D,E AND COMPARE WITH BDOS
	JNZ	ENDOP	;TREAT AS SIMPLE OPERATOR IF NOT BDOS
;	OTHERWISE, TREAT AS A RETURN INSTRUCTION
RETOP:	CALL	GETSP	;ADDRESS AT STACKTOP TO D,E
	JMP	ENDOP	;TREAT AS SIMPLE OPERATOR
;
CBDOS:	;COMPARE D,E WITH BDOS ADDRESS, RETURN ZERO FLAG IF EQUAL
	LDA	TRAPJMP+1
	CMP	E
	RNZ
	LDA	TRAPJMP+2
	CMP	D
	RET
;
GETOPA:	;GET OPERAND ADDRESS AND COMPARE WITH BDOS
	POP	B	;GET RETURN ADDRESS
	POP	H	;GET OPERAND ADDRESS
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	PUSH	H	;UPDATED PC INTO STACK
	PUSH	B	;RETURN ADDRESS TO STACK
	JMP	CBDOS	;RETURN THROUGH CBDOS WITH ZERO FLAG SET
;
GETSP:	;GET RETURN ADDRESS FROM USER'S STACK TO D,E
	LHLD	SLOC
	MOV	E,M
	INX	H
	MOV	D,M
	RET
;
CCOP:	;CALL CONDITIONAL OPERATOR
	CALL	GETOPA	;GET OPERAND ADDRESS TO D,E / COMPARE WITH BDOS
	JZ	CCOP1
;	NOT THE BDOS, BREAK AT OPERAND ADDRESS AND NEXT ADDRESS
	POP	B	;NEXT ADDRESS TO B,C
	PUSH	B	;BACK TO STACK
	MVI	A,2	;TWO BREAKPOINTS
	JMP	RETCAT	;RETURN FROM NBRK
;
CCOP1:	;BREAK ADDRESS AT NEXT LOCATION ONLY, WAIT FOR RETURN FROM BDOS
	POP	D
	PUSH	D	;BACK TO STACK
	JMP	ENDOP	;ONE BREAKPOINT ADDRESS
;
RSTOP:	;RESTART INSTRUCTION - CHECK FOR RST 7
	MOV	A,B
	CPI	RSTIN	;RESTART INSTRUCTION USED FOR SOFT INT
	JNZ	RST0
;
;	SOFT RST, NO BREAK POINT SINCE IT WILL OCCUR IMMEDIATELY
	XRA	A
	JMP	RETCAT1	;ZERO ACCUMULATOR
RST0:	ANI	111000B	;GET RESTART NUMBER
	MOV	E,A
	MVI	D,0	;DOUBLE PRECISION BREAKPOINT TO D,E
	JMP	ENDOP
;
PCOP:	;PCHL
	LHLD	HLOC
	XCHG	;HL VALUE TO D,E FOR BREAKPOINT
	CALL	CBDOS	;BDOS VALUE?
	JNZ	ENDOP
;	PCHL TO BDOS, USE RETURN ADDRESS
	JMP	RETOP
;
	JMP	ENDOP
;
SIMOP:	;SIMPLE OPERATOR, USE STACKED PC
	POP	D
	PUSH	D
	JMP	ENDOP
;
RCOND:	;RETURN CONDITIONAL
	CALL	GETSP	;GET RETURN ADDRESS FROM STACK
	POP	B	;B,C ALTERNATE LOCATION
	PUSH	B	;REPLACE IT
	MVI	A,2
	JMP	RETCAT	;TO SET FLAGS AND RETURN
;
DIMOP:	;DOUBLE PRECISION IMMEDIATE OPERATOR
	POP	D
	INX	D	;INCREMENTED ONCE, DROP THRU FOR ANOTHER
	PUSH	D	;COPY BACK
;
IMOP:	;SINGLE PRECISION IMMEDIATE
	POP	D
	INX	D
	PUSH	D
;
ENDOP:	;END OPERATOR SCAN
	MVI	A,1	;SINGLE BREAKPOINT
RETCAT:	;RETURN FROM NBRK
	INR	A	;COUNT UP FOR G,...
	STC
RETCAT1:
	POP	H	;RECALL NEXT ADDRESS
	RET
;
;
;
;	OPCODE CATEGORY TABLES
OPLIST:	DB	1111$1111B,	1100$0011B	;0 JMP
	DB	1100$0111B,	1100$0010B	;1 JCOND
	DB	1111$1111B,	1100$1101B	;2 CALL
	DB	1100$0111B,	1100$0100B	;3 CCOND
	DB	1111$1111B,	1100$1001B	;4 RET
	DB	1100$0111B,	1100$0111B	;5 RST 0..7
	DB	1111$1111B,	1110$1001B	;6 PCHL
	DB	1100$0111B,	0000$0110B	;7 MVI
	DB	1100$0111B,	1100$0110B	;8 ADI...CPI
	DB	1100$1111B,	0000$0001B	;9 LXI
	DB	1110$0111B,	0010$0010B	;10 LHLD SHLD LDA STA
	DB	1100$0111B,	1100$0000B	;11 RCOND
	DB	1111$0111B,	1101$0011B	;IN OUT
OPMAX	EQU	($-OPLIST)/2
;
CATNO:	DS	1	;CATEGORY NUMBER SAVED IN NBRK
RETLOC:	DS	2	;RETURN ADDRESS TO USER FROM BDOS
TMODE:	DS	1	;TRACE MODE
TRACER:	DS	2	;TRACE COUNT
BREAKS:	DS	7	;#BREAKS/BKPT1/DAT1/BKPT2/DAT2
EXPLIST:DS	7	;COUNT+(EXP1)(EXP2)(EXP3)
DISLOC:	DS	2	;DISPLAY LOCATION
DISMAX:	DS	2	;MAX VALUE FOR CURRENT DISPLAY
TDISP:	DS	2	;TEMP 16 BIT LOCATION
NEXTCOM:DS	2	;NEXT LOCATION FROM COMMAND BUFFER
COMLEN:	DB	CSIZE	;MAX COMMAND LENGTH
CURLEN:	DS	1	;CURRENT COMMAND LENGTH
COMBUF:	DS	CSIZE	;COMMAND BUFFER
MLOAD:	DS	2	;MAX LOAD ADDRESS
	DS	SSIZE	;STACK AREA
STACK:
PLOC	EQU	STACK-2	;PC IN TEMPLATE
HLOC	EQU	STACK-4	;HL
SLOC	EQU	STACK-6	;SP
ALOC	EQU	STACK-7	;A
FLOC	EQU	STACK-8	;FLAGS
BLOC	EQU	STACK-10	;BC
DLOC	EQU	STACK-12;D,E
;
	NOP		;FOR RELOCATION BOUNDARY
	END
