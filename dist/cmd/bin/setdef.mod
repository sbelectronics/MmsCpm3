 SETDEF   R  ��   BDISK � BUFF � BUFFA P CMDRV   CPU | CR m DOLLA \ FCB l FCB16 \ FCBA \ IFCB \ IFCBA  IOBYTE S LEN0 V LEN1  MAXB  MEMSIZ  MON1  MON2  MON2A  MON3 n PARMA Q PASS0 T PASS1  RO } RR } RRECA  RRECO \ SFCB � TBUFF <Y �PLM �@P0014 �@P0015 �@P0016 �@P0017 �@P0029 �@P0030 @P0101 @P0102 �}   1  ��                                                          CP/M Version 3.0COPYRIGHT 1982, DIGITAL RESEARCH151282   .$  �$  � y  654321@ MCD80Aev   BDISK � BUFF � BUFFA P CMDRV   CPU | CR m DOLLA \ FCB l FCB16 \ FCBA \ IFCB \ IFCBA  IOBYTE S LEN0 'w  V LEN1  MAXB  MEMSIZ  MON1  MON2  MON2A  MON3   OFFSET n PARMA Q PASS0 T PASS1  RO } RR } RRECA �   RRECO \ SFCB � TBUFF Y SETDEF'   MEMORY ��   
DRIVETABLE  
ORDERTABLE  DRIVE 
 	TEMPDRIVE  CCPFLAG1  CCPFLAG2  CONWIDTH  I  BEGINBUFFER  	BUFLENGTH  	SHOWDRIVE  	SHOWORDER  SHOWTEMP  SHOWPAGE  SHOWDISPLAY  SCBPD Z � OPTIONS � OPTIONSOFFSET � DRIVES � DRIVESOFFSET ENDLIST 
DELIMITERS SPACE @  J  BUFPTR  INDEX  ENDBUF   	DELIMITER ! ENDOFSTRING � �PLM �	PRINTCHAR �
 " CHAR � �PRINTBUF � # BUFFERADDRESS � �VERSION �
