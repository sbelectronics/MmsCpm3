title 	'CP/M 3 - HEXCOM - Oct 1982'
;

;  Copyright (C) 1982
;  Digital Research
;  P.O. Box 579
;  Pacific Grove, CA 93950

;  Revised:
;    22 Oct  82  by Paul Lancaster
;    25 Oct  82  by Doug Huskey
;
;
;	**********  HEXCOM  **********
;

;PROGRAM TO CREATE A CP/M "COM" FILE FROM A "HEX" FILE.

;THIS PROGRAM IS VERY SIMILAR IN FUNCTION TO THE CP/M
;UTILITY CALLED "LOAD". IT IS OPTIMIZED WITH RESPECT TO
;EXECUTION SPEED AND MEMORY SPACE. IT RUNS ABOUT TWICE
;AS FAST AS THE CP/M COUNTERPART ON A LONG "HEX" FILE.
;IT IS ALSO ABOUT 700 BYTES SHORTER.

;ONE MINOR DIFFERENCE BETWEEN "HEXCOM" AND "LOAD" THAT MAY
;BE VISIBLE TO THE USER IS THAT VERY LARGE LOAD ADDRESS
;INVERSIONS ARE TOLERATED BY "HEXCOM", WHEREAS THE MAXIMUM
;ALLOWED INVERSION IN "LOAD" IS 80H. THE MAXIMUM IN "HEXCOM"
;IS A FUNCTION OF THE TPA SIZE.
;CAUTION SHOULD BE EXERCIZED WHEN USING AN INVERSION GREATER
;THAN 80H IN "HEXCOM" SINCE PART OF THE COMFILE MAY NOT
;GET CREATED IF THE FINAL LOAD ADDRESS IS INVERTED WITH
;RESPECT TO THE "LAST ADDRESS" IN THE "HEX" FILE.

;*******************************************************

;VERSION 1.00			6 MARCH 1979
;ORIGINAL VERSION.
;*******************************************************

;22 October 1982 - Changed assumed CCP length for CP/M-PLUS
;25 October 1982 - Changed version to 3.0
;
;			EQUATES

VERS		EQU	300		;VERSION TIMES 100
CR		EQU	0DH
LF		EQU	0AH
BDOS		EQU	5
DEFAULT$FCB	EQU	5CH


		ORG	100H

	;	include file for use with ASM programs
	;
	;*********************************************
	;* STANDARD DIGITAL RESEARCH COM FILE HEADER *
	;*********************************************
	;
	JMP	BEGIN		;LABEL CAN BE CHANGED
	;
	;*********************************************
	;* Patch Area, Date, Version & Serial Number *
	;*********************************************
	;
	dw	0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	dw	0,0,0,0,0,0,0,0
	db	0

	db	'CP/M Version 3.0'
	db	'COPYRIGHT 1982, '
	db	'DIGITAL RESEARCH'
	db	'251082'	; version date day-month-year
	db	0,0,0,0		; patch bit map
	db	'654321'	; Serial no.

;
BEGIN:
;	code starts here
	LXI	H,0
	DAD	SP		;GET CURRENT CCP STACK
	SHLD	STACK$SAVE	;SAVE IT
	LXI	SP,STACK	;INIT LOCAL STACK
	LXI	D,SIGNON$MSG	;POINT SIGN-ON MESSAGE
	CALL	PRINT$BUFFER	;SEND IT TO CONSOLE
	LXI	D,DEFAULT$FCB	;FILE NAME TO HEX FCB
	LXI	H,HEX$FCB
	PUSH	D		;SAVE COM FCB ADDR
	PUSH	H		;-AND HEX FCB ADDR
	MVI	C,33		;MOVE ENTIRE FCB
