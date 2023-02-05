// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Raddish/VertexMasking"
{
	Properties
	{
		_TintMain("TintMain", Color) = (0.5754717,0.5754717,0.5754717,0)
		_TintSecondary("TintSecondary", Color) = (0.5754717,0.5754717,0.5754717,0)
		_TintAlpha("TintAlpha", Color) = (0.5754717,0.5754717,0.5754717,0)
		_TintOutline("TintOutline", Color) = (0.5754717,0.5754717,0.5754717,0)
		_DotVal("Dot Val", Float) = 0.5
		_DotAdd("DotAdd", Float) = 1
		_DotBias("DotBias", Float) = 1
		_TintShadow("TintShadow", Color) = (0,0,0.7803922,0)
		[Toggle(_SINGLETINT_ON)] _SingleTint("SingleTint", Float) = 1
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
		#pragma shader_feature_local _SINGLETINT_ON
		struct Input
		{
			float4 vertexColor : COLOR;
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

		uniform float4 _TintMain;
		uniform float4 _TintSecondary;
		uniform float4 _TintOutline;
		uniform float4 _TintAlpha;
		uniform float4 _TintShadow;
		uniform float _DotBias;
		uniform float _DotAdd;
		uniform float _DotVal;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 lerpResult824 = lerp( ( i.vertexColor.b * _TintMain ) , ( i.vertexColor.g * _TintSecondary ) , i.vertexColor.g);
			float4 lerpResult825 = lerp( lerpResult824 , ( i.vertexColor.r * _TintOutline ) , i.vertexColor.r);
			float temp_output_839_0 = ( 1.0 - i.vertexColor.a );
			float4 lerpResult838 = lerp( lerpResult825 , ( temp_output_839_0 * _TintAlpha ) , temp_output_839_0);
			#ifdef _SINGLETINT_ON
				float4 staticSwitch840 = i.vertexColor;
			#else
				float4 staticSwitch840 = lerpResult838;
			#endif
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 Normals590 = ase_normWorldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult735 = dot( Normals590 , ase_worldlightDir );
			float temp_output_736_0 = saturate( dotResult735 );
			float temp_output_743_0 = saturate( ( ( pow( temp_output_736_0 , _DotBias ) + _DotAdd ) * _DotVal ) );
			float Shading828 = temp_output_743_0;
			float4 lerpResult831 = lerp( staticSwitch840 , _TintShadow , ( 1.0 - saturate( Shading828 ) ));
			float4 Output821 = lerpResult831;
			c.rgb = Output821.rgb;
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				half4 color : COLOR0;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				surfIN.vertexColor = IN.color;
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
Node;AmplifyShaderEditor.CommentaryNode;577;-3221.685,-1064.024;Inherit;False;1183.375;365.2927;Comment;5;590;587;581;803;801;Normals;1,0.2216981,0.8386045,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;773;-1772.817,-857.4876;Inherit;False;2360.844;741.8618;Comment;14;745;735;734;736;740;769;738;737;739;741;743;744;640;828;MainLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;786;706.0175,-981.0801;Inherit;False;1304.114;733.9809;;14;776;777;779;780;781;783;782;767;785;772;768;711;791;790;ROUGHNESS;0.4150943,0.4150943,0.4150943,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;571;413.7632,-1557.166;Inherit;False;1271.351;456.8952;Comment;11;565;564;567;562;559;561;558;560;556;555;642;Light;0.9624187,1,0.1462264,1;0;0
Node;AmplifyShaderEditor.SamplerNode;711;764.0175,-485.0994;Inherit;True;Property;_ROM_Tex;ROM_Tex;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;712;321.2464,609.3055;Inherit;False;1336.916;605.7261;Comment;15;732;721;725;720;717;733;710;719;718;724;715;713;792;797;798;Shadow Tinting;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;555;463.763,-1366.172;Inherit;False;Property;_LightPosition;Light Position;18;0;Create;True;0;0;0;False;0;False;0,0,0;2,2,-2.05;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;42.96577,-660.7921;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;556;647.224,-1364.473;Inherit;False;View;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;768;1058.179,-477.7972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;772;875.0922,-574.3334;Inherit;False;Property;_RoughnessStrength;RoughnessStrength;7;0;Create;True;0;0;0;False;0;False;0;0.306;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;558;891.0222,-1415.838;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;767;1094.379,-854.5949;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;560;887.7651,-1319.215;Inherit;False;Property;_LightPower;LightPower;22;0;Create;True;0;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;782;878.8427,-778.4141;Inherit;False;Constant;_Float0;Float 0;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;783;814.3566,-698.0253;Inherit;False;Constant;_SpecularPower;SpecularPower;32;0;Create;True;0;0;0;False;0;False;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;776;1065.015,-931.08;Inherit;False;Blinn-Phong Half Vector;-1;;3;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;785;1236.63,-568.7387;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;1076.673,-1313.786;Inherit;False;Property;_LightStrength;Light Strength;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;781;1288.633,-758.3666;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;777;1352.766,-898.7983;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;559;1029.988,-1422.354;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;779;1516.636,-850.6788;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;1210.211,-1421.269;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;780;1668.718,-784.4648;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;567;1268.838,-1307.272;Inherit;False;Property;_LightColour;Light Colour;19;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.9852338,0.8726415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;564;1361.118,-1416.924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;643;-2852.111,624.3817;Inherit;False;916.4257;603.3906;;6;654;652;648;655;645;644;Fresnel;1,0.9858432,0.8632076,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;444;-4130.457,1332.43;Inherit;False;2330.867;492.6041;Matcap;13;430;437;433;457;439;432;440;428;427;426;425;589;641;;0.8730345,0.6839622,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;565;1513.112,-1410.411;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;800;2313.12,-958.5626;Inherit;False;640;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;790;1858.184,-790.5576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;751;426.0536,-2106.428;Inherit;False;1271.351;456.8952;Comment;11;762;761;760;759;758;757;756;755;754;753;752;Light2;0.9624187,1,0.1462264,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;762;1525.402,-1959.673;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;645;-2819.463,781.1932;Half;False;Property;_FresnelPow;Fresnel Pow;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;753;560.6705,-2038.019;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;752;474.4775,-1915.434;Inherit;False;Property;_LightPosition2;LightPosition2;23;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;654;-2206.132,818.1575;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;791;1746.603,-536.8752;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;457;-2426.688,1468.408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;655;-2609.507,703.5783;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;641;-2556.407,1385.875;Inherit;False;640;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;439;-2689.741,1471.358;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;758;1088.963,-1863.048;Inherit;False;Property;_LightStrength2;Light Strength2;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;426;-3644.619,1428.237;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;427;-3413.495,1427.237;Inherit;False;ConstantBiasScale;-1;;4;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-2540.005,972.2341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;589;-4065.492,1427.477;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;754;659.5142,-1913.735;Inherit;False;View;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;757;1042.278,-1971.616;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-3120.493,1703.542;Inherit;False;Property;_MatcapMax;Matcap Max;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;433;-2257.112,1469.236;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;644;-2815.323,682.4406;Half;False;Property;_FresnelScale;Fresnel Scale;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;425;-3855.52,1435.537;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;759;1222.501,-1970.531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;761;1279.552,-1858.11;Inherit;False;Property;_LightColour2;Light Colour2;24;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;760;1373.408,-1966.186;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;428;-3137.319,1392.59;Inherit;True;Property;_Matcap;Matcap;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;788;2466.662,-767.3285;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;437;-2005.647,1407.868;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-2626.4,1693.893;Inherit;False;Property;_MatcapVal;Matcap Val;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;756;903.3125,-1965.1;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;432;-3113.335,1609.247;Inherit;False;Property;_MatcapMin;Matcap Min;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;900.0555,-1868.477;Inherit;False;Property;_LightPower2;LightPower2;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;648;-2802.337,970.5394;Half;False;Property;_FresnelTint;FresnelTint;13;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;581;-3182.659,-952.6637;Inherit;True;Property;_NormTex;NormTex;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;587;-2779.779,-867.3282;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ToggleSwitchNode;803;-2539.559,-929.5159;Inherit;False;Property;_NormSwitch;NormSwitch;5;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;808;-2288.17,-1515.611;Inherit;True;Property;_TextureSample0;Texture Sample 0;29;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;642;548.3803,-1488.757;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;590;-2287.82,-924.2908;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;801;-2780.559,-1022.93;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;715;842.0614,719.1417;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;797;992.1263,732.9175;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;710;368.7278,876.2172;Inherit;False;Property;_ShadowColor;Shadow Color;30;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4678745,0.09019609,0.7176471,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;798;1164.365,738.3855;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;718;1028.874,870.5813;Inherit;False;Property;_AoVal;AoVal;27;0;Create;True;0;0;0;False;0;False;0;0.407;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;724;1347.37,678.7567;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;721;841.8374,1089.368;Inherit;False;Property;_ShadowVal;Shadow Val;31;0;Create;True;0;0;0;False;0;False;1;7.44;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;713;692.3104,783.2495;Inherit;False;Property;_AoPow;AoPow;28;0;Create;True;0;0;0;False;0;False;0;1.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;792;392.6875,666.9216;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;711;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;733;576.9609,968.296;Inherit;False;640;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;725;1110.114,965.2334;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;732;1554.995,756.1663;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;717;414.9452,1130.327;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;720;755.9545,882.3973;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;719;1033.121,601.6926;Inherit;False;Property;_NANI;NANI;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;811;448.2211,364.7565;Inherit;True;Property;_ROM;ROM;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;554;2888.552,-498.3857;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Raddish/VertexMasking;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;1;False;;3;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;805;2664.552,-130.3858;Inherit;False;821;Output;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;823;-1241.329,-1548.731;Inherit;False;Property;_TintMain;TintMain;0;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;734;-1391.284,-330.7912;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;735;-1124.766,-446.1288;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;736;-942.8019,-467.8067;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;738;-732.2621,-470.166;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;740;-533.5099,-470.6001;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;769;-368.9088,-473.5816;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;743;-225.6606,-472.5827;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;745;-1361.774,-455.6638;Inherit;False;590;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-541.2897,-370.2751;Inherit;False;Property;_DotVal;Dot Val;8;0;Create;True;0;0;0;False;0;False;0.5;0.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-728.1659,-368.4538;Inherit;False;Property;_DotAdd;DotAdd;9;0;Create;True;0;0;0;False;0;False;1;0.98;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-923.2788,-382.68;Inherit;False;Property;_DotBias;DotBias;10;0;Create;True;0;0;0;False;0;False;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;822;-981.3289,-1549.731;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;816;-962.0042,-1378.943;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;824;-780.8289,-1480.231;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;817;-1238.004,-1373.943;Inherit;False;Property;_TintSecondary;TintSecondary;1;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;814;-984.0041,-1218.544;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;836;-981.3036,-1028.59;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;809;-1222.378,-1181.797;Inherit;False;Property;_TintOutline;TintOutline;3;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;0.5754716,0.5754716,0.5754716,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;839;-1476.461,-1139.296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;837;-1219.678,-991.8427;Inherit;False;Property;_TintAlpha;TintAlpha;2;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;0.5754716,0.5754716,0.5754716,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;825;-574.428,-1448.134;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;838;-357.07,-1435.971;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;640;285.1042,-663.4394;Inherit;False;Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;828;85.77307,-418.2531;Inherit;False;Shading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;835;-407.018,-982.2351;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;832;-578.8742,-986.8831;Inherit;False;828;Shading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;833;-261.483,-983.0461;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;830;-300.3268,-1174.78;Inherit;False;Property;_TintShadow;TintShadow;33;0;Create;True;0;0;0;False;0;False;0,0,0.7803922,0;0,0,0.7803922,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;831;56.08613,-1214.711;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;840;-129.3224,-1589.749;Inherit;False;Property;_SingleTint;SingleTint;34;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;821;233.272,-1228.994;Inherit;False;Output;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;812;-1633.219,-1720.856;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;744;0;825;0
WireConnection;744;1;743;0
WireConnection;556;0;555;0
WireConnection;768;0;711;1
WireConnection;558;0;642;0
WireConnection;558;1;556;0
WireConnection;785;0;772;0
WireConnection;785;1;768;0
WireConnection;781;0;782;0
WireConnection;781;1;783;0
WireConnection;781;2;785;0
WireConnection;777;0;776;0
WireConnection;777;1;767;0
WireConnection;559;0;558;0
WireConnection;559;1;560;0
WireConnection;779;0;777;0
WireConnection;779;1;781;0
WireConnection;562;0;561;0
WireConnection;562;1;559;0
WireConnection;780;0;779;0
WireConnection;780;1;736;0
WireConnection;780;2;785;0
WireConnection;780;3;711;2
WireConnection;564;0;562;0
WireConnection;565;0;567;0
WireConnection;565;1;564;0
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
WireConnection;760;0;759;0
WireConnection;428;1;427;0
WireConnection;788;0;800;0
WireConnection;788;1;790;0
WireConnection;788;2;565;0
WireConnection;437;0;641;0
WireConnection;437;1;433;0
WireConnection;437;2;430;0
WireConnection;756;0;753;0
WireConnection;756;1;754;0
WireConnection;587;0;581;0
WireConnection;803;0;801;0
WireConnection;803;1;587;0
WireConnection;590;0;801;0
WireConnection;715;1;713;0
WireConnection;797;0;715;0
WireConnection;798;0;797;0
WireConnection;798;1;710;0
WireConnection;724;0;719;0
WireConnection;724;1;798;0
WireConnection;724;2;718;0
WireConnection;725;0;733;0
WireConnection;725;1;720;0
WireConnection;725;2;721;0
WireConnection;732;0;724;0
WireConnection;732;1;725;0
WireConnection;720;0;710;0
WireConnection;720;1;733;0
WireConnection;720;2;717;0
WireConnection;554;13;805;0
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
WireConnection;822;0;812;3
WireConnection;822;1;823;0
WireConnection;816;0;812;2
WireConnection;816;1;817;0
WireConnection;824;0;822;0
WireConnection;824;1;816;0
WireConnection;824;2;812;2
WireConnection;814;0;812;1
WireConnection;814;1;809;0
WireConnection;836;0;839;0
WireConnection;836;1;837;0
WireConnection;839;0;812;4
WireConnection;825;0;824;0
WireConnection;825;1;814;0
WireConnection;825;2;812;1
WireConnection;838;0;825;0
WireConnection;838;1;836;0
WireConnection;838;2;839;0
WireConnection;640;0;744;0
WireConnection;828;0;743;0
WireConnection;835;0;832;0
WireConnection;833;0;835;0
WireConnection;831;0;840;0
WireConnection;831;1;830;0
WireConnection;831;2;833;0
WireConnection;840;1;838;0
WireConnection;840;0;812;0
WireConnection;821;0;831;0
ASEEND*/
//CHKSM=175CB2732B2CE996F01542BA615DA45708630FC1