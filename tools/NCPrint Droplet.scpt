FasdUAS 1.101.10   ��   ��    k             l     ��  ��    A ;  Written by Gabriel Konar-Steenberg in the summer of 2019.     � 	 	 v     W r i t t e n   b y   G a b r i e l   K o n a r - S t e e n b e r g   i n   t h e   s u m m e r   o f   2 0 1 9 .   
  
 l     ��  ��    j d  Part of a University of Minnesota Department of Soil, Water, and Climate climate modeling project.     �   �     P a r t   o f   a   U n i v e r s i t y   o f   M i n n e s o t a   D e p a r t m e n t   o f   S o i l ,   W a t e r ,   a n d   C l i m a t e   c l i m a t e   m o d e l i n g   p r o j e c t .      l     ��������  ��  ��        l     ��  ��    � � AppleScript "droplet" app that uses Terminal and NCL to print information about a NetCDF file that is dragged and dropped onto the app icon     �     A p p l e S c r i p t   " d r o p l e t "   a p p   t h a t   u s e s   T e r m i n a l   a n d   N C L   t o   p r i n t   i n f o r m a t i o n   a b o u t   a   N e t C D F   f i l e   t h a t   i s   d r a g g e d   a n d   d r o p p e d   o n t o   t h e   a p p   i c o n      l     ��������  ��  ��        i         I     �� ��
�� .aevtodocnull  �    alis  o      ���� 0 	the_files  ��    I     �� ���� 0 process_items     ��  o    ���� 0 	the_files  ��  ��         l     ��������  ��  ��      ! " ! i     # $ # I      �� %���� 0 process_items   %  &�� & o      ���� 0 	the_items  ��  ��   $ Y     5 '�� ( )�� ' k    0 * *  + , + r     - . - n     / 0 / 4    �� 1
�� 
cobj 1 o    ���� 0 i   0 o    ���� 0 	the_items   . o      ���� 0 	this_item   ,  2�� 2 Z    0 3 4�� 5 3 =    6 7 6 n     8 9 8 1    ��
�� 
asdr 9 l    :���� : l    ;���� ; I   �� <��
�� .sysonfo4asfe        file < o    ���� 0 	this_item  ��  ��  ��  ��  ��   7 m    ��
�� boovtrue 4 I   ! '�� =���� 0 process_folder   =  >�� > o   " #���� 0 	this_item  ��  ��  ��   5 I   * 0�� ?���� 0 process_file   ?  @�� @ o   + ,���� 0 	this_item  ��  ��  ��  �� 0 i   ( m    ����  ) l   	 A���� A I   	�� B��
�� .corecnte****       **** B o    ���� 0 	the_items  ��  ��  ��  ��   "  C D C l     ��������  ��  ��   D  E F E i     G H G I      �� I���� 0 process_folder   I  J�� J o      ���� 0 this_folder  ��  ��   H k      K K  L M L r      N O N I    �� P��
�� .earslfdrutxt  @    file P o     ���� 0 this_folder  ��   O o      ���� 0 the_contents   M  Q�� Q I    �� R���� 0 process_items   R  S�� S o   	 
���� 0 the_contents  ��  ��  ��   F  T U T l     ��������  ��  ��   U  V�� V i     W X W I      �� Y���� 0 process_file   Y  Z�� Z o      ���� 0 	this_file  ��  ��   X Z     � [ \���� [ =    	 ] ^ ] l     _���� _ n      ` a ` 1    ��
�� 
nmxt a l     b���� b l     c���� c I    �� d��
�� .sysonfo4asfe        file d o     ���� 0 	this_file  ��  ��  ��  ��  ��  ��  ��   ^ m     e e � f f  n c \ k    � g g  h i h r     j k j l    l���� l n     m n m 1    ��
�� 
pnam n l    o���� o l    p���� p I   �� q��
�� .sysonfo4asfe        file q o    ���� 0 	this_file  ��  ��  ��  ��  ��  ��  ��   k o      ���� 0 filename   i  r s r r    - t u t n    + v w v 7   +�� x y
�� 
ctxt x m    ����  y l   * z���� z \    * { | { l   ( }���� } I   (���� ~
�� .sysooffslong    ��� null��   ~ ��  �
�� 
psof  m   ! " � � � � �  . � �� ���
�� 
psin � o   # $���� 0 filename  ��  ��  ��   | m   ( )���� ��  ��   w o    ���� 0 filename   u o      ���� 0 filename   s  � � � r   . 3 � � � l  . 1 ����� � n   . 1 � � � 1   / 1��
�� 
psxp � o   . /���� 0 	this_file  ��  ��   � o      ���� 0 the_path   �  ��� � O   4 � � � � k   8 � � �  � � � I  8 =�� ���
�� .coredoscnull��� ��� ctxt � m   8 9 � � � � � @ c o n d a   a c t i v a t e   U M N C l i m a t e S c i e n c e��   �  � � � I  > C�� ���
�� .sysodelanull��� ��� nmbr � m   > ?���� ��   �  � � � I  D R� � �
� .coredoscnull��� ��� ctxt � m   D E � � � � �  n c l � �~ ��}
�~ 
kfil � 4   H N�| �
�| 
cwin � m   L M�{�{ �}   �  � � � I  S X�z ��y
�z .sysodelanull��� ��� nmbr � m   S T�x�x �y   �  � � � I  Y q�w � �
�w .coredoscnull��� ��� ctxt � b   Y d � � � b   Y ` � � � b   Y ^ � � � o   Y Z�v�v 0 filename   � m   Z ] � � � � �    =   a d d f i l e ( " � o   ^ _�u�u 0 the_path   � m   ` c � � � � �  " ,   " r " ) � �t ��s
�t 
kfil � 4   g m�r �
�r 
cwin � m   k l�q�q �s   �  ��p � I  r ��o � �
�o .coredoscnull��� ��� ctxt � b   r { � � � b   r w � � � m   r u � � � � �  p r i n t ( � o   u v�n�n 0 filename   � m   w z � � � � �  ) � �m ��l
�m 
kfil � 4   ~ ��k �
�k 
cwin � m   � ��j�j �l  �p   � m   4 5 � ��                                                                                      @ alis    <  Macintosh HD                   BD ����Terminal.app                                                   ����            ����  
 cu             	Utilities   &/:Applications:Utilities:Terminal.app/    T e r m i n a l . a p p    M a c i n t o s h   H D  #Applications/Utilities/Terminal.app   / ��  ��  ��  ��  ��       �i � � � � ��i   � �h�g�f�e
�h .aevtodocnull  �    alis�g 0 process_items  �f 0 process_folder  �e 0 process_file   � �d �c�b � ��a
�d .aevtodocnull  �    alis�c 0 	the_files  �b   � �`�` 0 	the_files   � �_�_ 0 process_items  �a *�k+   � �^ $�]�\ � ��[�^ 0 process_items  �] �Z ��Z  �  �Y�Y 0 	the_items  �\   � �X�W�V�X 0 	the_items  �W 0 i  �V 0 	this_item   � �U�T�S�R�Q�P
�U .corecnte****       ****
�T 
cobj
�S .sysonfo4asfe        file
�R 
asdr�Q 0 process_folder  �P 0 process_file  �[ 6 4k�j  kh ��/E�O�j �,e  *�k+ Y *�k+ [OY�� � �O H�N�M � ��L�O 0 process_folder  �N �K ��K  �  �J�J 0 this_folder  �M   � �I�H�I 0 this_folder  �H 0 the_contents   � �G�F
�G .earslfdrutxt  @    file�F 0 process_items  �L �j  E�O*�k+  � �E X�D�C � ��B�E 0 process_file  �D �A ��A  �  �@�@ 0 	this_file  �C   � �?�>�=�? 0 	this_file  �> 0 filename  �= 0 the_path   � �<�; e�:�9�8 ��7�6�5�4 � ��3�2 ��1�0 � � � �
�< .sysonfo4asfe        file
�; 
nmxt
�: 
pnam
�9 
ctxt
�8 
psof
�7 
psin�6 
�5 .sysooffslong    ��� null
�4 
psxp
�3 .coredoscnull��� ��� ctxt
�2 .sysodelanull��� ��� nmbr
�1 
kfil
�0 
cwin�B ��j  �,�  ��j  �,E�O�[�\[Zk\Z*���� 	k2E�O��,E�O� R�j Okj O�a *a k/l Okj O�a %�%a %a *a k/l Oa �%a %a *a k/l UY hascr  ��ޭ