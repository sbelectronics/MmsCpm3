VERS	EQU	'5 '		; November 2, 1982  13:24  klf	"Z37.ASM"
; Step rate bug fixed
**********************************************************
;	Disk I/O module for MMS CP/M 2.24
;	on the Heath/Zenith 89
;	for the Zenith Z37 controller
;	Copyright (c) 1981 Magnolia Microsystems
;*********************************************************
	DW	modlen,buflen
 
BASE	EQU	0000H		; ORG FOR RELOCATION
				; alternate 0 and 100h.

	MACLIB Z80
	$-MACRO
;---------------------------------------------------------
;
;	Physical drives are assigned as follows:
;
;	46 - 1st Z37 drive
;	47 - 2nd Z37 drive
;	48 - 3rd Z37 drive
;	49 - 4th Z37 drive
;
;---------------------------------------------------------
;	Ports and Constants
;---------------------------------------------------------
;  PORT ASSIGNMENTS
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
FDCSEK	EQU	010H		; SEEK
FDCSTP	EQU	020H		; STEP
FDCSTI	EQU	040H		; STEP IN
FDCSTO	EQU	060H		; STEP OUT
FDCRDS	EQU	080H		; READ SECTOR
FDCWRS	EQU	0A0H		; WRITE SECTOR
FDCRDA	EQU	0C0H		; READ ADDRESS
FDCRDT	EQU	0E0H		; READ TRACK
FDCWRT	EQU	0F0H		; WRITE TRACK
FDCFI	EQU	0D0H		; FORCE INTERRUPT

;  TYPE 1 COMMAND FLAGS
FDFUTR	EQU	00010000B	; UPDATE TRACK REGISTER
FDFHLB	EQU	00001000B	; HEAD LOAD AT BEGINNING
FDFVRF	EQU	00000100B	; VERIFY FLAGS

;  TYPE 1 COMMAND STEP RATE FLAGS
FDFS6	EQU	00000000B	; STEP RATE 6 MS
FDFS12	EQU	00000001B	;	   12
FDFS20	EQU	00000010B	;	   20
FDFS30	EQU	00000011B	;	   30

;  TYPE 2&3 COMMAND FLAGS
FDFMRF	EQU	00010000B	; MULTIPLE RECORD FLAG
FDFSLF	EQU	00001000B	; SECTOR LENGTH FLAG
FDFDLF	EQU	00000100B	; 30 MS DELAY
FDFSS1	EQU	00000010B	; SELECT SIDE 1
FDFDDM	EQU	00000001B	; DELETED DATA MARK

;  TYPE 4 COMMAND FLAGS
FDFINI	EQU	00000000B	; TERMINATE WITH NO INTERRUPT
FDFII0	EQU	00000001B	; NOT READY TO READY TRANSITION
FDFII1	EQU	00000010B	; READY TO NOT READY TRANSITION
FDFII2	EQU	00000100B	; INDEX PULSE
FDFII3	EQU	00001000B	; IMMEDIATE INTERRUPT

;  STATUS FLAGS
FDSNRD	EQU	10000000B	; NOT READY
FDSWPV	EQU	01000000B	; WRITE PROTECT VIOLATION
FDSHLD	EQU	00100000B	; HEAD IS LOADED
FDSRTE	EQU	00100000B	; RECORD TYPE
FDSWTF	EQU	00100000B	; WRITE FAULT
FDSSEK	EQU	00010000B	; SEEK ERROR
FDSRNF	EQU	00010000B	; RECORD NOT FOUND
FDSCRC	EQU	00001000B	; CRC ERROR
FDSTK0	EQU	00000100B	; FOUND TRACK 0
FDSLDT	EQU	00000100B	; LOST DATA
FDSIND	EQU	00000010B	; INDEX HOLE
FDSBSY	EQU	00000001B	; BUSY

;  INFO RETURNED BY A READ ADDRESS COMMAND
FDRATRK EQU	0		; TRACK
FDRASID EQU	1		; SIDE
FDRASEC EQU	2		; SECTOR
FDRASL	EQU	3		; SECTOR LENGTH
FDRACRC EQU	4		; 2 BYTE CRC
FDRAL	EQU	6		; LENGTH OF READ ADDRESS INFO

;  DISK HEADER SECTOR LENGTH VALUES
FDSL128 EQU	0		; SECTOR LENGTH 128
FDSL256 EQU	1		; SECTOR LENGTH 256
FDSL512 EQU	2		; SECTOR LENGTH 512
FDSL1K	EQU	3		; SECTOR LENGTH 1024

