********** BOOT MODULE LOADER ROUTINE **********
**********  FOR GIDE (ATA) DRIVES     **********
************************************************
VERS	EQU	'1 '		; June 29, 2019 07:34 drm "BIDEBOT.ASM"
************************************************
********** MACRO ASSEMBLER DIRECTIVES **********
	MACLIB	z80
	$-MACRO
************************************************

************************************************
********** PORTS AND CONSTANTS *****************
************************************************
?PORT	EQU	0F2H
?STACK	EQU	2680H
BASE$PORT EQU	2150H		; PORT ADDRESS SAVED BY BOOT PROM
SEGOFF	EQU	2156H		; setup by GIDE boot code in ROM
BTDRV	EQU	2034H		; BOOT DRIVE NUMBER SAVED BY PROM
BOOT	EQU	2280H		; ADDRESS TO LOAD BOOT MODULE INTO
SECTR0	EQU	2280H		; LOCATION OF 'MAGIC SECTOR'
DCTYPE	EQU	SECTR0+3	; DRIVE/CONTROLLER TYPE
ISTRING EQU	SECTR0+13	; CONTROLLER INITIALIZATION STRING
NPART	EQU	SECTR0+19	; NUMBER OF PARTITIONS ON THIS DRIVE
CONTROL EQU	SECTR0+4	; CONTROL BYTE
DRVDATA EQU	SECTR0+5	; DRIVE CHARACTERISTIC DATA
SECTBL	EQU	SECTR0+20	; START OF PARTITION DEFINITION TABLE
DPB	EQU	SECTR0+47	; START OF DPB TABLE
SYSADR	EQU	2377H		; LOCATION IN BOOT MODULE TO PLACE SECTOR
				;  ADDRESS OF OPERATING SYSTEM
DRIV0	EQU	70

GIDE	equ	080h	; GIDE base port
GIDE$DA	equ	GIDE+8	; GIDE data port
GIDE$EF	equ	GIDE+9	; GIDE feature/error register
GIDE$SC	equ	GIDE+10	; GIDE sector count
GIDE$SE	equ	GIDE+11	; GIDE sector number	(lba7:0)
GIDE$CL	equ	GIDE+12	; GIDE cylinder low	(lba15:8)
GIDE$CH	equ	GIDE+13	; GIDE cylinder high	(lba23:16)
GIDE$DH	equ	GIDE+14	; GIDE drive+head	(drive+lba27:24)
GIDE$CS	equ	GIDE+15	; GIDE command/status

ERR	EQU	00000001B
DRQ	EQU	00001000B
RDY	EQU	01000000B
BUSY	EQU	10000000B

;
; STACK OPERATIONS -- GET BOOT STRING
;
	ORG	2480H
	JMP	START
BLCODE: DB	0		; VALUES TO BE PASSED TO BOOT MODULE
LSP:	DB	0
START:
	POP	D		; BOOT ERROR ROUTINE ADDRESS IS LOCATED HERE
	; no need to parse string, ROM did that.
	LXI	SP,?STACK	; SET UP LOCAL STACK
	PUSH	D		;  AND PUSH ADDRESS OF BOOT ERROR ROUTINE

;
; INITIALIZE THE CONTROLLER -- ASSIGN DRIVE TYPE
;
	; nothing to do?

;
; NOW, LOOK AT THE PARAMS TO SEE WHAT PARTITION
; THE USER REQUESTED.
;
	LDA	BTDRV		; BOOT DRIVE FROM PROM DETERMINES LOGICAL
	SUI	DRIV0		; PARTN NUMBER
	LXI	H,NPART
	CMP	M		; RETURN TO BOOT PROMPT IF PARTITION
	RNC			;  NUMBER IS OUT OF RANGE
	LXI	H,SECTBL
	MOV	C,A
	MVI	B,0
	DAD	B
	DAD	B
	DAD	B		; POINT TO SECTOR TABLE ENTRY
;
; GOT CORRECT PARTITION. PREPARE TO READ THE SECTOR
;
	MOV	A,M		; SET UP REGISTERS C,E,D TO CONTAIN SECTOR
	ANI	00011111B	; (EXCLUDE 3 MSB'S - LUN - FROM ROTATION)
	MOV	C,A		;  ADDRESS FOR ROTATION
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	SRLR	C		; ROTATE C:E:D >> 1
	RARR	E
	RARR	D		; 128/sec => 256/sec
	SRLR	C		; ROTATE C:E:D >> 1
	RARR	E
	RARR	D		; 256/sec => 512/sec
	lda	SEGOFF+0	; fixed bits, SEG 27:24
	sta	LBA+0		; save for boot module.
	ori	11100000b	; LBA mode, drive 0, LBA27:24=0
	out	GIDE$DH		; mode, drv, LBA 27:24
	LDA	SEGOFF+1	; SEG 23:16
	ORA	C		; OR IT INTO NEW SECTOR ADDRESS.
	STA	LBA+1
	out	GIDE$CH		; LBA 23:16
	mov	a,e
	STA	LBA+2
	out	GIDE$CL		; LBA 15:8
	mov	a,d
	STA	LBA+3
	out	GIDE$SE		; LBA 7:0
	MVI	A,1
	out	GIDE$SC 	; READ IN 1 SECTOR
	MVI	A,20h
	out	GIDE$CS		; READ COMMAND

;
;  READ IN BOOT MODULE AND JUMP TO IT WHEN DONE
;
load0:	in	GIDE$CS
	bit	7,a		; BUSY
	jrnz	load0
	bit	0,a		; ERR
	rnz
	bit	6,a		; RDY
	rz
	bit	3,a		; DRQ
	jrz	load0
	mvi	c,GIDE$DA
	mvi	b,0
	lxi	h,BOOT
	inir	; 256 bytes
	inir	; 512 bytes - done

	; now that module is loaded, we can overlay LBA to SYSADR
	lxi	h,LBA
	lxi	d,SYSADR
	lxi	b,4
	ldir
	JMP	BOOT

;
;  MISCELLANEOUS STORAGE
;
LBA:	db	0,0,0,0	; temp storage for partn offset.

	END
