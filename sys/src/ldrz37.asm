VERS EQU '1 ' ; July 19, 1983	9:55  mjm  "LDRZ37.ASM"
**********************************************************
;	Loader disk I/O module for MMS CP/M 3.1
;	for the Zenith Z37 controller
;	Copyright (c) 1983 Magnolia Microsystems
;*********************************************************

	MACLIB Z80

	public btend
	extrn BDOS,CBOOT,DSKSTA,TIMEOT,MIXER,DIRBUF,DLOG
	extrn NEWDSK,NEWTRK,NEWSEC,DMAA

driv0	equ	46

; Physical drives are assigned as follows:
;
;	46 - 1st Z37 drive
;	47 - 2nd Z37 drive
;	48 - 3rd Z37 drive
;	49 - 4th Z37 drive

;	Ports and Constants
FD$BASE EQU	078H		; BASE PORT ADDRESS
FD$CON	EQU	FD$BASE 	; DISK CONTROL PORT
FD$INT	EQU	FD$BASE+1	; INTERFACE MUX PORT
FD$CMD	EQU	FD$BASE+2	; 1797 COMMAND REGISTER
FD$STA	EQU	FD$BASE+2	;      STATUS REGISTER
FD$DAT	EQU	FD$BASE+3	;      DATA REGISTER
FD$SEC	EQU	FD$BASE+2	;      SECTOR REGISTER
FD$TRK	EQU	FD$BASE+3	;      TRACK REGISTER

;  INTERFACE MUX PORT FLAGS
FD$CD	EQU	0		; ACCESS C/D REGISTERS
FD$TS	EQU	1		; ACCESS T/S REGISTERS

;  COMMANDS
FDCRST	EQU	000H		; RESTORE
FDCSTI	EQU	040H		; STEP IN
FDCSTO	EQU	060H		; STEP OUT
FDCRDS	EQU	080H		; READ SECTOR
FDCRDA	EQU	0C0H		; READ ADDRESS
FDCFI	EQU	0D0H		; FORCE INTERRUPT

;  TYPE 1 COMMAND FLAGS
FDFUTR	EQU	00010000B	; UPDATE TRACK REGISTER
FDFHLB	EQU	00001000B	; HEAD LOAD AT BEGINNING

;  TYPE 2&3 COMMAND FLAGS
FDFSLF	EQU	00001000B	; SECTOR LENGTH FLAG
FDFDLF	EQU	00000100B	; 30 MS DELAY
FDFSS1	EQU	00000010B	; SELECT SIDE 1

FDFINI	EQU	00000000B	; TERMINATE WITH NO INTERUPT

;  STATUS FLAGS
FDSRNF	EQU	00010000B	; RECORD NOT FOUND
FDSCRC	EQU	00001000B	; CRC ERROR
FDSTK0	EQU	00000100B	; FOUND TRACK 0
FDSIND	EQU	00000010B	; INDEX HOLE

;  CONTROL REGISTER FLAGS
CONIRQ	EQU	00000001B	; ENABLE INT REQ
CONDRQ	EQU	00000010B	; ENABLE DRQ INT / DISABLE SYSTEM INT
CONMFM	EQU	00000100B	; ENABLE MFM
CONMO	EQU	00001000B	; MOTOR(S) ON
CONDS0	EQU	00010000B	; DRIVE 0
CONDS1	EQU	00100000B	; DRIVE 1
CONDS2	EQU	01000000B	; DRIVE 2
CONDS3	EQU	10000000B	; DRIVE 3

;  HEATH EXTENSIONS
DPEH37	EQU	01100000B	; H37
DPEHL	EQU	8		; LENGTH OF HEATH EXTENSION

; MODE BYTES
MOD48RO EQU	00000100B	; BIT 2 -- 48 TPI MEDIA IN 96 TPI DRIVE (R/O)
MODEDD	EQU	01000000B	; BIT 6 -- 0=SINGLE DENSITY 1=DOUBLE
MODE2S	EQU	00000001B	; BIT 0 -- 0=SINGLE DENSITY 1=DOUBLE

;  DISK LABEL DEFINITIONS
LABVER	EQU	0		; CURRENT FORM # FOR LABEL
LABBUF	EQU	0		; SLOT FOR JUMP INSTRUCTION AROUND LABEL
LABEL	EQU	LABBUF+4
LABTYP	EQU	LABEL+0 	; SLOT FOR LABEL TYPE
LABHTH	EQU	LABTYP+1	; SLOT FOR HEATH EXTENSIONS TO DPE
LABDPB	EQU	LABHTH+DPEHL	; SLOT FOR DISK PARAMETER BLOCK
LABCS	EQU	LABDPB+15	; CHECKSUM
LABLEN	EQU	LABCS-LABEL+1	; LABEL LENGTH

;  MISCELLANEOUS VALUES
FDHDD	EQU	20
DELAY37 EQU	6*256+15	; DESELECT AND MOTOR TURN OFF DELAY
H37VEC	EQU	8*4		; LEVEL 4 INTERRUPT
DLYMO37 EQU	H37VEC+3	; MOTOR TURN OFF DELAY COUNTER
H37CTL	EQU	H37VEC+5	; H37 CONTROL REGISTER IMAGE