;  CONTROL REGISTER FLAGS
CONIRQ	EQU	00000001B	; ENABLE INT REQ
CONDRQ	EQU	00000010B	; ENABLE DRQ INT / DISABLE SYSTEM INT
CONMFM	EQU	00000100B	; ENABLE MFM
CONMO	EQU	00001000B	; MOTOR(S) ON
CONDS0	EQU	00010000B	; DRIVE 0
CONDS1	EQU	00100000B	; DRIVE 1
CONDS2	EQU	01000000B	; DRIVE 2
CONDS3	EQU	10000000B	; DRIVE 3

;  DISK PARAMETER ENTRY DESCRIPTION
DPHDPB	EQU	10		; DISK PARAMETER BLOCK ADDRESS

;  HEATH EXTENSIONS
DPEH37	EQU	01100000B	; H37
DPEHL	EQU	8		; LENGTH OF HEATH EXTENSION

; MODE BYTES
MOD48RO EQU	00000100B	; BIT 2 -- 48 TPI MEDIA IN 96 TPI DRIVE (R/O)
MODEDD	EQU	01000000B	; BIT 6 -- 0=SINGLE DENSITY 1=DOUBLE
MODE2S	EQU	00000001B	; BIT 0 -- 0=SINGLE DENSITY 1=DOUBLE
TRKUNK	EQU	10000000B	; TRACK POSITION UNKNOWN

;  DISK PARAMETER BLOCK
DPBL	EQU	15		; LENGTH OF DISK PARAMETER BLOCK

;  DISK LABEL DEFINITIONS
LABVER	EQU	0		; CURRENT FORM # FOR LABEL
LABBUF	EQU	0		; SLOT FOR JUMP INSTRUCTION AROUND LABEL
LABEL	EQU	LABBUF+4
LABTYP	EQU	LABEL+0 	; SLOT FOR LABEL TYPE
LABHTH	EQU	LABTYP+1	; SLOT FOR HEATH EXTENSIONS TO DPE
LABDPB	EQU	LABHTH+DPEHL	; SLOT FOR DISK PARAMETER BLOCK
LABCS	EQU	LABDPB+DPBL	; CHECKSUM
LABLEN	EQU	LABCS-LABEL+1	; LABEL LENGTH

;  MISCELLANEOUS VALUES
FDHDD	EQU	20
DELAY37 EQU	6*256+15	; DESELECT AND MOTOR TURN OFF DELAY
H37VEC	EQU	8*4		; LEVEL 4 INTERRUPT
DLYMO37 EQU	H37VEC+3	; MOTOR TURN OFF DELAY COUNTER
DLYH37	EQU	H37VEC+4	; DESELECT DELAY COUNTER
H37CTL	EQU	H37VEC+5	; H37 CONTROL REGISTER IMAGE
H37IRET EQU	H37VEC+6	; WHERE TO GO AFTER INTERRUPT ADDRESS

PORT	EQU	0F2H		; Z89 INTERRUPT CONTROL
PORT1	EQU	0E8H		; SERIAL PORT #1
PORT2	EQU	0E0H		; SERIAL PORT #2
PORT3	EQU	0D8H		; SERIAL PORT #3
PORT4	EQU	0D0H		; SERIAL PORT #4

driv0	equ	46		; first drive in system
ndriv	equ	4		; # of drives is system
DPHL	EQU	16		; LENGTH OF DISK PARAMETER HEADER
DPBL	EQU	15		; LENGTH OF DISK PARAMETER BLOCK
DPHDPB	EQU	10		; LOCATION OF DPB ADDRESS WITHIN DPH
MOD48RO EQU	00000100B	; 48 TPI DISK IN 96 TPI DRIVE (R/O)
MODEDD	EQU	01000000B	; DOUBLE DENSITY
LABLEN	EQU	19H		; LENGTH OF Z37 DISK LABEL
LABEL	EQU	04H		; POSITION OF LABEL IN SECTOR 0
LABHTH	EQU	05H		; START OF "HEATH EXTENSION" IN SECTOR 0
MODE2S	EQU	00000001H	; DOUBLE SIDED
LABDPB	EQU	0DH		; START OF DPB IN SECTOR 0
LABVER	EQU	00		; LABEL VERSION NUMBER
DPEH37	EQU	60H		; I.D.
;--------------------------------------------------------
;	Links to rest of system
;--------------------------------------------------------
PATCH	EQU	BASE+1600H	; Points linker to BIOS overlay operation
MBASE	EQU	BASE		; Base address for module (0h or 0100h)
COMBUF	EQU	BASE+0C000H	; points linker to Common Buffer area
BUFFER	EQU	BASE+0F000H	; points linker to Module buffer area

