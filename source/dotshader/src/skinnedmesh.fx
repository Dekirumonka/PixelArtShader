//
// Skinned Mesh Effect file
// Copyright (c) 2000-2002 Microsoft Corporation. All rights reserved.
//

//float4 lightDir = {0.0f, 0.0f, -1.0f, 1.0f};	  //light Direction
//float4 lightDiffuse = {0.6f, 0.6f, 0.6f, 1.0f}; // Light Diffuse
//float4 MaterialAmbient : MATERIALAMBIENT = {0.1f, 0.1f, 0.1f, 1.0f};
//float4 MaterialDiffuse : MATERIALDIFFUSE = {0.8f, 0.8f, 0.8f, 1.0f};

// ���I�A���r�G���g���C�g
float DynamicAmbientLight = 0;

// �f�B���N�V���i�����C�g
float4 DirLight0_Dir = { 0.0f, 1.0f, 0.0f, 0.0f };
float DirLight0_Coeff = 0;
float4 DirLight1_Dir = { 0.0f, 1.0f, 0.0f, 0.0f };
float DirLight1_Coeff = 0;
float4 DirLight2_Dir = { 0.0f, 1.0f, 0.0f, 0.0f };
float DirLight2_Coeff = 0;


float SpecularCoefficient = 0;	// �X�y�L�����W��
float SpecularExponent = 1;		// �X�y�L�����w��

//float4 worldCameraPos;

float  PaletteU = 0.0f;


//float4 lht2Dir = {0.0f, 0.0f, -1.0f, 1.0f};

// Matrix Pallette
static const int MAX_MATRICES = 26;
float4x3	mWorldViewMatrixArray[MAX_MATRICES] : WORLDMATRIXARRAY;	// ���ۂ� WorldView �s��
//float4x4	mViewProj : VIEWPROJECTION;
float4x4	mViewProj : PROJECTION;	// TODO: mViewProj -> mProj


//float4		invTexSize = { 0, 0, 0, 0 };	// x,y : inverse size of temp tex    z : inverse width of palette tex   w : unused
float4		invSrcTexSize = { 0, 0, 0, 0 };		// x,y : inverse size of temp tex    z : inverse width of palette tex   w : unused
float4		invSplitTexSize = { 0, 0, 0, 0 };	// x,y : inverse size of split tex   z,w : unused
float4		invFinalTexSize = { 0, 0, 0, 0 };	// x,y : inverse size of final tex   z,w : unused


texture g_Texture;				// Color texture for mesh
texture g_Texture2;
texture g_Texture3;
texture g_Texture4;	// palette
texture g_Texture5;
texture g_Texture6;
texture g_Texture7;


//#define BG_Z	9999999	// �w�i��Z�l
//#define BGCOLOR	float4( 0, 0.3f, 0, 1 )
//#define BGCOLOR	float4( 1, 1, 1, 1 )


#define PI		3.141592f


#define MAX_PALETTE	24	// �V�F�[�_�[�ň�����}�e���A�����̌��E�i����1��2�͑��₹�邩���j


#define LIGHT_RANGE	3.0f

#define PALETTE_TEX_WIDTH	256
#define PALETTE_TEX_HEIGHT	256

#define PALETTE_TEX_COLOR_START_Y	( 2.5f / PALETTE_TEX_HEIGHT )	// �p���b�g�摜���́A�F���̊J�ny���W�i��������ɂ̓}�e���A���̊e���񂪓����Ă���j
#define PALETTE_TEX_DARK_Y			( 0.5f / PALETTE_TEX_HEIGHT )	// �p���b�g�摜���́A�Õ����̊J�ny���W
#define PALETTE_TEX_AA_Y			( 1.5f / PALETTE_TEX_HEIGHT )	// �p���b�g�摜���́AAA���̊J�ny���W

#define PALETTE_TEX_ADJACENT_X		( ( PALETTE_TEX_WIDTH - MAX_PALETTE + 0.5f ) / PALETTE_TEX_WIDTH )	// �p���b�g�摜���́A�אڃ}�e���A�����̊J�n���W
#define PALETTE_TEX_ADJACENT_Y		( ( PALETTE_TEX_HEIGHT - MAX_PALETTE + 0.5f ) / PALETTE_TEX_HEIGHT )



#define BLOCK_WIDTH		5
#define BLOCK_HEIGHT	5
#define BLOCK_NUM		( BLOCK_WIDTH * BLOCK_HEIGHT )
#define BLOCK_WHf		float2( BLOCK_WIDTH, BLOCK_HEIGHT )


float	g_ZThreshold = 0.05f;
float	g_AngleThreshold = 50.0f;
float	g_GutterThreshold = 0.2f;
float	g_IgnoreCountThreshold = 0.3f;	// 1.5f / 5.0f


///////////////////////////////////////////////////////

struct VS_INPUT
{
	float4	Pos 			: POSITION;
	float4	BlendWeights	: BLENDWEIGHT;
	float4	BlendIndices	: BLENDINDICES;
	float3	Normal			: NORMAL;
	float3	Tex0			: TEXCOORD0;
};

struct VS_OUTPUT
{
	float4	Pos 	: POSITION;
//	float4	Diffuse : COLOR;

	float4	ViewPos	: TEXCOORD3;

//	float3	Normal	: COLOR;
//	float3	Normal	: POSITION;
	float3	Normal	: TEXCOORD2;

	float2	Tex0	: TEXCOORD0;
	float2	PosZW	: TEXCOORD1;
};


#if 0
float BiasDiffuse( float3 Normal, float3 lightDir )
{
	const float bias = 0.2f;

	float CosTheta;

	// N.L Clamped
	CosTheta = max( 0.0f, ( dot( Normal, lightDir ) + bias ) / ( 1 + bias ) );

	return CosTheta;
}
#endif


float Diffuse( float3 Normal, float3 lightDir )
{
	float CosTheta;

	// N.L Clamped
	CosTheta = max( 0.0f, dot( Normal, lightDir ) );

	return CosTheta;
}


// ���j�A�ȃf�B�t���[�Y�l�̌v�Z
//   �@���������̕����������Ă���     : 2.0
//   �@���������Ƌt�̕����������Ă��� : 0.0
float LinearDiffuse( float3 Normal, float3 lightDir )
{
	// 1-(arccos(cos(x))*2/��)

	float diffuse = 2 - ( acos( dot( Normal, lightDir ) ) * 2 / PI );

	return diffuse;
}


VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
	VS_OUTPUT	o;
	float3		Pos = 0.0f;
	float3		Normal = 0.0f;
	float		LastWeight = 0.0f;

	// Compensate for lack of UBYTE4 on Geforce3
//	int4 IndexVector = D3DCOLORtoUBYTE4(i.BlendIndices);

	// cast the vectors to arrays for use in the for loop below
	float BlendWeightsArray[4] = (float[4])i.BlendWeights;