MOVEFCB	LDAX	D		;GET BYTE FROM DFLT FCB
	MOV	M,A		;MOVE TO HEX FCB
	INX	D		;BUMP POINTERS
	INX	H
	DCR	C		;HIT COUNTER
	JNZ	MOVEFCB		;LOOP TILL DONE
	LXI	H,HEX$FCB+9	;"HEX" TYPE NAME TO FCB
	MVI	M,'H'
	INX	H
	MVI	M,'E'
	INX	H
	MVI	M,'X'
	LXI	H,DEFAULT$FCB+9	;"COM" TYPE NAME TO FCB
	MVI	M,'C'
	INX	H
	MVI	M,'O'
	INX	H
	MVI	M,'M'
	POP	D		;HEX$FCB TO <DE>
	MVI	C,15		;OPEN FILE
	CALL	BDOS
	INR	A		;SEE IF -1 FOR ERROR
	LXI	D,COSMSG
	JZ	ERROR$ABORT	;CANNOT OPEN SOURCE
	POP	D		;COM FCB ADDR
	PUSH	D		;KEEP COPY ON STACK
	MVI	C,19		;DELETE FILE
	CALL	BDOS		;DELETE OLD "COM" FILE
	POP	D		;GET COM FCB ADDR AGAIN
	PUSH	D		;SAVE IT STILL
	MVI	C,22		;MAKE FILE
	CALL	BDOS		;CREATE "COM" FILE
	INR	A		;SEE IF -1 FOR ERROR
	LXI	D,NMDSMSG
	JZ	ERROR$ABORT	;NO MORE DIR SPACE

;DEFINE AND CLEAR THE COMFILE BUFFER

	LDA	7		;GET BDOS PAGE ADDRESS
	SUI	16		;ALLOW FOR UP TO 4K CCP
	MOV	H,A		;HI BYTE OF COM BUFFER TOP
	MVI	L,0		;END ON PAGE BOUNDARY
	SHLD	CURR$COM$BUF$END
	SUI	(HIGH COMFILE$BUFFER)+1
	MVI	L,80H		;START IN MIDDLE OF PAGE
	MOV	H,A		;BUFFER LENGTH IN PAGES
	SHLD	CURR$COM$BUF$LEN
	CALL	CLEAR$COMBUFFER	;ZERO-OUT COM BUFFER

;	HEX RECORD LOOP

SCAN$FOR$COLON:
	CALL	GET$HEXFILE$CHAR
	CPI	':'		;DO WE HAVE COLON YET?
	JNZ	SCAN$FOR$COLON
	CALL	GET$BINARY$BYTE	;GOT COLON. GET LOAD COUNT
	STA	LOAD$COUNT	;STORE COUNT FOR THIS RECORD
	JZ	FINISH$UP	;ZERO MEANS ALL DONE

;INCREMENT BYTES-READ COUNTER BY NUMBER OF BYTES TO BE
;LOADED IN THIS RECORD.

	LXI	H,BYTES$READ$COUNT
	ADD	M	;ADD LO BYTE OF SUM
	MOV	M,A	;SAVE NEW LO BYTE
	JNC	FORM$LOAD$ADDRESS
	INX	H	;POINT HI BYTE OF SUM
	INR	M	;BUMP HI BYTE

;NOW SET NEW LOAD ADDRESS FROM THE
;HEX FILE RECORD.

FORM$LOAD$ADDRESS:
	CALL	GET$BINARY$BYTE
	PUSH	PSW	
	CALL	GET$BINARY$BYTE
	POP	H		;HI BYTE TO <H>
	MOV	L,A		;AND LO BYTE TO <L>
	SHLD	LOAD$ADDRESS	;SAVE NEW LOAD ADDRESS
	XCHG			;PUT IN <DE>
	LHLD	CURRENT$COM$BASE

;NEW LOAD ADDRESS MINUS THE CURRENT COMFILE BASE GIVES
;THE NEW COM BUFFER OFFSET.

	MOV	A,E
	SUB	L
	MOV	L,A
	MOV	A,D
	SBB	H
	MOV	H,A
	SHLD	COM$BUF$OFFSET	;STORE NEW OFFSET
	LXI	D,ILAMSG	;POINT ERR MSG
	JC	ERROR$ABORT	;FATAL INVERSION IF CY SET

;FIRST ADDRESS HAS ALREADY BEEN ESTABLISHED IF "FIRST$ADDRESS"
;IS NON-ZERO.

	LDA	FIRST$ADDRESS+1	;--ONLY PAGE NO. NEED BE
	ORA	A		;--CHECKED SINCE 1ST ADDR
	JNZ	GET$ZERO$BYTE	;--CAN'T BE IN PAGE ZERO
	LXI	D,FAMSG		;POINT "1ST ADDR" MSG
	CALL	MSG$ON$NEW$LINE	;ANNOUNCE FIRST ADDRESS
	LHLD	LOAD$ADDRESS	;THIS IS FIRST ADDR
	SHLD	FIRST$ADDRESS	;SET FIRST ADDRESS
	CALL	WORD$OUT	;SEND IT TO CONSOLE