;-------------------------------------------------------
;	Standard CP/M page-zero assignments
;-------------------------------------------------------
	ORG	0
?CPM		DS	3	; Jump to warm boot routine in BIOS
?DEV$STAT	DS	1	; Iobyte
?LOGIN$DSK	DS	1	; High nybble = user #, low = Drive
?BDOS		DS	3	; Jump to BDOS call 5 routines.
?RST1		DS	3	; Clock servicing routine vector
?CLOCK		DS	2	; Timer values
?INT$BYTE	DS	1
?CTL$BYTE	DS	1
		DS	1
?RST2		DS	8
?RST3		DS	8
?RST4		DS	8
?RST5		DS	8
?RST6		DS	8	; Interrupt routine for DD board
?RST7		DS	8
		DS	28
?FCB		DS	36
?DMA		DS	128
?TPA		DS	0

;-------------------------------------------------------
;	Overlay module information on BIOS
;-------------------------------------------------------
	ORG	PATCH
	DS	51		;JUMP TABLE
DSK$STAT:
	DS	1		; FDC status byte from last disk I/O
STEPR:	DS	1		; MIMI-FLOPPY STEP-RATE
SIDED:	DS	3		; CONFIG CONTROL FOR DRIVES
	DS	4		; FOR EIGHT-INCH REMEX
MIXER:	DB	46,47,48,49
	DS	12
DRIVE$BASE:
	DB	46,50		; first drive, last drive+1
	DW	MBASE		; start of module
	DS	28

TIME$OUT:
	DS	3
NEWBAS	DS	2
NEWDSK	DS	1
NEWTRK	DS	1
NEWSEC	DS	1
HRDTRK	DS	2
DMAA	DS	2

;-------------------------------------------------------
;	Start of relocatable disk I/O module.
;-------------------------------------------------------
	ORG	MBASE		; START OF MODULE

	JMP	SEL$Z37
	JMP	READ$Z37
	JMP	WRITE$Z37

	DB	'Z89-37',0,'Double Density Controller ',0,'2.24'
	DW	VERS
	DB	'$'
DPH:
	DW	0,0,0,0,DIRBUF,DPB46,CSV46,ALV46
	DW	0,0,0,0,DIRBUF,DPB47,CSV47,ALV47
	DW	0,0,0,0,DIRBUF,DPB48,CSV48,ALV48
	DW	0,0,0,0,DIRBUF,DPB49,CSV49,ALV49

DPB46:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000111B	; MODE MASKS

DPB47:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000111B	; MODE MASKS

DPB48:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000111B	; MODE MASKS

DPB49:	DW	36		; SECTORS PER TRACK
	DB	4,15,1		; BSH,BSM,EXM
	DW	83-1,96-1	; DSM-1,DRM-1
	DB	11000000B,0	; AL0,AL1
	DW	24,3		; CKS,OFF
	DB	00000010B,01100011B,00000000B	; MODE BYTES
	DB	11000000B,10000100B,00000111B	; MODE MASKS

**************************************************************************
;									 *
; INIT$COMBO -- SETS UP JUMP TO INTERRUPT ROUTINE IN PAGE 0 OF MEMORY;	 *
;   AND JUMP TO Z37 MOTOR TIME OUT ROUTINE IN BIOS OVERLAY AREA 	 *
;*************************************************************************
 
INIT$Z37:
	MVI	A,1		; FLAG DRIVER AS INITIALIZED
	STA	INIT$FLAG

	MVI	A,(JMP) 	; INSTALL H37 INTERRUPT ROUTINE
	LXI	H,H37ISR
	STA	H37VEC
	SHLD	H37VEC+1

	LXI	H,TIME$OUT	; MOVE JUMP TO Z17 TIME OUT ROUTINE
	LXI	D,TIME$Z17
	LXI	B,3
	LDIR
	LXI	H,MTRDLY	; INSTALL Z37 TIME OUT ROUTINE
	SHLD	TIME$OUT+1
	STA	TIME$OUT	; ACC. STILL CONTAINS (JMP)
	RET

