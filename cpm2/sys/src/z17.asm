;  June 30, 1982  09:56  drm  "Z17.ASM"
********** CP/M DISK I/O ROUTINES FOR Z17  **********
********** MINI-FLOPPY - DOUBLE TRACK	  **********
	DW	MODLEN,BUFLEN

BASE	EQU	0000H	;ORG FOR RELOC

***** PHYSICAL DRIVES ARE ASSIGNED AS FOLLOWS *****
*****					      *****
*****  0 = FIRST (BUILT-IN) MINI FLOPPY       *****
*****  1 = SECOND (ADD-ON) MINI FLOPPY	      *****
*****  2 = THIRD (LAST ADD-ON) MINI FLOPPY    *****
*****					      *****
***************************************************
	MACLIB Z80

***************************************************
**  MINI-FLOPPY PORTS AND CONSTANTS
***************************************************
?DISK$CTL	EQU	7FH
?RCVR		EQU	7EH
?STAT		EQU	7DH
?DATA		EQU	7CH
?PORT		EQU	0F2H

?MOTOR$ON	EQU	10010000B	;AND ENABLE FLOPY-RAM
?SETTLE EQU	10	;10*2 = 20mS  STEP-SETTLING TIME
?SEL		EQU	25	; WAIT 50mS AFTER SELECTING
?MTRDLY EQU	2	; 1.024 SECONDS
?SEL$TIME	EQU	4	; = 2.048 SECONDS
?MOTOR$TIME	EQU	40	; = 20.48 SECONDS

WRALL	EQU	0		; WRITE TO ALLOCATED
WRDIR	EQU	1		; WRITE TO DIRECTORY
WRUNA	EQU	2		; WRITE TO UNALLOCATED
READOP	EQU	3		; READ OPERATION
***************************************************

***************************************************
** LINKS TO REST OF SYSTEM
***************************************************
BIOS	EQU	BASE+1600H
MBASE	EQU	BASE	;MODULE BASE
COMBUF	EQU	BASE+0C000H	;COMMON BUFFER
BUFFER	EQU	BASE+0F000H	;MODULE BUFFER
***************************************************

***************************************************
** PAGE ZERO ASSIGNMENTS
***************************************************
	ORG	0
?CPM		DS	3
?DEV$STAT	DS	1
?LOGIN$DSK	DS	1
?BDOS		DS	3
?RST1		DS	3	;08H
?CLOCK		DS	2
?INT$BYTE	DS	1
?CTL$BYTE	DS	1
		DS	1
		DS	8	;10H
		DS	8	;18H
		DS	8	;20H
		DS	8	;28H
		DS	8	;30H
		DS	6	;38H
?PASS		DS	2	;3EH
		DS	28	;40H
?FCB		DS	36	;5CH
?DMA		DS	128
?TPA		DS	0
***************************************************

***************************************************
** OVERLAY MODULE INFORMATION ON BIOS
***************************************************
	ORG	BIOS 
	DS	51	;JUMP TABLE
DSK$STAT DS	5	;DISK$STAT AND OLD Z17 MODE INFO
	DS	4	;OLD MODE FOR '47 (REMEX) DRIVES
MIXER	DB	0,1,2
	DS	13
	DB	0,3	;DRIVES 0,1,2
	DW	MBASE
	DS	28

	JMP	TIME$OUT

NEWBAS	DS	2
NEWDSK	DS	1
NEWTRK	DS	1
NEWSEC	DS	1
HRDTRK	DS	2
DMAA	DS	2
***************************************************

***************************************************
** START OF RELOCATABLE DISK I/O MODULE
*************************************************** 
	ORG	MBASE	;START OF MODULE
	JMP	SEL$Z17
	JMP	READ$Z17
	JMP	WRITE$Z17

	DB	'Z17 ',0,'Hard Sector controller ',0,'2.240$'

SGL$BASE:
	DW	0,0,0,0,DIRBUF,DPB0,CSV0,ALV0
	DW	0,0,0,0,DIRBUF,DPB1,CSV1,ALV1
	DW	0,0,0,0,DIRBUF,DPB2,CSV2,ALV2

DPB0:
	DW	20 ;SECTORS PER TRACK
	DB	3,7,0 ;SECTORS PER BLOCK
	DW	92-1 ;LAST BLOCK ON DISK
	DW	64-1 ; DIRECTORY ENTRIES
	DB 11000000B,0 ;DIRECTORY ALLOCATION MASK
	DW	16 ;CHECK SIZE
	DW	3  ;FIRST TRACK OF DIRECTORY
	DB	00000001B,00000011B,00001001B	;modes
	DB	11011111B,11100100B,11111111B	;masks