;SKIP OVER THE ZERO BYTE OF THE HEX RECORD. IT HAS NO
;SIGNIFICANCE TO THIS PROGRAM.

GET$ZERO$BYTE:
	CALL	GET$BINARY$BYTE

;THIS LOOP LOADS THE COM FILE WITH THE BYTE VALUES IN THE
;CURRENT HEX RECORD.

BYTE$LOAD$LOOP:
	CALL	GET$BINARY$BYTE	;GET BYTE TO LOAD
	CALL	PUT$TO$COMFILE	;LOAD IT TO COM FILE
	LXI	H,LOAD$COUNT
	DCR	M		;HIT LOAD COUNT
	JNZ	BYTE$LOAD$LOOP	;MORE LOADING IF NOT-ZERO

;UPDATE THE LAST ADDRESS IF CURRENT ABSOLUTE LOAD ADDRESS
;IS HIGHER THAN THE CURRENT VALUE OF "LAST$ADDRESS"

	LHLD	LAST$ADDRESS	;GET THE CURR VALUE
	XCHG			;TO <DE>
	CALL	ABSOLUTE	;ABSOLUTE ADDR TO <HL>
	MOV	A,E		;--SUBTRACT ABSOLUTE
	SUB	L		;--ADDRESS FROM CURRENT
	MOV	A,D		;--LAST ADDRESS
	SBB	H
	JNC	CHECK$CHECKSUM	;LAST ADDR LARGER IF NC
	DCX	H		;DOWN 1 FOR LAST ACTUAL LOAD
	SHLD	LAST$ADDRESS	;UPDATE IT

;VERIFY THE CHECKSUM FOR THIS RECORD.

CHECK$CHECKSUM:
	CALL	GET$BINARY$BYTE	;GET CHECKSUM BYTE
	JZ	SCAN$FOR$COLON	;ZERO ON FOR CHECKSUM OK
	LXI	D,CSEMSG	;CHECKSUM ERROR
	JMP	HEXFILE$ERROR

;SEND PROCESSING SUMMARY TO THE CONSOLE AND FLUSH THE
;COM BUFFER OF ANY UNWRITTEN DATA.

FINISH$UP:
	LXI	D,LSTADDRMSG	;POINT "LAST ADDR" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	LHLD	LAST$ADDRESS	;GET THE LAST ADDRESS
	CALL	WORD$OUT	;SEND IT TO CONSOLE
	LXI	D,BRMESSAGE	;POINT "BYTES READ" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	LHLD	BYTES$READ$COUNT	;GET THE COUNT
	CALL	WORD$OUT	;SEND IT OUT

;THE FOLLOWING CODE PREPARES FOR AND MAKES THE FINAL CALL
;TO THE "PUT" ROUTINE IN ORDER TO FLUSH THE "COM" BUFFER.
;IT HAS BEEN "KLUGED" IN ORDER TO WORK AROUND THE BOUNDARY
;CONDITION OF HAVING AN OFFSET OF <100H AT FLUSH TIME.
;WE FORCE THE OFFSET AND LENGTH TO BE NON-ZERO SO THE
;INITIAL COMPARE IN THE "PUT" ROUTINE WON'T GET SCREWED
;UP. THE BUFFER END ADDRESS IS NOT PLAYED WITH, HOWEVER.
;THIS IS TO INSURE THAT THE CORRECT NUMBER OF RECORDS GET
;WRITTEN.

	LHLD	COM$BUF$OFFSET	;GET THE CURRENT OFFSET
	PUSH	H		;SAVE OFFSET FOR LATER
	LXI	D,COMFILE$BUFFER ;GET BUFFER ADDRESS
	DAD	D		;ADD TO OFFSET TO GET LEN
	SHLD	CURR$COM$BUF$END ;STORE NEW END ADDR
	LXI	H,CLEAR$FLAG	;POINT TO CLEAR FLAG
	INR	M		;DISABLE CLEAR WITH NON-ZERO
	POP	H		;GET OFFSET BACK
	MVI	H,1		;FORCE HI BYTE NON-ZERO
	SHLD	COM$BUF$OFFSET	;FAKE OFFSET
	SHLD	CURR$COM$BUF$LEN ;AND FAKE LENGTH
	CALL	PUT$TO$COMFILE	;FLUSH THE BUFFER
	LXI	D,RWMSG		;POINT "REC WRIT" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	LDA	RECORDS$WRITTEN	;GET THE COUNT
	CALL	BYTE$OUT	;SEND IT OUT
	CALL	CRLF		;SEND OUT CRLF
	POP	D		;COM FILE FCB ADDR
	MVI	C,16		;CLOSE FILE
	CALL	BDOS		;COM FILE CLOSE
	INR	A		;SEE IF -1 FOR ERROR
	LXI	D,CCFMSG	;CANNOT CLOSE FILE
	JZ	ERROR$ABORT