SEL$Z37:
	LDA	PNDWRT		; CLEAR ANY PENDING WRITE
	ORA	A
	CNZ	WR$SEC
	LDA	INIT$FLAG	; INITIALIZE DRIVER IF THIS IS FIRST CALL
	ORA	A
	CZ	INIT$Z37
	XRA	A
	STA	SELERR		; NO SELECT ERROR (YET)
	STA	RDYFLG		; ASSUME DISK NOT READY 
	LDA	NEWDSK		; get drive select code in 'A'.
	SUI	DRIV0		; relate drive number to 0
	STA	RELDSK		; SAVE IT
SEL0:	LXI	H,DPH-DPHL	; POINT TO DPH TABLE
	LXI	D,DPHL
SEL1:	DAD	D
	DCR	A
	JP	SEL1
	LXI	D,DPHDPB
	DAD	D		; POINT TO ADDRESS OF DPB
	CALL	HLIHL		; POINT TO DPB
	SHLD	CURDPB
	LXI	D,DPBL
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
; RETURN TO BIOS
	LDA	RELDSK
	MOV	C,A		; RESTORE PHYSICAL DRIVE #
	LXI	D,DPH		; SELDSK NEEDS START OF DPH TABLE
	RET

LOGIN:	LDA	NEWDSK		; CHECK FOR DISK LOGGED IN
	LXI	B,17
	LXI	H,MIXER
	CCIR
	MVI	A,17
	SUB	C
	MOV	B,A
	LXI	H,PATCH
	LXI	D,0D89H
	ORA	A
	DSBC	D
	CALL	HLIHL
	INX	H
	CALL	HLIHL
	CALL	HLIHL
ROTHL:	RARR	H
	RARR	L
	DJNZ	ROTHL
	RET
;--------------------------------------------------------------------------
; PHYSICAL SELECT ROUTINE -- TO READ DISK LABEL, GET MODE AND DPB INFO,
;   AND CHECK FOR HALF-TRACK
;--------------------------------------------------------------------------
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

;
;  EXTRACT MODE INFORMATION FROM LABEL
;
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
;
;		MOVE LABEL INFO TO DISK PARAMETER BLOCK.
;
	LDED	CURDPB		; GET DPB ADDRESS
	LXI	H,HSTBUF+LABDPB ; GET ADDRESS OF INFO IN LABEL
	LXI	B,DPBL		; COUNT TO MOVE
	LDIR			; MOVE INFO
;
; CHECK FOR HALF-TRACK
;
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

;-------------------------------------------------------------------------
; HI-LEVEL READ/WRITE ROUTINES: THESE ROUTINES PERFORM DEBLOCKING AND
;   DETERMINE WHETHER A PRE-READ IS NECESSARY BEFORE A WRITE
;-------------------------------------------------------------------------
WRALL	EQU	0		; WRITE TO ALLOCATED
WRDIR	EQU	1		; WRITE TO DIRECTORY
WRUNA	EQU	2		; WRITE TO UNALLOCATED
READOP	EQU	3		; READ OPERATION

READ$Z37:
	LDA	PNDWRT		; SECTOR WAITING TO BE WRITTEN ?
	ORA	A
	CNZ	WR$SEC
	MVI	A,READOP	; FLAG A READ OPERATION
	JR	RWOPER

WRITE$Z37:
	MOV	A,C

RWOPER: STA	WRTYPE		; SAVE WRITE TYPE
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

	INR	A		; NON-ZERO VALUE TO ACC.
	STA	RD$FLAG 	; FLAG A PRE-READ
	LDA	WRTYPE
	RAR			; CARRY IS SET ON WRDIR AND READOP
	JRC	ALLOC		; NO NEED TO CHECK FOR UNALLOCATED RECORDS
	RAR			; CARRY IS SET ON WRUNA
	JRNC	CHKUNA
	SDED	URECORD 	; SET UNALLOCATED RECORD #
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
	INR	A		; FLAG A PENDING WRITE (ANY NON-ZERO VALUE)
	STA	PNDWRT
MOVIT3: LDIR			; MOVE IT
	CPI	WRDIR+1 	; CHECK FOR DIRECTORY WRITE (+1 BECAUSE OF INR)
	CZ	WR$SEC		; WRITE THE SECTOR IF IT IS
	XRA	A		; FLAG NO ERROR
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