PORT	EQU	0F2H		; Z89 INTERRUPT CONTROL

MOD48RO EQU	00000100B	; 48 TPI DISK IN 96 TPI DRIVE (R/O)
MODEDD	EQU	01000000B	; DOUBLE DENSITY
LABLEN	EQU	19H		; LENGTH OF Z37 DISK LABEL
LABEL	EQU	04H		; POSITION OF LABEL IN SECTOR 0
LABHTH	EQU	05H		; START OF "HEATH EXTENSION" IN SECTOR 0
MODE2S	EQU	00000001H	; DOUBLE SIDED
LABDPB	EQU	0DH		; START OF DPB IN SECTOR 0
LABVER	EQU	00		; LABEL VERSION NUMBER
DPEH37	EQU	60H		; I.D.

?CLOCK		equ	11
?INT$BYTE	equ	13

	cseg			; START OF MODULE
	jmp	init
	JMP	SEL$Z37
	JMP	READ$Z37

	DB	'Z89-37 ',0,'Double Density Loader ',0,'3.10'
	DW	VERS
	DB	'$'

modebt: equ	2288h
drvbt:	equ	2287h

; NOTE: DPH's are selected by "modebt"
DPH:	DW	0,0,0,0,DIRBUF,dpb5ssst,CSV,ALV
	DW	0,0,0,0,DIRBUF,dpb5dsst,CSV,ALV
	DW	0,0,0,0,DIRBUF,dpb5ssdt,CSV,ALV
	DW	0,0,0,0,DIRBUF,dpb5dsdt,CSV,ALV

dpb5ssst:
	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES

dpb5dsst:
	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	173-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00100010B,01100011B,00000000B	; MODE BYTES

dpb5ssdt:
	DW	36		; SECTORS PER TRACK
	DB	5,31,3		; BSH,BSM,EXM
	DW	86-1,128-1	; DSM-1,DRM-1
	DB	10000000B,0	; AL0,AL1
	DW	32,3		; CKS,OFF
	DB	00000010B,01101011B,00000000B	; MODE BYTES

dpb5dsdt:
	DW	36		; SECTORS PER TRACK
	DB	5,31,3		; BSH,BSM,EXM
	DW	176-1,128-1	; DSM-1,DRM-1
	DB	10000000B,0	; AL0,AL1
	DW	32,3		; CKS,OFF
	DB	00100010B,01101011B,00000000B	; MODE BYTES

INIT:
	MVI	A,(JMP) 	; INSTALL H37 INTERRUPT ROUTINE
	LXI	H,H37ISR
	STA	H37VEC
	SHLD	H37VEC+1
	LXI	H,MTRDLY	; INSTALL Z37 TIME OUT ROUTINE
	SHLD	TIMEOT+1
	mvi	a,(JMP)
	STA	TIMEOT		; ACC. STILL CONTAINS (JMP)
	lda	drvbt
	sta	mixer
	RET

SEL$Z37:
	XRA	A
	STA	SELERR		; NO SELECT ERROR (YET)
	STA	RDYFLG		; ASSUME DISK NOT READY 
	LDA	NEWDSK		; get drive select code in 'A'.
	SUI	DRIV0		; relate drive number to 0
	STA	RELDSK		; SAVE IT
	lxi	h,dph
	lda	modebt
	add	a
	add	a
	add	a
	add	a	;*16
	add	l
	mov	l,a
	mvi	a,0
	adc	h
	mov	h,a
	push	h
	LXI	D,10
	DAD	D		; POINT TO ADDRESS OF DPB
	CALL	HLIHL		; POINT TO DPB
	SHLD	CURDPB
	LXI	D,15
	DAD	D		; POINT TO MODE BYTES
	SHLD	MODE		; SAVE MODE BYTE POINTER
	PUSH	H
	CALL	LOGIN		; HAS DISK BEEN LOGGED IN ?
	CNC	PHYSEL
	POP	H		; GET MODE BYTE 1
	INX	H
	MVI	A,40		; 40 TRACKS PER SIDE
	BIT	3,M		;  FOR SINGLE TRACK
	JRZ	STRK		;  80 FOR DOUBLE TRACK
	ADD	A
STRK:	STA	TPS
; CALCULATE DEBLOCKING PARAMETERS
	LHLD	CURDPB		; GET DPB ADDRESS
	INX	H
	INX	H
	INX	H
	MOV	A,M		; GET BLOCK MASK
	STA	BLKMSK		; SAVE IT
	LXI	D,10
	DAD	D
	MOV	A,M		; GET TRACK OFFSET
	STA	OFFSET		; SAVE IT
	LHLD	MODE
	MOV	A,M
	ANI	03H		; ISOLATE SECTOR SIZE BITS
	STA	BLCODE		; STARE AS DEBLOCK CODE
	LDA	RELDSK
	MOV	C,A		; RESTORE PHYSICAL DRIVE #
	pop	h		; SELDSK NEEDS DPH
	RET

