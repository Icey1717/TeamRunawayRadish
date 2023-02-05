// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AnimalWarfare/Character_Galaxy_Shader"
{
	Properties
	{
		_TeamTint("Team Tint", Color) = (1,1,1,0)
		_TeamTintVal("Team Tint Val", Range( 0 , 1)) = 0
		_MainColor("Main Color", Color) = (1,1,1,0)
		_SecondaryColor("Secondary Color", Color) = (1,1,1,0)
		_SecondaryPow("Secondary Pow", Range( 0.01 , 10)) = 0
		[Toggle]_RoundedSecondary("Rounded Secondary", Float) = 1
		[Toggle]_InvertSecondayMask("Invert Seconday Mask", Float) = 0
		_ShadowColor("Shadow Color", Color) = (0.1697372,0.1164115,0.2264151,0)
		_ShadowVal("Shadow Val", Range( 0 , 1)) = 1
		_WorldDotPow("World Dot Pow", Float) = 0
		_WorldDotAdd("World Dot Add", Float) = 0
		_WorldDotVal("World Dot Val", Range( 0 , 1)) = 0
		_MatcapTex("Matcap Tex", 2D) = "white" {}
		_MatcapColor("Matcap Color", Color) = (1,1,1,0)
		_MatcapRound("Matcap Round", Range( 0 , 1)) = 0
		_MatcapRoundPow("Matcap Round Pow", Range( 0.01 , 10)) = 0
		_MatcapVal("Matcap Val", Range( 0 , 1)) = 0
		_MatcapRoundLevelUp("Matcap Round LevelUp", Float) = 0.5
		_FresnelColor("Fresnel Color", Color) = (1,1,1,0)
		_FrenselPow("Frensel Pow", Range( 0.01 , 10)) = 1
		_FrenselScale("Frensel Scale", Range( 1 , 10)) = 1
		_FrenselVal("Frensel Val", Range( 0 , 1)) = 1
		_FresnelMaskVal("Fresnel Mask Val", Range( 0 , 1)) = 0
		_ObjectGradVal("Object Grad Val", Range( 0 , 1)) = 0
		_ObjectGradPow("Object Grad Pow", Range( 0.01 , 10)) = 0
		_SheenTEX("Sheen TEX", 2D) = "white" {}
		_SheenOrient("Sheen Orient", Vector) = (-0.5,0.5,0,0)
		_SheenPan("Sheen Pan", Vector) = (0,0,0,0)
		_SheenVal("Sheen Val", Range( 0 , 1)) = 0
		_DissolveTEX("Dissolve TEX", 2D) = "white" {}
		_DissolveUV("Dissolve UV", Vector) = (0,0,0,0)
		_ShimmerUV("Shimmer UV", Vector) = (0,0,0,0)
		_ShimmerPan("Shimmer Pan", Vector) = (0,0,0,0)
		_TintBody("TintBody", Color) = (1,1,1,0)
		_TintFeet("TintFeet", Color) = (1,1,1,0)
		_TintMist("TintMist", Color) = (1,1,1,0)
		_Star("Star", 2D) = "white" {}
		_StarsTint("StarsTint", Color) = (0,0,0,0)
		_StarsWarp("StarsWarp", Range( 0 , 1)) = 0.5
		_StarsScale("StarsScale", Float) = 0.5
		[Toggle]_GRAD_XY("GRAD_XY", Float) = 0
		_Grad_Height("Grad_Height", Range( -2 , 5)) = 0
		_Grad_Blur("Grad_Blur", Range( 0 , 2)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			half3 worldNormal;
			float4 vertexColor : COLOR;
			float4 screenPos;
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

		uniform sampler2D _DissolveTEX;
		uniform half2 _ShimmerPan;
		uniform half2 _ShimmerUV;
		uniform half4 _TintFeet;
		uniform half4 _TintBody;
		uniform half4 _TintMist;
		uniform half2 _DissolveUV;
		uniform half _Grad_Height;
		uniform half _Grad_Blur;
		uniform half _GRAD_XY;
		uniform sampler2D _SheenTEX;
		uniform half2 _SheenPan;
		uniform half4 _SheenTEX_ST;
		uniform half3 _SheenOrient;
		uniform half _SheenVal;
		uniform half4 _FresnelColor;
		uniform half _FrenselScale;
		uniform half _FrenselPow;
		uniform half _ObjectGradPow;
		uniform half _FresnelMaskVal;
		uniform half _FrenselVal;
		uniform half4 _ShadowColor;
		uniform half _ObjectGradVal;
		uniform half4 _SecondaryColor;
		uniform half4 _MainColor;
		uniform half _RoundedSecondary;
		uniform half _SecondaryPow;
		uniform half4 _TeamTint;
		uniform half _InvertSecondayMask;
		uniform half _TeamTintVal;
		uniform half _WorldDotPow;
		uniform half _WorldDotAdd;
		uniform half _WorldDotVal;
		uniform half4 _MatcapColor;
		uniform sampler2D _MatcapTex;
		uniform half4 _MatcapTex_ST;
		uniform half _MatcapRoundPow;
		uniform half _MatcapRound;
		uniform half _MatcapRoundLevelUp;
		uniform half _MatcapVal;
		uniform half _ShadowVal;
		uniform half4 _StarsTint;
		uniform sampler2D _Star;
		uniform half _StarsWarp;
		uniform half _StarsScale;

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
			half2 panner365 = ( 1.0 * _Time.y * _ShimmerPan + ( _ShimmerUV * i.uv_texcoord ));
			half4 tex2DNode333 = tex2D( _DissolveTEX, ( _DissolveUV * i.uv_texcoord ) );
			half4 lerpResult413 = lerp( _TintBody , _TintMist , tex2DNode333);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			half smoothstepResult479 = smoothstep( ( _Grad_Height - _Grad_Blur ) , ( _Grad_Height + _Grad_Blur ) , (( _GRAD_XY )?( ase_vertex3Pos.y ):( ( 1.0 - ase_vertex3Pos.x ) )));
			half4 lerpResult402 = lerp( _TintFeet , lerpResult413 , saturate( smoothstepResult479 ));
			half4 Tint387 = lerpResult402;
			half3 normalizeResult302 = normalize( ase_vertex3Pos );
			half3 normalizeResult301 = normalize( _SheenOrient );
			half2 panner270 = ( 1.0 * _Time.y * _SheenPan + ( _SheenTEX_ST.xy * (cross( normalizeResult302 , normalizeResult301 )).yz ));
			half4 clampResult392 = clamp( tex2DNode333 , float4( 0.01,0,0,0 ) , float4( 1,0,0,0 ) );
			half4 temp_cast_0 = (1.0).xxxx;
			half4 temp_output_394_0 = step( clampResult392 , temp_cast_0 );
			half4 lerpResult320 = lerp( _FresnelColor , Tint387 , temp_output_394_0);
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 ase_worldNormal = i.worldNormal;
			half fresnelNdotV104 = dot( ase_worldNormal, ase_worldViewDir );
			half fresnelNode104 = ( 1.0 + ( 1.0 - _FrenselScale ) * pow( 1.0 - fresnelNdotV104, _FrenselPow ) );
			half temp_output_111_0 = ( 1.0 - fresnelNode104 );
			half temp_output_174_0 = pow( i.uv_texcoord.y , _ObjectGradPow );
			half lerpResult194 = lerp( temp_output_111_0 , ( temp_output_111_0 * temp_output_174_0 ) , _FresnelMaskVal);
			half4 temp_cast_1 = (1.0).xxxx;
			half4 lerpResult168 = lerp( temp_cast_1 , ( temp_output_174_0 + _ShadowColor ) , _ObjectGradVal);
			half temp_output_225_0 = pow( ( 1.0 - i.vertexColor.r ) , _SecondaryPow );
			half4 lerpResult220 = lerp( _SecondaryColor , _MainColor , (( _RoundedSecondary )?( round( temp_output_225_0 ) ):( temp_output_225_0 )));
			half lerpResult245 = lerp( 0.0 , 1.0 , (( _RoundedSecondary )?( round( temp_output_225_0 ) ):( temp_output_225_0 )));
			half lerpResult249 = lerp( 1.0 , 0.0 , (( _RoundedSecondary )?( round( temp_output_225_0 ) ):( temp_output_225_0 )));
			half temp_output_252_0 = saturate( ( (( _InvertSecondayMask )?( lerpResult249 ):( lerpResult245 )) + 0.75 ) );
			half4 lerpResult208 = lerp( lerpResult220 , ( _TeamTint * temp_output_252_0 ) , _TeamTintVal);
			half4 temp_cast_2 = (1.0).xxxx;
			half4 lerpResult316 = lerp( lerpResult208 , ( Tint387 * temp_output_252_0 ) , temp_output_394_0);
			half3 lerpResult213 = lerp( half3(0.45,0.4,0.55) , float3( 1,1,1 ) , i.vertexColor.b);
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			half3 ase_worldlightDir = 0;
			#else //aseld
			half3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half dotResult6 = dot( ase_worldNormal , ase_worldlightDir );
			half3 worldToViewDir52 = mul( UNITY_MATRIX_V, float4( ase_worldNormal, 0 ) ).xyz;
			half4 temp_output_113_0 = ( _MatcapColor * tex2D( _MatcapTex, ( ( ( ( (worldToViewDir52).xy * 0.5 ) + 0.5 ) * _MatcapTex_ST.xy ) + _MatcapTex_ST.zw ) ) );
			half4 temp_cast_4 = (_MatcapRoundPow).xxxx;
			half4 temp_cast_5 = (1.0).xxxx;
			half lerpResult376 = lerp( _MatcapRound , _MatcapRoundLevelUp , temp_output_394_0.r);
			half4 lerpResult128 = lerp( temp_output_113_0 , ( temp_output_113_0 + round( pow( temp_output_113_0 , temp_cast_4 ) ) ) , lerpResult376);
			half4 temp_output_32_0 = ( ( ( lerpResult316 * half4( lerpResult213 , 0.0 ) ) * saturate( ( ( pow( saturate( dotResult6 ) , _WorldDotPow ) + _WorldDotAdd ) * _WorldDotVal ) ) ) + saturate( ( lerpResult128 * _MatcapVal ) ) );
			half4 lerpResult14 = lerp( _ShadowColor , temp_output_32_0 , ase_lightAtten);
			half4 lerpResult135 = lerp( temp_output_32_0 , lerpResult14 , _ShadowVal);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			half2 appendResult442 = (half2(ase_screenPosNorm.x , ase_screenPosNorm.y));
			half2 lerpResult445 = lerp( appendResult442 , i.uv_texcoord , _StarsWarp);
			c.rgb = ( ( ( tex2D( _DissolveTEX, panner365 ).r * Tint387 ) + ( saturate( ( pow( tex2D( _SheenTEX, panner270 ).a , _SheenVal ) - ( 1.0 - _SheenVal ) ) ) + ( ( lerpResult320 * saturate( lerpResult194 ) * _FrenselVal ) + ( lerpResult168 * lerpResult135 ) ) ) ) + ( _StarsTint * tex2D( _Star, ( lerpResult445 * _StarsScale ) ).a ) ).rgb;
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
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19103
Node;AmplifyShaderEditor.WorldNormalVector;7;-3924.904,402.7202;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;180;-3801.112,813.7916;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;189;-4656.484,865.5024;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;127;-4732.535,17.67366;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;188;-4703.962,1142.03;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;177;-4620.303,995.3326;Inherit;False;2983.621;759.7833;Comment;23;54;48;49;128;129;131;130;132;113;133;41;114;159;158;157;46;156;45;47;44;52;376;377;Matcap;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformDirectionNode;52;-4499.877,1145.126;Inherit;False;World;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;226;-4606.167,-132.3451;Inherit;False;Property;_SecondaryPow;Secondary Pow;4;0;Create;True;0;0;0;False;0;False;0;1.59;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;236;-4461.781,-7.532471;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;411;-3624.733,-3343.352;Inherit;False;1437.487;803.3117;Comment;15;387;402;397;481;413;479;412;398;477;476;478;475;482;474;473;Galaxy Tint;1,0.07843138,0.9294118,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;44;-4170.664,1141.037;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;225;-4248.867,-152.733;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-4203.87,1284.321;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;375;-4628.673,-2372.716;Inherit;False;2641.509;939.6659;Comment;17;361;386;357;365;370;371;369;394;392;393;333;325;329;368;385;318;316;LevelUp;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;385;-4492.49,-1627.77;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;156;-4274.354,1404.772;Inherit;True;Property;_MatcapTex;Matcap Tex;12;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-3940.875,1146.7;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RoundOpNode;223;-4029.738,-32.27741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;368;-4128.502,-1807.735;Inherit;False;Property;_DissolveUV;Dissolve UV;30;0;Create;True;0;0;0;False;0;False;0,0;0.63,1.57;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureTransformNode;157;-3966.923,1565.071;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.ToggleSwitchNode;238;-3867.405,-156.7099;Inherit;False;Property;_RoundedSecondary;Rounded Secondary;5;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;329;-3845.847,-1695.319;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-3771.527,1239.529;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;325;-4505.787,-1938.414;Inherit;True;Property;_DissolveTEX;Dissolve TEX;29;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-3615.731,1485.318;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;333;-3480.817,-1949.362;Inherit;True;Property;_TextureSample0;Texture Sample 0;24;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;249;-3361.52,-119.6781;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;245;-3359.947,-251.5428;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-3440.835,1563.671;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;246;-3116.633,-191.889;Inherit;False;Property;_InvertSecondayMask;Invert Seconday Mask;6;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;178;-3610.827,300.8856;Inherit;False;1649.91;625.9037;Comment;10;27;18;20;19;16;21;17;26;6;5;Custom Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;253;-2957.862,-545.7193;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;114;-3218.083,1173.156;Inherit;False;Property;_MatcapColor;Matcap Color;13;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-3268.935,1403.19;Inherit;True;Property;_Tex2;Tex 2;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;5;-3459.294,662.0977;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;6;-3111.917,403.9923;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-2953.154,1289.266;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;15;-4378.287,-370.8341;Inherit;False;Property;_MainColor;Main Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.9433962,0.806816,0.3515486,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;221;-4378.074,-553.9211;Inherit;False;Property;_SecondaryColor;Secondary Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5566038,0.4441999,0.1969117,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;209;-3121.08,-884.6154;Inherit;False;Property;_TeamTint;Team Tint;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.4449537,0.6104838,0.9528302,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;252;-2801.512,-546.2856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-3183.533,1621.728;Inherit;False;Property;_MatcapRoundPow;Matcap Round Pow;15;0;Create;True;0;0;0;False;0;False;0;0.4;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;-3297.803,-1708.806;Inherit;False;Constant;_TintVal;TintVal;34;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;220;-3539.903,-381.029;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;175;-1192.215,-1334.708;Inherit;False;1379.244;771.2534;Comment;14;181;111;106;110;182;105;184;183;104;112;107;108;192;194;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;26;-2953.529,404.8998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;386;-3214.648,-1590.817;Inherit;False;387;Tint;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-2791.835,-280.2094;Inherit;False;Property;_TeamTintVal;Team Tint Val;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;132;-2774.85,1441.647;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;392;-3164.318,-1912.814;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.01,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3021.777,547.8035;Inherit;False;Property;_WorldDotPow;World Dot Pow;9;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;250;-2603.155,-569.3903;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-2885.214,1170.233;Inherit;False;Property;_MatcapRound;Matcap Round;14;0;Create;True;0;0;0;False;0;False;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;255;441.4925,-1847.58;Inherit;False;1956.653;743.7006;Comment;17;266;270;271;278;277;300;297;301;302;298;296;272;308;309;310;314;340;Sheen;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1181.137,-1237.622;Inherit;False;Property;_FrenselScale;Frensel Scale;20;0;Create;True;0;0;0;False;0;False;1;2.41;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;208;-2425.514,-388.0386;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;394;-3009.979,-1896.331;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;16;-2749.292,403.1516;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;130;-2602.6,1451.103;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;219;-3794.319,-32.97575;Half;False;Constant;_Vector0;Vector 0;20;0;Create;True;0;0;0;False;0;False;0.45,0.4,0.55;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;318;-2645.035,-1652.661;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-2906.249,1056.849;Inherit;False;Property;_MatcapRoundLevelUp;Matcap Round LevelUp;17;0;Create;True;0;0;0;False;0;False;0.5;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2928.301,650.9023;Inherit;False;Property;_WorldDotAdd;World Dot Add;10;0;Create;True;0;0;0;False;0;False;0;1.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-2563.163,464.9813;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2853.416,766.0541;Inherit;False;Property;_WorldDotVal;World Dot Val;11;0;Create;True;0;0;0;False;0;False;0;0.7;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;213;-2735.846,54.79396;Inherit;False;3;0;FLOAT3;1,0,0;False;1;FLOAT3;1,1,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;-2418.79,1379.169;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;316;-2288.216,-1674.222;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;112;-883.8082,-1232.075;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1100.258,-998.661;Inherit;False;Property;_FrenselPow;Frensel Pow;19;0;Create;True;0;0;0;False;0;False;1;2.12;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;376;-2515.06,1064.915;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-2408.56,555.9289;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;104;-686.1334,-1085.501;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-1974.946,-402.5447;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;128;-2249.229,1292.645;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2374.118,1503.431;Inherit;False;Property;_MatcapVal;Matcap Val;16;0;Create;True;0;0;0;False;0;False;0;0.395;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;278;648.1968,-1787.951;Inherit;True;Property;_SheenTEX;Sheen TEX;25;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.WireNode;187;-1874.091,115.2504;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;27;-2227.667,553.6251;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;183;-449.6912,-909.9623;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2043.404,1381.727;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;179;-1805.83,-483.4833;Inherit;False;2000.594;783.0706;Comment;13;115;135;10;14;168;167;172;169;165;174;173;12;190;Shadow Tinting;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;54;-1888.573,1380.387;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1884.19,329.828;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;184;-1151.506,-886.6351;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1703.246,390.9571;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;271;1135.876,-1360.14;Inherit;False;Property;_SheenPan;Sheen Pan;27;0;Create;True;0;0;0;False;0;False;0,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;111;-1110.682,-823.1298;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-1716.517,-218.2049;Inherit;False;Property;_ShadowColor;Shadow Color;7;0;Create;True;0;0;0;False;0;False;0.1697372,0.1164115,0.2264151,0;0.3247431,0.2142666,0.4245283,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;270;1481.879,-1491.558;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LightAttenuation;10;-1704.499,-18.16489;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;185;-675.2361,367.5122;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-842.3069,-702.0576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-652.4003,-665.3383;Inherit;False;Property;_FresnelMaskVal;Fresnel Mask Val;22;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;471;1327.685,-2800.668;Inherit;False;1353.759;522.2905;;10;460;461;416;463;445;464;442;441;446;435;Stars;1,0.9896944,0.745283,1;0;0
Node;AmplifyShaderEditor.Vector2Node;369;-4096.958,-2214.275;Inherit;False;Property;_ShimmerUV;Shimmer UV;31;0;Create;True;0;0;0;False;0;False;0,0;-0.22,0.52;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;167;-757.2208,-122.9903;Inherit;False;Property;_ObjectGradVal;Object Grad Val;23;0;Create;True;0;0;0;False;0;False;0;0.372;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-622.9048,-369.4589;Inherit;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;266;1695.291,-1790.745;Inherit;True;Property;_1;1;24;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;105;-501.7236,-1281.837;Inherit;False;Property;_FresnelColor;Fresnel Color;18;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,0.1981132,0.9464403,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;194;-375.6858,-835.8375;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;309;1507.501,-1219.078;Inherit;False;Property;_SheenVal;Sheen Val;28;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-1179.907,71.03241;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-467.6161,179.2541;Inherit;False;Property;_ShadowVal;Shadow Val;8;0;Create;True;0;0;0;False;0;False;1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;190;-573.1669,44.00706;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;172;-606.5186,-233.9034;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;340;2020.864,-1539.018;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;168;-275.0993,-258.9715;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;320;-204.693,-1497.105;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;135;-21.9016,58.05907;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-316.1567,-659.6111;Inherit;False;Property;_FrenselVal;Frensel Val;21;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;182;-188.4798,-943.4741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;310;1879.779,-1213.308;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;371;-4089.948,-2054.811;Inherit;False;Property;_ShimmerPan;Shimmer Pan;32;0;Create;True;0;0;0;False;0;False;0,0;0.02,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-3853.386,-2145.933;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;47.61133,-966.7174;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;365;-3674.646,-2070.584;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;290.416,-87.19602;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;308;2211.445,-1335.855;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;357;-3481.075,-2175.476;Inherit;True;Property;_TextureSample1;Texture Sample 1;24;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;254;450.8699,-959.8895;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;314;2210.257,-1205.119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;361;-2625.669,-2003.551;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;306;2511.636,-975.347;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;2556.446,-2134.781;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;417;2913.598,-2116.718;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3813.582,-2609.779;Half;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;AnimalWarfare/Character_Galaxy_Shader;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0.887241,0.6980392,1,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-1416.244,-287.4995;Inherit;False;Property;_ObjectGradPow;Object Grad Pow;24;0;Create;True;0;0;0;False;0;False;0;1.54;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;174;-1022.032,-357.5275;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;165;-1393.321,-431.0369;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;473;-3548.8,-2952.267;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;475;-3420.964,-2790.205;Inherit;False;Property;_Grad_Height;Grad_Height;41;0;Create;True;0;0;0;False;0;False;0;1.81;-2;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;474;-3421.362,-2683.314;Inherit;False;Property;_Grad_Blur;Grad_Blur;42;0;Create;True;0;0;0;False;0;False;0.5;0.997;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;482;-3314.935,-2928.235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;477;-3054.602,-2804.832;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;476;-3113.588,-2924.981;Inherit;False;Property;_GRAD_XY;GRAD_XY;40;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;478;-3035.26,-2705.155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;412;-3421.932,-3123.519;Inherit;False;Property;_TintMist;TintMist;35;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.4810929,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;398;-3416.729,-3308.714;Inherit;False;Property;_TintBody;TintBody;33;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.364706,0.7793129,0.9921569,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;479;-2869.838,-2816.534;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;397;-2940.357,-3284.705;Inherit;False;Property;_TintFeet;TintFeet;34;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.01814956,0,0.2169811,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;481;-2770.935,-2986.235;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;413;-3121.272,-3219.469;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;402;-2662.35,-3210.856;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;387;-2422.266,-3207.312;Inherit;False;Tint;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;298;466.1082,-1387.068;Inherit;False;Property;_SheenOrient;Sheen Orient;26;0;Create;True;0;0;0;False;0;False;-0.5,0.5,0;-0.25,2,-0.5;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;296;478.0897,-1540.307;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;302;710.0352,-1541.241;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;301;710.0352,-1382.695;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;297;895.882,-1476.08;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;300;1084.443,-1481.222;Inherit;False;False;True;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureTransformNode;277;956.4064,-1649.568;Inherit;False;-1;False;1;0;SAMPLER2D;;False;2;FLOAT2;0;FLOAT2;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;1312.966,-1565.026;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;435;1377.685,-2750.668;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;442;1592.78,-2683.205;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;446;1387.44,-2574.653;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;441;1383.266,-2447.982;Inherit;False;Property;_StarsWarp;StarsWarp;38;0;Create;True;0;0;0;False;0;False;0.5;0.048;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;464;1759.438,-2459.384;Inherit;False;Property;_StarsScale;StarsScale;39;0;Create;True;0;0;0;False;0;False;0.5;4.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;445;1761.133,-2617.076;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;463;1952.289,-2602.5;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;461;2142.628,-2716.575;Inherit;False;Property;_StarsTint;StarsTint;37;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.8396226,0.9305452,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;416;2134.983,-2519.296;Inherit;True;Property;_Star;Star;36;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;460;2500.118,-2600.389;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
WireConnection;180;0;7;0
WireConnection;189;0;180;0
WireConnection;188;0;189;0
WireConnection;52;0;188;0
WireConnection;236;0;127;1
WireConnection;44;0;52;0
WireConnection;225;0;236;0
WireConnection;225;1;226;0
WireConnection;45;0;44;0
WireConnection;45;1;47;0
WireConnection;223;0;225;0
WireConnection;157;0;156;0
WireConnection;238;0;225;0
WireConnection;238;1;223;0
WireConnection;329;0;368;0
WireConnection;329;1;385;0
WireConnection;46;0;45;0
WireConnection;46;1;47;0
WireConnection;158;0;46;0
WireConnection;158;1;157;0
WireConnection;333;0;325;0
WireConnection;333;1;329;0
WireConnection;249;2;238;0
WireConnection;245;2;238;0
WireConnection;159;0;158;0
WireConnection;159;1;157;1
WireConnection;246;0;245;0
WireConnection;246;1;249;0
WireConnection;253;0;246;0
WireConnection;41;0;156;0
WireConnection;41;1;159;0
WireConnection;6;0;7;0
WireConnection;6;1;5;0
WireConnection;113;0;114;0
WireConnection;113;1;41;0
WireConnection;252;0;253;0
WireConnection;220;0;221;0
WireConnection;220;1;15;0
WireConnection;220;2;238;0
WireConnection;26;0;6;0
WireConnection;132;0;113;0
WireConnection;132;1;133;0
WireConnection;392;0;333;0
WireConnection;250;0;209;0
WireConnection;250;1;252;0
WireConnection;208;0;220;0
WireConnection;208;1;250;0
WireConnection;208;2;210;0
WireConnection;394;0;392;0
WireConnection;394;1;393;0
WireConnection;16;0;26;0
WireConnection;16;1;17;0
WireConnection;130;0;132;0
WireConnection;318;0;386;0
WireConnection;318;1;252;0
WireConnection;20;0;16;0
WireConnection;20;1;21;0
WireConnection;213;0;219;0
WireConnection;213;2;127;3
WireConnection;131;0;113;0
WireConnection;131;1;130;0
WireConnection;316;0;208;0
WireConnection;316;1;318;0
WireConnection;316;2;394;0
WireConnection;112;0;108;0
WireConnection;376;0;129;0
WireConnection;376;1;377;0
WireConnection;376;2;394;0
WireConnection;18;0;20;0
WireConnection;18;1;19;0
WireConnection;104;2;112;0
WireConnection;104;3;107;0
WireConnection;126;0;316;0
WireConnection;126;1;213;0
WireConnection;128;0;113;0
WireConnection;128;1;131;0
WireConnection;128;2;376;0
WireConnection;187;0;126;0
WireConnection;27;0;18;0
WireConnection;183;0;104;0
WireConnection;48;0;128;0
WireConnection;48;1;49;0
WireConnection;54;0;48;0
WireConnection;8;0;187;0
WireConnection;8;1;27;0
WireConnection;184;0;183;0
WireConnection;32;0;8;0
WireConnection;32;1;54;0
WireConnection;111;0;184;0
WireConnection;270;0;272;0
WireConnection;270;2;271;0
WireConnection;185;0;32;0
WireConnection;181;0;111;0
WireConnection;181;1;174;0
WireConnection;266;0;278;0
WireConnection;266;1;270;0
WireConnection;194;0;111;0
WireConnection;194;1;181;0
WireConnection;194;2;192;0
WireConnection;14;0;12;0
WireConnection;14;1;32;0
WireConnection;14;2;10;0
WireConnection;190;0;185;0
WireConnection;172;0;174;0
WireConnection;172;1;12;0
WireConnection;340;0;266;4
WireConnection;340;1;309;0
WireConnection;168;0;169;0
WireConnection;168;1;172;0
WireConnection;168;2;167;0
WireConnection;320;0;105;0
WireConnection;320;1;386;0
WireConnection;320;2;394;0
WireConnection;135;0;190;0
WireConnection;135;1;14;0
WireConnection;135;2;115;0
WireConnection;182;0;194;0
WireConnection;310;0;309;0
WireConnection;370;0;369;0
WireConnection;370;1;385;0
WireConnection;106;0;320;0
WireConnection;106;1;182;0
WireConnection;106;2;110;0
WireConnection;365;0;370;0
WireConnection;365;2;371;0
WireConnection;170;0;168;0
WireConnection;170;1;135;0
WireConnection;308;0;340;0
WireConnection;308;1;310;0
WireConnection;357;0;325;0
WireConnection;357;1;365;0
WireConnection;254;0;106;0
WireConnection;254;1;170;0
WireConnection;314;0;308;0
WireConnection;361;0;357;1
WireConnection;361;1;386;0
WireConnection;306;0;314;0
WireConnection;306;1;254;0
WireConnection;360;0;361;0
WireConnection;360;1;306;0
WireConnection;417;0;360;0
WireConnection;417;1;460;0
WireConnection;0;13;417;0
WireConnection;174;0;165;2
WireConnection;174;1;173;0
WireConnection;482;0;473;1
WireConnection;477;0;475;0
WireConnection;477;1;474;0
WireConnection;476;0;482;0
WireConnection;476;1;473;2
WireConnection;478;0;475;0
WireConnection;478;1;474;0
WireConnection;479;0;476;0
WireConnection;479;1;477;0
WireConnection;479;2;478;0
WireConnection;481;0;479;0
WireConnection;413;0;398;0
WireConnection;413;1;412;0
WireConnection;413;2;333;0
WireConnection;402;0;397;0
WireConnection;402;1;413;0
WireConnection;402;2;481;0
WireConnection;387;0;402;0
WireConnection;302;0;296;0
WireConnection;301;0;298;0
WireConnection;297;0;302;0
WireConnection;297;1;301;0
WireConnection;300;0;297;0
WireConnection;277;0;278;0
WireConnection;272;0;277;0
WireConnection;272;1;300;0
WireConnection;442;0;435;1
WireConnection;442;1;435;2
WireConnection;445;0;442;0
WireConnection;445;1;446;0
WireConnection;445;2;441;0
WireConnection;463;0;445;0
WireConnection;463;1;464;0
WireConnection;416;1;463;0
WireConnection;460;0;461;0
WireConnection;460;1;416;4
ASEEND*/
//CHKSM=CE1984BCA2E42F5BC4A71E74D17F526A0185DCE3