WR$SEC: XRA	A
	STA	PNDWRT		; FLAG NO PENDING WRITE
	CALL	WRITE		; WRITE A PHYSICAL SECTOR
	RZ			; RETURN IF WRITE WAS SUCCESSFUL
	LDA	WRTYPE
	CPI	READOP		; IGNORE ERROR IF THIS IS A READ OPERATION
	RZ
	JR	RWERR

RD$SEC: CALL	READ		; READ A PHYSICAL SECTOR
	RZ			; RETURN IF SUCCESSFUL
	MVI	A,0FFH		; FLAG BUFFER AS UNKNOWN
	STA	HSTDSK
RWERR:	POP	D		; THROW AWAY TOP OF STACK
	MVI	A,1		; SIGNAL ERROR TO BDOS
	RET			; RETURN TO BDOS (OR RESEL ROUTINE)

;-------------------------------------------------------------------------
; READ: LO-LEVEL I/O ROUTINE
;-------------------------------------------------------------------------
READ:	CALL	ACCESS$R	; START DRIVE AND STEP TO PROPER TRACK
	JC	ERROR
	MVI	B,FDCRDS+FDFSLF ; READ COMMAND W/O SIDE SELECT
	MVI	A,0A2H		; INI INSTRUCTION (2ND BYTE)
	JR	TYPE$II

;------------------------------------------------------------------------
; WRITE: LO-LEVEL I/O ROUTINE						*
;------------------------------------------------------------------------
WRITE:	LHLD	MODE		; CHECK FOR HALF TRACK R/O
	INX	H
	BIT	4,M
	JNZ	ERROR		; R/O ERROR
	CALL	ACCESS$R	; ACCESS DRIVE FOR WRITE
	JC	ERROR
	LDA	DSK$STAT	; GET DISK STATUS BYTE
	RAL
	RAL			; WRITE PROTECT BIT TO CARRY
	JC	ERROR		; WRITE PROTECT ERROR
	MVI	B,FDCWRS+FDFSLF ; WRITE COMMAND W/O SIDE SELECT
	MVI	A,0A3H		; OUTI INSTRUCTION (2ND BYTE)
TYPE$II:
	STA	FIX1+1		;setup physical routines for read/write
RETRY:						     
	PUSH	B		; save registers
	PUSH	D
	LDA	?INT$BYTE	; get interrupt byte
	ANI	11111101B	; Turn 2 millisecond clock off
	OUT	PORT		; to prevent interupts from causing lost-data
	DI
	LXI	H,SERIAL	; TURN OFF INTERRUPTS FROM SERIAL PORTS
	IN	PORT1+1
	MOV	M,A
	INX	H
	IN	PORT2+1
	MOV	M,A
	INX	H
	IN	PORT3+1
	MOV	M,A
	INX	H
	IN	PORT4+1
	MOV	M,A
	XRA	A
	OUT	PORT1+1
	OUT	PORT2+1
	OUT	PORT3+1
	OUT	PORT4+1
	EI

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
	STA	DSK$STAT	; save status of transfer
	LDA	H37CTL	  
	OUT	FD$CON		; TURN OFF INTERRUPTS
	MVI	A,FDCFI
	OUT	FD$CMD		; FORCE TYPE I STATUS

	LDA	?INT$BYTE	; get interrupt byte
	OUT	PORT		; CLOCK ON AGAIN
	DI
	LXI	D,SERIAL	; RESTORE SERIAL PORT INTERRUPTS
	LDAX	D
	OUT	PORT1+1
	INX	D
	LDAX	D
	OUT	PORT2+1
	INX	D
	LDAX	D
	OUT	PORT3+1
	INX	D
	LDAX	D
	OUT	PORT4+1
	EI

	XRA	A		; CLEAR CARRY FOR DSBC
	LXI	D,HSTBUF
	DSBC	D		; HL NOW CONTAINS # OF BYTES TRANSFERRED
	LDA	DSK$STAT	; check for successful transfer
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

;-------------------------------------------------------------------------
; ERROR: RESET PSW/Z TO INDICATE ERROR AND FALL THROUGH TO DONE
; DONE:  SET DELAY VALUES FOR DESELECT AND MOTOR TURN OFF
;-------------------------------------------------------------------------
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

;----------------------------------------------------------------------------
; IO$1024: THIS IS THE I/O LOOP
;----------------------------------------------------------------------------
IO$1024:
	OUT	FD$CMD		; send command to controller
	EI			; turn on interrupts