//	int   IndexArray[4] 	   = (int[4])IndexVector;
	int   IndexArray[4] 	   = (int[4])i.BlendIndices;

	// calculate the pos/normal using the "normal" weights
	//		  and accumulate the weights to calculate the last weight
	for (int iBone = 0; iBone < NumBones-1; iBone++)
	{
		LastWeight = LastWeight + BlendWeightsArray[iBone];

		Pos += mul(i.Pos, mWorldViewMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
		Normal += mul(float4(i.Normal,0), mWorldViewMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
	}
	LastWeight = 1.0f - LastWeight;

	// Now that we have the calculated weight, add in the final influence
	Pos += (mul(i.Pos, mWorldViewMatrixArray[IndexArray[NumBones-1]]) * LastWeight);
	Normal += (mul(float4(i.Normal,0), mWorldViewMatrixArray[IndexArray[NumBones-1]]) * LastWeight);

	// transform position from world space into view and then projection space
	o.Pos = mul(float4(Pos.xyz, 1.0f), mViewProj);

	o.ViewPos = float4( Pos.xyz, 1.0f );

	// normalize normals
	Normal = normalize(Normal);

	// Shade (Ambient + etc.)
//	o.Diffuse.xyz = MaterialAmbient.xyz + Diffuse(Normal) * MaterialDiffuse.xyz;
//	o.Diffuse.w = 1.0f;
	o.Normal = Normal;

	// copy the input texture coordinate through
	o.Tex0	= i.Tex0.xy;

///	o.PosZW.xy = o.Pos.zw;
//	o.PosZW.xy = float2( 0, o.Pos.z / o.Pos.w );
//	o.PosZW.xy = float2( 0, 1 / o.Pos.w );
	o.PosZW.xy = float2( 0, o.ViewPos.z );
//	o.PosZW.xy = float2( 0, length( Pos.xyz ) );

	return o;
}

int CurNumBones = 2;
VertexShader vsArray[4] = { compile vs_2_0 VShade(1),
							compile vs_2_0 VShade(2),
							compile vs_2_0 VShade(3),
							compile vs_2_0 VShade(4)
						  };


//--------------------------------------------------------------------------------------
// Texture samplers
//--------------------------------------------------------------------------------------
sampler PS2TextureSampler1 =
sampler_state
{
	Texture = <g_Texture>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
//	MinFilter = LINEAR;
//	MagFilter = LINEAR;
};

sampler PS2TextureSampler2 =
sampler_state
{
	Texture = <g_Texture2>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
//	MinFilter = LINEAR;
//	MagFilter = LINEAR;
};

sampler PS2TextureSampler3 =
sampler_state
{
	Texture = <g_Texture3>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
};

sampler PS2TextureSampler4 =
sampler_state
{
	Texture = <g_Texture4>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
};

sampler PS2TextureSampler5 =
sampler_state
{
	Texture = <g_Texture5>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
};

sampler PS2TextureSampler6 =
sampler_state
{
	Texture = <g_Texture6>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
};

sampler PS2TextureSampler7 =
sampler_state
{
	Texture = <g_Texture7>;

	AddressU = CLAMP;
	AddressV = CLAMP;

	MipFilter = NONE;
	MinFilter = POINT;
	MagFilter = POINT;
};


//--------------------------------------------------------------------------------------
// Pixel shader output structure
//--------------------------------------------------------------------------------------
struct PS_OUTPUT
{
	float4 RGBColor		: COLOR0;  // Pixel color
	float4 RGBColor2	: COLOR1;  // Pixel color
	float4 Depth		: COLOR2;
};


//--------------------------------------------------------------------------------------
// This shader outputs the pixel's color by modulating the texture's
//		 color with diffuse material color
//--------------------------------------------------------------------------------------
PS_OUTPUT RenderScenePS(	VS_OUTPUT In,
							uniform bool bMaterialMap,
							uniform bool bAOMap,
							uniform bool bLightMap
						)
{
	PS_OUTPUT Output;

	float3		Normal = normalize( In.Normal );


	// �f�B���N�V���i�����C�g
//	float diffuse = Diffuse( Normal, DirLight0_Dir );
	float diffuse = LinearDiffuse( Normal, DirLight0_Dir.xyz ) * DirLight0_Coeff;	// [0,2 * DirLight0_Coeff]
	diffuse += Diffuse( Normal, DirLight1_Dir.xyz ) * DirLight1_Coeff;
	diffuse += Diffuse( Normal, DirLight2_Dir.xyz ) * DirLight2_Coeff;


	// �X�y�L����
	float specular = 0;	// [0,SpecularCoefficient]
#if 1
	{
//		float3 vHalf = normalize( lightDir.xyz + normalize( worldCameraPos.xyz - In.ViewPos.xyz ) );
		float3 vHalf = normalize( DirLight0_Dir.xyz + normalize( - In.ViewPos.xyz ) );

//		float powNum = 20;

//		specular = pow( max( dot( vHalf, Normal ), 0 ), powNum );

		specular = pow( max( dot( vHalf, Normal ), 0 ), SpecularExponent );	// [0,1]
		specular *= SpecularCoefficient;									// [0,SpecularCoefficient]
	}
#endif



	float lightCoefficient;	// �ŏI�I�ȏƖ��W��

	lightCoefficient = diffuse + specular;	// [0, 2 * DirLight0_Coeff + DirLight1_Coeff + DirLight2_Coeff + SpecularCoefficient ]

	// ���I�A���r�G���g���C�g
	lightCoefficient += DynamicAmbientLight;

	// ���C�g�}�b�v�i�A���r�G���g���C�g�̌��ʁj
	if( bLightMap )
	{
		lightCoefficient += tex2D( PS2TextureSampler1, In.Tex0 ).b * LIGHT_RANGE;
	}

	// AO�}�b�v
	if( bAOMap )
	{
		lightCoefficient *= tex2D( PS2TextureSampler1, In.Tex0 ).g;
	}

	lightCoefficient /= LIGHT_RANGE;	// �����W���k  ��LIGHT_RANGE���傫���l�̓t���[���o�b�t�@�ւ̏������ݎ��ɃN�����v�����



#if 0
	// �m�F�p
	{
		float3 col = tex2D( PS2TextureSampler4, float2( PaletteU, 0.5f ) ).xyz;

		col *= lightCoefficient * LIGHT_RANGE / 2;

		Output.RGBColor = float4( col, 1 );
	}
#else
//	Output.RGBColor = float4( lightCoefficient, PaletteU, 0, 0 );



	float palette = PaletteU;

	// �}�e���A���}�b�v
	if( bMaterialMap )
	{
		palette = tex2D( PS2TextureSampler1, In.Tex0 ).r;
	}

	Output.RGBColor = float4( lightCoefficient, palette, 0, 0 );






#endif








	float3 temp = ( Normal + 1.0f ) / 2.0f;
	Output.RGBColor2 = float4( temp, 1 );

///	Output.Depth = In.PosZW.x / In.PosZW.y;
//	Output.Depth = 1 / In.PosZW.y;
	Output.Depth = float4( In.ViewPos.xyz, In.PosZW.y );

	return Output;
}

int PSMode = 0;
PixelShader psArray[ 4 ] = {	compile ps_3_0 RenderScenePS( false, false, false ),	// 0:  �}�e���A���}�b�v�Ȃ�  AO�E���C�g�}�b�v�Ȃ�
								compile ps_3_0 RenderScenePS( true,  false, false ),	// 1:  �}�e���A���}�b�v����  AO�E���C�g�}�b�v�Ȃ�
								compile ps_3_0 RenderScenePS( false, true,  true ),		// 2:  �}�e���A���}�b�v�Ȃ�  AO�E���C�g�}�b�v����
								compile ps_3_0 RenderScenePS( true,  true,  true )		// 3:  �}�e���A���}�b�v����  AO�E���C�g�}�b�v����
							};


///////////////////////////////////////////////////////////////////////////////

struct PS_OUTPUT_ANALYZE_COUNTPALETTE_MEANPOS
{
	float4 dst		: COLOR0;  // �p���b�g�ԍ�, �ʐρi�I�΂ꂽ�p���b�g�̂݁j, �ʐρiz�l�Ŗ������ꂽ�̈���܂ށj, 0
	float4 dst2		: COLOR1;  // ���ύ��Wxyz, 0
};

PS_OUTPUT_ANALYZE_COUNTPALETTE_MEANPOS RenderScenePSAnalyze_CountPalette_MeanPos( in float2 texcoord : TEXCOORD0 )
{
	PS_OUTPUT_ANALYZE_COUNTPALETTE_MEANPOS output;


#if 1

	float aPaletteCount[ MAX_PALETTE ];
	float aMeanPos_Z[ MAX_PALETTE ];


	{
		for( int i = 0;  i < MAX_PALETTE;  i ++ )
		{
			aPaletteCount[ i ] = 0;
			aMeanPos_Z[ i ] = 0;
		}
	}


	{
		float2 origin = texcoord - invSrcTexSize.xy * ( BLOCK_WHf / 2.0f - 0.5f );

//		[unroll(BLOCK_HEIGHT)] // attribute
		for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
		{
//			[unroll(BLOCK_WIDTH)] // attribute
			for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
			{
				float2 srcTexCoord = origin + invSrcTexSize.xy * float2( x, y );

				float paletteU = tex2D( PS2TextureSampler1, srcTexCoord ).g;

				int paletteIndex = round( paletteU * 255 );

				float posZ = tex2D( PS2TextureSampler3, srcTexCoord ).z;


//				[unroll(MAX_PALETTE)]
				for( int i = 0;  i < MAX_PALETTE;  i ++ )
				{
					if( i == paletteIndex )
					{
						aPaletteCount[ i ] ++;
						aMeanPos_Z[ i ] += posZ;
					}
				}
			}
		}
	}


	{
		for( int i = 1;  i < MAX_PALETTE;  i ++ )
		{
			if( 0 < aPaletteCount[ i ] )
			{
				aMeanPos_Z[ i ] /= aPaletteCount[ i ];
			}
		}
	}

	//////////////////////////////////////////////////////////////////////

	#define IGNORE_COUNT_THRESHOULD	( BLOCK_NUM * g_IgnoreCountThreshold )

	int n = -1;
	int ignoreCount = 0;

	float meanPos_minZ = 999999;
	float paletteCount_minZ = aPaletteCount[ 0 ];

	{
		if( 0 < aPaletteCount[ 0 ] )
		{
			n = 0;
		}

		// 臒l���z����ʐς����}�e���A���̒��ŁA�ł���O�̂��̂�I��
		for( int i = 1;  i < MAX_PALETTE;  i ++ )
		{
			if( IGNORE_COUNT_THRESHOULD < aPaletteCount[ i ] )
			{
				if( aMeanPos_Z[ i ] < meanPos_minZ )
				{
					n = i;

					meanPos_minZ = aMeanPos_Z[ i ];
					paletteCount_minZ = aPaletteCount[ i ];
				}
			}
		}

		// �w�i�����݂����A�S�Ẵ}�e���A����臒l�ȉ��������̂ŁA臒l�𔲂��ɂ��Ă�����x���ׂ�
		if( n == -1 )
		{
			for( int i = 1;  i < MAX_PALETTE;  i ++ )
			{
				if( 0 < aPaletteCount[ i ] )
				{
					if( aMeanPos_Z[ i ] < meanPos_minZ )
					{
						n = i;

						meanPos_minZ = aMeanPos_Z[ i ];
						paletteCount_minZ = aPaletteCount[ i ];
					}
				}
			}
		}

		// �����ʐς̌v�Z
		if( n != 0 )
		{
			for( int i = 1;  i < MAX_PALETTE;  i ++ )
			{
				if( aMeanPos_Z[ i ] < meanPos_minZ )
				{
					// �I�����ꂽ�}�e���A������O�ɂ���}�e���A���̖ʐς��J�E���g

					ignoreCount += aPaletteCount[ i ];
				}
				else if( i != n )
				{
					// �u�אڃ}�e���A���ɃG�b�W�������Ȃ��t���O�v�������Ă�����̂��J�E���g

					// �אڃ}�e���A���ɃG�b�W�������Ȃ��t���O  0 or 1
					float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( PALETTE_TEX_ADJACENT_X + (float)n / PALETTE_TEX_WIDTH, PALETTE_TEX_ADJACENT_Y + (float)i / PALETTE_TEX_HEIGHT ) ).r;

					if( 0 < adjacent_noEdge )
						ignoreCount += aPaletteCount[ i ];
				}
			}
		}
	}


	//////////////////////////////////////////////////////////////////////

	float2 meanPosXY = float2( 0, 0 );

	if( n != 0 )
	{
		float2 origin = texcoord - invSrcTexSize.xy * ( BLOCK_WHf / 2.0f - 0.5f );

//		[unroll(BLOCK_HEIGHT)] // attribute
		for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
		{
//			[unroll(BLOCK_WIDTH)] // attribute
			for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
			{
				float2 srcTexCoord = origin + invSrcTexSize.xy * float2( x, y );

				float paletteU = tex2D( PS2TextureSampler1, srcTexCoord ).g;

				int paletteIndex = round( paletteU * 255 );

				if( n == paletteIndex )
				{
					meanPosXY += tex2D( PS2TextureSampler3, srcTexCoord ).xy;
				}
			}
		}

		for( int i = 1;  i < MAX_PALETTE;  i ++ )
		{
			if( i == n )
			{
				meanPosXY /= aPaletteCount[ i ];
			}
		}
	}






#else

	float aPaletteCount[ MAX_PALETTE ];
	float3 aMeanPos[ MAX_PALETTE ];


	for( int i = 0;  i < MAX_PALETTE;  i ++ )
	{
		aPaletteCount[ i ] = 0;
		aMeanPos[ i ] = float3( 0, 0, 0 );
	}


	{
		float2 origin = texcoord - invSrcTexSize.xy * ( BLOCK_WHf / 2.0f - 0.5f );

//		[unroll(BLOCK_HEIGHT)] // attribute
		for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
		{
//			[unroll(BLOCK_WIDTH)] // attribute
			for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
			{
				float2 srcTexCoord = origin + invSrcTexSize.xy * float2( x, y );

				float paletteU = tex2D( PS2TextureSampler1, srcTexCoord ).g;

				int paletteIndex = round( paletteU * 255 );

				float3 pos = tex2D( PS2TextureSampler3, srcTexCoord ).xyz;


//				[unroll(MAX_PALETTE)]
				for( int i = 0;  i < MAX_PALETTE;  i ++ )
				{
					if( i == paletteIndex )
					{
						aPaletteCount[ i ] ++;
						aMeanPos[ i ] += pos;
					}
				}
			}
		}
	}


	for( int i = 1;  i < MAX_PALETTE;  i ++ )
	{
		if( 0 < aPaletteCount[ i ] )
		{
			aMeanPos[ i ] /= aPaletteCount[ i ];
		}
	}

	aMeanPos[ 0 ].z = 999999;

	//////////////////////////////////////////////////////////////////////

	#define IGNORE_COUNT_THRESHOULD	( BLOCK_WIDTH * BLOCK_HEIGHT / 5.0f * 1.5f )

	int n = 0;
	int ignoreCount = 0;

	float3 meanPos_minZ = aMeanPos[ 0 ];
	float paletteCount_minZ = aPaletteCount[ 0 ];
	{
#if 1
		for( int i = 1;  i < MAX_PALETTE;  i ++ )
		{
#if 1
			if( IGNORE_COUNT_THRESHOULD < aPaletteCount[ i ] )
			{
				if( aMeanPos[ i ].z < meanPos_minZ.z )
				{
					n = i;

					meanPos_minZ = aMeanPos[ i ];
					paletteCount_minZ = aPaletteCount[ i ];
				}
			}
#else
			float b = step( IGNORE_COUNT_THRESHOULD, aPaletteCount[ i ] ) * step( aMeanPos[ i ].z, meanPos_minZ.z );

			n = lerp( n, i, b );


			meanPos_minZ = lerp( meanPos_minZ, aMeanPos[ i ], b );
			paletteCount_minZ = lerp( paletteCount_minZ, aPaletteCount[ i ], b );
#endif
		}
#endif

#if 1
		if( n != 0 )
		{
			for( int i = 1;  i < MAX_PALETTE;  i ++ )
			{
				if( aMeanPos[ i ].z < meanPos_minZ.z )
				{
					ignoreCount += aPaletteCount[ i ];
				}
			}
		}
#endif
	}
#endif









//////////////////////////////////////////////////////////////////////

#if 1
	output.dst = float4(
							n,
							paletteCount_minZ,
							paletteCount_minZ + ignoreCount,
							0
						) / 255.0f;
//	output.dst2 = float4( meanPos_minZ, 0 );
	output.dst2 = float4( meanPosXY, meanPos_minZ, 0 );
#else
	output.dst = float4( aPaletteCount[ 0 ], 0, 0, 0 );
	output.dst2 = float4( aMeanPos[ 0 ].xyz, 0 );
#endif
	return output;
}


