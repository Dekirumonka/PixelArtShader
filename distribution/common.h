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

	COMMAND_DEBUG,


	COMMAND_WINDOW_SIZE,
	COMMAND_MODEL_NAME,
	COMMAND_CAPTURE,
	COMMAND_CAPTURE_PATH,
	COMMAND_RESOLUTION,

	COMMAND_RESOLUTION_INNER_MAX,

	COMMAND_CAMERA_POS,
	COMMAND_CAMERA_LOOKAT,
	COMMAND_CAMERA_FOV_Y,
	COMMAND_CAMERA_ORTHO_HEIGHT,
	COMMAND_CAMERA_Z_NEAR,
	COMMAND_CAMERA_Z_FAR,
	COMMAND_CAMERA_IGNORE_DATA,

	COMMAND_ANIME_SET_FRAME,

	COMMAND_RESULT_DISP_SCALE,


	COMMAND_SHADER_Z_THRESHOLD,
	COMMAND_SHADER_Z_THRESHOLD_MIN,
	COMMAND_SHADER_Z_THRESHOLD_MAX,

	COMMAND_SHADER_ANGLE_THRESHOLD,
	COMMAND_SHADER_ANGLE_THRESHOLD_MIN,
	COMMAND_SHADER_ANGLE_THRESHOLD_MAX,

	COMMAND_SHADER_GUTTER_THRESHOLD,
	COMMAND_SHADER_GUTTER_THRESHOLD_MIN,
	COMMAND_SHADER_GUTTER_THRESHOLD_MAX,

	COMMAND_SHADER_IGNORE_COUNT_THRESHOLD,
	COMMAND_SHADER_IGNORE_COUNT_THRESHOLD_MIN,
	COMMAND_SHADER_IGNORE_COUNT_THRESHOLD_MAX,
};


#define true	1
#define false	0



// �t�b�^�i�X�N���v�g�̍Ō�Ɏ����I�ɌĂ΂��j
macro footer
{
	Raw COMMAND_END
}


macro debug int b
{
	Raw COMMAND_DEBUG, b
}


macro window_size int w, int h
{
	Raw COMMAND_WINDOW_SIZE, w, h
}


macro model_name str name
{
	Raw COMMAND_MODEL_NAME, name
}


macro capture int b
{
	Raw COMMAND_CAPTURE, b
}


macro capture_path str path
{
	Raw COMMAND_CAPTURE_PATH, path
}


macro resolution int w, int h
{
	Raw COMMAND_RESOLUTION, w, h
}


macro resolution_inner_max int w, int h
{
	Raw COMMAND_RESOLUTION_INNER_MAX, w, h
}


macro camera_pos float x, float y, float z
{
	Raw COMMAND_CAMERA_POS, x, y, z
}


macro camera_lookat float x, float y, float z
{
	Raw COMMAND_CAMERA_LOOKAT, x, y, z
}


macro camera_fov_y float fovy
{
	Raw COMMAND_CAMERA_FOV_Y, fovy
}


macro camera_ortho_height float height
{
	Raw COMMAND_CAMERA_ORTHO_HEIGHT, height
}


macro camera_z_near float z
{
	Raw COMMAND_CAMERA_Z_NEAR, z
}


macro camera_z_far float z
{
	Raw COMMAND_CAMERA_Z_FAR, z
}


// ���f���f�[�^���ɃJ������񂪂����Ă���������(�f�t�H���g:false)
// b : true(��������) or false(�������Ȃ�)
macro camera_ignore_data int b
{
	Raw COMMAND_CAMERA_IGNORE_DATA, b
}



// �\������t���[���i���ԁj���w��
// ���A�j���[�V�����f�[�^�����݂���ꍇ�̂ݗL��
// ���w�肵�Ȃ���΁A�A�j���[�V�����̑S�Ẵt���[�����\�������
// ��0���ŏ��̃t���[���A����1
macro anime_set_frame int frame
{
	Raw COMMAND_ANIME_SET_FRAME, frame
}



macro result_disp_scale int n
{
	Raw COMMAND_RESULT_DISP_SCALE, n
}



macro shader_z_threshold float n
{
	Raw COMMAND_SHADER_Z_THRESHOLD, n
}
macro shader_z_threshold_min float n
{
	Raw COMMAND_SHADER_Z_THRESHOLD_MIN, n
}
macro shader_z_threshold_max float n
{
	Raw COMMAND_SHADER_Z_THRESHOLD_MAX, n
}


macro shader_angle_threshold float n
{
	Raw COMMAND_SHADER_ANGLE_THRESHOLD, n
}
macro shader_angle_threshold_min float n
{
	Raw COMMAND_SHADER_ANGLE_THRESHOLD_MIN, n
}
macro shader_angle_threshold_max float n
{
	Raw COMMAND_SHADER_ANGLE_THRESHOLD_MAX, n
}


macro shader_gutter_threshold float n
{
	Raw COMMAND_SHADER_GUTTER_THRESHOLD, n
}
macro shader_gutter_threshold_min float n
{
	Raw COMMAND_SHADER_GUTTER_THRESHOLD_MIN, n
}
macro shader_gutter_threshold_max float n
{
	Raw COMMAND_SHADER_GUTTER_THRESHOLD_MAX, n
}


macro shader_ignore_count_threshold float n
{
	Raw COMMAND_SHADER_IGNORE_COUNT_THRESHOLD, n
}
macro shader_ignore_count_threshold_min float n
{
	Raw COMMAND_SHADER_IGNORE_COUNT_THRESHOLD_MIN, n
}
macro shader_ignore_count_threshold_max float n
{
	Raw COMMAND_SHADER_IGNORE_COUNT_THRESHOLD_MAX, n
}