RW1	HLT			; WAIT FOR DRQ
FIX1	INI			; transfer byte (INI becomes OUTI for writes)
	JR	RW1		; loop until transfer complete.
				; RETURN DONE BY INTERRUPT ROUTINE

;----------------------------------------------------------------------------
; ACCESS$R: PREPARE DRIVE TO READ A SECTOR
;	    - SELECT DRIVE
;	    - SEEK TO DESIRED TRACK
;----------------------------------------------------------------------------
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
	LDA	DSK$STAT	; GET TRUE ERROR STATUS OF READ-ADDRESS
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
;----------------------------------------------------------------------------
; STEPIN: STEP IN ONE TRACK
;----------------------------------------------------------------------------
STEPIN: LHLD	MODE
	INX	H		; MODE BYTE 2
	BIT	4,M		; CHECK HALF TRACK BIT
	MVI	B,FDC$STI+FDFHLB; STEP IN WITHOUT UPDATE
	CNZ	TYPE$I		; STEP A SECOND TIME (W/O UPDATE) FOR HALF-TRK
	MVI	B,FDC$STI+FDFHLB+FDFUTR; STEP IN AND UPDATE TRACK REGISTER
	JR	TYPE$I

;----------------------------------------------------------------------------
; HOME: POSITION HEAD AT TRACK ZERO...
;----------------------------------------------------------------------------
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

;---------------------------------------------------------------------------
; READ$ADDR: READ A SECTOR HEADER OFF THE REQUESTED SIDE
;---------------------------------------------------------------------------
READ$ADDR:
	LDA	SIDE
	ORI	FDCRDA+FDFDLF	; READ-ADDRESS COMMAND WITH SETTLE DELAY
	JR	PUT$I		; IGNORE DATA (AND DATA-LOST ERROR)

;************************************************************************
; TYPE$I -- Send a Type I (Seek/Restore) Command To The Controller	*
; PUT$I -- Entry That Ignores Steprate Bits				*
;************************************************************************
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
	STA	DSK$STAT	;SAVE TYPE$II (III) STATUS FOR ERROR DETECTION.
	MVI	A,FDCFI 	;TERMINATE COMMAND (RESET STATUS TO TYPE 1)
	OUT	FD$CMD 
	EI			; re-enable interrupts.
	IN	FD$DAT
	IN	FD$STA		; MUST RETURN WITH STATUS IN ACC.
	RET

;---------------------------------------------------------------------------
; SELECT: TURN ON MOTOR, SET UP STEP RATE, SET UP CORRENT TRACK NUMBER
;---------------------------------------------------------------------------
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

;************************************************************************
; CHKRDY -- Check for drive ready					*
;************************************************************************
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

;------------------------------------------------------------------
; TURN ON MOTOR, SELECT DRIVE, AND SET SETTLE DELAY COUNTER
;------------------------------------------------------------------
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

;---------------------------------------------------
;	Z37 interrupt service routine.
;---------------------------------------------------
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

;---------------------------------------------------
; Z37 MOTOR TIME OUT ROUTINE
;---------------------------------------------------
MTR$DLY: 
	LXI	H,DLYMO$37	; POINTER TO MOTOR DELAY TIME FOR H37
	MOV	A,M
	ORA	A		; IF ALREADY ZERO
	JRZ	TIME$Z17
DLY1:	DCR	M		; DECREMENT TIMER
	JRNZ	TIME$1		;   IF IT HAS NOT TIMED OUT CHECK HEADS
	LDA	H37CTL		; GET THE CURRENT VALUE OF THE CONTROL PORT
	ANI	0FFH-CONMO	; TURN OFF MOTOR
	STA	H37CTL
	OUT	FD$CON
TIME$1: INX	H		; POINT TO THE HEAD DELAY FOR H37
	MOV	A,M
	ORA	A		; IF ALREADY ZERO
	JRZ	TIME$Z17	;   THEN DON'T DECREMENT
	DCR	M		; DECREMENT TIMER
	JRNZ	TIME$Z17	;   IF IT HAS NOT TIMED OUT THEN SKIP
	LDA	H37CTL		; DESELECT THE DRIVE
	ANI	0FFH-CONDS0-CONDS1-CONDS2-CONDS3
	STA	H37CTL	  
	OUT	FD$CON
	XRA	A
	STA	RDYFLG		; FLAG DRIVE AS NOT READY
