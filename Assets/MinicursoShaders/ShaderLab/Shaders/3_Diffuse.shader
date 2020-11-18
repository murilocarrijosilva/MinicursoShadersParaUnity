Shader "Minicurso/2_Diffuse" {

	Properties {
		_MainTex("Albedo", 2D) = "white" {}
		_Tint("Tint", Color) = (1, 1, 1, 1)
	}

		SubShader{
			Pass {
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma vertex VertexProgram
				#pragma fragment FragmentProgram

				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"

				struct VertexData {
					float4 position : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};

				struct FragmentData {
					float4 position : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : TEXCOORD1;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				
				float4 _Tint;

				FragmentData VertexProgram(VertexData v) {
					FragmentData i;

					i.position = UnityObjectToClipPos(v.position);
					i.uv = TRANSFORM_TEX(v.uv, _MainTex);
					i.normal = UnityObjectToWorldNormal(v.normal);

					return i;
				}

				float4 FragmentProgram(FragmentData i) : SV_TARGET {
					i.normal = normalize(i.normal);

					float3 lightDir = _WorldSpaceLightPos0.xyz;
					float3 lightColor = _LightColor0.rgb;
					float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
					float3 diffuse = saturate(dot(lightDir, i.normal)) * lightColor * albedo;

					return float4(diffuse, 1);
				}

				ENDCG
			}
	}
}