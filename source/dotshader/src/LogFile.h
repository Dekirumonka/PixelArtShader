/**
	@file
	@brief ���O�pHTML�t�@�C��
	@author �t���`
*/

#pragma once

//-----------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------------
//#include <Common.h>

//-----------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------------
	/**
		@brief ���O�pHTML�t�@�C������
		@author �t���`
	*/
	class LogFile
	{
	private:
		HANDLE	m_hFile;

	private:
		int Write( const void* pData, int Size );
		int GetFileSize();
		int GetFilePosition();
		int SeekStart( int Offset );
		int SeekEnd( int Offset );
		int Seek( int Offset );

	public:
		/**
			@brief �R���X�g���N�^
			@author �t���`
			@param pFileName	[in] �t�@�C����
			@param pTitle		[in] �^�C�g��
			@note
			�w�肵���t�@�C������html�t�@�C���𐶐����܂��B
		*/
		LogFile( const wchar_t* pFileName, const wchar_t* pTitle );
		/**
			@brief �f�X�g���N�^
			@author �t���`
			@note
			html�^�O����ăt�@�C����close���܂��B
		*/
		~LogFile();
		/**
			@brief �`��
			@author �t���`
			@param Color	[in] �`��F
			@param pStr		[in] �`�敶����iprintf�Ɠ��������j
			@note
			������̕`������܂��B
		*/
		void Print( int Color, const wchar_t* pStr,... );
		/**
			@brief �����`��
			@author �t���`
			@param Color	[in] �`��F
			@param pStr		[in] �`�敶����iprintf�Ɠ��������j
			@note
			�����ŕ�����̕`������܂��B
		*/
		void PrintStrong( int Color, const wchar_t* pStr,... );
		/**
			@brief ���s�t���`��
			@author �t���`
			@param Color	[in] �`��F
			@param pStr		[in] �`�敶����iprintf�Ɠ��������j
			@note
			���s�t���̕�����̕`������܂��B
		*/
		void PrintLine( int Color, const wchar_t* pStr,... );
		/**
			@brief ���s�t�������`��
			@author �t���`
			@param Color	[in] �`��F
			@param pStr		[in] �`�敶����iprintf�Ɠ��������j
			@note
			���s�t���̑����ŕ�����̕`������܂��B
		*/
		void PrintStrongLine( int Color, const wchar_t* pStr,... );
		/**
			@brief �e�[�u���`��
			@author �t���`
			@param Width	[in] �^�C�g����
			@param pTitle	[in] �^�C�g��
			@param pStr		[in] �`�敶����iprintf�Ɠ��������j
			@note
			�P�s�����̃e�[�u����`�悵�܂�
		*/
		void PrintTable( int Width, const wchar_t* pTitle, const wchar_t* pStr,... );
		/**
			@brief �e�[�u���`��
			@author �t���`
			@param ColorTitle	[in] �^�C�g���F
			@param Color		[in] �����F
			@param pTitle		[in] �^�C�g��
			@param pKind		[in] ���
			@param pStr			[in] �`�敶����iprintf�Ɠ��������j
			@note
			�P�s�����̃e�[�u����`�悵�܂�
		*/
		void PrintTable( int ColorTitle, int Color, const wchar_t* pTitle, const wchar_t* pKind, const wchar_t* pStr,... );
		/**
			@brief �Z���^�C�g���`��
			@author �t���`
			@param Color		[in] �����F
			@param pTitle		[in] �^�C�g��
			@note
			�Z���̃^�C�g����`�悵�܂��B
		*/
		void PrintCellTitle( int Color, const wchar_t* pTitle );
		/**
			@brief �Z����ޕ`��
			@author �t���`
			@param pKind	[in] ��ށiprintf�Ɠ��������j
			@note
			�Z���̎�ނ�`�悵�܂��B
		*/
		void PrintCellKind( const wchar_t* pKind,... );
		/**
			@brief �e�[�u���J�n
			@author �t���`
			@note
			�e�[�u���̊J�n�����܂��B
		*/
		void TableBegin();
		/**
			@brief �e�[�u���I��
			@author �t���`
			@note
			�e�[�u���̏I�������܂��B
		*/
		void TableEnd();
		/**
			@brief �P�s�e�[�u��
			@author �t���`
			@param Bold	[in] ����
			@note
			�P�s�����̃e�[�u�����o�͂��܂��B
		*/
		void TableLine( int Bold );
		/**
			@brief �Z���J�n
			@author �t���`
			@param Width	[in] �Z���̕�
			@note
			�Z���̊J�n�����܂��B
		*/
		void CellBegin( int Width );
		/**
			@brief �Z���I��
			@author �t���`
			@note
			�Z���̏I�������܂��B
		*/
		void CellEnd();
	};