DPB1:
	DW	20 ;SECTORS PER TRACK
	DB	3,7,0 ;SECTORS PER BLOCK
	DW	92-1 ;LAST BLOCK ON DISK
	DW	64-1 ; DIRECTORY ENTRIES
	DB 11000000B,0 ;DIRECTORY ALLOCATION MASK
	DW	16 ;CHECK SIZE
	DW	3  ;FIRST TRACK OF DIRECTORY
	DB	00000001B,00000011B,00001001B	;modes
	DB	11011111B,11100100B,11111111B	;masks

DPB2:
	DW	20 ;SECTORS PER TRACK
	DB	3,7,0 ;SECTORS PER BLOCK
	DW	92-1 ;LAST BLOCK ON DISK
	DW	64-1 ; DIRECTORY ENTRIES
	DB 11000000B,0 ;DIRECTORY ALLOCATION MASK
	DW	16 ;CHECK SIZE
	DW	3  ;FIRST TRACK OF DIRECTORY
	DB	00000001B,00000011B,00001001B	;modes
	DB	11011111B,11100100B,11111111B	;masks

SEC$TBL:
	DB	1,2,9,10,17,18,5,6,13,14   ;LOGICAL/PHYSICAL SECTOR TABLE
	DB	3,4,11,12,19,20,7,8,15,16

SKEW4:	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

STPTBL: DB	3	;00 =  6 mS (fastest rate)
	DB	6	;01 = 12 mS
	DB	10	;10 = 20 mS
	DB	15	;11 = 30 mS (slowest rate)
 IF $/256 NE STPTBL/256
 DS '"STPTBL" POSITION ERROR'
 ENDIF

TPS:	DB	0	;NUMBER OF PHYSICAL HEAD POSITIONS (TRACKS PER SIDE)
TPS2:	DB	0	;NUMBER OF TRACKS USED ON SECOND SIDE
 IF TPS+1 NE TPS2
 DS 'ERROR: "TPS2" DOES NOT FOLLOW "TPS"'
 ENDIF

SEL$Z17:
	LXI	H,DISK$CTLR	;DEFINE ENTRY TO THIS INTERNAL ROUTINE
	SHLD	?PASS	;PUT ADDRESS WHERE FORMAT PROGRAM CAN FIND IT
	SIXD	SAVE$IX
	SIYD	SAVE$IY
	XRA	A
	STA	SELRR
	LDA	PNDWRT
	ORA	A
	CNZ	WR$SEC
	LDA	NEWDSK
	ADD	A	;*2
	ADD	A	;*4
	ADD	A	;*8
	ADD	A	;*16
	MOV	C,A
	MVI	B,0
	LXI	H,SGL$BASE
	DAD	B
	SHLD	DPHA
	PUSH	H
	POPIX
	LDX	L,+10	;DPB ADDRESS
	LDX	H,+11
	SHLD	DPBA
	PUSH	H
	POPIY
	LDY	A,+3	;BSM
	STA	BLKMSK
	LDY	A,+13	;TRACK OFFSET
	STA	OFFSET
	LXI	D,+15	;MODE BYTES
	DAD	D	;
	SHLD	MODES
	MOV	A,M
	ANI	11B	;PHYSICAL SECTOR SIZE
	STA	BLCODE
	INX	H
	LXI	B,(36)*256+(40) ;40 TRACKS, 36 USED ON SECOND SIDE
	BIT	3,M	;TRACK DENSITY BIT
	JRZ	NOTDT
	LXI	B,(72)*256+(80) ;80 TRACKS, 72 USED ON SECOND SIDE
NOTDT:	SBCD	TPS
	MOV	A,M
	ANI	11B	;STEPRATE
	LXI	D,STPTBL
	ADD	E	;TABLE MUST NOT SPAN PAGE BOUNARY
	MOV	E,A
	LDAX	D
	STA	ASTEPR	;COUNTER VALUE EQUIVELENT TO STEPRATE CODE
	INX	H
	MOV	A,M
	ANI	111B	;SKEW TABLE CODE
	LXI	D,SEC$TBL
	CPI	4
	JC	GOTSKW
	LXI	D,SKEW4
GOTSKW: STX	E,+0	;SAVE SKEW TABLE
	STX	D,+1
	CALL	LOGIN	;CONDITIONAL LOG-IN OF DRIVE (TEST FOR HALF-TRACK)
	POP	H	;DISCARD RETURN ADDRESS (TO BIOS)
	LHLD	DPHA
	LDA	NEWDSK
	MOV	C,A
	LIXD	SAVE$IX
	LIYD	SAVE$IY
	RET

LOGIN:	
	LDA	NEWDSK
	LXI	B,17
	LXI	H,MIXER
	CCIR
	MVI	A,17
	SUB	C
	MOV	B,A
	LXI	H,BIOS 
	LXI	D,-0D89H	;POSITION OF "GET LOGIN" FUNCTION IN BDOS
	DAD	D
	MOV	E,M	;PICK UP ADDRESS OF "GET LOGIN" ROUTINE
	INX	H
	MOV	D,M
	XCHG
	INX	H	;SKIP PAST OP-CODE
	MOV	E,M	;PICK UP ADDRESS OF LOGIN VECTOR
	INX	H
	MOV	D,M
	XCHG
	MOV	E,M	;PICK UP LOGIN VECTOR
	INX	H
	MOV	D,M