LOGIN:	lhld	dlog		; CHECK FOR DISK LOGGED IN
	mov	a,l
	rar
	ret

PHYSEL: LHLD	MODE		; DO WE NEED TO READ THE LABEL ?
	BIT	4,M
	JZ	PHYSEL3 	;  GO ON IF NOT
	LDA	NEWDSK
	STA	HSTDSK
	XRA	A
	STA	HSTTRK		; TRACK 0
	STA	HSTSEC		; SECTOR 0
	STA	SELOP		; FLAG A SELECT OPERATION
	STA	MODFLG		; RESET CHANGED MODE FLAG
	MVI	A,5		; 5 RETRYS FOR A SELECT OPERATION
	STA	RETRYS
	CALL	READ		; TRY READING LABEL AT DENSITY
				; CURRENTLY INDICATED IN TABLES
	JRZ	PHYSEL1 	; BR IF SUCCESSFUL
	MVI	A,5		; RESET RETRYS TO 5
	STA	RETRYS
	STA	MODFLG		; SET CHANGED MODE FLAG
	LHLD	MODE
	INX	H		; POINT TO MODE BYTE 2
	MOV	A,M		; TRY OTHER DENSITY
	XRI	MODEDD
	MOV	M,A
	CALL	ON$H37		; THIS SETS DENSITY ACCORDING TO MODE BYTE
	CALL	READ		; TRY TO READ LABEL
	JNZ	PHYSEL5 	; ERROR
PHYSEL1:XRA	A		; ZERO ACCUM.
	MVI	B,LABLEN	; GET LENGTH OF LABEL
	LXI	H,HSTBUF+LABEL
CHKLAB1:ADD	M
	INX	H
	DJNZ	CHKLAB1
	INR	A
	JRZ	PHYSEL2 	; BR IF CORRECT CHECKSUM
	LDA	MODFLG
	ORA	A		; MODE BEEN CHANGED ?
	JNZ	PHYSEL6 	;  THEN ERROR
	JR	PHYSEL3 	; OTHERWISE DONE, KEEPING OLD MODE BYTES

PHYSEL2:
	LHLD	MODE		; HL POINTS TO MODE BYTE
	LXI	D,HSTBUF+LABHTH ; DE POINTS TO HEATH EXTENSION IN LABEL
	LDAX	D		; GET FIRST BYTE OF HEATH EXTENSION
	MVI	B,00011000B	; Z37 DOUBLE DENSITY FORMAT
	MVI	C,00000001B	; 256 BYTES PER SECTOR
	BIT	2,A		; GET EXTENDED DOUBLE DENSITY BIT
	JRZ	GETSID
	MVI	B,00110000B	; Z37 EXTENDED DOUBLE DENSITY FORMAT
	MVI	C,00000011B	; 1024 BYTES PER SECTOR
GETSID: ANI	00000001B	; GET SIDED BIT
	RRC
	RRC
	RRC			; MOVE TO BIT POSITION 5
	ORA	C		; OR IN SECTOR SIZE BITS
	ORI	00010100B	; OR IN OTHER Z37 RELATED BITS
	MOV	M,A		; SAVE NEW MODE BYTE 1
	INX	H		; POINT TO MODE BYTE 2
	MVI	C,0		; BITS FOR SINGLE DENSITY
	LDAX	D
	BIT	1,A		; GET DOUBLE DENSITY BIT
	JRZ	SDEN
	MVI	C,01100000B	; DOUBLE DENSITY
SDEN:	ANI	00001000B	; GET TRACK DENSITY BIT
	ORA	C		; OR IN SECTOR SIZE BITS
	MOV	C,A
	MOV	A,M		; GET MODE BYTE 2
	ANI	00000011B	; KEEP STEP RATE BITS
	ORA	C		; OR IN NEW BITS
	MOV	M,A		; SAVE NEW MODE BYTE 2
	INX	H		; POINT TO MODE BYTE 3
	MOV	M,B		; SAVE NEW MODE BYTE 3
	LDED	CURDPB		; GET DPB ADDRESS
	LXI	H,HSTBUF+LABDPB ; GET ADDRESS OF INFO IN LABEL
	LXI	B,15		; COUNT TO MOVE
	LDIR			; MOVE INFO
PHYSEL3:CALL	SELECT
	JRC	PHYSEL6 	; ERROR IF NOT READY
	CALL	HOME		;RESTORE HEAD TO TRACK 0
	JRC	PHYSEL6
	MVI	B,FDCSTI+FDFHLB ;STEP IN, NO UPDATE
	CALL	TYPE$I
	CALL	TYPE$I		;STEP IN TWICE
	MVI	A,FDCRDA	; READ ADDRESS
	CALL	PUT$I
	ANI	FDSRNF+FDSCRC
	JRNZ	PHYSEL6
	MVI	A,FD$TS 	; SELECT SECTOR REGISTER
	OUT	FD$INT
	IN	FD$SEC
	CPI	2
	JRZ	PHYSEL4
	CPI	1
	JRNZ	PHYSEL6
	LHLD	MODE
	INX	H		; MODE BYTE 2
	BIT	3,M		; IS MODE SET TO DOUBLE TRACK ?
	JRNZ	PHYSEL6 	; ERROR BECAUSE WRONG DPB IS INSTALLED
	SETB	4,M		; SET HALF TRACK BIT