CRLF$AND$EXIT:
	CALL	CRLF
EXIT:
	LXI	D,80H
	MVI	C,26		;RE-SET DMA TO 80H
	CALL	BDOS
	LHLD	STACK$SAVE	;RECOVER CCP STACK POINTER
	SPHL			;TO <SP>
	RET			;RET TO CCP




;		SUBROUTINES



;THIS ROUTINE GETS TWO CHARACTERS FROM THE HEX FILE
;AND CONVERTS TO AN 8-BIT BINARY VALUE, RETURNED IN <A>.

GET$BINARY$BYTE:
	CALL	GET$HEX$DIGIT	;GET HI NYBBLE FIRST
	ADD	A		;SHIFT UP 4 SLOTS
	ADD	A
	ADD	A
	ADD	A
	PUSH	PSW		;SAVE HI NYBBLE
	CALL	GET$HEX$DIGIT	;NOW GET LO NYBBLE
	POP	B		;HI NYBBLE TO <B>
	ORA	B		;COMBINE NYBBLES TO FORM BYTE
	MOV	B,A		;SAVE THE BYTE
	LXI	H,CHECKSUM
	ADD	M		;UPDATE THE CHECKSUM
	MOV	M,A		;AND STORE IT
	MOV	A,B		;GET BYTE BACK
	RET			;ZERO SET MEANS CHECKSUM=0


;ROUTINE TO GET A HEX-ASCII CHARACTER FROM THE HEX FILE
;AND RETURN IT IN THE <A> REGISTER CONVERTED TO BINARY.
;A CHECK FOR LEGAL HEX VALUE IS MADE. PROGRAM ABORTS
;WITH APPROPRIATE MESSAGE IF ILLEGAL DIGIT ENCOUNTERED.

GET$HEX$DIGIT:
	CALL	GET$HEXFILE$CHAR
	SUI	'0'		;REMOVE ASCII BIAS
	CPI	10		;DECIMAL DIGIT?
	RC
	SUI	7		;STRIP ADDITIONAL BIAS
	CPI	10		;MUST BE AT LEAST 10
	JC	ILLHEX
	CPI	16		;MUST BE 15 OR LESS
	RC
ILLHEX	LXI	D,IHDMSG	;ILLEGAL HEX DIGIT

;ROUTINE TO INDICATE THAT AN ERROR HAS BEEN FOUND IN THE
;HEX FILE (EITHER CHECKSUM OR ILLEGAL HEX DIGIT).
;APPROPRIATE MESSAGES ARE PRINTED AND THE PROGRAM ABORTS.

HEXFILE$ERROR:
	CALL	MSG$ON$NEW$LINE	;PRINT ERROR TYPE
	LXI	D,LAMESSAGE	;POINT "LOAD ADDR" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	LHLD	LOAD$ADDRESS	;GET LOAD ADDR
	CALL	WORD$OUT	;SEND IT OUT
	LXI	D,EAMSG		;POINT "ERR ADDR" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	CALL	ABSOLUTE	;GET ABSOLUTE ADDR
	CALL	WORD$OUT	;THIS IS ERR ADDR
	LXI	D,BRMESSAGE	;POINT "BYTES READ" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	CALL	PRINT$LOAD$ADDR	;SEND OUT CURR LOAD ADDR

;PRINT OUT ALL BYTES THAT WERE LOADED FROM THE CURRENT
;HEX RECORD UP TO THE POINT WHERE THE ERROR WAS DETECTED.