LG0:	RARR	D
	RARR	E
	DJNZ	LG0
	RC
;
;   TEST DISKETTE/DRIVE FOR "48 IN 96 TPI"
;
	LDA	NEWDSK
	STA	HSTDSK	;MAKE SURE "SELECT" KNOWS WHAT DRIVE TO SELECT
	CALL	SELECT
	RC		;NOT READY
	CALL	RECALIBRATE	;[CY]=ERROR
	RC	;IF ERROR HERE, IGNORE IT.
	MVI	C,00100000B	;STEP-IN
	CALL	STEPHEAD	;STEP IN ONCE...
	CALL	STEPHEAD	;STEP IN TWICE.
	LXIX	TEC
	CALL	READ$ADDRESS	;FIND OUT WHERE WE ARE.
	PUSH	PSW
	CALL	RECALIBRATE	;PUT HEAD WHERE SYSTEM CAN FIND IT.
	POP	PSW
	JRC	SELERR	;ERROR HERE MAY INDICATE 96 IN 48 TPI
	MOV	A,D	;TRACK NUMBER
	CPI	2
	RZ	;MEDIA MATCHES DRIVE, NO CHANGES TO MAKE
	CPI	1	;IF 48 TPI DISK IN 96 TPI DRIVE
	JRNZ	SELERR
	LHLD	MODES
	INX	H
	BIT	3,M	;TEST IF DPB IS SET CORRECTLY
	JRNZ	SELERR	;IF NOT, CANNOT PROCESS THE DISKETTE
	SETB	4,M	;ELSE SETUP FOR "HALF-TRACK"
	RET

SELERR: XRA	A
	INR	A
	STA	SELRR
	RET

READ$Z17:
	SIXD	SAVE$IX
	SIYD	SAVE$IY
	LDA	PNDWRT
	ORA	A
	CNZ	WR$SEC
	MVI	A,READOP
	JR	RWOPER

WRITE$Z17:
	SIXD	SAVE$IX
	SIYD	SAVE$IY
	MOV	A,C

RWOPER: STA	WRTYPE		; SAVE WRITE TYPE
	LDA	SELRR
	ORA	A
	RNZ
	PUSH	D		; TEMPORARILY SAVE RECORD NUMBER
	LXI	B,3
	LXI	H,NEWDSK
	LXI	D,REQDSK
	LDIR
	POP	D		; RESTORE RECORD NUMBER
;*****************************************************************************
; DBLOCK: THIS SUBROUTINE PERFORMS THE DEBLOCKING FUNCTION.		     ;
;	  INPUTS: NEWSEC (THE REQUESTED LOGICAL SECTOR) 		     ;
;		  BLCODE (THE DEBLOCKING CODE DETERMINED FROM THE MODE BYTE) ;
;	  OUTPUTS:NEWSEC (THE REQUIRED PHYSICAL SECTOR) 		     ;
;		  BLKSEC (THE POSITION OF THE REQUESTED LOGICAL SECTOR	     ;
;			   WITHIN THE PHYSICAL SECTOR)			     ;
;									     ;
DBLOCK: XRA	A		; CLEAR CARRY				     ;
	MOV	C,A		; CALCULATE PHYSICAL SECTOR		     ;
	LDA	BLCODE							     ;
	MOV	B,A							     ;
	LDA	NEWSEC							     ;
DBLOK1: DCR	B							     ;
	JM	DBLOK2							     ;
	RAR								     ;
	RARR	C							     ;
	JR	DBLOK1							     ;
DBLOK2: STA	REQSEC		; SAVE IT				     ;
	LDA	BLCODE		; CALCULATE BLKSEC			     ;
DBLOK3: DCR	A							     ;
	JM	DBLOK4							     ;
	RLCR	C							     ;
	JR	DBLOK3							     ;
DBLOK4: MOV	A,C							     ;
	STA	BLKSEC		; STORE IT				     ;
;*****************************************************************************

	XRA	A		; NON-ZERO VALUE TO ACC.
	DCR	A
	STA	RD$FLAG 	; FLAG A PRE-READ
	LDA	WRTYPE
	RAR			; CARRY IS SET ON WRDIR AND READOP
	JRC	ALLOC		; NO NEED TO CHECK FOR UNALLOCATED RECORDS
	RAR			; CARRY IS SET ON WRUNA
	JRNC	CHKUNA
	SDED	URECORD 	; SET UNALLOCATED RECORD #
	XRA	A
	DCR	A
	STA	UNALLOC 	; FLAG WRITING OF AN UNALLOCATED BLOCK