///////////////////////////////////////////////////////////////////////////////

struct PS_OUTPUT_ANALYZE
{
	float4 dst		: COLOR0;  // ���ϖ@��xyz, ���ϏƓx
	float4 dst2		: COLOR1;  // bEdge( 0 or 1 ), bGutter( 0 or 1 ), 0,0
};

PS_OUTPUT_ANALYZE RenderScenePSAnalyze( in float2 texcoord : TEXCOORD0 )
{
	PS_OUTPUT_ANALYZE output;

/*
	output.dst = float4( 0, 0, 0, 0 );

	return output;
*/


	float paletteU = tex2D( PS2TextureSampler5, texcoord ).r;						// �p���b�g�ԍ�
//	float areaRate = tex2D( PS2TextureSampler5, texcoord ).g * 255.0f / BLOCK_NUM;	// �ʐϔ�
	float area = round( tex2D( PS2TextureSampler5, texcoord ).g * 255.0f );			// �ʐ�

	float avgLight = 0;
	float3 avgNormal = float3( 0, 0, 0 );



	// �G�b�W�`�F�b�N
	float bEdge = 0;
	{
		float maxSubZ = 0;

		float2 origin = texcoord - invSrcTexSize.xy * ( BLOCK_WHf / 2.0f - 0.5f );

//		[loop] // attribute
		for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
		{
//			[loop] // attribute
			for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
			{
				float2 srcTexCoord = origin + invSrcTexSize.xy * float2( x, y );

				float _paletteU = tex2D( PS2TextureSampler1, srcTexCoord ).g;

				if( _paletteU == paletteU )
				{
					avgLight += tex2D( PS2TextureSampler1, srcTexCoord ).r;
//					avgLight = max( avgLight, tex2D( PS2TextureSampler1, srcTexCoord ).r );

					float3 normal = tex2D( PS2TextureSampler2, srcTexCoord ).xyz * 2.0f - 1.0f;

					avgNormal += normal;

					float3 pos = tex2D( PS2TextureSampler3, srcTexCoord ).xyz;

					// �א�4�s�N�Z���Ƃ�Z���𑪂�
					{
						float D = dot( normal, pos );	// ���ʃp�����[�^ -D = N�EP0

						//   0
						// 2 C 3
						//   1
						const int2 aNeighborhoodUVTable[] =
						{
							{  0, -1 },
							{  0,  1 },
							{ -1,  0 },
							{  1,  0 },
						};

//						[loop] // attribute
						for( int i = 0;  i < 4;  i ++ )
						{
							float2 NbTexCoord = srcTexCoord + invSrcTexSize.xy * aNeighborhoodUVTable[ i ];

							// �אڃ}�e���A���������ƈقȂ�A���u�אڃ}�e���A���ɃG�b�W�������Ȃ��t���O�v�������Ă���Ȃ�A��������Ȃ�
							{
								float NbPaletteU = tex2D( PS2TextureSampler1, NbTexCoord ).g;

								// �אڃ}�e���A���ɃG�b�W�������Ȃ��t���O  0 or 1
//								float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( NbPaletteU + 0.5f, PALETTE_TEX_ADJACENT_Y ) ).r;
								float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( PALETTE_TEX_ADJACENT_X + _paletteU, PALETTE_TEX_ADJACENT_Y + NbPaletteU ) ).r;

								if( _paletteU != NbPaletteU  &&  0 < adjacent_noEdge )
									continue;
							}


							float3 NbPos = tex2D( PS2TextureSampler3, NbTexCoord ).xyz;

//							float t = D / dot( normal, NbPos );	// 0���Z�̉\������
							float NbD = dot( normal, NbPos );

							// t �� 1 �����Ȃ�A�אڃs�N�Z���̍��W�͗��z��艜�ɂ���
//							if( t < 1.0f )

							// �אڃs�N�Z���̍��W�͗��z��艜�ɂ���
							if( NbD < D )
							{
//								float3 IdealPos = NbPos * t;	// (x,y) ���狁�߂����z�̍��W

								// �אڃs�N�Z�������z���W��艜�ɂ���Ȃ�ANbD �͕K�����̒l�i0���Z�͔������Ȃ��j
								float3 IdealPos = NbPos * ( D / NbD );	// ���z�̍��W�i���_����אڍ��W�܂ł̐����ƕ��ʂ̌�_�j

								float Sub = length( NbPos - IdealPos );	// ���z���W�Ƃ̋���

								maxSubZ = max( maxSubZ, Sub );
							}
						}
					}
				}


//				int paletteU = floor( paletteUf * 255 + 0.5f );	// 0.5f : �O�̂���
			}
		}

		if( g_ZThreshold <= maxSubZ )
		{
			bEdge = 1;
		}
	}

	if( paletteU == 0 )
	{
		avgNormal = float3( 0, 0, -1 );
		bEdge = 0;
	}





	// �a�`�F�b�N
	float bGutter = 0;
	{
		float gutter = 0;


		float2 origin = texcoord - invSrcTexSize.xy * ( BLOCK_WHf / 2.0f - 0.5f );


#if 0

		// �{���͂���ŃR���p�C�����ʂ�͂��Ȃ̂����A�G���[���o��̂Ł����[�v�W�J������

		const float2 aToAdjacent[] =	{
											{  1,  0 },	// ��   �� �E
											{  0,  1 },	// ��   �� ��
											{  1,  1 },	// ���� �� �E��
											{  1, -1 },	// ���� �� �E��
										};

		const float2 aAxis[] =	{
									{  0,  1 },	// ��   �� �E
									{  1,  0 },	// ��   �� ��
									{  1,  1 },	// ���� �� �E��
									{ -1,  1 },	// ���� �� �E��
								};

		[unroll] // attribute
		for( int i = 0;  i < 4;  i ++ )
		{
//			[unroll] // attribute
			for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
			{
//				[unroll] // attribute
				for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
				{
					float2 srcTexCoord1 = origin + invSrcTexSize.xy * float2( x, y );
					float2 srcTexCoord2 = origin + invSrcTexSize.xy * ( float2( x, y ) + aToAdjacent[ i ] );

					float3 normal1 = normalize( tex2D( PS2TextureSampler2, srcTexCoord1 ).xyz * 2.0f - 1.0f );
					float3 normal2 = normalize( tex2D( PS2TextureSampler2, srcTexCoord2 ).xyz * 2.0f - 1.0f );

					float3 cp = cross( normal1, normal2 );

					// �@�������������Ă��邩
					if( 0 < dot( cp.xy, aAxis[ i ] ) )
					{
						float dp = dot( normal1, normal2 );

						float sinTheta = length( cp );

						// ������x�ȏ�̊p�x�Ō��������Ă��邩
						if( dp <= 0  ||  g_AngleThreshold < sinTheta )
						{
							gutter ++;
						}
					}
				}
			}
		}

#else

		// ���[�v�W�J��

		{
			for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
			{
				for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
				{
					float2 srcTexCoord1 = origin + invSrcTexSize.xy * float2( x, y );
//					float2 srcTexCoord2 = origin + invSrcTexSize.xy * ( float2( x, y ) + aToAdjacent[ i ] );
					float2 srcTexCoord2 = origin + invSrcTexSize.xy * float2( x + 1, y );

					float3 normal1 = normalize( tex2D( PS2TextureSampler2, srcTexCoord1 ).xyz * 2.0f - 1.0f );
					float3 normal2 = normalize( tex2D( PS2TextureSampler2, srcTexCoord2 ).xyz * 2.0f - 1.0f );

					float3 cp = cross( normal1, normal2 );

					// �@�������������Ă��邩
//					if( 0 < dot( cp.xy, aAxis[ i ] ) )
					if( 0 < cp.y )
					{
						float dp = dot( normal1, normal2 );
						float sinTheta = length( cp );
						float theta = asin( sinTheta );

						if( dp <= 0 )
						{
							theta = PI - theta;
						}

						// ������x�ȏ�̊p�x�Ō��������Ă��邩
//						if( dp <= 0  ||  angleThreshould < sinTheta )
						if( radians( g_AngleThreshold ) < theta )
						{
							gutter ++;
						}
					}
				}
			}
		}

		{
			for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
			{
				for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
				{
					float2 srcTexCoord1 = origin + invSrcTexSize.xy * float2( x, y );
//					float2 srcTexCoord2 = origin + invSrcTexSize.xy * ( float2( x, y ) + aToAdjacent[ i ] );
					float2 srcTexCoord2 = origin + invSrcTexSize.xy * float2( x, y + 1 );

					float3 normal1 = normalize( tex2D( PS2TextureSampler2, srcTexCoord1 ).xyz * 2.0f - 1.0f );
					float3 normal2 = normalize( tex2D( PS2TextureSampler2, srcTexCoord2 ).xyz * 2.0f - 1.0f );

					float3 cp = cross( normal1, normal2 );

					// �@�������������Ă��邩
//					if( 0 < dot( cp.xy, aAxis[ i ] ) )
					if( 0 < cp.x )
					{
						float dp = dot( normal1, normal2 );
						float sinTheta = length( cp );
						float theta = asin( sinTheta );

						if( dp <= 0 )
						{
							theta = PI - theta;
						}

						// ������x�ȏ�̊p�x�Ō��������Ă��邩
						if( radians( g_AngleThreshold ) < theta )
						{
							gutter ++;
						}
					}
				}
			}
		}

		{
			for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
			{
				for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
				{
					float2 srcTexCoord1 = origin + invSrcTexSize.xy * float2( x, y );
//					float2 srcTexCoord2 = origin + invSrcTexSize.xy * ( float2( x, y ) + aToAdjacent[ i ] );
					float2 srcTexCoord2 = origin + invSrcTexSize.xy * float2( x + 1, y + 1 );

					float3 normal1 = normalize( tex2D( PS2TextureSampler2, srcTexCoord1 ).xyz * 2.0f - 1.0f );
					float3 normal2 = normalize( tex2D( PS2TextureSampler2, srcTexCoord2 ).xyz * 2.0f - 1.0f );

					float3 cp = cross( normal1, normal2 );

					// �@�������������Ă��邩
//					if( 0 < dot( cp.xy, aAxis[ i ] ) )
					if( 0 < cp.x + cp.y )
					{
						float dp = dot( normal1, normal2 );
						float sinTheta = length( cp );
						float theta = asin( sinTheta );

						if( dp <= 0 )
						{
							theta = PI - theta;
						}

						// ������x�ȏ�̊p�x�Ō��������Ă��邩
						if( radians( g_AngleThreshold ) < theta )
						{
							gutter ++;
						}
					}
				}
			}
		}

		{
			for( int y = 0;  y < BLOCK_HEIGHT;  y ++ )
			{
				for( int x = 0;  x < BLOCK_WIDTH;  x ++ )
				{
					float2 srcTexCoord1 = origin + invSrcTexSize.xy * float2( x, y );
//					float2 srcTexCoord2 = origin + invSrcTexSize.xy * ( float2( x, y ) + aToAdjacent[ i ] );
					float2 srcTexCoord2 = origin + invSrcTexSize.xy * float2( x + 1, y - 1 );

					float3 normal1 = normalize( tex2D( PS2TextureSampler2, srcTexCoord1 ).xyz * 2.0f - 1.0f );
					float3 normal2 = normalize( tex2D( PS2TextureSampler2, srcTexCoord2 ).xyz * 2.0f - 1.0f );

					float3 cp = cross( normal1, normal2 );

					// �@�������������Ă��邩
//					if( 0 < dot( cp.xy, aAxis[ i ] ) )
					if( 0 < cp.y - cp.x )
					{
						float dp = dot( normal1, normal2 );
						float sinTheta = length( cp );
						float theta = asin( sinTheta );

						if( dp <= 0 )
						{
							theta = PI - theta;
						}

						// ������x�ȏ�̊p�x�Ō��������Ă��邩
						if( radians( g_AngleThreshold ) < theta )
						{
							gutter ++;
						}
					}
				}
			}
		}
#endif

		if(	    BLOCK_NUM * g_GutterThreshold <= gutter
			&&  0 < paletteU
		)
		{
			bGutter = 1;
		}
	}



	output.dst = float4( ( normalize( avgNormal ) + 1.0f ) / 2, avgLight / area );
