// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Raddish/ENV_VertTinted"
{
	Properties
	{
		_TintOutline("TintOutline", Color) = (0.5754717,0.5754717,0.5754717,0)
		_OutlineTintStrength("OutlineTintStrength", Float) = 0.5
		_ShadingTint("ShadingTint", Color) = (0,0,0.7803922,0)
		_ShadingVal("ShadingVal", Float) = 0.5
		_ShadingAdd("ShadingAdd", Float) = 1
		_ShadingBias("ShadingBias", Float) = 1
		_ShadowStrength("ShadowStrength", Range( 0 , 1)) = 0.5
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

		uniform float _ShadingBias;
		uniform float _ShadingAdd;
		uniform float _ShadingVal;
		uniform float4 _TintOutline;
		uniform float _OutlineTintStrength;
		uniform float4 _ShadingTint;
		uniform float _ShadowStrength;

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
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult735 = dot( ase_normWorldNormal , ase_worldlightDir );
			float Shading828 = saturate( ( ( pow( saturate( dotResult735 ) , _ShadingBias ) + _ShadingAdd ) * _ShadingVal ) );
			float4 lerpResult846 = lerp( _TintOutline , ( i.vertexColor * _TintOutline ) , _OutlineTintStrength);
			float4 lerpResult843 = lerp( ( i.vertexColor * Shading828 ) , lerpResult846 , i.vertexColor.r);
			float lerpResult851 = lerp( saturate( Shading828 ) , ase_lightAtten , _ShadowStrength);
			float4 lerpResult831 = lerp( lerpResult843 , _ShadingTint , ( 1.0 - lerpResult851 ));
			c.rgb = lerpResult831.rgb;
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
Node;AmplifyShaderEditor.CommentaryNode;773;-2049.791,-567.6915;Inherit;False;1686.487;441.541;Comment;12;828;737;739;741;743;769;740;738;736;735;734;801;MainLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;571;614.4073,-2463.35;Inherit;False;1271.351;456.8952;Comment;11;565;564;567;562;559;561;558;560;556;555;642;Light;0.9624187,1,0.1462264,1;0;0
Node;AmplifyShaderEditor.Vector3Node;555;664.407,-2272.354;Inherit;False;Property;_LightPosition;Light Position;9;0;Create;True;0;0;0;False;0;False;0,0,0;2,2,-2.05;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;556;847.8679,-2270.656;Inherit;False;View;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;558;1091.667,-2322.021;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;560;1088.409,-2225.397;Inherit;False;Property;_LightPower;LightPower;12;0;Create;True;0;0;0;False;0;False;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;561;1277.319,-2219.968;Inherit;False;Property;_LightStrength;Light Strength;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;559;1230.635,-2328.536;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;1410.858,-2327.451;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;567;1469.484,-2213.454;Inherit;False;Property;_LightColour;Light Colour;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.9852338,0.8726415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;564;1561.765,-2323.106;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;565;1713.759,-2316.594;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;800;2313.12,-958.5626;Inherit;False;-1;;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;751;626.6976,-3012.612;Inherit;False;1271.351;456.8952;Comment;11;762;761;760;759;758;757;756;755;754;753;752;Light2;0.9624187,1,0.1462264,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;762;1726.048,-2865.857;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;753;761.3144,-2944.203;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;752;675.1215,-2821.618;Inherit;False;Property;_LightPosition2;LightPosition2;13;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;758;1289.609,-2769.232;Inherit;False;Property;_LightStrength2;Light Strength2;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;754;860.1581,-2819.919;Inherit;False;View;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;757;1242.924,-2877.8;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;759;1423.147,-2876.715;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;761;1480.198,-2764.294;Inherit;False;Property;_LightColour2;Light Colour2;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;760;1574.054,-2872.37;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;788;2466.662,-767.3285;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;756;1103.957,-2871.284;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;755;1100.7,-2774.661;Inherit;False;Property;_LightPower2;LightPower2;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;808;-2288.17,-1515.611;Inherit;True;Property;_TextureSample0;Texture Sample 0;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;642;749.0242,-2394.94;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;823;-1379.101,-2070.297;Inherit;False;Property;_TintMain;TintMain;2;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;822;-1119.101,-2071.297;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;816;-1099.776,-1900.509;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;824;-918.6017,-2001.797;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;817;-1375.776,-1895.509;Inherit;False;Property;_TintSecondary;TintSecondary;3;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;814;-1121.776,-1740.11;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;836;-1119.076,-1550.156;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;839;-1614.233,-1660.862;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;837;-1357.45,-1513.409;Inherit;False;Property;_TintAlpha;TintAlpha;4;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;0.5754716,0.5754716,0.5754716,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;825;-712.2007,-1969.7;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;838;-494.8421,-1957.537;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;840;-267.0943,-2111.316;Inherit;False;Property;_SingleTint;SingleTint;18;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;812;-1799.868,-2300.175;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;734;-1995.88,-316.7449;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;735;-1729.362,-432.0827;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;736;-1547.398,-453.7605;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;738;-1336.858,-456.1198;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;740;-1138.106,-456.5539;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;769;-973.5045,-459.5354;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;743;-830.256,-458.5365;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;828;-611.5198,-471.3382;Inherit;False;Shading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;744;-240.1982,-886.0945;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;843;311.1928,-924.1835;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;801;-2004.355,-504.9407;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;554;1206.124,-1095.99;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Raddish/ENV_VertTinted;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;1;False;;3;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.LerpOp;831;894.5298,-800.8138;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;809;-652.2469,-1270.342;Inherit;False;Property;_TintOutline;TintOutline;0;0;Create;True;0;0;0;False;0;False;0.5754717,0.5754717,0.5754717,0;0.5754716,0.5754716,0.5754716,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;847;-644.4284,-1059.6;Inherit;False;Property;_OutlineTintStrength;OutlineTintStrength;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;846;27.67104,-1226.003;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;848;-295.8953,-1035.583;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;737;-1527.875,-368.6339;Inherit;False;Property;_ShadingBias;ShadingBias;8;0;Create;True;0;0;0;False;0;False;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-1332.762,-354.4076;Inherit;False;Property;_ShadingAdd;ShadingAdd;7;0;Create;True;0;0;0;False;0;False;1;0.98;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;741;-1145.886,-356.2289;Inherit;False;Property;_ShadingVal;ShadingVal;6;0;Create;True;0;0;0;False;0;False;0.5;0.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;830;538.1171,-760.8826;Inherit;False;Property;_ShadingTint;ShadingTint;5;0;Create;True;0;0;0;False;0;False;0,0,0.7803922,0;0,0,0.7803922,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;842;-627.9093,-767.2861;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;833;650.9609,-585.149;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;849;212.3915,-350.5589;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;835;304.4255,-541.338;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;832;132.5688,-545.9859;Inherit;False;828;Shading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;851;475.3915,-540.5589;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;852;219.3915,-447.5589;Inherit;False;Property;_ShadowStrength;ShadowStrength;19;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
WireConnection;556;0;555;0
WireConnection;558;0;642;0
WireConnection;558;1;556;0
WireConnection;559;0;558;0
WireConnection;559;1;560;0
WireConnection;562;0;561;0
WireConnection;562;1;559;0
WireConnection;564;0;562;0
WireConnection;565;0;567;0
WireConnection;565;1;564;0
WireConnection;762;0;761;0
WireConnection;762;1;760;0
WireConnection;754;0;752;0
WireConnection;757;0;756;0
WireConnection;757;1;755;0
WireConnection;759;0;758;0
WireConnection;759;1;757;0
WireConnection;760;0;759;0
WireConnection;788;0;800;0
WireConnection;788;2;565;0
WireConnection;756;0;753;0
WireConnection;756;1;754;0
WireConnection;822;0;812;3
WireConnection;822;1;823;0
WireConnection;816;0;812;2
WireConnection;816;1;817;0
WireConnection;824;0;822;0
WireConnection;824;1;816;0
WireConnection;824;2;812;2
WireConnection;814;0;812;1
WireConnection;836;0;839;0
WireConnection;836;1;837;0
WireConnection;839;0;812;4
WireConnection;825;0;824;0
WireConnection;825;1;814;0
WireConnection;825;2;812;1
WireConnection;838;0;825;0
WireConnection;838;1;836;0
WireConnection;838;2;839;0
WireConnection;840;1;838;0
WireConnection;840;0;812;0
WireConnection;735;0;801;0
WireConnection;735;1;734;0
WireConnection;736;0;735;0
WireConnection;738;0;736;0
WireConnection;738;1;737;0
WireConnection;740;0;738;0
WireConnection;740;1;739;0
WireConnection;769;0;740;0
WireConnection;769;1;741;0
WireConnection;743;0;769;0
WireConnection;828;0;743;0
WireConnection;744;0;842;0
WireConnection;744;1;828;0
WireConnection;843;0;744;0
WireConnection;843;1;846;0
WireConnection;843;2;842;1
WireConnection;554;13;831;0
WireConnection;831;0;843;0
WireConnection;831;1;830;0
WireConnection;831;2;833;0
WireConnection;846;0;809;0
WireConnection;846;1;848;0
WireConnection;846;2;847;0
WireConnection;848;0;842;0
WireConnection;848;1;809;0
WireConnection;833;0;851;0
WireConnection;835;0;832;0
WireConnection;851;0;835;0
WireConnection;851;1;849;0
WireConnection;851;2;852;0
ASEEND*/
//CHKSM=A71D66280A27632582139F5ECEB03CB6E33F2921