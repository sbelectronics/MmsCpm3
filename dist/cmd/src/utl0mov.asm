	TITLE	'SID UTILITY RELOCATOR 12/26/77'
;
;	THE SID UTILITY RELOCATOR PERFORMS THE MOVE AND RELOCATION
;	REQUIRED TO PLACE THE UTILITY DIRECTLY BELOW THE DEBUGGER.
;
;	THE RELOCATABLE IMAGE IS CREATED BY:
;		(ASSEMBLE THE ORG 000H FILE)
;		MAC X $PP+S
;		(SAVE THE REL-0 HEX FILE)
;		REN X0.HEX=X.HEX
;		(ASSEMBLE THE ORG 100H FILE)
;		MAC X $PZ+R
;		(COMBINE THE REL0 AND REL1 IMAGES)
;		PIP X.HEX=X0.HEX,X.HEX
;		(CREATE THE RELOCATABLE IMAGE)
;		GENMOD X.HEX X.COM
;		(INCLUDE THE RELOCATOR)
;		SID X.COM
;		(THEN NOTE THE LXI ADDRESS FIELD-)
;		L100<CR>
;		(ASSUME THE INSTRUCTION IS LXI D,V)
;		(INCLUDE THE RELOCATOR)
;		IUMOV.HEX
;		R
;		(PATCH THE LXI B)
;		A100<CR>
;		LXI B,V
;		<CR>
;		(NOW SAVE THE IMAGE)
;		G0
;		(CONVERT THE HIGH ADDRESS, AND)
;		SAVE D X.UTL
;		(WHERE D IS THE HIGH ADDRESS IN DECIMAL)
;
	ORG	100H
BDOS	EQU	0005H
MODULE	EQU	200H	;MODULE ADDRESS
;
	LXI	B,0	;ADDRESS FIELD FILLED-IN WHEN MODULE BUILT
	PUSH	B	;USING DDT'S STACK
	LXI	H,BDOS+2;ADDRESS FIELD OF JUMP TO BDOS (TOP MEMORY)
;	CHECK LEAST SIGNIFICANT BYTE OF SIZE FIELD
	MOV	A,C
	ORA	A	;ZERO FLAG SET IF = 00H
	MOV	A,M	;A HAS HIGH ORDER ADDRESS OF MEMORY TOP
	JZ	NODEC
	DCR	A	;PAGE DIRECTLY BELOW BDOS
NODEC:	SUB	B	;A HAS HIGH ORDER ADDRESS OF RELOC AREA
	MOV	D,A
	MVI	E,0	;D,E ADDRESSES BASE OF RELOC AREA
	PUSH	D	;SAVE FOR RELOCATION BELOW
;
	LXI	H,MODULE;READY FOR THE MOVE
MOVE:	MOV	A,B	;BC=0?
	ORA	C
	JZ	RELOC
	DCX	B	;COUNT MODULE SIZE DOWN TO ZERO
	MOV	A,M	;GET NEXT ABSOLUTE LOCATION
	STAX	D	;PLACE IT INTO THE RELOC AREA
	INX	D
	INX	H
	JMP	MOVE
;
RELOC:	;STORAGE MOVED, READY FOR RELOCATION
;	HL ADDRESSES BEGINNING OF THE BIT MAP FOR RELOCATION
	POP	D	;RECALL BASE OF RELOCATION AREA
	POP	B	;RECALL MODULE LENGTH
	PUSH	H	;SAVE BIT MAP BASE IN STACK
	MOV	H,D	;RELOCATION BIAS IS IN D
;
REL0:	MOV	A,B	;BC=0?
	ORA	C
	JZ	ENDREL
;
;	NOT END OF THE RELOCATION, MAY BE INTO NEXT BYTE OF BIT MAP
	DCX	B	;COUNT LENGTH DOWN
	MOV	A,E
	ANI	111B	;0 CAUSES FETCH OF NEXT BYTE
	JNZ	REL1
;	FETCH BIT MAP FROM STACKED ADDRESS
	XTHL
	MOV	A,M	;NEXT 8 BITS OF MAP
	INX	H
	XTHL		;BASE ADDRESS GOES BACK TO STACK
	MOV	L,A	;L HOLDS THE MAP AS WE PROCESS 8 LOCATIONS
REL1:	MOV	A,L
	RAL		;CY SET TO 1 IF RELOCATION NECESSARY
	MOV	L,A	;BACK TO L FOR NEXT TIME AROUND
	JNC	REL2	;SKIP RELOCATION IF CY=0
;
;	CURRENT ADDRESS REQUIRES RELOCATION
	LDAX	D
	ADD	H	;APPLY BIAS IN H
	STAX	D
REL2:	INX	D	;TO NEXT ADDRESS
	JMP	REL0	;FOR ANOTHER BYTE TO RELOCATE
;
ENDREL:	;END OF RELOCATION
	POP	D	;CLEAR STACKED ADDRESS
	MVI	L,0
;	HL IS THE MODULE ADDRESS - GO THERE TO ALTER BRANCHES
	PCHL		;GONE...
	END