PHYSEL4:			; RESTORE
	CALL	HOME  
	JRC	PHYSEL6
	JR	PHYSEL7

PHYSEL5:MVI	A,0FFH
	STA	HSTDSK		; FLAG BUFFER AS UNKNOWN
PHYSEL6:MVI	A,1
	STA	SELERR		; FLAG A SELECT ERROR
PHYSEL7:MVI	A,0FFH
	STA	SELOP		; SELECT OPERATION IS OVER
	JMP	DONE

READ$Z37:
	LDA	SELERR		; WAS THERE AN ERROR ON SELECT ?
	ORA	A
	RNZ
	MVI	A,21		; 21 RETRYS FOR A READ/WRITE OPERATION
	STA	RETRYS
	PUSH	D		; TEMPORARILY SAVE RECORD NUMBER
	LXI	B,3
	LXI	H,NEWDSK
	LXI	D,REQDSK
	LDIR
	POP	D		; RESTORE RECORD NUMBER
	XRA	A		; CLEAR CARRY
	MOV	C,A		; CALCULATE PHYSICAL SECTOR
	LDA	BLCODE
	MOV	B,A
	LDA	NEWSEC
DBLOK1: DCR	B
	JM	DBLOK2
	RAR
	RARR	C
	JR	DBLOK1
DBLOK2: STA	REQSEC		; SAVE IT
	LDA	BLCODE		; CALCULATE BLKSEC
DBLOK3: DCR	A
	JM	DBLOK4
	RLCR	C
	JR	DBLOK3
DBLOK4: MOV	A,C
	STA	BLKSEC		; STORE IT
	INR	A		; NON-ZERO VALUE TO ACC.
	STA	RD$FLAG 	; FLAG A PRE-READ
	XRA	A		; NO LONGER WRITING AN UNALLOCATED BLOCK
	STA	UNALLOC
	LXI	H,NEWTRK
	LDA	OFFSET
	CMP	M		; IS IT THE DIRECTORY TRACK ?
	JRNZ	CHKBUF
	INX	H
	MOV	A,M
	ORA	A		; FIRST SECTOR OF DIRECTORY ?
	JRZ	READIT 
CHKBUF: LXI	H,REQDSK
	LXI	D,HSTDSK
	MVI	B,3
CHKNXT: LDAX	D
	CMP	M
	JRNZ	READIT
	INX	H
	INX	D
	DJNZ	CHKNXT
	JR	NOREAD		; THEN NO NEED TO PRE-READ
READIT:
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
	LDIR			; MOVE IT
	XRA	A		; FLAG NO ERROR
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

RD$SEC: CALL	READ		; READ A PHYSICAL SECTOR
	RZ			; RETURN IF SUCCESSFUL
	MVI	A,0FFH		; FLAG BUFFER AS UNKNOWN
	STA	HSTDSK
	POP	D		; THROW AWAY TOP OF STACK
	MVI	A,1		; SIGNAL ERROR TO BDOS
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

READ:	CALL	ACCESS$R	; START DRIVE AND STEP TO PROPER TRACK
	JC	ERROR
	MVI	B,FDCRDS+FDFSLF ; READ COMMAND W/O SIDE SELECT
	MVI	A,0A2H		; INI INSTRUCTION (2ND BYTE)
	STA	FIX1+1		;setup physical routines for read/write
RETRY:						     
	PUSH	B		; save registers
	PUSH	D
	LDA	?INT$BYTE	; get interrupt byte
	ANI	11111101B	; Turn 2 millisecond clock off
	OUT	PORT		; to prevent interupts from causing lost-data

	MVI	A,FD$TS 	; SELECT SECTOR REGISTER
	OUT	FD$INT
	LDA	HSTSEC		; MAKE SECTOR 1,2,3,...,SPT
	INR	A
	OUT	FD$SEC		; SEND SECTOR NUMBER TO CONTROLLER
	LDA	SIDE		; get the side select bits
	ORA	B		; merge COMMAND and SIDE SELECT bits
	MOV	B,A
	LDA	H37CTL		; TURN ON DRQ AND IRQ
	ORI	CONDRQ+CONIRQ
	OUT	FD$CON
	MVI	A,FD$CD 	; ACCESS C/D REGS.
	OUT	FD$INT
	MOV	A,B		; GET COMMAND BACK IN ACC.
	LXI	H,HSTBUF	; DATA BUFFER ADDRESS
	MVI	C,FD$DAT	; DATA PORT TO REG. C
	CALL	IO$1024 	; TRANSFER THE SECTOR
	STA	DSKSTA		; save status of transfer
	LDA	H37CTL	  
	OUT	FD$CON		; TURN OFF INTERRUPTS
	MVI	A,FDCFI
	OUT	FD$CMD		; FORCE TYPE I STATUS

	LDA	?INT$BYTE	; get interrupt byte
	OUT	PORT		; CLOCK ON AGAIN

	XRA	A		; CLEAR CARRY FOR DSBC
	LXI	D,HSTBUF
	DSBC	D		; HL NOW CONTAINS # OF BYTES TRANSFERRED
	LDA	DSKSTA		; check for successful transfer
	ANI	10111111B
	JRNZ	IOERR		; RETRY IF ERROR
	LDA	SELOP		; IS THIS A SELECT OPERATION ?
	ORA	A
	JRZ	POPRET		; THEN DON'T CHECK SECTOR SIZE
	LDA	BLCODE		; CHECK IF CORRECT NUMBER OF BYTES TRANSFERRED
	CPI	3
	JRNZ	NOTED		; BLCODE=3 => 1024 BYTE SECTOR EXPECTED
	INR	A		; INCREMENT BECAUSE (H) FOR 1024 IS 4