CHKUNA: LDA	UNALLOC 	; ARE WE WRITING AN UNALLOCATED BLOCK ?
	ORA	A
	JRZ	ALLOC
	LHLD	URECORD 	; IS REQUESTED RECORD SAME AS EXPECTED
	DSBC	D		; SAME AS EXPECTED UNALLOCATED RECORD ?
	JRNZ	ALLOC		; IF NOT, THEN DONE WITH UNALLOCATED BLOCK
	XRA	A		; CLEAR PRE-READ FLAG
	STA	RD$FLAG
	INX	D		; INCREMENT TO NEXT EXPECTED UNALLOCATED RECORD
	SDED	URECORD
	LDA	BLKMSK
	ANA	E		; IS IT THE START OF A NEW BLOCK ?
	JRNZ	CHKRD
ALLOC:	XRA	A		; NO LONGER WRITING AN UNALLOCATED BLOCK
	STA	UNALLOC
CHKRD:				; IS SECTOR ALREADY IN BUFFER ?
;*****************************************************************************
; CHKSEC: THIS SUBROUTINE COMPARES THE REQUESTED DISK TRACK AND SECTOR	     ;
;	  TO THE DISK,TRACK AND SECTOR CURRENTLY IN THE BUFFER. 	     ;
;	  OUTPUT: ZERO FLAG SET IF SAME, RESET IF DIFFERENT		     ;
;									     ;
CHKSEC: LXI	H,NEWTRK
	LDA	OFFSET
	CMP	M		; IS IT THE DIRECTORY TRACK ?
	JRNZ	CHKBUF
	INX	H
	MOV	A,M
	ORA	A		; FIRST SECTOR OF DIRECTORY ?
	JRZ	READIT 
CHKBUF: LXI	H,REQDSK						     ;
	LXI	D,HSTDSK						     ;
	MVI	B,3							     ;
CHKNXT: LDAX	D							     ;
	CMP	M							     ;
	JRNZ	READIT
	INX	H							     ;
	INX	D							     ;
	DJNZ	CHKNXT							     ;
;*****************************************************************************

	JR	NOREAD		; THEN NO NEED TO PRE-READ
READIT: LDA	PNDWRT		; IS THERE A SECTOR THAT NEEDS TO BE WRITTEN ?
	ORA	A
	CNZ	WR$SEC		; WRITE IT
	LXI	D,HSTDSK	; SET UP NEW BUFFER PARAMETERS
	LXI	H,REQDSK
	LXI	B,3
	LDIR
	LDA	RD$FLAG 	; DO WE NEED TO PRE-READ ?
	ORA	A
	CNZ	RD$SEC		; READ THE SECTOR
NOREAD: LXI	H,HSTBUF	; POINT TO START OF SECTOR BUFFER
	LXI	B,128
	LDA	BLKSEC		; POINT TO LOCATION OF CORRECT LOGICAL SECTOR
MOVIT1: DCR	A
	JM	MOVIT2
	DAD	B
	JR	MOVIT1
MOVIT2: LDED	DMAA		; POINT TO DMA
	LDA	WRTYPE		; IS IT A READ OR A WRITE
	CPI	READOP
	JRZ	MOVIT3
	XCHG			; SWITCH DIRECTION OF MOVE FOR WRITE
	XRA	A		; FLAG A PENDING WRITE
	DCR	A
	STA	PNDWRT
MOVIT3: LDIR			; MOVE IT
	LDA	WRTYPE		; CHECK FOR DIRECTORY WRITE
	DCR	A
	CZ	WR$SEC		; WRITE THE SECTOR IF IT IS
	XRA	A		; FLAG NO ERROR
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

WR$SEC: CALL	WRITE		; WRITE A PHYSICAL SECTOR
	MVI	A,0
	STA	PNDWRT		; FLAG NO PENDING WRITE
	RZ			; RETURN IF WRITE WAS SUCCESSFUL
	LDA	WRTYPE
	CPI	READOP		; IGNORE ERROR IF THIS IS A READ OPERATION
	MVI	A,0	;BUT MAKE SURE EVERYONE SEES "NO ERROR"
	RZ
	JR	RWERR

RD$SEC: CALL	READ		; READ A PHYSICAL SECTOR
	RZ			; RETURN IF SUCCESSFUL
	MVI	A,0FFH		; FLAG BUFFER AS UNKNOWN
	STA	HSTDSK
RWERR:	POP	D		; THROW AWAY TOP OF STACK
	MVI	A,1		; SIGNAL ERROR TO BDOS
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)



***** PHYSICAL READ-SECTOR ROUTINE ******
** RETURNS [NZ] IF ERROR	       **
** USES ALL REGISTERS (IX,IY)	       **
*****************************************
READ:
	CALL	SELECT
	JC	ERROR
	CALL	SEEK
	JC	ERROR