TIME$Z17:
	RET
	DW	BASE		; TO GENERATE BIT MAP

;-------------------------------------------------------------------------
; MISCELLANEOUS STORAGE
;-------------------------------------------------------------------------
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
WRTYPE	DB	0
RD$FLAG DB	0
URECORD DW	0
UNALLOC DB	0
BLKMSK	DB	0
HSTDSK	DB	0FFH
HSTTRK	DB	0
HSTSEC	DB	0
REQDSK: DB	0
REQTRK: DB	0
REQSEC: DB	0
BLKSEC	DB	0
PNDWRT	DB	0
BLCODE	DB	0
INIT$FLAG:
	DB	0
OFFSET: DB	0		; OFFSET TO DIRECTORY TRACK
SELERR: DB	0
SELOP:	DB	0FFH
CURDPB: DW	0
SERIAL: DB	0,0,0,0
MODFLG: DB	0
;----------------------------------------------------
;	Current head positions for each drive
;----------------------------------------------------
TRKS:	DB	255,255,255,255,0	
	
	REPT	(($+0FFH) AND 0FF00H)-$
	DB	0	
	ENDM

MODLEN	EQU	$-MBASE 

 DB 00100100B,10000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00010101B
 DB 01000000B,00010101B,01000000B,00010101B,01000000B,00010101B,01000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00100001B,00000000B,10010000B,00010010B,01000100B,01001000B,10001001B
 DB 00100001B,00100000B,00100000B,01001000B,00010001B,00100000B,00000010B,01000000B
 DB 10000000B,10010000B,01001000B,10001000B,00100000B,00010000B,00001000B,10010000B
 DB 00000100B,00100100B,10001001B,00100100B,00100100B,00001001B,00100000B,00100100B
 DB 10000010B,00000000B,10001000B,01001000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00010010B,00000010B,00010000B,00100100B,00100000B,00000000B,00000001B
 DB 00000000B,01000000B,00100001B,00001001B,00100010B,00000010B,01000000B,10000001B
 DB 00100000B,00100010B,00100000B,00100100B,01000000B,01000100B,10000000B,00100010B
 DB 01000001B,00000001B,00001001B,00000010B,01001000B,00000001B,00100000B,00000000B
 DB 01000100B,10010000B,00010001B,00100000B,10001000B,00010010B,00000001B,00000010B
 DB 00001001B,00010000B,00010000B,01000000B,10010000B,00001000B,00100100B,10010000B
 DB 10000001B,00000000B,00001000B,00000000B,00000000B,00000000B,00001000B,00100000B
 DB 00000000B,00010000B,10010000B,00000000B,00000100B,00000000B,00000000B,01000010B
 DB 00000100B,00010000B,00000000B,00001001B,00010000B,01001000B,10000100B,10000100B
 DB 00010000B,00000000B,00000000B,01000100B,00100000B,01000000B,00000000B,00000000B
 DB 00010010B,00000000B,10010000B,00000000B,00000000B,00000001B,00000000B,10000000B
 DB 00000000B,01000000B,00000010B,00001000B,00000000B,00000000B,01000000B,00000001B
 DB 00000010B,01001001B,00000001B,00000000B,00000000B,00000000B,00000001B,00000000B
 DB 00010000B,00000000B,10000001B,00000000B,00000000B,00000001B,00000000B,00001000B
 DB 10000010B,01000100B,00001001B,00000001B,00000000B,00100000B,00100100B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,10000000B,10000000B
 DB 01000000B,00000000B,00000000B,00000000B,00000000B,10000000B,00000000B,00000000B
 DB 00000001B,00000000B,00000000B,00000000B,00000000B,00000000B,00000001B,00100000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B
 DB 00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B,00000000B

;--------------------------------------------------
;	Common Buffers
;--------------------------------------------------
	ORG	COMBUF	
	DS	20	
	DS	64	
	DS	2	
DIRBUF	DS	128
;
;-----------------------------------------------
;	Local Buffers
;-----------------------------------------------
	ORG	BUFFER
HSTBUF	DS	1024
CSV46	DS	64
ALV46	DS	50
CSV47	DS	64
ALV47	DS	50
CSV48	DS	64
ALV48	DS	50
CSV49	DS	64
ALV49	DS	50
;-------------------------------------------------------
BUFLEN	EQU	$-BUFFER
	END
