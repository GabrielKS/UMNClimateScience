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
���� 0 the_contents  ��  ��  ��   F  T U T l     ��������  ��  ��   U  V�� V i     W X W I      �� Y���� 0 process_file   Y  Z�� Z o      ���� 0 	this_file  ��  ��   X Z     v [ \���� [ =    	 ] ^ ] l     _���� _ n      ` a ` 1    ��
�� 
nmxt a l     b���� b l     c���� c I    �� d��
�� .sysonfo4asfe        file d o     ���� 0 	this_file  ��  ��  ��  ��  ��  ��  ��   ^ m     e e � f f  n c \ k    r g g  h i h r     j k j l    l���� l n     m n m 1    ��
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
psxp � o   . /���� 0 	this_file  ��  ��   � o      ���� 0 the_path   �  ��� � O   4 r � � � k   8 q � �  � � � I  8 =�� ���
�� .coredoscnull��� ��� ctxt � m   8 9 � � � � �  n c l��   �  � � � I  > C�� ���
�� .sysodelanull��� ��� nmbr � m   > ?���� ��   �  � � � I  D Z� � �
� .coredoscnull��� ��� ctxt � b   D M � � � b   D I � � � b   D G � � � o   D E�~�~ 0 filename   � m   E F � � � � �    =   a d d f i l e ( " � o   G H�}�} 0 the_path   � m   I L � � � � �  " ,   " r " ) � �| ��{
�| 
kfil � 4   P V�z �
�z 
cwin � m   T U�y�y �{   �  ��x � I  [ q�w � �
�w .coredoscnull��� ��� ctxt � b   [ d � � � b   [ ` � � � m   [ ^ � � � � �  p r i n t ( � o   ^ _�v�v 0 filename   � m   ` c � � � � �  ) � �u ��t
�u 
kfil � 4   g m�s �
�s 
cwin � m   k l�r�r �t  �x   � m   4 5 � ��                                                                                      @ alis    <  Macintosh HD                   BD ����Terminal.app                                                   ����            ����  
 cu             	Utilities   &/:Applications:Utilities:Terminal.app/    T e r m i n a l . a p p    M a c i n t o s h   H D  #Applications/Utilities/Terminal.app   / ��  ��  ��  ��  ��       �q � � � � ��q   � �p�o�n�m
�p .aevtodocnull  �    alis�o 0 process_items  �n 0 process_folder  �m 0 process_file   � �l �k�j � ��i
�l .aevtodocnull  �    alis�k 0 	the_files  �j   � �h�h 0 	the_files   � �g�g 0 process_items  �i *�k+   � �f $�e�d � ��c�f 0 process_items  �e �b ��b  �  �a�a 0 	the_items  �d   � �`�_�^�` 0 	the_items  �_ 0 i  �^ 0 	this_item   � �]�\�[�Z�Y�X
�] .corecnte****       ****
�\ 
cobj
�[ .sysonfo4asfe        file
�Z 
asdr�Y 0 process_folder  �X 0 process_file  �c 6 4k�j  kh ��/E�O�j �,e  *�k+ Y *�k+ [OY�� � �W H�V�U � ��T�W 0 process_folder  �V �S ��S  �  �R�R 0 this_folder  �U   � �Q�P�Q 0 this_folder  �P 0 the_contents   � �O�N
�O .earslfdrutxt  @    file�N 0 process_items  �T �j  E�O*�k+  � �M X�L�K � ��J�M 0 process_file  �L �I ��I  �  �H�H 0 	this_file  �K   � �G�F�E�G 0 	this_file  �F 0 filename  �E 0 the_path   � �D�C e�B�A�@ ��?�>�=�< � ��;�: � ��9�8 � �
�D .sysonfo4asfe        file
�C 
nmxt
�B 
pnam
�A 
ctxt
�@ 
psof
�? 
psin�> 
�= .sysooffslong    ��� null
�< 
psxp
�; .coredoscnull��� ��� ctxt
�: .sysodelanull��� ��� nmbr
�9 
kfil
�8 
cwin�J w�j  �,�  k�j  �,E�O�[�\[Zk\Z*���� 	k2E�O��,E�O� ;�j Okj O��%�%a %a *a k/l Oa �%a %a *a k/l UY h ascr  ��ޭ