READ01:
	LXIY	SSC
	MVIY	10,+0
READ1:
	CALL	FIND$SECTOR	;DISABLES INTERUPTS ++++++++++++++++++++++
	JC	ERROR	;MUST ENABLE INTERUPTS
	MVI	C,3
XSYNC	CALL	SYNC0
	DCR	C
	JNZ	XSYNC
	LXI	H,HSTBUF
	MVI	B,0	;256 BYTES
	CALL	SYNC
	JC	ERRX
RD	CALL	INPUT$DISK
	MOV	M,A
	INX	H
	DJNZ	RD
	MOV	L,D
	CALL	INPUT$DISK
	EI			;ENABLE INTERUPTS +++++++++++++++++++++++++
	SUB	L
	RZ	;SUCCESSFULL READ...
ERRX	EI			;ENABLE INTERUPTS +++++++++++++++++++++++++
	DCRY	+0
	JRNZ	READ1
	CALL	ERROR1	;SETS STATUS BIT
	JMP	ERROR

***** PHYSICAL WRITE-SECTOR ROUTINE ******
** RETURNS [NZ] IF ERROR		**
** USES ALL REGISTERS (IX,IY)		**
**					**
******************************************
WRITE:
	CALL	SELECT
	JC	ERROR
	JZ	ERROR
	CALL	SEEK
	JC	ERROR
	LHLD	MODES	;PREVENT ATTEMPTED WRITE TO 48 TPI DISK IN 96 TPI DRIVE
	INX	H
	BIT	4,M
	RNZ	;RETURN ERROR IF ATTEMPTED WRITE TO "HALF TRACK" DISK
	XRA	A
	OUT	?STAT	;SET FILL CHARACTER
	CALL	FIND$SECTOR	;DISABLES INTERUPTS ++++++++++++++++++++++++
	JC	ERROR
	MVI	A,45	;312uS
WLOOP	DCR	A
	JNZ	WLOOP
	LDA	?CTL$BYTE
	ORI	00000001B	;WRITE ENABLE
	OUT	?DISK$CTL
	LXI	H,HSTBUF
	MVI	B,0	;256 BYTES
	MVI	C,10	; WRITE 10 NULLS TO PAD DATA
NLOOP	XRA	A
	CALL	OUTPUT$DISK
	DCR	C
	JNZ	NLOOP
	MVI	A,0FDH	;SYNC CHARACTER
	MOV	D,A	;FORCE CLEARING OF CRC
	CALL	OUTPUT$DISK
WRT	MOV	A,M
	CALL	OUTPUT$DISK
	INX	H
	DJNZ	WRT
	MOV	A,D	;GET CRC
	CALL	OUTPUT$DISK	;WRITE CRC ON DISK
	CALL	OUTPUT$DISK	; NOW 3 NULLS...
	CALL	OUTPUT$DISK
	CALL	OUTPUT$DISK
	LDA	?CTL$BYTE
	CALL	DISK$CTLR	;RESTORE CTRL LINES
	XRA	A
	EI			;ENABLE INTERUPTS ++++++++++++++++++++++++++
	RET


***** FINDS SECTOR HEADER ****************
** RETURNS [CY] IF ERROR		**
** USES ALL REGISTERS (IX)		**
**					**
******************************************
FIND$SECTOR:
	LXIX	TEC
	MVIX	5,+0	;TRACK-ERROR RETRY COUNTER
FIND1	MVIX	36,+1	;SECTOR SEARCH RETRY COUNTER
FIND5	CALL	READ$ADDRESS	;DISABLES INTERUPTS +++++++++++++++++++++++
	RC		; >> ACCUMILATED NO-ERROR TIME....
	LXI	H,SIDE	;
	MOV	A,E	;SIDE NUMBER
	CMP	M	; >>	CYCLES
	JNZ	SKERR
	INX	H
	MOV	A,D	;TRACK NUMBER
	CMP	M
	JZ	OVER2	; >>	CYCLES
SKERR:	EI
	DCRX	+0
	JZ	SEEK$ERROR
	CALL	RECALIBRATE
	JC	SEEK$ERROR
	CALL	SEEK
	JC	SEEK$ERROR
	JMP	FIND1
OVER2	LDA	HSTSEC	;SECTOR NUMBER
	CMP	C
	RZ		; >>	CYCLES
	DCRX	+1
	JNZ	FIND5
	JMP	ERROR1

;******* READ ADDRESS from diskette ***************
; ENTRY: assumes IX points to "TEC"
; RETURN: (D)=track  (E)=side  (C)=sector
;	or [CY] if error.
;
READ$ADDRESS:		;ALWAYS EXITS WITH INTERUPTS DISABLED....
	MVIX	10,+2	;INIT CHECK-SUM ERROR COUNTER
FIND50:
	MVI	L,12	;MUST FIND SYNC IN 12 INDEX HOLES
