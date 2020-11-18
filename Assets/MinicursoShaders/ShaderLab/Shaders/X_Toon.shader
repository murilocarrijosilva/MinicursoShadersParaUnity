Shader "Minicurso/ToonLighting" {

	Properties {
		_MainTex("Albedo", 2D) = "white" {}
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_Smoothness("Smoothness", Float) = 1

		_BorderColor("Border color", Color) = (0, 0, 0, 0)
		_BorderSize("Border size", Float) = 3
	}

	SubShader {

		Pass {
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM

			#pragma target 3.0

			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "AutoLight.cginc"

			struct VertexInput {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct VertexOutput {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Tint;
			float _Smoothness;

			VertexOutput VertexProgram(VertexInput v) {
				VertexOutput o;

				o.position = UnityObjectToClipPos(v.position);
				o.worldPos = mul(unity_ObjectToWorld, v.position);
				o.normal = UnityObjectToWorldNormal(float4(v.normal, 0));
				o.normal = normalize(o.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			float4 FragmentProgram(VertexOutput i) : SV_TARGET {
				i.normal = normalize(i.normal);

				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 lightColor = _LightColor0.rgb;
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				float3 reflectionDir = reflect(-viewDir, i.normal);

				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
				
				float3 diffuse = max(0, dot(lightDir, i.normal));
				float3 specular = pow(max(0, dot(viewDir, reflectionDir)), _Smoothness);

				//diffuse = round(diffuse * 2) / 2;

				//return float4(diffuse + specular, 1);
				return float4(1, 1, 1, 1);
			}

			ENDCG
		}

		Pass {
			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha

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

			float4 _BorderColor;
			float _BorderSize;

			v2f vert(appdata v) {
				v2f o;
				float4 clipPos = UnityObjectToClipPos(v.vertex);
				float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, UnityObjectToWorldNormal(v.normal));
				clipPos.xy += normalize(clipNormal.xy) / _ScreenParams.xy * _BorderSize * clipPos.w * 2;
				o.vertex = clipPos;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return _BorderColor;
			}

			ENDCG
		}

	}

}