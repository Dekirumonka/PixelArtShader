@echo off

rem ���̏ꏊ�ɃV�F�[�_�[���s���̃R�s�[�iexe�f�B���N�g���j�𐶐�����
rem �R�s�[�̓o�[�W�����Ǘ��O�Ȃ̂ŁA���R�ɕύX���ē��삳���邱�Ƃ��ł���
rem ���ɃR�s�[�����݂���ꍇ�́A�X�V���ꂽ�t�@�C���������R�s�[����

rem ��O1: exe\config.txt �͌����ď㏑���R�s�[����Ȃ��i�t�@�C�������݂��Ȃ���΃R�s�[�����j
rem ��O2: dest�f�B���N�g���̒��g�͌����ăR�s�[����Ȃ�





cd /D %~dp0


rem set OPT=/D /I /E /Y /L
set OPT=/D /I /E /Y


set SRC_DIR=trunk\dotshader\exe
set DST_DIR=.\exe


rem ���O�t�@�C�����X�g
echo \dest\>temp.txt
echo exe\config.txt>>temp.txt
rem echo \pastel\>>temp.txt


xcopy %SRC_DIR% %DST_DIR% %OPT% /EXCLUDE:temp.txt


if not exist %DST_DIR%\dest mkdir %DST_DIR%\dest
if not exist %DST_DIR%\config.txt copy %SRC_DIR%\config.txt %DST_DIR%\


del temp.txt


rem pause