FIND$INDEX:
	EI			;ENABLE INTERUPTS +++++++++++++++++++++++
	IN	?DISK$CTL
	ANI	00000001B
	MOV	C,A
FLOOP	IN	?DISK$CTL
	ANI	00000001B
	CMP	C
	JRZ	FLOOP
	MOV	C,A
	CPI	00000000B
	JRNZ	FLOOP
	PUSH	H
	LXI	H,?CLOCK
	MVI	A,6	;12 mS WAIT
	ADD	M
FXL	CMP	M
	JNZ	FXL
	DI			;DISABLE INTERUPTS ++++++++++++++++++++++
	POP	H
FL1	IN	?DISK$CTL
	RAR
	JRNC	FL1
	CALL	SYNC0
	CALL	SYNC
	JNC	OVER1
	DCR	L
	JNZ	FIND$INDEX
	JMP	ERROR1		;SETS [CY] AND STATUS BIT, RETURNS
OVER1	CALL	INPUT$DISK	;SIDE NUMBER
	MOV	L,A
	CALL	INPUT$DISK	;TRACK NUMBER
	MOV	H,A
	CALL	INPUT$DISK	;SECTOR NUMBER
	MOV	C,A
	CALL	INPUT$DISK	;TEST CHECK-SUM
	XCHG		;PUT TRACK/SIDE IN EXPECTED PLACE (DE)
	RZ		;CHECK-SUM CORRECT
	DCRX	+2
	JZ	ERROR1
	JR	FIND50

ERROR:
	XRA	A
	INR	A	;TO SIGNAL ERROR
	EI
	RET

ERROR1:
	LXI	H,DSK$STAT
	SETB	3,M	;FORMAT ERROR
	STC
	RET

PAUSE5	LXI	H,?CLOCK+1	;HI BYTE TICS EVERY 512mS
	JR	PAUSX
PAUSE:	LXI	H,?CLOCK
PAUSX	ADD	M
	EI
PLOOP	CMP	M
	JRNZ	PLOOP
	RET

RECALIBRATE:
	XRA	A
	STA	TRACK
RECAL	MVI	B,255
REC1	IN	?DISK$CTL
	ANI	00000010B
	JRNZ	RECDON	;IF ALREADY AT TRK0
	LDA	?CTL$BYTE
	ORI	01000000B	;STEP
	CALL	DISK$CTLR
	ANI	10111111B
	CALL	DISK$CTLR
	LDA	ASTEPR	;TIME FOR HEAD TO STEP
	CALL	PAUSE
	DJNZ	REC1
SEEK$ERROR:
	XRA	A
	CMA
	STA	TRACK
	LXI	H,DSK$STAT
	SETB	2,M	;SEEK ERROR
	STC
	RET

RECDON	MVI	A,?SETTLE
	JR	PAUSE

INPUT$DISK:
	IN	?STAT
	RAR
	JNC	INPUT$DISK
	IN	?DATA
	MOV	E,A
	XRA	D
	RLC
	MOV	D,A
	MOV	A,E
	RET

OUTPUT$DISK:
	MOV	E,A
	IN	?STAT
	RAL
	JNC	OUTPUT$DISK+1
	MOV	A,E
	OUT	?DATA
	XRA	D
	RLC
	MOV	D,A
	RET

SYNC0	XRA	A
	JR	SYNCX

SYNC:
	MVI	A,0FDH
SYNCX:
	MVI	D,80	;TRY 80 TIMES
	OUT	?RCVR
	IN	?RCVR	;RESET RECEIVER
SLOOP	IN	?DISK$CTL
	ANI	00001000B
	JRNZ	FOUND
	DCR	D
	JRNZ	SLOOP
	STC
	RET
FOUND	IN	?DATA
	MVI	D,0	;CLEAR CRC
	RET


SELECT:
	LXI	H,DRIVE
	LDA	HSTDSK
	CMP	M
	PUSH	PSW
	MOV	E,M
	MOV	M,A
	MVI	D,0
	LXI	H,TRKA
	DAD	D
	LDA	TRACK
	MOV	M,A
	LDED	DRIVE
	MVI	D,0
	LXI	H,TRKA
	DAD	D
	MOV	A,M
	STA	TRACK
	POP	PSW
	JRZ	NO$SEL
	XRA	A
	STA	SEL$TIMER
NO$SEL	LDA	DRIVE
	INR	A
	MVI	B,3
	MVI	C,00000010B	;DRIVE A:
DRVL	DCR	A
	JZ	GDRIVE
	RLCR	C
	DJNZ	DRVL
	MVI	C,0	;DESELECT ALL DRIVES