//	output.dst = float4( ( normalize( avgNormal ) + 1.0f ) / 2, avgLight );

	output.dst2 = float4( bEdge, bGutter, 0, 0 );

	return output;
}


///////////////////////////////////////////////////////////////////////////////

// �p�����[�^�����p�X

struct PS_OUTPUT_MIX
{
//	float4 RGBColor		: COLOR0;  // Pixel color

	float4 Color		: COLOR0;  // paletteU, colorNum, 0, 0
};

PS_OUTPUT_MIX RenderScenePSMix( in float2 texcoord : TEXCOORD0, uniform int mode_DispContour )
{
	PS_OUTPUT_MIX output;


	//   0
	// 2 C 3
	//   1
	const int2 aNeighborhoodUVTable[] =
	{
		{  0, -1 },
		{  0,  1 },
		{ -1,  0 },
		{  1,  0 },
	};


	// ����4�u���b�N�Ƃ�Z���𒲂ׂ�
	float bBlockEdge = 0;
#if 1
	{
		float3 pos = tex2D( PS2TextureSampler6, texcoord ).xyz;				// ���ύ��W
		float3 normal = tex2D( PS2TextureSampler1, texcoord ).xyz * 2 - 1;	// �@��

		float D = dot( normal, pos );	// ���ʃp�����[�^ -D = N�EP0

		float paletteU = tex2D( PS2TextureSampler5, texcoord ).r;	// �p���b�gU

		for( int i = 0;  i < 4;  i ++ )
		{
			float2 NbTexCoord = texcoord + invSplitTexSize.xy * aNeighborhoodUVTable[ i ];

			// �אڃ}�e���A���������ƈقȂ�A���u�אڃ}�e���A���ɃG�b�W�������Ȃ��t���O�v�������Ă���Ȃ�A��������Ȃ�
			{
				float NbPaletteU = tex2D( PS2TextureSampler5, NbTexCoord ).r;

				// �אڃ}�e���A���ɃG�b�W�������Ȃ��t���O  0 or 1
//				float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( NbPaletteU + 0.5f, PALETTE_TEX_ADJACENT_Y ) ).r;
				float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( PALETTE_TEX_ADJACENT_X + paletteU, PALETTE_TEX_ADJACENT_Y + NbPaletteU ) ).r;

				if( paletteU != NbPaletteU  &&  0 < adjacent_noEdge )
					continue;
			}


			float3 NbPos = tex2D( PS2TextureSampler6, NbTexCoord ).xyz;

//			float t = D / dot( normal, NbPos );	// 0���Z�̉\������
			float NbD = dot( normal, NbPos );

			// t �� 1 �����Ȃ�A�אڃs�N�Z���̍��W�͗��z��艜�ɂ���
//			if( t < 1.0f )

			// �אڃs�N�Z���̍��W�͗��z��艜�ɂ���
			if( NbD < D )
			{
//				float3 IdealPos = NbPos * t;	// (x,y) ���狁�߂����z�̍��W

				// �אڃs�N�Z�������z���W��艜�ɂ���Ȃ�ANbD �͕K�����̒l�i0���Z�͔������Ȃ��j
				float3 IdealPos = NbPos * ( D / NbD );	// ���z�̍��W�i���_����אڍ��W�܂ł̐����ƕ��ʂ̌�_�j

				float Sub = length( NbPos - IdealPos );	// ���z���W�Ƃ̋���

				if( g_ZThreshold <= Sub )
				{
					bBlockEdge = 1;
				}
			}
		}
	}