NOTED:	CMP	H		; COMPARE TO EXPECTED SIZE
POPRET: POP	D
	POP	B
	JRZ	DONE		; DONE IF CORRECT
	JR	TRYAGN		; RETRY IF INCORRECT
IOERR:	POP	D
	POP	B
	JC	ERROR		; ERROR IF NO READY SIGNAL
TRYAGN: LXI	H,RETRYS	; decrement retry count
	DCR	M
	JZ	ERROR		; NO MORE RETRIES
	MOV	A,M
	CPI	10
	JNC	RETRY		; LESS THAN TEN RETRYS LEFT => STEP HEAD
	LDA	SELOP
	ORA	A
	JZ	RETRY		; DO NOT STEP HEAD IF SELECT OPERATION
	PUSH	B		; SAVE REGISTERS
	PUSH	D
	CALL	STEPIN		; STEP IN COMMAND
	CALL	SEEK		; SEEK WILL REPOSITION HEAD
	POP	D		; RESTORE REGISTERS
	POP	B
	JMP	RETRY		; TRY AGAIN

ERROR:	XRA	A		; PSW/Z MUST BE RESET TO INDICATE ERROR
	INR	A
DONE:	PUSH	PSW		; SAVE ERROR STATUS
	LDA	SELOP		; CHECK FOR SELECT OPERATION
	ORA	A
	JRZ	RETRN
	LXI	H,DELAY37	; SET DESELECT AND MOTOR TURN OFF DELAYS
	SHLD	DLYMO$37	;  UNLESS SELECT OPERATION IS IN PROGRESS
RETRN:	POP	PSW		; RECALL ERROR STATUS
	RET

IO$1024:
	OUT	FD$CMD		; send command to controller
	EI			; turn on interrupts
RW1	HLT			; WAIT FOR DRQ
FIX1	INI			; transfer byte (INI becomes OUTI for writes)
	JR	RW1		; loop until transfer complete.
				; RETURN DONE BY INTERRUPT ROUTINE

ACCESS$R:
	CALL	SELECT		; SELECT DRIVE
	RC			; ERROR IF DRIVE NOT READY
SEEK:	LDA	HSTTRK		; GET REQUESTED TRACK
	MVI	B,0		; SET SIDE VALUE FOR SIDE 0
	LHLD	MODE
	BIT	2,M
	JRNZ	CONZEN		; ALTERNATE CONVERT PROCEDURE FOR ZENITH DISKS
	LXI	H,TPS		; GET TRACKS PER SIDE
	MOV	C,M
	CMP	C		; COMPARE REQUESTED TRACK WITH TRACKS-PER-SIDE
	JRC	SIDE0		; NO CONVERSION IF ON FIRST SIDE
	CMA			; NEGATE LOGICAL TRACK NUMBER
	INR	A
	ADD	C
	ADD	C		; ADD TOT TRACKS ON DISK SURFACES (2*NUM$TRKS)
	DCR	A		; SUBTRACT 1 BECAUSE TRACKS START AT 0
	JR	SIDE1
CONZEN: BIT	5,M		; CHECK SIDED BIT
	JRZ	SIDE0		; NO CONVERT IF SINGLE SIDED
	ANA	A		; TO CLEAR CARRY
	RAR			; DIVIDE BY 2 TO GET REAL TRACK NUMBER
	JRNC	SIDE0
SIDE1:	MVI	B,FDFSS1	; set side value for 2nd side	 

SIDE0:	MOV	C,A		; store track number
	MOV	A,B		
	STA	SIDE		; save side value for read/write command
	LXI	H,SEKERR	; initialize seek error counters
	MVI	M,4		; 4 ERRORS ON SEEK IS FATAL
	INX	H
	MVI	M,10		; RESTORE once, then 9 errors are fatal