GDRIVE	MVI	A,?MOTOR$ON
	ORA	C
	STA	?CTL$BYTE
	CALL	DISK$CTLR	;TURN MOTOR ON NOW
	LDA	TRACK
	CPI	0FFH	;MEANS DRIVE IS NOT LOGGED-ON
	JRNZ	LOGGED
	CALL	RECALIBRATE	;DETERMINE HEAD POSITION
	RC		;IF ERROR
	LXI	H,0
	SHLD	SIDE
	LXI	H,?INT$BYTE
	RES	6,M
	MOV	A,M
	OUT	?PORT
LOGGED:
	IN	?DISK$CTL
	ANI	00000001B
	MOV	E,A
	LXI	B,0800H ;MUST FIND INDEX BEFORE COUNT GOES TO ZERO
IDX	IN	?DISK$CTL
	ANI	00000001B
	CMP	E
	JRNZ	IDX$FOUND
	DCX	B
	MOV	A,B
	ORA	C
	JRNZ	IDX
	MVI	E,0
IDX$FOUND:
	ORA	E
	MOV	E,A
	IN	?DISK$CTL
	ANI	00000100B	;WRITE PROTECT
	RRC
	ORA	E		;READY
	STA	DSK$STAT
	CMA		;NOT-READY
	RAR		; INTO CY BIT
	BIT	0,A	; WRITE ENABLE NOTCH INTO ZR BIT
	RET

SEEK:
	LXI	H,TRACK
	LDA	HSTTRK
	MOV	B,M
	MOV	M,A
	CALL	CONVERT
	STA	SIDE+1
	PUSH	PSW
	LDA	?INT$BYTE
	ANI	10111111B
	ORA	C
	STA	?INT$BYTE
	OUT	?PORT
	MOV	A,C
	RLC
	RLC
	STA	SIDE
	MOV	A,B
	CALL	CONVERT
	MOV	B,A
	POP	PSW
	CPI	0	;IF SEEK-TRK-0 THEN RECALIBRATE
	JZ	RECAL
	MVI	C,00100000B	;STEP TOWARDS HUB
	SUB	B
	RZ		;IF RELATIVE TRACKS SAME
	JRNC	SEEK1
	CMA
	INR	A
	MVI	C,00000000B	;ELSE STEP OUTWARD (TOWARDS RIM)
SEEK1	MOV	B,A	;# OF TRACKS TO SKIP
	LHLD	MODES
	INX	H
	MOV	D,M	;HALF-TRACK BIT IS #4
STEP:
	BIT	4,D
	CNZ	STEPHEAD
	CALL	STEPHEAD
	DJNZ	STEP
	LDA	?CTL$BYTE
	CALL	DISK$CTLR	;RESTORE CTL LINES
	JMP	RECDON	;HEAD-SETTLE PAUSE

STEPHEAD:
	BIT	5,C	;TEST DIRECTION OF STEP
	JRNZ	NOTOUT	;IF NOT "OUT" THEN DON'T WORRY...
	IN	?DISK$CTL	;ELSE MAKE SURE WE DON'T TRY TO STEP PAST TRK-0
	ANI	0010B	;INTO "NEGATIVE TRACKS"
	RNZ
NOTOUT: LDA	?CTL$BYTE
	ORA	C
	CALL	DISK$CTLR
	ORI	01000000B	;STEP BIT
	CALL	DISK$CTLR
	ANI	10111111B	;STEP BIT OFF
	CALL	DISK$CTLR
	LDA	ASTEPR	;TIME FOR HEAD TO STEP
	JMP	PAUSE

CONVERT:
	MVI	C,00000000B	;SIDE 0
	LHLD	TPS	;TPS AND TPS2
	CMP	L	;ACCESS TO SECOND SIDE??
	RC	;IF NOT, QUIT HERE
	SUB	L	;PUT TRACK NUMBER IN PROPER RANGE
	CMA
	INR	A	;NEGATE TRACK NUMBER FOR COMPUTATION
	ADD	H	;EFFECT: SUBTRACT TRACK FROM "TPS2"
	DCR	A	; -1 BECAUSE TRACKS ARE NUMBERED 0-N
	MVI	C,01000000B	;BIT TO SELECT SECOND SIDE
	RET

DISK$CTLR:
	OUT	?DISK$CTL
	PUSH	PSW
	MOV	C,A
	ANI	00010000B	;MOTOR BIT
	JZ	MT$ON
	DI
	LDA	MOTOR$TIMER
	ORA	A
	MVI	A,?MOTOR$TIME
	STA	MOTOR$TIMER
	STA	SEL$TIMER
	JNZ	MT$ON
	MVI	A,?MTRDLY
	CALL	PAUSE5
MT$ON	MOV	A,C
	ANI	00001110B	;SELECT BITS
	JZ	NOT$ON
	DI
	LDA	SEL$TIMER
	ORA	A
	MVI	A,?SEL$TIME
	STA	SEL$TIMER
	JNZ	NOT$ON
	MVI	A,?SEL
	CALL	PAUSE
NOT$ON	POP	PSW
	EI
	RET

