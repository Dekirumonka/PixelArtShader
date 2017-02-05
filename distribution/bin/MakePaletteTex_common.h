///////////////////////////////////////////////////////////////////////////////
//
//	���ʃw�b�_
//
///////////////////////////////////////////////////////////////////////////////

// �R���o�[�^�̐ݒ�
// 0:false 1:true
#setting "NeedVariableDeclaration"		1		// �ϐ��錾���K�v��(default:false)
#setting "DefaultVariableType"			0		// �f�t�H���g�^ 0:int 1:uint 2:float 3:str 4:label (default:int)

#setting "NoHeader"						1		// �w�b�_���o�͂��Ȃ�(default:false)
#setting "ResumableSegment"				0		// �Z�O�����g�̍ĊJ���\��(default:true)
#setting "MixableCodeData"				0		// �Z�O�����g�ɃR�[�h�ƃf�[�^�����݂���̂�����(default:false)
#setting "DeleteEmptySegment"			1		// ��̃Z�O�����g���폜���邩(default:true)
#setting "MacroLoopMax"					2000	// �}�N�����[�v�̌J��Ԃ��񐔂̏��(default:2000)

///////////////////////////////////////////////////////////////////////////////


// ���߂̎��
enum
{
	COMMAND_END,		// �X�N���v�g�̏I���

	COMMAND_MAXPER,
	COMMAND_MATERIAL,
	COMMAND_COL,
	COMMAND_COLGRAD,
	COMMAND_COLMIX,
	COMMAND_PERCOL,
	COMMAND_PERCOLEND,
	COMMAND_DARK,
	COMMAND_EDGE,
	COMMAND_MATEEDGE,
	COMMAND_GUTTER,
	COMMAND_AATHRESHOLD,
	COMMAND_AASUBTRACTER,
	COMMAND_NOEDGE,
	COMMAND_ADJUST_RATE,
};

// �Õ����[�h
enum
{
	MODE_DARK_NORMAL,
	MODE_DARK_NONE,
	MODE_DARK_COL,
};


enum
{
	off,
	on,
};



macro Material int num
{
	Raw COMMAND_MATERIAL, num
}


macro Col int divNum, int r, int g, int b
{
	Raw COMMAND_COL, divNum, r, g, b
}


macro ColGrad int divNum, int r1, int g1, int b1, int r2, int g2, int b2
{
	Raw COMMAND_COLGRAD, divNum, r1, g1, b1, r2, g2, b2
}


macro ColMix int divNum
{
	Raw COMMAND_COLMIX, divNum
}


macro PerCol int per, int r, int g, int b
{
	Raw COMMAND_PERCOL, per, r, g, b
}

macro PerColEnd
{
	Raw COMMAND_PERCOLEND
}


macro MaxPer int per
{
	Raw COMMAND_MAXPER, per
}


macro DarkNormal
{
	Raw COMMAND_DARK, MODE_DARK_NORMAL, 0, 0, 0
}


macro DarkNone
{
	Raw COMMAND_DARK, MODE_DARK_NONE, 0, 0, 0
}


macro DarkCol int r, int g, int b
{
	Raw COMMAND_DARK, MODE_DARK_COL, r, g, b
}


macro Edge int flag
{
	Raw COMMAND_EDGE, flag
}


macro MateEdge int flag
{
	Raw COMMAND_MATEEDGE, flag
}


macro Gutter int flag
{
	Raw COMMAND_GUTTER, flag
}


// �ʐϔ䂪���̒l�ɖ����Ȃ��ꍇ��AA����������
// n : 0.0 �` 1.0
// n �� 0 �Ȃ�AAA�Ȃ�
// n �� 1 �Ȃ�A���Ȃ�̕����i�G�b�W�Ɍ���j��AA��������
// default : 0.5
macro AAThreshold float n
{
	Raw COMMAND_AATHRESHOLD, n
}


// AA�̋���
// n : 0.0 �` 1.0
// default : 1.0
macro AASubtracter float n
{
	Raw COMMAND_AASUBTRACTER, n
}


// �w��̃}�e���A���ɑ΂��ẴG�b�W��}������
macro NoEdge int targetMaterialNo, int flag
{
	Raw COMMAND_NOEDGE, targetMaterialNo, flag
}


// �}�e���A�����̐F�̔䗦�𒲐�����
// rate > 1 : ���邢�����𑝂₷
// rate < 1 : �Â������𑝂₷
// rate = 1 : default�i�������Ȃ��j
// ������� PerCol �ɂ̂݉e������BPerCol����ɏ������ƁB
macro AdjustRate float rate
{
	Raw COMMAND_ADJUST_RATE, rate
}



// �t�b�^�i�X�N���v�g�̍Ō�Ɏ����I�ɌĂ΂��j
macro footer
{
	Raw COMMAND_END
}
