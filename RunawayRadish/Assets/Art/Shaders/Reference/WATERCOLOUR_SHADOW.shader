// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BIA/Lit_V2"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_NormTex("NormTex", 2D) = "bump" {}
		[Toggle]_NormSwitch("NormSwitch", Float) = 1
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
		_DotVal("Dot Val", Float) = 0
		_DotAdd("DotAdd", Float) = 0
		_DotBias("DotBias", Float) = 0
		_ShadowVal("Shadow Val", Float) = 0
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
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _NormSwitch;
		uniform sampler2D _NormTex;
		uniform float4 _NormTex_ST;
		uniform float _DotBias;
		uniform float _DotAdd;
		uniform float _DotVal;
		uniform float4 _ShadowColor;
		uniform float _ShadowVal;

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
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float2 uv_NormTex = i.uv_texcoord * _NormTex_ST.xy + _NormTex_ST.zw;
			float3 Normals590 = (( _NormSwitch )?( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormTex, uv_NormTex ) ) )) ) ):( ase_normWorldNormal ));
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult735 = dot( Normals590 , ase_worldlightDir );
			float temp_output_736_0 = saturate( dotResult735 );
			float temp_output_743_0 = saturate( ( ( pow( temp_output_736_0 , _DotBias ) + _DotAdd ) * _DotVal ) );
			float4 Diffuse640 = ( tex2D( _MainTex, uv_MainTex ) * temp_output_743_0 );
			float4 lerpResult720 = lerp( _ShadowColor , Diffuse640 , ase_lightAtten);
			float4 lerpResult725 = lerp( Diffuse640 , lerpResult720 , _ShadowVal);
			c.rgb = lerpResult725.rgb;
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
			o.Normal = float3(0,0,1);
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
Version=18707
0;0;1920;1029;382.6715;528.8857;1.483035;True;False
Node;AmplifyShaderEditor.CommentaryNode;577;-1109.316,-2144.985;Inherit;False;1183.375;365.2927;Comment;4;590;587;581;803;Normals;1,0.2216981,0.8386045,1;0;0
Node;AmplifyShaderEditor.SamplerNode;581;-1070.29,-2033.625;Inherit;True;Property;_NormTex;NormTex;1;0;Create;True;0;0;False;0;False;-1;None;4c892ebf7284cd944b7e63ae6f20eb32;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;587;-667.41,-1948.289;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;801;-670.1901,-2095.477;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ToggleSwitchNode;803;-427.1901,-2010.477;Inherit;False;Property;_NormSwitch;NormSwitch;2;0;Create;True;0;0;False;0;False;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;590;-175.4514,-2005.252;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;773;-1772.817,-857.4876;Inherit;False;2360.844;741.8618;Comment;14;745;735;734;736;740;769;738;737;739;741;743;744;640;434;MainLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;734;-1391.284,-330.7912;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;745;-1361.774,-455.6638;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;735;-1124.766,-446.1288;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-923.2788,-382.68;Inherit;False;Property;_DotBias;DotBias;8;0;Create;True;0;0;False;0;False;0;0.69;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;736;-942.8019,-467.8067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;738;-732.2621,-470.166;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-728.1659,-368.4538;Inherit;False;Property;_DotAdd;DotAdd;7;0;Create;True;0;0;False;0;False;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;740;-533.5099,-470.6001;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-541.2897,-370.2751;Inherit;False;Property;_DotVal;Dot Val;6;0;Create;True;0;0;False;0;False;0;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;786;706.0175,-981.0801;Inherit;False;1304.114;733.9809;;14;776;777;779;780;781;783;782;767;785;772;768;711;791;790;ROUGHNESS;0.4150943,0.4150943,0.4150943,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;571;413.7632,-1557.166;Inherit;False;1271.351;456.8952;Comment;11;565;564;567;562;559;561;558;560;556;555;642;Light;0.9624187,1,0.1462264,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;769;-368.9088,-473.5816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;711;764.0175,-485.0994;Inherit;True;Property;_ROM_Tex;ROM_Tex;3;0;Create;True;0;0;False;0;False;-1;None;3b9860678e7414746b725a9818b60262;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;712;496.623,198.5551;Inherit;False;1336.916;605.7261;Comment;15;732;721;725;720;717;733;710;719;718;724;715;713;792;797;798;Shadow Tinting;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;743;-225.6606,-472.5827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;555;463.763,-1366.172;Inherit;False;Property;_LightPosition;Light Position;17;0;Create;True;0;0;False;0;False;0,0,0;2,2,-2.05;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;434;-436.3921,-814.9041;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;False;0;False;-1;None;5b2d59784c2bec24985950b2dfdf5274;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;792;568.0641,256.1712;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;711;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;713;853.687,363.499;Inherit;False;Property;_AoPow;AoPow;26;0;Create;True;0;0;False;0;False;0;1.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;42.96577,-660.7921;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;556;647.224,-1364.473;Inherit;False;View;World;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;768;1058.179,-477.7972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;642;548.3803,-1488.757;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;772;875.0922,-574.3334;Inherit;False;Property;_RoughnessStrength;RoughnessStrength;4;0;Create;True;0;0;False;0;False;0;0.306;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;558;891.0222,-1415.838;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;767;1094.379,-854.5949;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;715;1017.438,308.3913;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;560;887.7651,-1319.215;Inherit;False;Property;_LightPower;LightPower;20;0;Create;True;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;782;878.8427,-778.4141;Inherit;False;Constant;_Float0;Float 0;32;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;783;814.3566,-698.0253;Inherit;False;Constant;_SpecularPower;SpecularPower;32;0;Create;True;0;0;False;0;False;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;640;246.2294,-711.0945;Inherit;False;Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;776;1065.015,-931.08;Inherit;False;Blinn-Phong Half Vector;-1;;3;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;785;1236.63,-568.7387;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;1076.673,-1313.786;Inherit;False;Property;_LightStrength;Light Strength;19;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;781;1288.633,-758.3666;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;733;802.9702,531.9083;Inherit;False;640;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;777;1352.766,-898.7983;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;559;1029.988,-1422.354;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;797;1167.503,322.167;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;710;544.1044,465.4666;Inherit;False;Property;_ShadowColor;Shadow Color;5;0;Create;True;0;0;False;0;False;0,0,0,0;0.4678745,0.09019609,0.7176471,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;717;742.3218,641.5765;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;720;1027.331,504.6468;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;779;1516.636,-850.6788;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;719;1104.498,242.9422;Inherit;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;721;1017.214,678.617;Inherit;False;Property;_ShadowVal;Shadow Val;16;0;Create;True;0;0;False;0;False;0;7.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;1210.211,-1421.269;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;798;1339.742,327.6351;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;718;1204.251,459.8308;Inherit;False;Property;_AoVal;AoVal;25;0;Create;True;0;0;False;0;False;0;0.407;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;724;1522.747,268.0063;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;780;1668.718,-784.4648;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;725;1281.444,630.7262;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;567;1268.838,-1307.272;Inherit;False;Property;_LightColour;Light Colour;18;0;Create;True;0;0;False;0;False;0,0,0,0;1,0.9852338,0.8726415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;564;1361.118,-1416.924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;643;-2852.111,624.3817;Inherit;False;916.4257;603.3906;;6;654;652;648;655;645;644;Fresnel;1,0.9858432,0.8632076,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;444;-4130.457,1332.43;Inherit;False;2330.867;492.6041;Matcap;13;430;437;433;457;439;432;440;428;427;426;425;589;641;;0.8730345,0.6839622,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;565;1513.112,-1410.411;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;800;2313.12,-958.5626;Inherit;False;640;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;732;1680.289,338.4386;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;790;1858.184,-790.5576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;751;426.0536,-2106.428;Inherit;False;1271.351;456.8952;Comment;11;762;761;760;759;758;757;756;755;754;753;752;Light2;0.9624187,1,0.1462264,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;762;1525.402,-1959.673;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;645;-2819.463,781.1932;Half;False;Property;_FresnelPow;Fresnel Pow;15;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;753;560.6705,-2038.019;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;752;474.4775,-1915.434;Inherit;False;Property;_LightPosition2;LightPosition2;21;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;654;-2206.132,818.1575;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;791;1746.603,-536.8752;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;-2426.688,1468.408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;655;-2609.507,703.5783;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;641;-2556.407,1385.875;Inherit;False;640;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;439;-2689.741,1471.358;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;758;1088.963,-1863.048;Inherit;False;Property;_LightStrength2;Light Strength2;23;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;426;-3644.619,1428.237;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;427;-3413.495,1427.237;Inherit;False;ConstantBiasScale;-1;;4;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-2540.005,972.2341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;589;-4065.492,1427.477;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;754;659.5142,-1913.735;Inherit;False;View;World;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;757;1042.278,-1971.616;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-3120.493,1703.542;Inherit;False;Property;_MatcapMax;Matcap Max;14;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;433;-2257.112,1469.236;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;644;-2815.323,682.4406;Half;False;Property;_FresnelScale;Fresnel Scale;13;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;425;-3855.52,1435.537;Inherit;False;World;View;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;759;1222.501,-1970.531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;793;350.2774,-279.437;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;761;1279.552,-1858.11;Inherit;False;Property;_LightColour2;Light Colour2;22;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;760;1373.408,-1966.186;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;428;-3137.319,1392.59;Inherit;True;Property;_Matcap;Matcap;10;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;788;2466.662,-767.3285;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;437;-2005.647,1407.868;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-2626.4,1693.893;Inherit;False;Property;_MatcapVal;Matcap Val;9;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;756;903.3125,-1965.1;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;432;-3113.335,1609.247;Inherit;False;Property;_MatcapMin;Matcap Min;12;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;900.0555,-1868.477;Inherit;False;Property;_LightPower2;LightPower2;24;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;648;-2802.337,970.5394;Half;False;Property;_FresnelTint;FresnelTint;11;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;554;2800.445,-1023.609;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BIA/Lit_V2;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;1;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;587;0;581;0
WireConnection;803;0;801;0
WireConnection;803;1;587;0
WireConnection;590;0;803;0
WireConnection;735;0;745;0
WireConnection;735;1;734;0
WireConnection;736;0;735;0
WireConnection;738;0;736;0
WireConnection;738;1;737;0
WireConnection;740;0;738;0
WireConnection;740;1;739;0
WireConnection;769;0;740;0
WireConnection;769;1;741;0
WireConnection;743;0;769;0
WireConnection;744;0;434;0
WireConnection;744;1;743;0
WireConnection;556;0;555;0
WireConnection;768;0;711;1
WireConnection;558;0;642;0
WireConnection;558;1;556;0
WireConnection;715;0;792;2
WireConnection;715;1;713;0
WireConnection;640;0;744;0
WireConnection;785;0;772;0
WireConnection;785;1;768;0
WireConnection;781;0;782;0
WireConnection;781;1;783;0
WireConnection;781;2;785;0
WireConnection;777;0;776;0
WireConnection;777;1;767;0
WireConnection;559;0;558;0
WireConnection;559;1;560;0
WireConnection;797;0;715;0
WireConnection;720;0;710;0
WireConnection;720;1;733;0
WireConnection;720;2;717;0
WireConnection;779;0;777;0
WireConnection;779;1;781;0
WireConnection;562;0;561;0
WireConnection;562;1;559;0
WireConnection;798;0;797;0
WireConnection;798;1;710;0
WireConnection;724;0;719;0
WireConnection;724;1;798;0
WireConnection;724;2;718;0
WireConnection;780;0;779;0
WireConnection;780;1;736;0
WireConnection;780;2;785;0
WireConnection;780;3;711;2
WireConnection;725;0;733;0
WireConnection;725;1;720;0
WireConnection;725;2;721;0
WireConnection;564;0;562;0
WireConnection;565;0;567;0
WireConnection;565;1;564;0
WireConnection;732;0;724;0
WireConnection;732;1;725;0
WireConnection;790;0;780;0
WireConnection;762;0;761;0
WireConnection;762;1;760;0
WireConnection;654;0;437;0
WireConnection;654;1;652;0
WireConnection;654;2;655;0
WireConnection;791;2;711;2
WireConnection;457;0;641;0
WireConnection;457;1;439;0
WireConnection;655;2;644;0
WireConnection;655;3;645;0
WireConnection;439;0;428;0
WireConnection;439;3;432;0
WireConnection;439;4;440;0
WireConnection;426;0;425;0
WireConnection;427;3;426;0
WireConnection;652;0;437;0
WireConnection;652;1;648;0
WireConnection;754;0;752;0
WireConnection;757;0;756;0
WireConnection;757;1;755;0
WireConnection;433;0;457;0
WireConnection;425;0;589;0
WireConnection;759;0;758;0
WireConnection;759;1;757;0
WireConnection;793;2;743;0
WireConnection;760;0;759;0
WireConnection;428;1;427;0
WireConnection;788;0;800;0
WireConnection;788;1;790;0
WireConnection;788;2;732;0
WireConnection;788;3;565;0
WireConnection;437;0;641;0
WireConnection;437;1;433;0
WireConnection;437;2;430;0
WireConnection;756;0;753;0
WireConnection;756;1;754;0
WireConnection;554;13;788;0
WireConnection;554;15;725;0
ASEEND*/
//CHKSM=4B8239267AB6E517E4921BA0148FE28F8597A9C3