TIME$OUT:
	LXI	H,MOTOR$TIMER
	DCR	M
	JM	MOTOR$OFF
	DCX	H
	DCR	M
	RP
SEL$OFF:
	LDA	?CTL$BYTE
	ANI	11110001B
	OUT	?DISK$CTL
	MVI	M,0
	RET

MOTOR$OFF:
	MVI	M,0
	LDA	?CTL$BYTE
	ANI	11100001B
	OUT	?DISK$CTL
	RET

ASTEPR: DB	0	;STEP RATE (CONVERTED FROM MODE BYTES)
WRTYPE: DB	0
PNDWRT	DB	0
BLKSEC	DB	0
RD$FLAG DB	0
OFFSET	DB	0
UNALLOC DB	0
BLKMSK	DB	0
URECORD DW	0
BLCODE	DB	0
MODES	DW	0
DPBA	DW	0
DPHA	DW	0

DRIVE	DB	4	;CURRENTLY SELECTED DRIVE (IN HARDWARE)
TRACK	DB	0FFH	;CURRENT HEAD POSITION FOR CURRENT DRIVE
SEL$TIMER	DB	1
MOTOR$TIMER	DB	1
SELRR	DB	0
TEC	DB	0
SEC	DB	0
CEC	DB	0

SSC	DB	0

SIDE	DB	0,0	;SIDE/TRACK NUMBERS FOR COMPARE TO SECTOR-HEADER

TRKA:	DB	255,255,255,255,0	;CURRENT HEAD POSITION FOR EACH DRIVE

SAVE$IX DW	0
SAVE$IY DW	0

REQDSK: DB	0
REQTRK: DB	0
REQSEC: DB	0

HSTDSK: DB	0FFH
HSTTRK: DB	0FFH
HSTSEC: DB	0FFH

	REPT	(($+0FFH) AND 0FF00H)-$
	DB	0
	ENDM

MODLEN	EQU	$-MBASE
 DB 00100100B,10000000B,00000000B,00000000B,00000000B,00000000B,00000101B,01010000B
 DB 00000101B,01010000B,00000101B,01010000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000001B,00000010B,00100010B,01000100B,10000000B,00100010B
 DB 00000000B,00100000B,00010000B,01000000B,10000010B,00000000B,00000100B,00010000B
 DB 01000000B,10000100B,10000000B,01000100B,10000100B,01000100B,00010000B,00001000B
 DB 00000000B,00000000B,00000010B,01001000B,10000010B,01000100B,10001000B,00000000B
 DB 00100000B,00000001B,00001000B,10010001B,00000001B,00010001B,00100000B,00010010B
 DB 00000010B,00100010B,00000010B,01000100B,00000100B,00100100B,00000001B,00001001B
 DB 00000100B,00000100B,00100100B,00001001B,00100000B,00000100B,10000000B,00000001B
 DB 00010010B,01000000B,01000100B,10000010B,00100000B,01001000B,00000010B,00010001B
 DB 00001000B,01000100B,00000001B,00000100B,00001001B,00100100B,01000000B,10010000B
 DB 10001001B,00001001B,00100000B,00100000B,00000010B,01001001B,00100100B,10010000B
 DB 00000100B,10000010B,00000000B,10000000B,10001000B,00100010B,00000100B,10010010B
 DB 00001000B,00010000B,00000010B,00100001B,00000100B,00001001B,00100100B,10010010B
 DB 00000010B,01000000B,00000000B,00000000B,00000000B,00001000B,00000010B,01001000B
 DB 10010010B,00100010B,00100000B,00100000B,00010000B,00000000B,00000000B,01000000B
 DB 00000000B,01000010B,01001000B,00010010B,00000000B,00001000B,00000000B,00010000B
 DB 00000000B,00000000B,00000000B,00000000B,10010000B,00001000B,10000100B,00100001B
 DB 00000010B,01000000B,00100000B,00000000B,01001000B,00010000B,00100000B,00000000B
 DB 00000000B,00000000B,00000000B,00010000B,00010010B,00010010B,00000000B,00000000B
 DB 10001000B,00010000B,00000000B,01000000B,10010000B,00010010B,00000000B,00000010B
 DB 00010000B,10010010B,00010000B,00000000B,00000010B,00100000B,10010010B,00010000B
 DB 01000100B,00010010B,00010000B,01000100B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B

********************************************************
** COMMON BUFFERS
********************************************************
	ORG	COMBUF
	DS	20
	DS	64
	DS	2
DIRBUF	DS	128
********************************************************

********************************************************
** MINI-FLOPPY BUFFERS
********************************************************
	ORG	BUFFER
HSTBUF: DS	256

CSV0	DS	16
CSV1	DS	16
CSV2	DS	16
ALV0	DS	24
ALV1	DS	24
ALV2	DS	24
**********************************************************
BUFLEN	EQU	$-BUFFER
	END