#endif


	// �}�e���A���G�b�W
	float bMaterialEdge = 0;
	{
		float3 pos = tex2D( PS2TextureSampler6, texcoord ).xyz;		// ���ύ��W
		float paletteU = tex2D( PS2TextureSampler5, texcoord ).r;	// �p���b�gU

		for( int i = 0;  i < 4;  i ++ )
		{
			float2 NbTexCoord = texcoord + invSplitTexSize.xy * aNeighborhoodUVTable[ i ];
			float NbPaletteU = tex2D( PS2TextureSampler5, NbTexCoord ).r;

			if( paletteU == NbPaletteU )
				continue;


			// �אڃ}�e���A���������ƈقȂ�A���u�אڃ}�e���A���ɃG�b�W�������Ȃ��t���O�v�������Ă���Ȃ�A��������Ȃ�
			{
				// �אڃ}�e���A���ɃG�b�W�������Ȃ��t���O  0 or 1
//				float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( NbPaletteU + 0.5f, PALETTE_TEX_ADJACENT_Y ) ).r;
				float adjacent_noEdge = tex2D( PS2TextureSampler4, float2( PALETTE_TEX_ADJACENT_X + paletteU, PALETTE_TEX_ADJACENT_Y + NbPaletteU ) ).r;

				if( 0 < adjacent_noEdge )
					continue;
			}


			float3 NbPos = tex2D( PS2TextureSampler6, NbTexCoord ).xyz;

			if( pos.z < NbPos.z )
			{
				bMaterialEdge = 1;
			}
		}
	}







	float paletteU = tex2D( PS2TextureSampler5, texcoord ).r + 0.5f * invSrcTexSize.z;	// �p���b�gU

