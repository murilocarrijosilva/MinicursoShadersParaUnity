Shader "Minicurso/4_Phong" {

	Properties {
		_MainTex("Albedo", 2D) = "white" {}
		
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_Ambient("Ambient", Float) = 0.25
		_Shininess("Shininess", Float) = 0.5
	}

		SubShader {
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
				float _Ambient;
				float _Shininess;

				FragmentData VertexProgram(VertexData v) {
					FragmentData i;

					i.position = UnityObjectToClipPos(v.position);
					i.worldPos = mul(unity_ObjectToWorld, v.position);
					i.uv = TRANSFORM_TEX(v.uv, _MainTex);
					i.normal = UnityObjectToWorldNormal(v.normal);

					return i;
				}

				float4 FragmentProgram(FragmentData i) : SV_TARGET {
					float3 normalDirection = normalize(i.normal); // Como o valor é interpolado entre os fragments, a magnitude do vetor normal pode ser diferente de 1
					float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.worldPos));
					float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.worldPos));
					
					// Aditional stuff
					float3 lightColor = _LightColor0.rgb;
					float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;

					/* * * * * * * * * * * *
					 * DIFFUSE CALCULATION
					 * * * * * * * * * * * */
					float3 diffuse = max(_Ambient, dot(lightDirection, i.normal));

					/* * * * * * * * * * * *
					 * SPECULAR CALCULATION
					 * * * * * * * * * * * */
					float3 reflection = reflect(-viewDirection, i.normal);
					float3 specular = pow(max(_Ambient, dot(reflection, lightDirection)), _Shininess);

					float4 finalColor = float4(diffuse * albedo * lightColor, 0) + float4(specular * lightColor, 1);
					return finalColor;
				}

				ENDCG
			}
		}
}