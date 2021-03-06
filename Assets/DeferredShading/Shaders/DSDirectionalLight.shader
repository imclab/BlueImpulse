﻿Shader "DeferredShading/DSDirectionalLight" {

Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
}
SubShader {
	Tags { "RenderType"="Opaque" }
	Blend One One
	ZTest Always
	ZWrite Off
	Cull Back

	CGINCLUDE
	#include "Compat.cginc"

	sampler2D g_normal_buffer;
	sampler2D g_position_buffer;
	sampler2D _ColorBuffer;
	sampler2D g_glow_buffer;
	float4 _LightColor;
	float4 _LightDir;
	float4 _ShadowParams; // [0]: 0=disabled, [1]: steps


	struct ia_out
	{
		float4 vertex : POSITION;
		float4 normal : NORMAL;
	};

	struct vs_out
	{
		float4 vertex : SV_POSITION;
		float4 screen_pos : TEXCOORD0;
	};

	struct ps_out
	{
		float4 color : COLOR0;
	};


	vs_out vert (ia_out v)
	{
		vs_out o;
		o.vertex = v.vertex;
		o.screen_pos = v.vertex;
		return o;
	}

	ps_out frag (vs_out i)
	{
		float2 coord = (i.screen_pos.xy / i.screen_pos.w + 1.0) * 0.5;
		// see: http://docs.unity3d.com/Manual/SL-PlatformDifferences.html
		#if UNITY_UV_STARTS_AT_TOP
			coord.y = 1.0-coord.y;
		#endif

		float4 FragPos4	= tex2D(g_position_buffer, coord);
		if(FragPos4.w==0.0) { discard; }
		float4 AS		= tex2D(_ColorBuffer, coord);
		float4 NS		= tex2D(g_normal_buffer, coord);

		float3 FragPos		= FragPos4.xyz;
		float3 LightColor	= _LightColor.rgb;
		float3  LightDir	= _LightDir;

		float3 Albedo	= AS.rgb;
		float Shininess	= AS.a;
		float3 Normal	= NS.xyz;
		float3 EyePos	= _WorldSpaceCameraPos.xyz;
		float3 EyeDir	= normalize(EyePos - FragPos);

		float3 h		= normalize(EyeDir + LightDir);
		float nh		= max(dot(Normal, h), 0.0);
		float Specular	= pow(nh, Shininess);
		float Intensity	= max(dot(Normal, LightDir), 0.0);

		float4 Result	= float4(0.0, 0.0, 0.0, 1.0);
		Result.rgb += LightColor * (Albedo * Intensity);
		Result.rgb += LightColor * Specular;

		ps_out r = {Result};
		return r;
	}
	ENDCG

	Pass {
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 3.0
		#ifdef SHADER_API_OPENGL 
			#pragma glsl
		#endif
		ENDCG
	}
}
FallBack "Diffuse"
}