#if 0
//	float areaRate = tex2D( PS2TextureSampler5, texcoord ).g;		// �ʐϔ�
	float areaRate = tex2D( PS2TextureSampler5, texcoord ).b;		// �ʐϔ�i�����ʐϊ܂ށj

	areaRate = ( areaRate * 255.0f ) / BLOCK_NUM;
#else

//	float areaNum = tex2D( PS2TextureSampler5, texcoord ).g;		// �ʐ� [ g_IgnoreCountThreshold * BLOCK_NUM / 255, BLOCK_NUM / 255 ]
	float areaNum = tex2D( PS2TextureSampler5, texcoord ).b;		// �ʐρi�����ʐϊ܂ށj


	float areaRate = smoothstep( g_IgnoreCountThreshold, 1.0f, areaNum * 255.0f / BLOCK_NUM );	// �ʐϔ� [ 0, 1 ]
	// areaRate �� 0 ���Ƃ��Ă��A���̃}�e���A���̖ʐς� 0 �Ƃ�����ł͂Ȃ��A臒l�M���M���Ƃ����Ӗ��ɂȂ�
#endif




	float light = tex2D( PS2TextureSampler1, texcoord ).a * LIGHT_RANGE;	// ���邳

	float edge = tex2D( PS2TextureSampler2, texcoord ).r;	// �G�b�W  0 or 1
	float gutter = tex2D( PS2TextureSampler2, texcoord ).g;	// �a  0 or 1

	float darkMode = tex2D( PS2TextureSampler4, float2( paletteU + 0.5f, PALETTE_TEX_DARK_Y ) ).r;	// 0, 1/255, 1 �̂����ꂩ


	float emgInfo = tex2D( PS2TextureSampler4, float2( paletteU + 0.5f, PALETTE_TEX_DARK_Y ) ).g;	// 0�`2 �r�b�g�ڂ����ꂼ�� edge, material_edge, gutter ��ON/OFF�t���O
	int emgInfo_int = (int)round( emgInfo * 255 );

	float emg_b_edge			= emgInfo_int % 2;		// 0�r�b�g��
	float emg_b_materialEdge	= emgInfo_int / 2 % 2;	// 1�r�b�g��
	float emg_b_gutter			= emgInfo_int / 4 % 2;	// 2�r�b�g��


	float AAThreshold	= tex2D( PS2TextureSampler4, float2( paletteU + 0.5f, PALETTE_TEX_AA_Y ) ).r;	// �ʐϔ䂪���̒l�ɖ����Ȃ��ꍇ��AA���������� [ 0.0, 1.0 ]
	float AASubtracter	= tex2D( PS2TextureSampler4, float2( paletteU + 0.5f, PALETTE_TEX_AA_Y ) ).g;	// AA�̋��� [ 0.0, 1.0 ]


#define SELECT	2

	float colorNum = 0;

#if SELECT == 0		// ���ǑO

	float dark = min( min( edge + bBlockEdge, 1 ) + gutter + bMaterialEdge, 1.5f );

	float coeff = light - dark * 0.5f - ( 1 - areaRate ) * 0.3f;