RETRS:	MOV	A,C		; get track number back
	ORA	A		; FORCES "RESTORE" IF "seek to track 0"
	JZ	HOME		;RESTORE HEAD TO TRACK 0
	LHLD	MODE		;TRACK NUMBER IN (A) MUST BE PRESERVED
	INX	H		; MODE BYTE 2
	MOV	H,M		; BIT 4 IS THE HALF-TRACK OPTION
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	IN	FD$TRK		; GET CURRENT HEAD POSITION,
	SUB	C		;SEE HOW FAR WE WANT TO GO.
	RZ			       ; IF ZERO TRACKS TO STEP, WERE FINISHED
	MVI	B,FDCSTO+FDFHLB+FDFUTR ; ASSUME STEP-OUT + UPDATE + HEADLOAD
	JRNC	STOUT		       ; ASSUMPTION WAS CORRECT...
	MVI	B,FDCSTI+FDFHLB+FDFUTR ; ELSE MUST BE STEP-IN
	NEG			       ; AND NUMBER OF TRACKS WOULD BE NEGATIVE
STOUT:	MOV	L,A		; COUNTER FOR STEPPING
SEEK5:	BIT	4,H		; CHECK FOR 48 TPI DISK IN 96 TPI DRIVE
	JRZ	NOTHT
	RES	4,B		; SELECT NO-UPDATE
	CALL	TYPE$I		; STEP HEAD
	ANI	FDSTK0		; DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
NOTHT:	SETB	4,B		; SELECT UPDATE TO TRACK-REG
	CALL	TYPE$I		; STEP HEAD
	ANI	FDSTK0		; DID THIS STEP PUT US AT TRACK 0 ?
	JRNZ	TRK0ERR
	DCR	L
	JRNZ	SEEK5
	MVI	A,FD$TS 	; SELECT SECTOR REGISTER
	OUT	FD$INT
	IN	FD$SEC		; SAVE CURRENT SECTOR NUMBER
	MOV	L,A
	CALL	READ$ADDR	; GET ACTUAL TRACK UNDER HEAD (IN SECTOR REG)
	MVI	A,FD$TS 	; SECLECT SECTOR REGISTER
	OUT	FD$INT
	IN	FD$SEC		; GET TRACK NUMBER FROM MEDIA
	MOV	H,A
	MOV	A,L
	OUT	FD$SEC		; RESTORE SECTOR NUMBER
	LDA	DSKSTA		; GET TRUE ERROR STATUS OF READ-ADDRESS
	ANI	FDSRNF+FDSCRC	; CRC ERROR + REC-NOT-FOUND
	MOV	A,H		; ACTUAL TRACK FROM READ-ADDRESS
	LXI	H,SEKERR	; POINT TO ERROR COUNTERS
	JRNZ	RESTR0
	CMP	C		; (C) MUST STILL BE VALID DEST. TRACK
	RZ	;NO ERRORS
RTS00:	DCR	M		; SHOULD WE KEEP TRYING ?
	STC
	RZ			; NO, WE'VE TRYED TOO MUCH
	MOV	B,A
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	MOV	A,B
	OUT	FD$TRK		; re-define head position accordingly
	JR	RETRS		; RETRY SEEK

TRK0ERR:
	XRA	A
	LXI	H,SEKERR
	JR	RTS00

RESTR0: INX	H		; RESTORE ERROR COUNT
	DCR	M
	STC
	RZ			; If count 0, return with Carry set.
	MOV	A,M
	CPI	9
	JRNC	RESTR1		; RESTORE ONLY FIRST TIME
	CALL	STEPIN		; OTHERWISE STEP HEAD IN 1 TRACK
	JR	RETRS
RESTR1: 			; RESTORE HEAD TO TRACK 0
	MVI	A,00000011B
	STA	STEPRA		; RETRY WITH MAXIMUM STEP RATE
	CALL	HOME
	JMP	RETRS		; RETRY SEEK

STEPIN: LHLD	MODE
	INX	H		; MODE BYTE 2
	BIT	4,M		; CHECK HALF TRACK BIT
	MVI	B,FDC$STI+FDFHLB; STEP IN WITHOUT UPDATE
	CNZ	TYPE$I		; STEP A SECOND TIME (W/O UPDATE) FOR HALF-TRK
	MVI	B,FDC$STI+FDFHLB+FDFUTR; STEP IN AND UPDATE TRACK REGISTER
	JR	TYPE$I

HOME:	MVI	A,FD$CD 	; SELECT STATUS REGISTER
	OUT	FD$INT
	IN	FD$STA		; GET STATUS
	MOV	B,A
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	MOV	A,B
	ANI	FDSTK0		;TEST TRACK ZERO SENSOR,
	JRNZ	@TRK0		;SKIP ROUTINE IF WE'RE ALREADY AT TRACK 0.
	IN	FD$TRK		;DOES THE SYSTEM THINK WE'RE AT TRACK 0 ??
	ORA	A
	JRNZ	HOME1	;IF IT DOESN'T, ITS PROBEBLY ALRIGHT TO GIVE "RESTORE"
	MVI	L,6 ;(6 TRKS)	;ELSE WE COULD BE IN "NEGATIVE TRACKS" SO...
	MVI	B,FDCSTI+FDFHLB ;WE MUST STEP-IN A FEW TRACKS, LOOKING FOR THE
HOME0:	CALL	TYPE$I		;TRACK ZERO SIGNAL.
	ANI	FDSTK0
	JRNZ	@TRK0
	DCR	L
	JRNZ	HOME0
