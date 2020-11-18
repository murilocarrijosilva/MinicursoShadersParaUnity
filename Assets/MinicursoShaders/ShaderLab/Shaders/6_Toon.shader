Shader "Minicurso/Toon" {
    Properties {
		_MainTex("Albedo", 2D) = "white" {}
		_Tint("Tint", Color) = (1, 1, 1, 1)

        _Color("Border Color", Color) = (0, 0, 0, 1)
		_Size("Border Size", Float) = 0.1
    }
    SubShader {

		Pass {
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
				float3 normal : TEXCOORD1;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Tint;

			FragmentData VertexProgram(VertexData v) {
				FragmentData o;
				o.position = UnityObjectToClipPos(v.position);
				o.worldPos = mul(unity_ObjectToWorld, v.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
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
					float3 diffuse = max(0, dot(lightDirection, i.normal));

					diffuse = round(diffuse * 2) / 2;

					/* * * * * * * * * * * *
					 * SPECULAR CALCULATION
					 * * * * * * * * * * * */
					float3 reflection = reflect(-viewDirection, i.normal);
					float3 specular = pow(max(0, dot(reflection, lightDirection)), 100);

					specular = round(specular * 1) / 1;

					float4 finalColor = float4(diffuse * albedo * lightColor, 0) + float4(specular * lightColor, 1);
					return finalColor;
			}

			ENDCG
		}

		Pass {
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
			};

			float4 _Color;
			float _Size;

			v2f vert(appdata v) {
				v2f o;
				float4 clipPos = UnityObjectToClipPos(v.vertex);
				float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, UnityObjectToWorldNormal(v.normal));
				clipPos.xy += normalize(clipNormal.xy) / _ScreenParams.xy * _Size * clipPos.w * 2;
				o.vertex = clipPos;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return _Color;
			}
			ENDCG
		}
    }
}