#elif SELECT == 1	// �K���ɉ���

//	float _bEdge = min( edge + bBlockEdge + bMaterialEdge, 1 );
	float _bEdge = min( edge + bBlockEdge, 1 );

	float _coeff = 2.0f;

	areaRate = max( areaRate, 0.5f );	// [ 0.5, 1.0 ]

	if( _bEdge != 0.0f )
	{
		areaRate = 0.5f;
	}

//	float _dark = ( 1 - areaRate ) * _bEdge * _coeff;
	float _dark = ( 1 - areaRate ) * _coeff;

//	float _gutter = gutter * _coeff;
	float _gutter = 0;

	float coeff = light - max( _dark, _gutter );

#elif SELECT == 2	// �G�b�W�p���b�g�쐬

//	float dark = min( edge + bBlockEdge + gutter + bMaterialEdge, 1 );

	float dark = min(
						  ( edge + bBlockEdge ) * emg_b_edge
						+ bMaterialEdge * emg_b_materialEdge
						+ gutter * emg_b_gutter
						, 1
					);


	if( 0 < dark )
	{
//		colorNum = 1.0f / 255;
		colorNum = darkMode;
	}


//	float areaRateThreshold = 0.5f;	// �ʐϔ䂪���̒l�ɖ����Ȃ��ꍇ��AA����������

	// AA�ɂ��u�Â��v�ւ̉e���x [ 0.0, 1.0 )
	//   �ʐϔ䂪 areaRateThreshold �ȏ�ł���΁AAARate �� 0.0 �ɂȂ�
	//   �ʐϔ䂪 areaRateThreshold �����ł���΁A�ʐϔ䂪 0.0 �ɋ߂Â��ɂ�AAARate �� 1.0 �ɋ߂Â�
	float AARate = max( 1 - areaRate - ( 1.0f - AAThreshold ), 0 ) / AAThreshold;


//	float coeff = light;
	float coeff = light - AARate * AASubtracter;

#elif SELECT == 3	// �G�b�W����\��

	float coeff = light;

#endif
#undef SELECT


//	output.RGBColor = tex2D( PS2TextureSampler4, float2( paletteU, 1 - coeff / LIGHT_RANGE ) );


	float bDark = 0;

	colorNum += tex2D( PS2TextureSampler4, float2( paletteU, 1 - coeff / LIGHT_RANGE ) ).r;

	// ���邳��񂪍ő�l�𒴂��Ȃ��悤�ɂ���
	{
		float colorNumMax = tex2D( PS2TextureSampler4, float2( paletteU, 1 ) ).r;

		if( darkMode < 1 )
		{
			// �ʏ�
			colorNum = min( colorNum, colorNumMax );
		}
		else
		{
			// �_�[�N�J���[���g�p

			if( colorNumMax < colorNum )
			{
				bDark = 1;
			}

			colorNum = min( colorNum, colorNumMax + 1.0f / 255 );
		}
	}


	output.Color = float4( paletteU, colorNum, bDark, 0 );


/*
	if( mode_DispContour == 0 )
	{
		// �֊s�\���Ȃ�
	}
	else if( mode_DispContour == 1 )
	{
		// �֊s�\���i�P�F�j

//		if( edge != 0 )
		if( gutter != 0 )
		{
			output.RGBColor = float4( 1, 0, 0, 1 );
		}
	}
*/

	return output;
}

///////////////////////////////////////////////////////////////////////////////

// �F����p�X

struct PS_OUTPUT_SELECTCOLOR
{
	float4 RGBColor		: COLOR0;  // Pixel color
};