HOME1:	MVI	B,FDCRST+FDFHLB ;RESTORE COMMAND, WITH HEADLOAD
	CALL	TYPE$I
	XRI	FDSTK0		;TEST TRACK-0 SIGNAL
	RAR
	RAR
	RAR	;[CY] = 1 IF NOT AT TRACK 0
@TRK0:	MVI	A,0
	OUT	FD$TRK		;MAKE SURE EVERYONE KNOWS WERE AT TRACK 0
	RET

READ$ADDR:
	LDA	SIDE
	ORI	FDCRDA+FDFDLF	; READ-ADDRESS COMMAND WITH SETTLE DELAY
	JR	PUT$I		; IGNORE DATA (AND DATA-LOST ERROR)

TYPE$I: LDA	STEPRA
	ORA	B
PUT$I:	MOV	B,A
	MVI	A,FD$CD 	; SELECT COMMAND/STATUS PORT
	OUT	FD$INT
	MOV	A,B
	DI			; prevent interrupt routines
	OUT	FD$CMD		; SEND command TO CONTROLLER
WB:	IN	FD$STA		; WAIT FOR BUSY SIGNAL
	RAR			; TO COME UP
	JRNC	WB
WNB:	IN	FD$STA		; poll controller for function-complete
	RAR			; Busy?
	JRC	WNB		; wait until not busy.
	RAL
	STA	DSKSTA		;SAVE TYPE$II (III) STATUS FOR ERROR DETECTION.
	MVI	A,FDCFI 	;TERMINATE COMMAND (RESET STATUS TO TYPE 1)
	OUT	FD$CMD 
	EI			; re-enable interrupts.
	IN	FD$DAT
	IN	FD$STA		; MUST RETURN WITH STATUS IN ACC.
	RET

SELECT: LDA	RDYFLG		; NEED TO CHECK FOR READY ?
	ORA	A
	CZ	CHKRDY
	RC			; ERROR IF NOT READY
	MVI	A,0FFH
	STA	RDYFLG		; FLAG DRIVE AS READY
	LHLD	MODE		; point to drive mode byte table
	INX	H
	LDA	RELDSK
	MOV	C,A
	MOV	A,M
	ANI	00000011B	; setup steprate bits for seek-restore commands
	STA	STEPRA		; RATE FOR SUBSEQUENT SEEK/RESTORE
	LXI	H,LOGDSK	; save position (track) of current drive
	MOV	E,M		; in 'trks' array addressed by contents of
	MOV	M,C		; location 'logdsk'.
	MVI	B,0
	MOV	D,B
	LXI	H,TRKS
	DAD	D
	MVI	A,FD$TS 	; SELECT TRACK REGISTER
	OUT	FD$INT
	IN	FD$TRK
	MOV	M,A		; SAVE CURRENT TRACK #
	LXI	H,TRKS		; identify position (track) of requested drive
	DAD	B		; from 'trks' array addressed by new 'logdsk'.
	MOV	A,M
	OUT	FD$TRK		; set track number
	RET

CHKRDY: CALL	ON$H37		; TURN ON DRIVE
	CALL	WAIT		; WAIT 'TIL UP TO SPEED
	MVI	A,FD$CD 	; ACCESS C/D REGS
	OUT	FD$INT
	MVI	A,FDCFI+FDFINI	; FORCE TYPE I STATUS
	OUT	FD$CMD
	MVI	A,10
RDYH37B:
	DCR	A		; DELAY A WHILE TO LET CONTROLLER SETTLE
	JRNZ	RDYH37B
	EI
	LXI	H,?CLOCK	; GET TIME VALUE
	MVI	A,200
	ADD	M
	MOV	B,A		; (B) = TIME VALUE
	MVI	C,0		; (C) = HOLE COUNTER
	MOV	D,C		; (D) = INIT HOLE STATUS TO NO HOLE
RDYH37C:
	IN	FD$STA		; GET HOLE STATUS
	ANI	FDSIND
	CMP	D		; CHECK IF CHANGE IN STATUS
	JRZ	RDYH37D 	; BR IF NO CHANGE
	MOV	D,A		; SAVE NEW STATUS
	INR	C		; COUNT TRANSITION
	MVI	A,FDHDD
RDYH37C1:
	DCR	A
	JRNZ	RDYH37C1
RDYH37D:
	MOV	A,B		; CHECK IF TIME UP
	CMP	M
	JRNZ	RDYH37C 	; BR IF NOT
	MOV	A,C		; TIME UP -- CHECK # OF HOLES
	CPI	1*2
	RC			; IF < 1 THEN ERROR
	CPI	3*2+1		; IF <=3 THEN OK
	CMC
	RET 

ON$H37:
	LXI	H,0
	SHLD	DLYMO37
	LDA	RELDSK
	MVI	B,4
	MVI	C,CONDS0	; START WITH DRIVE 0 BIT POSITION
DRVL:	DCR	A
	JM	GDRIVE
	RLCR	C		; DRIVE SELECT CODE IN REG. C
	DJNZ	DRVL
	MVI	C,0		; NO DRIVE SELECTED
