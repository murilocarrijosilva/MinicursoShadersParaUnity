Shader "Minicurso/3_Specular" {

	Properties {
		_MainTex("Albedo", 2D) = "white" {}
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_Gloss("Gloss", Float) = 0.5
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
					float3 worldPos : TEXCOORD2;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				float4 _Tint;
				float _Gloss;

				FragmentData VertexProgram(VertexData v) {
					FragmentData i;

					i.position = UnityObjectToClipPos(v.position);
					i.worldPos = mul(unity_ObjectToWorld, v.position);
					i.uv = TRANSFORM_TEX(v.uv, _MainTex);
					i.normal = UnityObjectToWorldNormal(v.normal);

					return i;
				}

				float4 FragmentProgram(FragmentData i) : SV_TARGET {
					i.normal = normalize(i.normal);

					float3 lightDir = _WorldSpaceLightPos0.xyz;

					float3 camPos = _WorldSpaceCameraPos.xyz;
					float3 fragToCam = camPos - i.worldPos;
					float3 viewDir = normalize(fragToCam);

					// Reflect = 2(N dot I)N - I
					float3 reflectionDir = reflect(-viewDir, i.normal);

					float3 lightColor = _LightColor0.rgb;
					float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

					float3 specular = max(0, dot(reflectionDir, lightDir));
					specular = pow(specular, _Gloss) * lightColor * albedo;
					
					return float4(specular, 1);
				}

				ENDCG
			}
		}
}