PS_OUTPUT_SELECTCOLOR RenderScenePSSelectColor( in float2 texcoord : TEXCOORD0 )
{
	PS_OUTPUT_SELECTCOLOR output;

/*
	//   0
	// 2 C 3
	//   1
	const int2 aNeighborhoodUVTable[] =
	{
		{  0, -1 },
		{  0,  1 },
		{ -1,  0 },
		{  1,  0 },
	};
*/


#define SELECT	2

	float2 paletteUV;

#if SELECT == 0		// ���ǑO

	paletteUV = tex2D( PS2TextureSampler7, texcoord ).rg;

#elif SELECT == 1	// �K���ɉ���


	float2 palC = tex2D( PS2TextureSampler7, texcoord ).rg;
	float bDark = tex2D( PS2TextureSampler7, texcoord ).b;

//	float plusMinus = 0;
	float plus = 0;
	float minus = 0;

	bool bExistSamePal = false;


	for( int y = -1;  y <= +1;  y ++ )
	{
		for( int x = -1;  x <= +1;  x ++ )
		{
			if( x == 0  &&  y == 0 )
				continue;

			float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( x, y );

			float2 pal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;

			if( palC.x == pal.x )
			{
				// �����}�e���A��������

				if( palC.y == pal.y )
				{
					// �������邳������
					bExistSamePal = true;
				}
				else
				{
//					plusMinus += pal.y - palC.y;

					plus += max( pal.y - palC.y, 0 );
					minus += max( palC.y - pal.y, 0 );
				}
			}
		}
	}

	if( ! bExistSamePal )
	{
//		palC.y += sign( plusMinus ) * ( 1.0f / 255 );

		if( 0 < plus  &&  0 < minus )
		{
			if( 2 < max( plus, minus ) / min( plus, minus ) )
			{
				palC.y += sign( plus - minus ) * ( 1.0f / 255 );
			}
			else
			{
				// nothing
//				palC.x = 5.0f / 255;	// debug GREEN
			}
		}
		else if( 2.0f / 255 <= plus  ||  2.0f / 255 <= minus )
		{
			palC.y += sign( plus - minus ) * ( 1.0f / 255 );
		}
		else
		{
//			palC.x = 8.0f / 255;	// debug RED
		}
	}

	paletteUV = palC;

#elif SELECT == 2	// �_�[�N�����ɑΉ�

	float2 palC = tex2D( PS2TextureSampler7, texcoord ).rg;
	float bDark = tex2D( PS2TextureSampler7, texcoord ).b;

//	float plusMinus = 0;
	float plus = 0;
	float minus = 0;

	bool bExistSamePal = false;



//	const int checkStep = 5;
	#define CHECK_SAME_MATE_NUM		5
	#define CHECK_SAME_MATE_START	-2
//	#define CHECK_SAME_MATE_STEP	

	float sameMateNum[ CHECK_SAME_MATE_NUM ];

	for( int i = 0;  i < CHECK_SAME_MATE_NUM;  i ++ )
	{
		sameMateNum[ i ] = 0;
	}




	for( int y = -1;  y <= +1;  y ++ )
	{
		for( int x = -1;  x <= +1;  x ++ )
		{
			if( x == 0  &&  y == 0 )
				continue;

			float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( x, y );

			float2 pal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;

			if( palC.x == pal.x )
			{
				// �����}�e���A��������

				int sub = (int)round( ( pal.y - palC.y ) * 255 );

				if( sub <= -2 )			sameMateNum[ 0 ] ++;
				else if( sub == -1 )	sameMateNum[ 1 ] ++;
				else if( sub == 0 )		sameMateNum[ 2 ] ++;
				else if( sub == 1 )		sameMateNum[ 3 ] ++;
				else					sameMateNum[ 4 ] ++;

			}
		}
	}


	if( sameMateNum[ 2 ] == 0 )
	{
		// �������邳�̃}�e���A�����Ȃ�����

		if( ! bDark )
		{
			// �ʏ핔��

			float plus = sameMateNum[ 3 ] + sameMateNum[ 4 ];
			float minus = sameMateNum[ 0 ] + sameMateNum[ 1 ];

			if( 0 < minus  &&  0 < plus )
			{
				if( 2 < max( plus, minus ) / min( plus, minus ) )
				{
					palC.y += sign( plus - minus ) * ( 1.0f / 255 );
				}
				else
				{
					// nothing
//					palC.x = 5.0f / 255;	// debug GREEN
				}
			}
			else if( 2 <= plus  ||  2 <= minus )
			{
				palC.y += sign( plus - minus ) * ( 1.0f / 255 );
			}
			else
			{
//				palC.x = 8.0f / 255;	// debug RED
			}
		}
		else
		{
			// �_�[�N����

			int sameNum[ 9 ];

			for( int i = 0;  i < 9;  i ++ )
			{
				sameNum[ i ] = 0;
			}


			// ���͂ɓ����}�e���A�������݂���Ȃ� 1
			int bSameMaterial = min( sameMateNum[ 0 ] + sameMateNum[ 1 ] + sameMateNum[ 3 ] + sameMateNum[ 4 ], 1 );


			// ���͂ɓ����}�e���A�������݂���F
			// ���͂̓����}�e���A���̒��ŁA�ł��ʐς̑������邳��I��

			// ���͂ɓ����}�e���A�������݂��Ȃ��F
			// ���͂̃}�e���A���̒��ŁA�ł��ʐς̑����}�e���A����I��


			for( int i = 0;  i < 9;  i ++ )
			{
				int curX = i % 3 - 1;
				int curY = i / 3 - 1;

				float2 curPal;
				{
					float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( curX, curY );

					curPal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;
				}

				for( int y = -1;  y <= +1;  y ++ )
				{
					for( int x = -1;  x <= +1;  x ++ )
					{
//						if( x == 0  &&  y == 0 )
//							continue;

						float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( x, y );

						float2 pal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;

						if( curPal.x == pal.x  &&  curPal.y == pal.y )
						{
							sameNum[ i ] ++;
						}
					}
				}

				// �u���͂ɓ����}�e���A�������݂���v�̏ꍇ�A�����ƈႤ�}�e���A���͏��O����
				if( bSameMaterial  &&  curPal.x != palC.x )
				{
					sameNum[ i ] = 0;
				}
			}









/*
			if( 0 < sameMateNum[ 0 ] + sameMateNum[ 1 ] + sameMateNum[ 3 ] + sameMateNum[ 4 ] )
			{
				// ���͂ɓ����}�e���A�������݂���F
				// ���͂̓����}�e���A���̒��ŁA�ł��ʐς̑������邳��I��

				// sameNum[ i ]: �ꏊ i �̃}�e���A���������Ɠ����ꍇ�̂݁A�ꏊ i �Ɠ����}�e���A���œ������邳�̃s�N�Z����������i�������g���J�E���g�����j

				for( int i = 0;  i < 9;  i ++ )
				{
					int curX = i % 3 - 1;
					int curY = i / 3 - 1;

					float2 curPal;
					{
						float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( curX, curY );

						curPal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;
					}

					if( curPal.x == palC.x )
					{
						for( int y = -1;  y <= +1;  y ++ )
						{
							for( int x = -1;  x <= +1;  x ++ )
							{
//								if( x == 0  &&  y == 0 )
//									continue;

								float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( x, y );

								float2 pal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;

								if( curPal.x == pal.x  &&  curPal.y == pal.y )
								{
									sameNum[ i ] ++;
								}
							}
						}
					}
				}
			}
			else
			{
				// ���͂ɓ����}�e���A�������݂��Ȃ��F

				// ���͂̃}�e���A���̒��ŁA�ł��ʐς̑����}�e���A����I��
				// ���邳�́A�ŏ��ɒ��ׂ��i�܂荶��́j�s�N�Z���̂��̂��̗p

				// sameNum[ i ]: �ꏊ i �̃}�e���A���������Ɠ����ꍇ�A�ꏊ i �Ɠ����}�e���A���œ������邳�̃s�N�Z����������i�������g���J�E���g�����j

				for( int i = 0;  i < 9;  i ++ )
				{
					int curX = i % 3 - 1;
					int curY = i / 3 - 1;

					float2 curPal;
					{
						float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( curX, curY );

						curPal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;
					}

					for( int y = -1;  y <= +1;  y ++ )
					{
						for( int x = -1;  x <= +1;  x ++ )
						{
//							if( x == 0  &&  y == 0 )
//								continue;

							float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( x, y );

							float2 pal = tex2D( PS2TextureSampler7, NbTexCoord ).rg;

							if( curPal.x == pal.x  &&  curPal.y == pal.y )
							{
								sameNum[ i ] ++;
							}
						}
					}
				}
			}
*/

			int mostIndex = 0;
			int mostNum = sameNum[ 0 ];

			for( int i = 1;  i < 9;  i ++ )
			{
				if( i == 4 )
				{
					// �����̒l�͖���
					continue;
				}

				if( mostNum < sameNum[ i ] )
				{
					mostIndex = i;
					mostNum = sameNum[ i ];
				}
			}

			{
				int x = mostIndex % 3 - 1;
				int y = mostIndex / 3 - 1;

				float2 NbTexCoord = texcoord + invFinalTexSize.xy * float2( x, y );

				palC = tex2D( PS2TextureSampler7, NbTexCoord ).rg;
			}
		}
	}

	paletteUV = palC;

#endif
#undef SELECT


	// �F���̍��W�ɕϊ�
	paletteUV.x += 0.5f;
	paletteUV.y += PALETTE_TEX_COLOR_START_Y;

	// �e�N�Z���̒��S�ɕϊ�
	paletteUV.x += 0.5f * invSrcTexSize.z;

	paletteUV.y = ( round( paletteUV.y * 255.0f ) + 0.5f ) * invSrcTexSize.z;	// �l�␳���e�N�Z���̒��S�ɕϊ�


	output.RGBColor = tex2D( PS2TextureSampler4, paletteUV );

	return output;
}

///////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////
// Techniques specs follow
//////////////////////////////////////
technique Mesh
{
	pass p0
	{
		VertexShader = (vsArray[CurNumBones]);

//		PixelShader  = compile ps_3_0 RenderScenePS( true ); // trivial pixel shader (could use FF instead if desired)
		PixelShader  = (psArray[PSMode]);
	}
}


technique Analyze_CountPalette_MeanPos
{
	pass p0
	{
		PixelShader  = compile ps_3_0 RenderScenePSAnalyze_CountPalette_MeanPos();
	}
}


technique Analyze
{
	pass p0
	{
		PixelShader  = compile ps_3_0 RenderScenePSAnalyze();
	}
}


int mixPass_mode_DispContour = 0;

PixelShader mixPass_psArray[3] = {	compile ps_3_0 RenderScenePSMix( 0 ),
									compile ps_3_0 RenderScenePSMix( 1 ),
									compile ps_3_0 RenderScenePSMix( 1 ),
								};

technique Mix
{
	pass p0
	{
//		PixelShader  = compile ps_3_0 RenderScenePSMix();
		PixelShader = mixPass_psArray[ mixPass_mode_DispContour ];
	}
}

technique SelectColor
{
	pass p0
	{
		PixelShader  = compile ps_3_0 RenderScenePSSelectColor();
	}
}
