// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Raddish/ENV_NoiseTex"
{
	Properties
	{
		_TintMain("TintMain", Color) = (0.5754717,0.5754717,0.5754717,0)
		_TintGradient("TintGradient", Color) = (0.254717,0.254717,0.254717,0)
		_ShadingTint("ShadingTint", Color) = (0,0,0.7803922,0)
		_ShadingVal("ShadingVal", Float) = 0.5
		_ShadingAdd("ShadingAdd", Float) = 1
		_ShadingBias("ShadingBias", Float) = 1
		_ShadowStrength("ShadowStrength", Range( 0 , 1)) = 0.5
		[Toggle]_GRAD_XY("GRAD_XY", Float) = 1
		_Grad_Height("Grad_Height", Range( -2 , 5)) = 0
		_Grad_Blur("Grad_Blur", Range( 0 , 4)) = 0.5
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseTexStrength("NoiseTexStrength", Range( 0 , 1)) = 0
		_LightPosition("Light Position", Vector) = (0,1,1,0)
		_LightColour("Light Colour", Color) = (0,0,0,0)
		_LightAdd("LightAdd", Float) = 0.05
		_LightVal("LightVal", Float) = 0.5
		_LightBias("LightBias", Float) = 1.5
		[Toggle(_LIGHTONEMINUS_ON)] _LightOneMinus("LightOneMinus", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		ZWrite On
		ZTest LEqual
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _LIGHTONEMINUS_ON
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _NoiseTex;
		uniform float4 _NoiseTex_ST;
		uniform float4 _LightColour;
		uniform float3 _LightPosition;
		uniform float _LightBias;
		uniform float _LightAdd;
		uniform float _LightVal;
		uniform float _ShadingBias;
		uniform float _ShadingAdd;
		uniform float _ShadingVal;
		uniform float _ShadowStrength;
		uniform float4 _TintMain;
		uniform float4 _TintGradient;
		uniform float _Grad_Height;
		uniform float _Grad_Blur;
		uniform float _GRAD_XY;
		uniform float4 _ShadingTint;
		uniform float _NoiseTexStrength;


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_NoiseTex = i.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 viewToWorldDir902 = ASESafeNormalize( mul( UNITY_MATRIX_I_V, float4( _LightPosition, 0 ) ).xyz );
			float dotResult933 = dot( ase_normWorldNormal , viewToWorldDir902 );
			float temp_output_937_0 = saturate( ( ( pow( saturate( dotResult933 ) , _LightBias ) + _LightAdd ) * _LightVal ) );
			#ifdef _LIGHTONEMINUS_ON
				float staticSwitch948 = ( 1.0 - temp_output_937_0 );
			#else
				float staticSwitch948 = temp_output_937_0;
			#endif
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult735 = dot( ase_normWorldNormal , ase_worldlightDir );
			float Shading828 = saturate( ( ( pow( saturate( dotResult735 ) , _ShadingBias ) + _ShadingAdd ) * _ShadingVal ) );
			float lerpResult851 = lerp( saturate( Shading828 ) , ase_lightAtten , _ShadowStrength);
			float temp_output_833_0 = ( 1.0 - lerpResult851 );
			float lerpResult954 = lerp( ase_lightAtten , temp_output_833_0 , 0.15);
			float ShadowDirection924 = lerpResult954;
			float4 lerpResult930 = lerp( float4( 0,0,0,0 ) , ( _LightColour * staticSwitch948 ) , ShadowDirection924);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float smoothstepResult872 = smoothstep( ( _Grad_Height - _Grad_Blur ) , ( _Grad_Height + _Grad_Blur ) , (( _GRAD_XY )?( ase_vertex3Pos.y ):( ( 1.0 - ase_vertex3Pos.x ) )));
			float4 lerpResult876 = lerp( _TintMain , _TintGradient , ( 1.0 - saturate( smoothstepResult872 ) ));
			float4 temp_output_855_0 = ( lerpResult876 * Shading828 );
			float4 temp_output_912_0 = ( lerpResult930 + temp_output_855_0 );
			float4 lerpResult831 = lerp( temp_output_912_0 , _ShadingTint , temp_output_833_0);
			float4 lerpResult896 = lerp( ( tex2D( _NoiseTex, uv_NoiseTex ) * lerpResult831 ) , lerpResult831 , ( 1.0 - _NoiseTexStrength ));
			c.rgb = lerpResult896.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19103
Node;AmplifyShaderEditor.CommentaryNode;919;1240.064,-1523.953;Inherit;False;903.2378;402.6237;Comment;5;884;897;898;896;882;NoiseTex;0.7993677,0.645283,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;880;607.7068,-902.5841;Inherit;False;904.3382;645.4066;Comment;8;830;833;849;835;832;851;852;831;Shadow;0.4566038,0.5622443,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;773;-2049.791,-567.6915;Inherit;False;1686.487;441.541;Comment;12;828;737;739;741;743;769;740;738;736;735;734;801;MainLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;862;-1940.076,-1558.58;Inherit;False;1437.487;803.3117;Comment;13;876;874;873;872;869;868;867;866;865;864;863;879;823;Dif;1,0.07843138,0.9294118,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;855;-200.8862,-709.735;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;863;-1904.526,-1184.581;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;864;-1776.691,-1022.519;Inherit;False;Property;_Grad_Height;Grad_Height;8;0;Create;True;0;0;0;False;0;False;0;1.81;-2;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;867;-1410.328,-1037.146;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;869;-1390.986,-937.4673;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;872;-1225.565,-1048.848;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;873;-1502.783,-1472.819;Inherit;False;Property;_TintGradient;TintGradient;1;0;Create;True;0;0;0;False;0;False;0.254717,0.254717,0.254717,0;0.1960784,0.1843137,0.1843137,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;868;-1480.314,-1182.295;Inherit;False;Property;_GRAD_XY;GRAD_XY;7;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;866;-1691.662,-1244.549;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;876;-740.2006,-1113.567;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;874;-1041.363,-1062.227;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;879;-899.8423,-1070.742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;865;-1777.089,-915.6262;Inherit;False;Property;_Grad_Blur;Grad_Blur;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;823;-1798.994,-1482.484;Inherit;False;Property;_TintMain;TintMain;0;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;0.1981132,0.1844072,0.1844072,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;830;1063.255,-777.9011;Inherit;False;Property;_ShadingTint;ShadingTint;2;0;Create;True;0;0;0;False;0;False;0,0,0.7803922,0;0.03732051,0.03732051,0.1603774,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;849;737.5295,-367.5771;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;835;829.5641,-558.3564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;832;657.7068,-563.0043;Inherit;False;828;Shading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;851;1000.53,-557.5773;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;852;744.5295,-464.5773;Inherit;False;Property;_ShadowStrength;ShadowStrength;6;0;Create;True;0;0;0;False;0;False;0.5;0.58;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;554;2549.694,-1544.936;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Raddish/ENV_NoiseTex;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;1;False;;3;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;916;-261.2843,-1126.563;Inherit;False;Property;_LightOPacity;LightOPacity;12;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;897;1324.574,-1236.729;Inherit;False;Property;_NoiseTexStrength;NoiseTexStrength;11;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;898;1624.873,-1247.129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;896;1961.302,-1307.891;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;882;1290.064,-1473.953;Inherit;True;Property;_NoiseTex;NoiseTex;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;912;76.32554,-1305.486;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;831;1322.232,-848.6774;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;884;1664.705,-1381.907;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;915;251.475,-1301.643;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;735;-1729.362,-432.0827;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;736;-1547.398,-453.7605;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;738;-1336.858,-456.1198;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;769;-973.5045,-459.5354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;743;-830.256,-458.5365;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-1527.875,-368.6339;Inherit;False;Property;_ShadingBias;ShadingBias;5;0;Create;True;0;0;0;False;0;False;1;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-1145.886,-356.2289;Inherit;False;Property;_ShadingVal;ShadingVal;3;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;828;-611.5198,-471.3382;Inherit;False;Shading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;801;-2004.355,-504.9407;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;740;-1138.106,-456.5539;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-1332.762,-354.4076;Inherit;False;Property;_ShadingAdd;ShadingAdd;4;0;Create;True;0;0;0;False;0;False;1;1.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;734;-1995.88,-316.7449;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;932;-1680.264,-3018.71;Inherit;False;1686.487;441.541;Comment;9;942;941;937;936;935;934;933;902;948;MainLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;933;-1359.835,-2883.102;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;934;-1177.871,-2904.78;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;935;-967.3312,-2907.139;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;936;-603.9777,-2910.554;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;937;-460.7291,-2909.556;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;941;-1634.828,-2955.96;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;942;-768.5791,-2907.573;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;904;-1248.618,-2779.591;Inherit;False;Property;_LightBias;LightBias;17;0;Create;True;0;0;0;False;0;False;1.5;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;918;-1077.125,-2787.126;Inherit;False;Property;_LightAdd;LightAdd;15;0;Create;True;0;0;0;False;0;False;0.05;1.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;905;-922.639,-2786.735;Inherit;False;Property;_LightVal;LightVal;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;908;-747.9229,-2787.827;Inherit;False;Property;_LightColour;Light Colour;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.9852338,0.8726415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;910;19.32921,-2942.402;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;947;447.3167,-2898.72;Inherit;False;Debug;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;945;-341.1884,-2792.529;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;948;-208.5481,-2938.125;Inherit;False;Property;_LightOneMinus;LightOneMinus;18;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;902;-1635.694,-2783.856;Inherit;False;View;World;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;901;-1879.735,-2772.092;Inherit;False;Property;_LightPosition;Light Position;13;0;Create;True;0;0;0;False;0;False;0,1,1;2,2,-2.05;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;931;-274.3878,-2679.506;Inherit;False;924;ShadowDirection;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;946;2309.615,-1174.815;Inherit;False;947;Debug;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;930;221.0491,-2882.445;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;924;1514.88,-487.2907;Inherit;False;ShadowDirection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;954;1324.987,-467.959;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;833;1169.599,-566.2672;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;953;924.9867,-241.959;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
WireConnection;855;0;876;0
WireConnection;855;1;828;0
WireConnection;867;0;864;0
WireConnection;867;1;865;0
WireConnection;869;0;864;0
WireConnection;869;1;865;0
WireConnection;872;0;868;0
WireConnection;872;1;867;0
WireConnection;872;2;869;0
WireConnection;868;0;866;0
WireConnection;868;1;863;2
WireConnection;866;0;863;1
WireConnection;876;0;823;0
WireConnection;876;1;873;0
WireConnection;876;2;879;0
WireConnection;874;0;872;0
WireConnection;879;0;874;0
WireConnection;835;0;832;0
WireConnection;851;0;835;0
WireConnection;851;1;849;0
WireConnection;851;2;852;0
WireConnection;554;13;896;0
WireConnection;898;0;897;0
WireConnection;896;0;884;0
WireConnection;896;1;831;0
WireConnection;896;2;898;0
WireConnection;912;0;930;0
WireConnection;912;1;855;0
WireConnection;831;0;912;0
WireConnection;831;1;830;0
WireConnection;831;2;833;0
WireConnection;884;0;882;0
WireConnection;884;1;831;0
WireConnection;915;0;855;0
WireConnection;915;1;912;0
WireConnection;915;2;916;0
WireConnection;735;0;801;0
WireConnection;735;1;734;0
WireConnection;736;0;735;0
WireConnection;738;0;736;0
WireConnection;738;1;737;0
WireConnection;769;0;740;0
WireConnection;769;1;741;0
WireConnection;743;0;769;0
WireConnection;828;0;743;0
WireConnection;740;0;738;0
WireConnection;740;1;739;0
WireConnection;933;0;941;0
WireConnection;933;1;902;0
WireConnection;934;0;933;0
WireConnection;935;0;934;0
WireConnection;935;1;904;0
WireConnection;936;0;942;0
WireConnection;936;1;905;0
WireConnection;937;0;936;0
WireConnection;942;0;935;0
WireConnection;942;1;918;0
WireConnection;910;0;908;0
WireConnection;910;1;948;0
WireConnection;947;0;930;0
WireConnection;945;0;937;0
WireConnection;948;1;937;0
WireConnection;948;0;945;0
WireConnection;902;0;901;0
WireConnection;930;1;910;0
WireConnection;930;2;931;0
WireConnection;924;0;954;0
WireConnection;954;0;849;0
WireConnection;954;1;833;0
WireConnection;954;2;953;0
WireConnection;833;0;851;0
ASEEND*/
//CHKSM=431F71CC82DD4A3EDC31EDF69E5C7E4C3D84770B