ERR$OUT$LOOP:
	LHLD	LOAD$ADDRESS	;POINT TO BYTE TO BE OUTPUT
	XCHG			;TO <DE>
	CALL	ABSOLUTE	;GET ABSOLUTE ADDR
	MOV	A,E		;--SEE IF "LOAD ADDR"
	SUB	L		;--HAS REACHED ABSO ADDR
	MOV	A,D
	SBB	H
	JNC	CRLF$AND$EXIT	;DONE IF THEY'RE EQUAL
	MOV	A,E		;SEE IF MULTIPLE OF 16
	ANI	0FH
	CZ	PRINT$LOAD$ADDR	;IF MULTIPLE OF 16
	LHLD	LOAD$ADDRESS	;GET LOAD ADDR AGAIN
	XCHG			;TO <DE>
	LHLD	CURRENT$COM$BASE
	MOV	A,E		;--CALC OFFSET OF CURR
	SUB	L		;--BYTE TO GO OUT
	MOV	L,A		;LO BYTE OF OFFSET
	MOV	A,D		;HI BYTE OF LOAD ADDR
	SBB	H
	MOV	H,A		;HI BYTE OF OFFSET
	LXI	B,COMFILE$BUFFER
	DAD	B	;<HL> NOW POINTS TO BYTE TO GO
	MOV	A,M		;GET THE BYTE FROM BUFFER
	CALL	BYTE$OUT	;SEND IT OUT
	LHLD	LOAD$ADDRESS	;BUMP LOAD ADDRESS
	INX	H
	SHLD	LOAD$ADDRESS
	MVI	A,' '		;SEND A SPACE BETWEEN BYTES
	CALL	CHAR$TO$CONSOLE
	JMP	ERR$OUT$LOOP	;BACK FOR MORE



;ROUTINE TO GET A CHARACTER FROM THE HEX FILE BUFFER.
;CHAR IS RETURNED IN <A>.


GET$HEXFILE$CHAR:
	LDA	HEX$BUFFER$OFFSET
	INR	A		;BUMP HEX OFFSET
	JP	GETCHAR		;PLUS IF NOT 80H YET
	LXI	D,HEX$BUFFER
	MVI	C,26		;SET-DMA CODE
	CALL	BDOS		;SET DMA ADDR TO HEX BUFFER
	LXI	D,HEX$FCB	;POINT HEX FCB
	MVI	C,20		;READ-NEXT-RECORD CODE
	CALL	BDOS		;GET NEXT HEXFILE RECORD
	ORA	A		;TEST FOR ERROR
	LXI	D,DRMSG		;ASSUME ERROR FOR NOW
	JNZ	ERROR$ABORT	;FATAL ERR IF NOT ZERO
GETCHAR:
	STA	HEX$BUFFER$OFFSET
	MVI	H,HIGH HEX$BUFFER
	MOV	L,A		;POINT TO NEXT CHAR
	MOV	A,M		;GET THE CHARACTER
	RET


;
;THIS ROUTINE PUTS A DATA BYTE TO THE "COM" FILE.
;THE BYTE IS PASSED IN <A>.
;THE FIRST COMPARE IS DONE ON JUST THE HI BYTES FOR THE
;SAKE OF SPEED, SINCE WE ARE PROCESSING THE "HEX" FILE
;"ON THE FLY".

PUT$TO$COMFILE:
	PUSH	PSW		;SAVE BYTE TO LOAD
	LHLD	COM$BUF$OFFSET	;GET CURRENT OFFSET
	XCHG			;TO <DE>
PTC	LDA	CURR$COM$BUF$LEN+1 ;PAGE NO. OF BUFF TOP
	DCR	A		;ONE LESS FOR COMPARE
	CMP	D		;TOP < OFFSET?
	JNC	STORE$BYTE	;STORE BYTE IF NOT
	LHLD	CURR$COM$BUF$LEN
	MOV	A,E		;SUBTRACT LEN FROM OFFSET--
	SUB	L		;--TO GET NEW OFFSET
	MOV	C,A		;<C> HAS LO BYTE OF DIFF
	MOV	A,D		;HI BYTE OF OFFSET
	SBB	H		;MINUS HI BYTE OF BUFF LENGTH
	MOV	B,A		;<BC> HAS NEW OFFSET
	PUSH	B		;SAVE NEW OFFSET
	XCHG			;BUFFER LENGTH TO <DE>
	LHLD	CURRENT$COM$BASE ;COM BASE TO <HL>
	DAD	D		;INCREASE IT BY BUFFER LENGTH
	SHLD	CURRENT$COM$BASE ;STORE NEW BASE
	LHLD	CURR$COM$BUF$END
	LXI	D,COMFILE$BUFFER	;BUFFER ADDR TO <DE>
