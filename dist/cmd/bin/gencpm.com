1T�d �                                                      CP/M Version 3.0COPYRIGHT 1982, DIGITAL RESEARCH151282    6543210123456789ABCDEF
ERROR:  $Reading file:  $Writing file:  $Directory full$Reading file: $Writing file:  $Invalid drive.$) ? $) ? $) ? $Bad character, re-enter $   
 $
 Disk read error:  $File cannot fit into GENCPM buffer:  $Unable to open:  $BDOS3   BIOS3            
Setting up directory hash tables:
$ Enable hashing for drive $: $Unable to allocate space for hash table.$
Setting up Allocation vector for drive $
Setting up Checksum vector for drive $
*** Bank 1 and Common are not included ***
*** in the memory segment table.       ***

$Number of memory segments $
CP/M 3 Base,size,bank ($)
$
Enter memory segment table:
$ Base,size,bank $Zero length segment not allowed.$Bank one not allowed.$
ERROR:  Memory conflict - segment trimmed.
$Memory conflict - cannot trim segment.$
ERROR:  Memory conflict - segment trimmed.
$
ERROR:  Memory conflict - segment trimmed.
$ CP/M 3 Sys   $ Memseg No. $  Bank $
Accept new memory segment table entries $Default entries are shown in (parens).
Default base is Hex, precede entry with # for decimal
$
Use GENCPM.DAT for defaults $Create a new GENCPM.DAT file $Display Load Map at Cold Boot $Number of console columns $Number of lines in console page $Backspace echoes erased character $Rubout echoes erased character $Initial default drive ($:) ? $Top page of memory $Bank switched memory $Common memory base page $Long error messages $Double allocation vectors $Accept new system definition $

CP/M 3.0 System Generation
Copyright (C) 1982, Digital Research

$
 BNKBIOS3 SPR$BIOS3    SPR$BNKBIOS3 SPR$BDOS3    SPR$RESBDOS3 SPR$BNKBDOS3 SPR$
 64K TPA
Copyright (C) 1982, Digital Research

*** CP/M 3.0 SYSTEM GENERATION DONE ***$   � �!�Tq:U�M*�T& �� �!�Tp+q:U�d*�T�	� �!�Tp+q*�T#6 :UҀ:�Tڀ�*�T�
� *�T#N ! 	�*�T6 ��7
�7�!�Tr+s+q+��q�!U6���N*�TDM�N:�T����T�N͜:�T���.:�T/!U���!] 6 !m 6 � �!�Tp+q *�T	6   *�T	6 *�T�� �!�Tp+q*�T�� �!�Tp+q*�T�� �!�Tp+q*�T�� � �]	���ͧ�!�Tp+q*�T�� � �}	���ͧ�!�Tp+q*�T�� ��	��� ͧ  *�T	6 �!�Tp+q*�T�� �!�Tp+q*�T�!� � ��	���ͧ�!�Tp+q*�T�"� � ��	���ͧ�! Up+q*�T�$� �!�Vr+s+p+q+��q�:�V� �
�*�V�*�VDM*�V��
-�-
�!�Vs+p+q:�V� �J
*�V�*�VM!�V�LS��!�Vq:�V� �e
>�:�V�a�/�>z!�V��/�H�҄
:�V�_2�V:�V�!�Vq:�V� �/�>!�V��/�H�Ҧ
>�� �� ͧ> �!�Vp+q(�7*�V~����
Y�7��
N�7��N�T�e:�T� ��
�*�TM�V
�Y��*�Vw�!�Vq:�V��O !�	N�7:�V�O !�	N�7�!�Vp+q �7*�V|O��
*�V}O��
H�7�!�Vq*�V&  �+SDM�$�!�Vp+q!�V6 !�V60!'"�V> �V͇S�*�VM�7��!�V6 >!�V����V�V�zSڽ!�V6�:�V<2�V�V�V�zS�+s#rÔ:�V��*�VM�7!�V60*�V�!
 �S�"�V:�V<2�V�!�Vs+q(�7:�V�
�#�7*�V& DM�Z�*�VM��
��N�!�Vs+p+q+��p+q��
:�T� �:͜�*�V6 :�V<2�VO !�T	N�V
2�V��:�V�,�u*�V#"�V*�V6 !�V6�:�V�#!�V6
�:�V�02�V:�V����>	!�V���H�ҽ>!�V�Ҹ:�V�2�Vý!�V6�!�V:�V���*�V^ *�V& �+S�*�V& �	�*�V�q�!�V6 *�V6  � ͧ�
*�V6 �?͜�*�VDM�N*�V~� �(�7*�VN��
!�V6>!�V��n*�V#"�V:�V����:-Q/�H��X*�V6 �d,�7*�VN��
:�V<2�V�,*�V++"�V�NÊ*�VN*�V���!�V6!�V6�T�e�!�Vr+s+q:-Q/Ү> �!�V6���#q#p!�V6:5Q!�V�ڳ *�V& �+SFQ	 	��V�zSک:�V��M *�V& �+SFQ	 	~� �� *�V& ��+SFQ	 	��V�zS��H��J:�V2�V *�V& �+SFQ	 	^#V�"�Vé *�V& �+SFQ	 	~� ��� *�V& ��+SFQ	 	��V�zS��H�ҩ:�V2�V *�V& �+SFQ	 	^#V�"�V:�V<2�V¿:�V�����:�V����H��`!�V6:5Q!�V��` *�V& �+SFQ	 	��V�zS�/ *�V& ��+SFQ	 	~� ���H� *�V& ��+SFQ	 	��V�zS��H��V:�V2�V *�V& �+SFQ	 	^#V�"�V:�V<2�V��:�V�!$V6 !U6�ͬ#�Q$��!�H> 	U͇S�ʔ� *	U|2Uß� *U|2U!U:.Q�2�T� *U|!U�O:/Q�2�T� *U|O:�T�2�TUT���I:-Q/�!$V>�O:�T�2�T� *U|O:�T�!$V�2�T�:�T=2�T� *U|O:�T�2�T�Ү� :-Qқ*nV�*U�*�V�	� |!U�O:/Q�2�T� *U|O:�T�2�T��2Uͬ:U/Ҙ!!V6 >!!V�ژ*!V& �$S�Q	 	6 :!V<2!V�sà!U6 :V/ҫ���*:U2�T:�T2�TTͩ:-Q����*�T&  �+SDM*U�������*�T&  �+SDM*U���:-Q/�&:U2!V! ""V*!VM"V͟:!V2U! U6 Û� *U|!U�2!V� *U|!U�o& )##""V��*�T&  �+SDM*!V���*!VM"V͟:!V2 U:U2!V! ""V>��T͇S�+s#r*!VM"V͟:!V2U� *U|!$V�2�T:�T2�TU(T��(Tͩ�C *$V& �+S�T͊S�+s#r� *U|!$V�2!V:-Q/�
��*�T&  �+SDM*!V����"��*�T&  �+SDM*!V���*!VM"V͟:!V!U�w:-QҢ!�T6�:�T2�TULT��LTͩ� *U|2!V� *U|!U�o& )�*"V""V��*�T&  �+SDM*!V���*!VM"V͟:!V! U�w:,Q/Ҳ:V�2V�*V& U	���
:�T��2�T*�T& �!
 �S!0 �*V&  U	�q*�T& �!
 �S0 �*V& !U	�q:V�2V *�T& �+S"!U$�-U��
�RU�W�
!�T6 #6 #6 :.Q2U:/Q2U��TqT�
��TyT�
Uͧ	pT��	!�T6�Uͧ	pT��	pT�	:;Rһ!;R6 :%V2.Q:4Q/24Q��T�T�
��T�T�
�L!U6��N�!�Vr+s+p+q*�V6 *�V#6 *�V|��O !�	�*�V##�
w*�V|�O !�	 �*�V	�w*�V}��O !�	 �*�V	�w*�V}�O !�	 �*�V	�w�!�T:�T�O `i�PS�W	� "�V *�V	:0Qw *�V	:2Qw *�V	:1Qw. *�V	:3Qw*�V	:4Qw�X *�V	� �
:+Q/ҼW *�V	>�*�V	w:<R/�:-Q/�H���W *�V	>@�*�V	w��W *�V	>��*�V	w^ *�V	:/Qw�!)X"�V*�VN#F!�W	"�V*�V"�V*�V��͕S��(!$V6�-!$V6 *�V����S�D*�V�W��R�!������"&V!V6���&V�S���!�V6 >!�V�ڷ*�V& )�*&V> ͒S�ʭ*�V& )�*&V�W��R"(V *(V	��͕S�ʭ!V6 :�V<2�V�f:-Q/!V���!$V6��!$V6 ���V>X�
�W*�V"�V*�V~����> �>���!�Vs+p+q+��p+q�%�N*�VDM�N �7*�VDM�$ �7*�VM�E:,QҨ�*V& U	�*�VDM�
:V�2V*V& U	DM*�V���:V�2V*V& U	�*�V&  �+S����:V�2V�*V& U	�)�
:V�2V�!�Vp+q*�V"TͣN� ����,ͧ*�VDM�	�!�Vr+s+p+q*�V^#V�"�T*�V##^#V�"�T *�V	^#V�"�T�*�V#DM�T�
�	 *�VDM�T�
� *�T�ZSU͊S�@��?ͧ*�T+�ZS}<2�V!�V6 !�V:�V�҆� *�V& �+S�W	"�TDMͧ	*�VDM�>	:�V<2�V�S��*�TDM�O�
�W*�T"�T�!�Vr+s+q:�V� �G��TqT�
��TyT�
*�Vn}2�T*�V#~2�TpT��	�W�T�S} �pS}�T��R�+s#r*�V& )+�!�Vs+6 :�V!�V��4>��T͇S�+s#rBKͧ	pT�^	:�V<2�V�pT��	�*�V��T�
�:-Q/�k�)Tw�
�T�
�z!LT"�V!U"�V͙!T"�V!U"�V͙!(T"�V!U"�V͙��*�V#DM�T�
�	 *�VDM�T�
*�VDM��������eͧ�Wͧ	*�VDM�>	*�V�*�W��s#r*�V##�*�W��s#r *�V	�*�W��s#r*�VDM�>	�!�V6 ��&V�S��(> �!�V6 >!�V���*�V& )�*&V> ͒S���*�V& )�*&V�W��R"(V	�*(V##���
 *(V	��͕S��� *(V	���͕S����H� *(V	���͕S����H� *(V	���͕S����H� *(V	���͕S����H���!�V6�:�V<2�V�-:�V�!�V6 !�V6�!�V6 >!�V���*�V& )�*&V�W��R"(V*�V& )�*&V> ͒S��� *(V	����S�?!�V6  *(V	��͕S���:�V/�c!�V6���N:�V�O !=R	~2�T *(V	�W��R"*V **V	N#F`i))"�V��N:�V�AO�7��N*�V& 6Q	DMʹ
