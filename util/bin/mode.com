Í  
MODE v3.104   (c) 1983 Magnolia Microsystems

$Requires CP/M 3.1 or MP/M
$GETDP.REL not linked into system
$�{u7	� �{uT��su1�	� � }�0�x|* �µ#^#V�"f 	͒�[�_�Rʄ����	� ���J½:n��͞��ʗ��ʝ~�©͇�n͞��ʗ��ʝ~�©�x��!� ~��#"gO 	6 *g�;� �-+"g��~��#�a��{?�� 7�>2n*g�;҃�Aڃ�Q҃2�2�
2;	2��AG�;҃�:x2o�;�� ʀ+��d�� �y������#ʬ� ~�ʻ�,ʻ� ���:p�y�02p�[��Ò��;�D���S� �HG�;҃�Tx2q�[>SG�;҃�T���D��Sx2r�[x2s�[~�0ڃ�:���;�0G~��W�,�W� �W�0ڃ�:҃�;�0Ox�����Gx2t�;�~�,�o� �[+Ê�;�~� �o+Ê�2n�>�����:p�ʣ�0! <=()��t �u:r�ʹ���/�ݶ�w:s������/�ݶ�w:q����D(�S(������������������:t��0��~!T � ��#�x������ݶ�w�d�¯!_�>�Kc�[e�
���¯#�=�E��[c~#��_*f 	͒�͆��:i  �
ʋ�~�
G!00	}�0> o"�
 :n�ʨ�
	� �
	� *c��~��##�~~	���		� �		� ͇	� ����###�f��
���		� ��###�v��	��		� ��###�n�0+�n#�*R
�3 
�39
	� ��##~��~(��!D_ ^#V�"�
�
	� �
:�
� �h	� �
	� �V#^��d� ��:�8	�^��� ��#����:o*b ͒_ ~2i���W *	O͆ڣ"\2^>���>��>��+~�$>��*\ ͒:^���_ "c�! "e!_� ��!_:i�� ͒"j�2l2m:l��e"jd~#�$�I��I� �A�>�2l�e:mG����ex2m+~#"j��A�#�[j�:l�:o< =ʀ�#��u%� ��*\ ^#V�N#fi���������5	��J	� x��	� �{u��
	� �The MODE utility is called in one of the following ways:

        MODE
Outputs HELP information

        MODE d:
Displays the present drive status to the user

        MODE d:arg1,arg2,arg3
Updates the present status and displays it. Valid arguments are:

        DS or SS = double or single sided
        DT, ST or HT = double (96 tpi), single (48 tpi), or half track
          half track is 48 tpi media in a 96 tpi drive.
        DD or SD = double or single density
        S6, S30, etc. = step rate in milliseconds
        MMS, Z37, Z37X etc. (media formats); the X implies extended format.

$Drive A: has a fixed configuration which cannot be determined by MODE.
$5.25 inch floppy
$8 inch floppy
$       Controller - $            Sides - 1
$            Sides - 2
$Recording Density - Single
$Recording Density - Double
$  Tracks per Inch - 48
$  Tracks per Inch - 96
$  Tracks per Inch - 48 tpi media in 96 tpi drive (R/O)
$      Format Type - $        Step Rate - $00 milliseconds
$            Drive - A: (  ) $PRESENT Configuration is:
$NEW Configuration is:
$Invalid command line or command line arguments.
$The requested format is invalid for the specified drive.
The complete configuration must be supplied
$A: does not exist.
$The driver module for A: is incompatible with MODE.
$ inoperative.
$Drive is specified but not linked - ERROR IN SYSTEM-
$ 6122030 3 61015                                                           