COMLOOP:
	MOV	A,E		;SUBTRACT BUFF END FROM POINTER
	SUB	L
	MOV	A,D
	SBB	H		;WRITTEN TO END OF BUFFER YET?
	JNC	STORE		;CY OFF MEANS WE'RE DONE
	PUSH	H		;SAVE BUFFER END ADDRESS
	PUSH	D		;SAVE WRITE POINTER
	MVI	C,26		;SET DMA FUNCTION CODE
	CALL	BDOS		;SET NEW DMA ADDRESS
	MVI	C,21		;WRITE-NEXT-RECORD CODE
	LXI	D,DEFAULT$FCB	;POINT COM FILE FCB
	CALL	BDOS		;WRITE NEXT COM RECORD
	ORA	A		;TEST FOR ERROR ON WRITE
	LXI	D,DWMSG		;POINT WRITE ERROR MSG
	JNZ	ERROR$ABORT	;BOMB IF WRITE ERROR
	POP	D		;RESTORE WRITE POINTER
	LXI	H,128		;SECTOR SIZE
	DAD	D		;BUMP POINTER BY 128
	XCHG			;NEW POINTER TO <DE>
	LXI	H,RECORDS$WRITTEN
	INR	M
	POP	H		;RESTORE BUFFER END ADDR
	JMP	COMLOOP		;SEE IF END OF BUFFER YET
STORE:
	LDA	CLEAR$FLAG	;GET CLEAR-BUFFER FLAG
	ORA	A		;SHALL WE CLEAR?
	CZ	CLEAR$COMBUFFER	;ZERO THE BUFFER
	POP	D		;GET BACK NEW OFFSET
	JMP	PTC		;SEE IF WE MUST FLUSH AGAIN
STORE$BYTE:
	LXI	H,COMFILE$BUFFER	;BUFFER ADDR TO <HL>
	DAD	D			;ADD TO CURRENT OFFSET
	POP	PSW		;RETRIEVE BYTE TO WRITE
	MOV	M,A		;STUFF IT
	INX	D		;BUMP OFFSET
	XCHG			;TO <HL> FOR STORE
	SHLD	COM$BUF$OFFSET	;UPDATE OFFSET
	RET			;ALL DONE


;
;ROUTINE TO CONVERT THE 2-BYTE VALUE IN <HL> TO
;TWO ASCII CHARACTERS AND SEND THEM TO THE CONSOLE.
;
WORD$OUT:
	PUSH	H	;SAVE WORD
	MOV	A,H	;HI WORD GOES OUT 1ST
	CALL	BYTE$OUT
	POP	H	;RESTORE WORD
	MOV	A,L	;LO BYTE GOES NEXT
BYTE$OUT:
	PUSH	PSW	;SAVE BYTE
	RRC! RRC! RRC! RRC	;HI NYBBLE COMES DOWN
	CALL	NYBBLE$OUT
	POP	PSW	;RESTORE VALUE
NYBBLE$OUT:
	ANI	0FH
	ADI	90H
	DAA
	ACI	40H
	DAA
CHAR$TO$CONSOLE:
	MOV	E,A
	MVI	C,2	;WRITE CONSOLE CHAR FUNC CODE
	JMP	BDOS
;
;ROUTINE TO OUTPUT A "CRLF".
;
CRLF:
	MVI	A,CR
	CALL	CHAR$TO$CONSOLE
	MVI	A,LF
	JMP	CHAR$TO$CONSOLE
;
;ROUTINE TO PRINT A BUFFER TO THE CONSOLE.
;<DE> POINTS TO THE MESSAGE ON ENTRY.
;EARLIEST ENTRY POINT STARTS MESSAGE ON A NEW LINE
;
MSG$ON$NEW$LINE:
	PUSH	D	;SAVE MESSAGE POINTER
	CALL	CRLF	;START NEW LINE
	POP	D	;RESTORE MESSAGE POINTER
PRINT$BUFFER:
	MVI	C,9	;OUTPUT BUFFER TO CONSOLE
	JMP	BDOS
;
;
;ERROR ABORT ROUTINE
;

