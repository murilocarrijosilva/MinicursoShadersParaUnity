Shader "Unlit/5_Border" {
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
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float4 _Tint;

			FragmentData VertexProgram(VertexData v) {
				FragmentData o;
				o.position = UnityObjectToClipPos(v.position);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			float4 FragmentProgram(FragmentData i) : SV_TARGET {
				return tex2D(_MainTex, i.uv);
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