GETSCBBYTE  % OFFSET � �
SETSCBBYTE � & OFFSET ' VALUE ; 	SEPARATOR  ( 	CHARACTER ) K � LOOP I
OPTSCANNER $� * LISTPTR , OFFPTR . IDXPTR 0 I 1 J 2 WRDPOS 3 	CHARACTER 4 LETTERINWORD 5 
FOUNDFIRST 6 START 7 	SAVEINDEX 8 LENNEW 9 LENFOUND : VALID � oCHECKINLIST , ; I `g �SETUP �
TESTLETTER #SKIP 	EATBLANKS �EXIT1 �GOOD �NEXTOPT ?FINISHED �CRLF �ERROR �M < CODE = I > J ? NLINES @ REM A 	STRINGPTR C 
TSTRINGPTR E 	CAROTFLAG � �PRINTCOMMAND Q
 F SIZE ] VDISPLAYPATH 0) G I H DISPLAYFLAG I PGMODE J ORDER � '
PROCESSDRIVES � K I L CT e PROCESSOPTIONS q M FIRSTSUB N PAREN O VAL 	 �
INPUTFOUND  P 	BUFFERADR �   �  �  �  �  �  �D � TEMPORARY~ORDER~PAGE~DISPLAY~NO~COM~SUB~NOPAGE~NODISPLAY~ON~OFF�� �  
 $(/9<?�6 � *~A:~B:~C:~D:~E:~F:~G:~H:~I:~J:~K:~L:~M:~N:~O:~P:�� �   #&),/1, ��  []=, ./;() �� �   � ! ~T Error at the '^'; $ 2Error at end of line; $$ IMore than four drives specified$� iInvalid delimiter$� {Invalid drive$F" �Invalid type for ORDER option$� �Invalid option$� �End of line expected$�' �Drive defined twice in search path$c  �Invalid ORDER specification$� 
Must be ON or OFF$j Drive Search Path:
$0 1st$� 4nd$� 7rd$� :th$� = Drive            - $� RDefault$� ZSearch Order         - $~ rCOM$z vCOM, SUB$; SUB, COM$2 �Temporary Drive      - $E �Default$b �Console Page Mode    - $- �On$O �Off$� �Program Name Display - $ �Off$� �On$, �Requires CP/M 3.0$� �* 
 �, �-  �!" q*" & �� �w$ ��f �. 
 �0 �1 � �!$ p+q*# �	� ��$ ��D �2 �
 �3 �4 � �  � �T �5 � �7 �8 �9 �: b �!% q:% 2 ! 6  1� �2$ �����Z �; � �> �? @ 	A B �& �!' s+q:& 2 ! 6�*' & "  1� ɾ$ 
����� C �" E F *G -H =I AJ EK HL �; !( q!) 6*) & 	
��-> �*) & 	:( ��A:) �!) 4���$ F;3(!�$ B>7. IM W oP - I!/ r+s+p+q+��p+q�b$ J�2 oR uS �T �U �V �W �X �Y �Z �[ �\ �] �Z o:6 2; O *, 	~22 *2 & �** :�ʿ!; 4*. :; w*2 & �** :3 �®�*; & �*, ~22 À*. 6 ��$ ����7$# ������������~ysp� �^ � �_ �` �a �b �c �d �" �* ~23 �o:2 24 !0 6* #~23 �4$ �$ �������� �e �" �f �g �h �i j k l "m GD �!4 4N ** 	:! ���!: 6 �*4 & �** :3 ��!: 6 !0 4N * 	~23 ��$	 ���$  �����e #n Z. #o 1p ;q Pr Ts _t iu lv rw ~x y �` #*0 & �* ~23 *3 M�2  :  ���>!  ���H��l!0 4N * 	~23 *3 M�2  �;:0 2  ��#�+s#rɟ$ vjdN6�$! spmg`]XQE<92/*$� z � | �} �~ � �  * N�2  !�* #" ��s$ �����$ ������ Z� ]� b� e� n� u� � �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� ��  � � � � � &� )� 0� 3� 6� ;� >� ?� F� T� W� _� i� n� o� �Z�!6 6 ��*. ~� ʯ*. ~26 *3 M�2  !: 6:  � ¦��:: ڙé*3 M�2  Äù���e:0 2 �#�:0 2 29 *. ~27 !: 6 *. ~26 ��*. ~� ���?*. N �! 	�*, �*, 	�
�=28 !9 ���3!: 6!1 6:9 !1 ��0��:: �)��!1 4��6��*. 6 �#�*. :7 w:  ���+s#r�:  � �i* #" �n!  6�$? Mg]U<41.'$�������������zlc[�$W jd`XJGC@7* 	��������������������}vsof^� �� � �� �� �� � �ͯ
ͯ�O$ ��� �� � �� D �!< qw$ �%> �� �� � � � � %� 2� 7� <� ?� D� K� R� U� Yo �!F q!> 6:F !> ��*A Nͯ*A #"A !> 4��͛!> 6:F !> ��R*C  ���?!E 6^ͯ�D ͯ*C #"C !> 4�͛�$ ,SPB=:0#�_$% LIE3)&
������� �� �� �� �� �� �� �� �� � � � !� 0� 6� =� D� K� R� [� a� i� l� |� �� �� �� �� �� �� �� �� �� �� �� �� pE�!E 6 * "A "C ��2 : �(��! 6(* & �* & ��!? s* & ����!@ s:< ����:< ����H��* +" �:  �+�+s#r͛!= 6:? != ��D*A "C * M��!= 4�&*@ M��:E �[Ϳ�a2Ϳ: �A�l͛*< M !�		^#V��IͿ��iͿ��{Ϳ���Ϳ���Ϳ���Ϳ���Ϳ���Ϳ��
Ϳ��|��������͛   � �4$w ��������������������������������������}sjg_\YVSPIB;.��\$= mbLE>741*'"
��������������� V� �V� ^� f� n� v� ~� �� �� �� �� �� �� � ����� 						 	
/	8	H	M	M	P	T	W	W	^	a	g	w	�	�	�	�	�	�	 �	!�	"�	#�	$�	%�	'�	(�	)�	*�	+�	-�	.�	/�	0�	1�	2�	3
5
6
7
8
9#
:#
;&
<��VL��2 M��2 N��2 O��2	 P��2
 ,��2I ��2 : �2H : ���2J : �W	͛Ϳ!G 6 *G &  	~������:G ���H��W	:G �1Oͯ*G M !			^#V��1Ϳ�	4Ϳ�	7Ϳ�	:Ϳ�	�� 			=Ϳ*G &  	~� �8	RͿ�M	*G &  	>@�Oͯ:ͯ͛!G 4ø: Ҙ	͛ZͿ*J M !�			^#V��rͿØ	vͿØ	ͿØ	w	�	�	: ��	͛�Ϳ>!
 �Ҷ	!
 6 :
 � ��	�Ϳ��	:
 �@Oͯ:ͯ: ��	͛�Ϳ:I � ��	�Ϳ��	�Ϳ: �#
͛�Ϳ:H � �
�Ϳ�#
�Ϳ͛�]$� $
!










�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	�	~	{	x	n	e	b	_	\	U	N	K	F	6	3	0	-									
				���������������yqiaY	$G 
�	�	�	�	�	�	�	�	h	X	Q	>	9	&	!	�������������|tld\� '
=�b '
?,
@1
A6
BD
CO
DV
E[
Fs
G�
H�
I�
J�
K�
L�
M�
N�
O�
P�
Q�
R�
S�
T�
UV � '
! 6! 6 !  6 !K 6 >!K ��V
*K &   	6�!K 4�;
!L 6 :  �����:  �����H���
� � � �I>!L �Ҏ
 ͦ: � 
ͦ!K 6 >!K ���
*K &   	: =�¿
ͦ!K 4 
: =*L &   	w!L 4�[
!K 6 >!K ��:K �L*K &   	^O��!K 4��
��$' �
�
�
�
�
�
�
�
�
�
�
~
{
t
q
T
B
�$? �
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
�
x
e
\
W
P
J
E
>
7
2
-
(
$ W��Z[!\&]3^C_K`KaPbXc]djerfwg�h�i�j�k�l�m�n�o�p�q�s�t�u�v�w�x�yz{|+}0~@�M�e�j�r����������������������������������������� �%�-�:�B�J�R�W�W�`�i�l�l�v�~������������������������������� ������#�+�3�<�<�?�G�O�O�T�[�b�e�e�j�r�z�������������F�:  �����:  �����H�ұ! 6 !  6� � � �I* M !�		^#V��ͦî! 6:  ��]ͦ� � � �I: � �wͦ: =_P��î! 6!M 6 #6 :  �ʞͦ* ~� ���~�	���H�ҿ* #" Þ* ~�(��!N 6* #" � � � �I: �����: �����H���ͦ: ��!M 6: �2 :  �
���:N /�H�!M ��0ͦ:  �
���!N �҇� � � �I: �����: �����H��jͦ: �2 : ���!M �҇ͦ��2 : � ¢: ��2 ê: �2 : � ½: ��2 ��: �2 * ���:N ��:  �
��ͦ��* #" ��:  �
��ͦ* ~�]���~� ���H��!  6î! 6!O 6 :  ��W� � � �I: �
�W: ��R!O 6��Wͦ*O �,��*O �-��î! 6!O 6:  �¨� � � �I: �
ʨ: �£!O 6 èͦ��2 :O ��: �2 ��: ��2 * ���î� � � �I: �����: �����H�� ͦ: ��! 6�,���-���<! 6��2 : ��2 * ���îͦîͦî! 6�,���-��î! 6��2 : ��2 * ���îͦîͦîCK�l�?GOe����u$� �������������������mc`YMJEB=:&����������������|jg^UPH@85.+���������������hcKHA>.)�����������uphe^[VIF:1.'�$� {xspfP41,)	��������������wrmaXKC;2&!������������������{spkWNE91$��������������xkbQL4+"T ��U ��������������d; �!Q p+q*P ~� ���~�	���H���*P #"P ø*P ~� ��> �>�ɧ$	 ���!$ ������r ������$�$�.�1�9�9�>�M�Q�T�e�k�p�{������������ ����� �1  1  ��}�0����|����H��$�Ϳ   � � Ͳ�9�V   � ! 6* & � 	~� �T! 4�>! 6 #6 #6 #6 #6 !� " +~2 �* & �	" * & 	~�[* #" �â�'
:  �¢��V   � �v?$% �������RK/,(��$ ���|yrniUN?:�$ ��� ��_ ��o�gɯ# �DM!  >�)�)덑o|�g�	�=���+$ � o& �o�g� �� �