ERROR$ABORT:
	PUSH	D		;SAVE MESSAGE POINTER
	LXI	D,ERRMSG	;POINT "ERROR" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	POP	D		;RESTORE MESSAGE POINTER
	CALL	PRINT$BUFFER	;SEND OUT ERR TYPE
	LXI	D,LAMESSAGE	;POINT "LOAD ADDR" MSG
	CALL	MSG$ON$NEW$LINE	;SEND IT OUT
	CALL	ABSOLUTE	;GET ABSOLUTE ADDR
	CALL	WORD$OUT	;SEND IT OUT
	JMP	EXIT		;BAIL OUT

;THIS ROUTINE PRINTS THE LOAD ADDRESS OF THE CURRENT
;HEX RECORD ON A NEW LINE FOLLOWED BY A ':' AND SPACE.

PRINT$LOAD$ADDR:
	CALL	CRLF
	LHLD	LOAD$ADDRESS
	CALL	WORD$OUT
	MVI	A,':'
	CALL	CHAR$TO$CONSOLE
	MVI	A,' '
	JMP	CHAR$TO$CONSOLE


;ROUTINE TO CLEAR THE COMFILE BUFFER.


CLEAR$COMBUFFER:
	LXI	H,COMFILE$BUFFER
	LDA	CURR$COM$BUF$END+1	;PAGE NO. OF BUF END
	MVI	C,0			;GET ZERO
CLOOP	MOV	M,C			;ZERO TO BUFFER
	INX	H			;BUMP POINTER
	CMP	H			;END OF BUFFER YET?
	JNZ	CLOOP			;LOOP TILL DONE
	RET


;ROUTINE TO COMPUTE CURRENT ABSOLUTE LOAD ADDRESS
;AND RETURN IT IN <HL>


ABSOLUTE:
	LHLD	CURRENT$COM$BASE ;GET BASE OF COM BUFFER
	MOV	B,H		;MOVE IT TO <BC>
	MOV	C,L
	LHLD	COM$BUF$OFFSET	;GET THE CURRENT OFFSET
	DAD	B		;SUM IS THE ABSO ADDR
	RET


;			MESSAGES


ERRMSG:
	DB	'ERROR: $'
DRMSG:
	DB	'DISK READ$'
ILAMSG:
	DB	'LOAD ADDRESS LESS THAN 100$'
DWMSG:
	DB	'DISK WRITE$'
LAMESSAGE:
	DB	'LOAD  ADDRESS $'
EAMSG:
	DB	'ERROR ADDRESS $'
IHDMSG:
	DB	'INVALID HEX DIGIT$'
CSEMSG:
	DB	'CHECKSUM ERROR $'
FAMSG:
	DB	'FIRST ADDRESS $'
LSTADDRMSG:
	DB	'LAST  ADDRESS $'
BRMESSAGE:
	DB	'BYTES READ    $'
RWMSG:
	DB	'RECORDS WRITTEN $'
COSMSG:
	DB	'CANNOT OPEN SOURCE FILE$'
NMDSMSG:
	DB	'DIRECTORY FULL$'
CCFMSG:
	DB	'CANNOT CLOSE FILE$'
SIGNON$MSG:
	DB	'HEXCOM	VERS: ',VERS/100+'0'
	DB	'.',VERS/10 MOD 10 +'0'
	DB	VERS MOD 10 + '0',CR,LF,'$'


;		DATA AREA



HEX$BUFFER$OFFSET	DB	127
FIRST$ADDRESS		DW	0
LAST$ADDRESS		DW	0
BYTES$READ$COUNT	DW	0
RECORDS$WRITTEN		DB	0
LOAD$ADDRESS		DW	100H
CURRENT$COM$BASE	DW	100H
CHECKSUM		DB	0
COM$BUF$OFFSET		DW	0
CLEAR$FLAG		DB	0	;CLEAR-COM-BUF FLAG



;		STORAGE AREA



STACK$SAVE		DS	2
HEX$FCB			DS	33
LOAD$COUNT		DS	1
CURR$COM$BUF$END	DS	2	;COM BUFFER TOP
CURR$COM$BUF$LEN	DS	2	;COM BUFFER LENGTH
			DS	32	;STACK AREA
STACK			EQU	$
		ORG	((HIGH $)+1)*256
HEX$BUFFER		DS	128
COMFILE$BUFFER		EQU	$
		END