͜*�V& 6Q	~/�� *(V	��q#p��:-Q/�!�V6 *�V& ,V)	�*�V��s#r*�V�*LV"LV��*�V�͛2�V���' �� ͧ�� *�V& �+SFQ	 	 �*(V	�
w *�V& �+SFQ	N `i�PS �*�V& �+SFQ	 	N `i�PS �*�V& �+SFQ	 	�͕S�	 �*(V	�q#p *�V& �+SFQ	 	��V�zS �*�V& �+SFQ	 	�q#p:�V<2�V��:-Q/!�V���!$V6:�T<<2�T:�T<<2�T�!�V6 >!�V��8*�V& NV)	> w#6 *�V& pV)	> w#6 :�V<2�V�:<R/�:-Q/�H��P!�V6�U!�V6!  "nV!  "�V!�V6 !�V6 >!�V�ڡ*�V& )�*&V> ͒S�ʗ*�V& )�*&V�W��R"(V *(V	�W��R"*V *(V	��͕S����N:�V�AO�7:�7!�V6� **V	^#V! �S*�V& �+S�*�V& NV)	�q#p*�V& NV)	nV��R�+s#r *(V	��͕S�'�N:�V�AO�7:�7!�V6� **V	>��R�! �S*�V& pV)	s#r*�V& )	�V��R�+s#r **V	 ���R�*�V& pV)	��CS �**V	�q#p:�V<2�V�k:�Vҫ͜�:�T2FQ!�T:/Q�2GQ!  "IQ!HQ6 !�V6 O�N:GR2�T��
5Q���N*FQM��
,�7*GQM��
,�7*HQM��
��N:�V/҈!��N!�V6:5Q!�V��� !�V6 :�V/�� :�V�=O !=R	~2�T� *�V& �+SFQ	DM� *�V& �+SFQ	 	N `i�PS �*�V& �+SFQ	 	�q#p *�V& �+SFQ	 	~� �� � ͧ��  *�V& �+SFQ	 	~��� �7 ͧ��  *�V& �+SFQ	~2�V*�V&  �*�V& �+SFQ	 	N �	"�V*�V|� ���*�V�}O:/Q���H�҆M�N!�V:/Q� *�V& ��+SFQ	 	�Hq!�V:/Q�O `i�PS �*�V& �+SFQ	 	�q#p�� *�V}2�V!�V6 !�V6�!�V:�V��#���  *�V& �+SFQ	~2�V *�V& �+SFQ	 	:�V�2�V *�V& �+SFQ	 	 �*�V& �+SFQ	 	�
��� !�V:�V��/+�~!�V��/�H��+  �| ͧ!�V6 �� :�V!�V��+�~!�V���H��c ��N *�V& �+SFQ	:�Vw!�V6 �� :�V!�V��+�~!�V���H��� ��N!�V:�V� *�V& ��+SFQ	 	�Hq!�V:�V�O `i�PS �*�V& �+SFQ	 	�q#p!�V6 :�V<2�V×�1:�V<2�V�"͜!�V6 :5Q!�V��o!:�V� �!�N�!�N:�V=O��
 *�V& �+SFQ	N�E *�V& �+SFQ	 	N�E:-Q�b!�N *�V& �+SFQ	 	N��
͜:�V<2�V�� !�T6 !�V6�%�N�Vʹ
�͜�P�N�T��2�V����!��T�T�
��T�T�
��N!�V6��Vʹ
͜:�V��!��F�T�	��!!U6�+6 �! W6 ͌!: W/җ#:�R2�T͜��N;Rʹ
:=R2�T͜͜��N,Qʹ
͜͜:>R2�T:2Q<22Q�
2Q�:2Q=22Q:?R2�T:1Q<21Q'�
1Q�:1Q=21Q:@R2�TH�N3Qʹ
͜:AR2�Tk�N4Qʹ
͜͜:BR2�T��N:0Q�AO�7��N�T�e:�T� ��"*�TM�V
�A2W*WM͈
/��"Þ":W20Q͜͜:CR2�T��.Q�*.Q& �PS "U:DR2�T��N-Qʹ
͜:-Q/2�T:-Q�[#:ER2�T��/Q�͜:FR2�T��N+Qʹ
͜�x#:�R2�T͜�N<Rʹ
͜!/Q6 !�T6 ! W6�͜�N Wʹ
͜��!:.Q2%V:.Q<2.Q:4Q/24Q�:�NpT�.	pT�~	!�T6 !W6 >!W���#*W& U	6 :W<2W��#!W6�>�!W��	$*W& U	6$:W<2W��#!V6��*V& U	���
!V6���TqT�
��TyT�
�Wͧ	pT�^	pT�^	��W �S#�ZS"U!W6 >!W�ڋ$*W& ,V)	> w#6 :W<2W�h$!  "LV:] �A��$!U6�#6 !W6 >�!W���$*W& =R	6 :W<2W¦$��$!U6 #6�:m �D��$!U6�!�T6 �
     Available space in 256 byte pages:
     $TPA =$, Bank 0 =$, Other banks =$Unable to allocate Dir deblocking buffer space.$Unable to allocate Data deblocking buffer space.$Unable to allocate Data deblocking buffer space.$Drive specified has not been defined. $0FFFFH is an invalid value in the
DPH directory BCB address field.$
Setting up Blocking/Deblocking buffers:
$
The physical record size is$:
$     *** Directory buffer required  ***
     *** and allocated for drive $: ***
$               Overlay Directory buffer for drive $: $               Number of directory buffers for drive $: $Minumum number of buffers is 1. $               Number of directory buffers for drive $: $
*** Maximum number of directory buffers ***
*** for the current drive is$.     ***
*** Number of directory buffers reduced ***
*** accordingly.                        ***
$               Share buffer(s) with which drive ($:) ? $     *** Data buffer required and ***
     *** allocated for drive $:   ***
$               Overlay Data buffer for drive $: $               Number of data buffers for drive $: $Minumum number of buffers is 1. $               Number of data buffers for drive $: $               Share buffer(s) with which drive ($:) ? $               Allocate buffers outside of Common $
Accept new buffer definitions $!W6 >!W���**W& )�*&V> ͒S���**W& )�*&V�W��R"(V 	��͕S��� *(V	���͕S����H�Ҹ* *(V	�W��R"*V **V	^� �6
�*W& �$S�Q	�q#p*W& �$S�Q	 	6  *(V	��͕S���*���% ͧ!W4�*!W6 >!W���+!  "HW}2W>!W��=+*W& �$S�Q	�HW�|S�� 	�~� ���H��6+*W& �$S�Q	^#V�"HW!W4��**W& ))lW	�*HW��s#r*W& ))	 	> w#6 !W6 >!W���+*W& �$S�Q	HW�|S����> ͇S�����H���+*W& ))lW	 	�*W� �6
��DS�+s#r*W& �$S�Q	 	6�!W4�h+!W4��*!W6 >!W��7, *W& �+SFQ	 	�*W& W)	�N#F�q#p *W& �+SFQ	 	�*W& 7W	�
w!W4��+:-Q�F,!fW6�K,!fW6!W6 :W�4:fW=2iW!  "gW"dW}2	W!W6�*�T& �PS�*LV�iS"bW:-Qڞ,nVbW�zS�*�V�iS"bW!W6 >!W���,*W& W)	 �*W& �+SKQ	 	�N#F�q#p*W& �$S�Q	 	6 !W4£,!W6 !W6�#6�!W6 n& ))lW	 	^#V�"JW*W& ))lW	> ͒S�����:W���H���3:W�E-1&�N!W6�]&�N*W& ))lW	N#F�${&�N!W6 >JW��R>�fS�����:W���H�Қ-!JW�VS�+s#r!W4�g-!JW�VS�+s#r:W���3*W& )�*&V�W��R"(V 	�W��R"*V 	>��R�ZS"^W **V	 �͕S���-!W6���-!W6  *(V	��͕S��c0�bB*W& �$S�Q	 	>�w:-Q��.:W�d.!W6 *W& �$S�Q	 	6&�N:W�AO�7�&�N��.:W�{O !=R	~2�T�&�N:W�AO�7'�N*W& �$S�Q	 	DMʹ
͜*W& �$S�Q	 	~��.*W& �$S�Q	 	6��.*W& �$S�Q	 	6 �t/:W�;O !=R	~2�T'�N:W�AO�7>'�*W& �$S�Q	 	DM
�:W�t/!W6 *W& �$S�Q	 	~� �t/ �A' ͧb'�N:W�AO�7�'�*W& �$S�Q	 	DM
��&/*W& �$S�Q	 	~^W͇Sҹ/�'�N*^WDM�$�'�N*W& �$S�Q	 	�*^W��s*W& �$S�Q	 	~� �R0:W�[O !=R	~2�TM(�N*W& �$S�Q	 	~�AO�7(�N�T�e:�T� �L0*�TM�V
�A2
W*
WM͈
�*0��/*
WM�F�80��/*W& �$S�Q	 	:
Ww͜�c0*WM�TC� �c0�4 *(V	��͕S��n3!W6 *W& �$S�Q	>�͒S�°0 *(V	��q#p*W& �$S�Q	 	6 �n3�bB*W& �$S�Q	 	>�w:-Qګ1:	W��1:W�1!	W6!W6�*W& �$S�Q	 	6�(�N:W�AO�7�(�N�1:W�1!W6!W6 :W��ʨ1:WƋO !=R	~2�T�(�N:W�AO�7)�N*W& �$S�Q		 	DMʹ
͜*W& �$S�Q		 	~ґ1*W& �$S�Q	 	6 è1*W& �$S�Q	 	6!	W6�S2:W�KO !=R	~2�T)�N:W�AO�76)�*W& �$S�Q	 	DM
�*W& �$S�Q	 	>�w:W�S2!W6 *W& �$S�Q	 	~� �S2 �9) ͧZ)�N:W�AO�7�)�*W& �$S�Q	 	DM
��2*W& �$S�Q	 	~� �$3:WҌ2!W6 *W& �$S�Q	 	:Ww�3:W�kO !=R	~2�T�)�N*W& �$S�Q	 	~�AO�7�)�N�T�e:�T� �	3*�TM�V
�A2
W*
WM͈
��2Ü2*
WM�F��2Ü2*W& �$S�Q	 	:
Ww͜*W& �$S�Q	 	:W�w�n3:U!W��]3:W�+O !=R	~2�T�)�N*W& �$S�Q	 	DMʹ
͜*WM�TC� �n3�4!W6 *W� �6
dW�DS�+s#r!W4>JW��R>�fS�����:W���H�ҿ3!JW�VS�+s#r!W4Ì3!JW�VS�+s#rç-!W4n& ))lW	 	^#V�"JW�-!�T6 !W6�:W�4�bB�)�NWʹ
͜�P,!  "PW}2Wo& "TW2W>!W��u5*W& �$S�Q	 	~� �n5*W& �$S�Q	 �	~� ���� 	�>�����H�һ4:-Q�|4!W4á4*W& �$S�Q	���! ^ �N#F�-S�*TW"TW*W& �$S�Q	 	^ *PW"PW*W& �$S�Q	 �	~� ���� 	�>�����H��n5:-Q�/5!W4*W& �$S�Q	 	~�,5*W& �$S�Q	���! ^ �N#F�-S�*TW"TW�T5*W& �$S�Q	���! ^ �N#F�-S�*TW"TW*W& �$S�Q	 	^ *PW"PW!W4�#4*fW& �*PW�+S�*W& )�	"RW:-Q��9�W*U"jW*RW�*U�*TW�	��*LV�	�*�V�	�*nV�	� |O:.Q�O:�T�2UO:�T�2�T:�T�2�T:�T�2�T��|2U!�T�2.Q�W�"�T*�T& �PS�*U�	"ZW�*RW�	"VW*�T"`W*`W�W	�!�T͕S�C6*`W�W	6 *`W#"`W�6!W6 n& ))lW	 	^#V�"JW*W& ))lW	> ͒S�����:W���H��9!W6 >JW��R>�fS�����:W���H�Ҷ6!JW�VS�+s#r!W4Ã6!JW�VS�+s#r:W���8*W& )�*&V�W��R"(V*W& �$S�Q	 	>��«7*W& �$S�Q	 	~� �h7*jW6�
 *jW	�*VW��s#r*W& �$S�Q	VW��R�+s#r *(V	�*ZW��s#r:fWZW��R�+s#r:fWjW��R�+s#rë7*(V"LW*W& �$S�Q	 	n& )�*&V�W��R"(V 	^#V�"NW*LW"(V	�*NW��s#r*W& �$S�Q	 	>��£8*W& �$S�Q	 	~� �48*jW6�
 *jW	�*VW��s#r*W& �$S�Q	VW��R�+s#r *(V	�*ZW��s#r:fWZW��R�+s#r:fWjW��R�+s#rã8*(V"LW*W& �$S�Q�	 	>�o& )�*&V�W��R"(V�!�Q	 	>�� ʂ8 *(V	^#V�"NWÐ8 *(V	^#V�"NW*LW"(V 	�*NW��s#r!W4>JW��R>�fS�����:W���H���8!JW�VS�+s#r!W4ç8!JW�VS�+s#r��6!W4n& ))lW	 	^#V�"JW�\6!W6 >!W��c9*W& ,V)	> ͒S��\9*W& )�*&V�W��R"(V 	�*VW��s#r*W& ,V)	VW��R�+s#r!W4�
9!W6 >!W���9*W& )�*&V�W��R"(V*W& NV)	> ͒S�ʽ9 *(V	�*VW��s#r*W& NV)	VW��R�+s#r*W& pV)	> ͒S���9 *(V	�*VW��s#r*W& pV)	VW��R�+s#r!W4�h9�aB!W6 >!W��::*W& W)	 �*W& �+SFQ	 	�N#F�q#p!W4�:*�V�*RW�*nV�	"RW> 	U͇S���U��zS����H�҇:*TW�*U� |O:.Q�O:�T�2Uá:*TW�*	U� |O:.Q�O:�T�2U!U:�T�2�T:�T�2�T:�T�2�T:.Q�2.Q*	U} �pS}	U��RU͊S"`W> 	U͇S���U��zS����H��B;� *RW|O:/Q�2�T*U}�pS}U��R�W"\W*�T& �PS"XW*�T& �PS�*U�	"VWÇ;*RW�*`W� |O:/Q�2�T�W*U"\WO `i�PS�*`W�	"XW*�T& �PS�*	U�	"VW*RW�*\W"�T� *U|O:�T�2�T*W& )�*\W"jW*XW"ZW�W�T�S"U*�T"`W*`W�W	�!�T͕S��;*`W�W	6 *`W#"`W��;!W6�!W6 !W6:5Q!W��S< *W& �+SFQ�	 �	�
�2W�!FQ	 	~� ���:W!W���H��L<:W2W:W2W!W4��;:�T2FQ!�T:/Q�2GQ:W����< *W& �+SFQ	 �	�
�O:�T���< *W& �+SFQ�	 �	N `i�PS��! �͕S"`W�!FQ	�:�T�� 	w *W& �+SFQ	 �	N `i�PS�*`W�iS��! �q#p!W6 n& ))lW	 	^#V�"JW*W& ))lW	> ͒S�����:W���H�ғA!W6 >JW��R>�fS�����:W���H��h=!JW�VS�+s#r!W4�5=!JW�VS�+s#r:W��xA*W& )�*&V�W��R"(V*W& �$S�Q	 	>���0?*W& �$S�Q	 	~� �>*(V"LW*W& �$S�Q	 	n& )�*&V�W��R"(V 	^#V�"NW*LW"(V	�*NW��s#r�0?*\W�*ZW��s#r *(V	�*XW��s#r*XW##"XW*\W##"\W!W6*W& �$S�Q	 	~!W��
?*W& �$S�Q	^#V͛2W*jW6� *W& �+SFQ	�N `i�PS��! N `i�PS�! �͕S�	
 �*jW	�q#p *jW	6  *W& �+SFQ	 	�*W& �$S�Q	��|S�+s#r:fWZW��R�+s#r *jW	s#r:fWjW��R�+s#r!W4�6>:fWjW͇S�+s#r! > w#6 :fWjW��R�+s#r*W& �$S�Q	 	>���1A*W& �$S�Q	 	~� ¤?*(V"LW*W& �$S�Q	 	n& )�*&V�W��R"(V 	^#V�"NW*LW"(V	�*NW��s#r�1A*\W�*ZW��s#r *(V	�*XW��s#r*XW##"XW*\W##"\W!W6*W& �$S�Q	 	~!W��A*W& �$S�Q	 	~ҩ@*W& �$S�Q	^#V͛2W*jW6� *W& �+SFQ	�N `i�PS��! N `i�PS�! �͕S�	
 �*jW	�q#p *W& �+SFQ	 	 �*jW	�
w *W& �+SFQ	 	�*W& �$S�Q	��|S�+s#r��@*jW6�
 *jW	�*VW��s#r*W& �$S�Q	VW��R�+s#r *jW	6 :fWZW��R�+s#r *jW	s#r:fWjW��R�+s#r!W4��?:fWjW͇S�+s#r! > w#6 :fWjW��R�+s#r!W4>JW��R>�fS�����:W���H��hA!JW�VS�+s#r!W4�5A!JW�VS�+s#r�u=!W4n& ))lW	 	^#V�"JW�=!W6 >!W���A*W& 7W	 �*W& �+SFQ	 	�
w!W4A!W6 >!W��aB*W& )�*&V�W��R"(V*W& NV)	> ͒S��"B *(V	�*ZW��s#r*W& NV)	ZW��R�+s#r*W& pV)	> ͒S��ZB *(V	�*ZW��s#r*W& pV)	ZW��R�+s#r!W4��A�!  "�W"�W!�W6:5Q!�W���B *�W& �+SFQ	 	~� ¶B *�W& �+SFQ	 	�VS�*�W"�W��B *�W& �+SFQ	 	�VS�*�W"�W!�W4�pB�$�N%�N!bW�VSDM�$:-Q�MC%�N*�WDM�$:U� C$%�N*�WDM�$> �W͇S�����> �W͇S�����H��HC!W6��MC!W6 ͜͜�!�Ws+q*�W& �$S�Q	^#V�"�W:-QڋC:fW�W��RbW͊S�+s#r�F!iW55:�W�®D*�W& �$S�Q	 	~2�W!�W6:�W!�W�ګD!fW:iW��YD!iW6�*gW#"gW!�W6�!�W6 !�W6:5Q!�W��7D *�W& �+SFQ�	 �	�
�2�W�!FQ	 	~� ���:�W!�W���H��0D:�W2�W:�W2�W!�W4��C *�W& �+SFQ	 	� �S�+s#r�cD!fW:iW�2iW*�W�͛2�W��D �4% ͧ> �äD *�W& �+SFQ	 	��W�zS�+s#r!�W4±C�F*�W& �$S�Q	 	~2�W!�W6:�W!�W��F!fW:iW��oE!iW6�*gW#"gW!�W6�!�W6 !�W6:5Q!�W��ME *�W& �+SFQ�	 �	�
�2�W�!FQ	 	~� ���:�W!�W���H��FE:�W2�W:�W2�W!�W4��D *�W& �+SFQ	 	� �S�+s#r�yE!fW:iW�2iW*�W& �$S�Q	 	~ڼE�WbW�zS�+s#r�YS�:/Q�pSҹE �d% ͧ> ���E*�W�͛2�W����E ��% ͧ> ���E *�W& �+SFQ	 	��W�zS�+s#r!�W4��D>��!�Wq*�W� �6
dW��R> �fS��'F> � ��% ͧ>��ERROR:  $ at line $Missing parameter variable$Equals (=) delimiter missing$Invalid drive ignored$Invalid character$Invalid parameter variable$! "�W�Wͧ	!�W6!�W6 :�W�	G��G:�W�G͈K2�W:�W����F�I�G�F �
G��F�!�Wr+s+q:U2�W!U6�5F�N*�WDM�N>F�N*�WDM�Z:�W�CG�.͜:�W2U�:�W��oG!�W6 �T� � �lG!�W6��sG!�W4��MG*�W& �W	~2�W:�W� ���:�W�	���H��:�W�
���H���G:�W�
·G*�W#"�W�MG*�W& �W	~2�WÄG:�W�a�/�>z!�W��/�H���G:�W�_2�W:�W���G!�W6�:�W�!�W6 :�W/�:�W/�H��I!�W6 >!�W��/H*�W& �W	6 !�W4�H�tG2�W!�W6 :�W���:�W�=����H��:�W�����H��:�W/�H��~H*�W& �W	:�Ww�tG2�W!�W4�:H:�W�=����:�W�����H��:�W/�H�ҧH�tG2�W�~H:�W�I:�W�=���> !�W���H���H!�W6��I:�W�=��HHF �
G��H:�W� ��HcF �
G:�W�����:�W/�H��I�tG2�W��H��G��tG2�W!�W6 !�T:�W���:�W�����H��:�W/�H��[I*�W& �T	:�Ww!�W4~`i+w�tG2�W�I:�W�����:�W/�H��xI�tG2�W�[I!�W6 #6> !�W�҇K *�W& �+SP�	 	^#V�"�W�!P		 	~2�W�� �J:�W�� ��I:�W�A2�W��I:�W�0�/�>9!�W��/�H���I:�W�02�W��I:�W�A�
2�W *�W& �+SP	 	^ *�W& �+S�*�W"�W*�W& �T	~�?�[J *�W& �+SP	
 	:�W�O !=R	6�!U6�!�W4!�T5> !�T�҇K:�W�� ʧJ*�W& �T	~�A�/�>P��/�H�ҜJ*�W& �T	~�A*�WwäJ�F �
GÇK:�W�� ��J*�W& �T	~�Y��*�WwÇK!�W6*�W6 !�W6 :�T=!�W�ڇK:�W!�W�O !�T	~2�W�,�	K*�W#"�W6 !�W6ÀK:�W�#�K!�W6
ÀK:�W�02�W:�W����>	!�W���H��QK>!�W��LK:�W�2�W�QK!�W6�!�W:�W��xK*�W^ �*�W& �+S�*�W& �	��sÀK�F �
G!�W4��J�!�W6 !�W6 :�W���:�W/�H���K!�W6 :�W�� *�W& ��+SP	�*�W& �	�*�W& �W	�
����H���K!�W4éK:�W���K!�W6���K!�W4ÒK:�W�L>��:�W���Wͧ	�T�.	�T�~	!�W6�!�W6 >!�W��N!�W6 #n&  �+SP		 	~2�W!�W6 :�W���:�W/�H��
N!�W6 >!�W�ڞL�'N *�W& �+SP	�*�W& �	�*�W& �W	�
w!�W4�gL:�W�� °L!�W6���L:�W�� ��L:�W�A*�W& �W	w��L:�W�
��L:�W�0*�W& �W	w��L:�W�A�
*�W& �W	w�'N*�W& �W	6 �'N*�W& �W	6=�'N*�W& �W	6  *�W& �+SP	 �	��! ^ *�W& �+S���R"�W:�W�� �mM�'N*�W~�A*�W& �W	w��M:�W�� ʞM�'N*�W~ҐM*�W& �W	6YÛM*�W& �W	6N��M*�WN�bN:�W����M�'N*�W& �W	6,*�W#"�W*�WN�bN�'N*�W& �W	6,*�W#"�W*�WN�bN�'N*�W& �W	6�'N*�W& �W	6
!�W4�PL!�W4�'L>!�W�� N�T�^	�T�	�:�W��]N�T�^	!�W6 >!�W��UN*�W& �W	6!�W4�:N!�W6 �aN!�W4�!�Wq�'N:�W��O !�	�*�W& �W	�w�'N:�W�O !�	�*�W& �W	�w��O� *�TDM}�o��N��*T�� ��O] !�O>2P�W�:�Tgx�ʀO{����
O�:P��O��*T�� ��!�O�O~#�o}o�|O�<�O:�T�zO<�.O:�T�Ɯ��zO<�8O:�T�zO<�BO:�T�zO<�LO:�T�zO:�Tg:�T��gO��tO>�:�T�zO:�To��tO��zO:�Tg����N�!  |��!��|�                                                                                                                                 PRTMSG   ,QPAGWID  2QPAGLEN  1QBACKSPC 3QRUBOUT  4QBOOTDRV 0QMEMTOP  .QBNKSWT  -QCOMBAS  /QLERROR  	+QNUMSEGS 
5QMEMSEG00KQHASHDRVA6QALTBNKSA
+�QNDIRRECA
;�QNDTARECA
K�QODIRDRVA
[�QODTADRVA
k�QOVLYDIRA
{�QOVLYDTAA
��QCRDATAF �;RDBLALV  �<R����� O �����������������      �    �   �   �   �   �   �   �   �	   �
   �   �   �   �   �   �        ��      ��      ��      ��      ��      ��      ��      ��      ��      ��      ��      ��      ��      ��      ��      �� �                                                                                                                                                             i`N#F�o�g��_ ��o�g��_ ��o�g�DM!  >�)�)덑o|�g�S	�=�S�^#V�)�))�	�DM!  >)�)��:S	=�2S��_ ��o�g�^#V�)�PS�^#V�|�g}o�ZS�_ {�oz�g�O {�oz�g�i`N#F�o�g�o& �o�g�_ {�_z#�W��                                                                                                       BNKBIOS3SPR                         RESBDOS3SPR                         BNKBDOS3SPR                         CPM3    SYS                         GENCPM  DAT                                                             .   $