GDRIVE: LHLD	MODE
	INX	H
	MOV	A,M
	ANI	MODEDD
	JRZ	ONH37A		; BR IF SINGLE
	MVI	A,CONMFM	; SET DOUBLE DENSITY CONTROL FLAG
ONH37A: ORA	C		; OR IN UNIT SELECT
	ORI	CONMO		; OR THE MOTOR ON
	OUT	FD$CON
	MOV	B,A
	LXI	H,H37CTL	; GET CURRENT VALUE OF THE CONTROL PROT
	MOV	A,M
	ANI	CONMO		; IF THE MOTOR WAS ON
	JRNZ	ONH37B		; THEN WE DON'T HAVE TO WAIT FOR IT TO COME UP
	MVI	A,(1000+3)/4+1	; NORMAL TIMING (APPROX 1 SECOND)
	JR	ONH37C
ONH37B	MOV	A,M		; GET THE OLD VALUE OF THE CONTROL PORT
	ANI	CONDS0+CONDS1+CONDS2+CONDS3	; CHECK SELECT DRIVE(S)
	ANA	B		; CHECK TO SEE IF SAME HEAD ALREADY DOWN
	MVI	A,0
	JRNZ	ONH37C		; YES, ALREADY LOADED, NO DELAY
	MVI	A,(50+3)/4+1	; MUST DELAY FOR HEAD LOAD
ONH37C: STA	DLYW
	MOV	M,B		; SET NEW VALUE OF CONTROL PORT
	RET

HLIHL:	MOV	A,M		; LOAD HL INDIRECT THRU HL
	INX	H
	MOV	H,M
	MOV	L,A
	RET

H37ISR: MVI	A,10
H37ISR1:DCR	A		; DELAY A WHILE TO LET STATUS SETTLE
	JRNZ	H37ISR1
	MVI	A,FD$CD 	; SELECT STATUS REGISTER
	OUT	FD$INT
	IN	FD$STA		; Clear interrupt request
	INX	SP		; TERMINATE SUB-ROUTINE by eliminating the
	INX	SP		; return address PUSHed by the interrupt.
	EI			; turn interrupts back on.
	RET			; end

WAIT:	LDA	?CLOCK
	RAR			; IS IT EVEN, MAKING 4MS BIG TICKS ?
	JRC	WAIT
	LXI	H,DLYW		; CHECK WAIT TIMER
	MOV	A,M		;  AND DECREMENT IF IT IS NOT ALREADY ZERO
	ORA	A
	RZ
	DCR	M
	JR	WAIT

MTR$DLY: 
	LXI	H,DLYMO$37	; POINTER TO MOTOR DELAY TIME FOR H37
	MOV	A,M
	ORA	A		; IF ALREADY ZERO
	RZ
	DCR	M		; DECREMENT TIMER
	JRNZ	TIME$1		;   IF IT HAS NOT TIMED OUT CHECK HEADS
	LDA	H37CTL		; GET THE CURRENT VALUE OF THE CONTROL PORT
	ANI	0FFH-CONMO	; TURN OFF MOTOR
	STA	H37CTL
	OUT	FD$CON
TIME$1: INX	H		; POINT TO THE HEAD DELAY FOR H37
	MOV	A,M
	ORA	A		; IF ALREADY ZERO
	RZ			;   THEN DON'T DECREMENT
	DCR	M		; DECREMENT TIMER
	RNZ			;   IF IT HAS NOT TIMED OUT THEN SKIP
	LDA	H37CTL		; DESELECT THE DRIVE
	ANI	0FFH-CONDS0-CONDS1-CONDS2-CONDS3
	STA	H37CTL	  
	OUT	FD$CON
	XRA	A
	STA	RDYFLG		; FLAG DRIVE AS NOT READY
	RET

RDYFLG: DB	0
DLYW:	DB	0
TPS:	DB	0		; TRACKS PER SIDE
STEPRA	DB	0		; STEP RATE CODE 
RETRYS	DB	0
SEKERR	DB	0,0		; SEEK,RESTORE ERROR COUNTS
MODE	DW	0		; POINTER TO MODE BYTE
RELDSK	DB	0		; DRIVE # RELATIVE TO 0
LOGDSK	DB	4		; CURRENT DRIVE SELECTED BY THIS MODULE
SIDE	DB	0		; SIDE SELECT BIT FOR COMMANDS
RD$FLAG DB	0
UNALLOC DB	0
BLKMSK	DB	0
HSTDSK	DB	0FFH
HSTTRK	DB	0
HSTSEC	DB	0
REQDSK: DB	0
	DB	0
REQSEC: DB	0
BLKSEC	DB	0
BLCODE	DB	0
OFFSET: DB	0		; OFFSET TO DIRECTORY TRACK
SELERR: DB	0
SELOP:	DB	0FFH
CURDPB: DW	0
MODFLG: DB	0
;	Current head positions for each drive
TRKS:	DB	255,255,255,255,0	

btend	equ	$
	
HSTBUF	DS	1024
CSV	DS	0
ALV	DS	0

	end
