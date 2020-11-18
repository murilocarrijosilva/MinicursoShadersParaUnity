Shader "Minicurso/Texturas" {

	Properties{
		_MainTex("Main texture", 2D) = "white" {}
		_OutraTex("Outra textura", 2D) = "white" {}
		_Mask("Máscara", 2D) = "white" {}
	}

	SubShader{

		Pass {

			CGPROGRAM
			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityCG.cginc"

			struct VertexInput {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uvSec : TEXCOORD1;
				float2 uvMask : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _OutraTex;
			float4 _OutraTex_ST;

			sampler2D _Mask;
			float4 _Mask_ST;

			VertexOutput VertexProgram(VertexInput i) {
				VertexOutput o;
				o.position = UnityObjectToClipPos(i.position);
				o.uv = TRANSFORM_TEX(i.uv, _MainTex);
				o.uvSec = TRANSFORM_TEX(i.uv, _OutraTex);
				o.uvMask = TRANSFORM_TEX(i.uv, _Mask);
				return o;
			}

			float4 FragmentProgram(VertexOutput v) : SV_TARGET {
				float4 texColor = tex2D(_MainTex, v.uv);
				float4 auxColor = tex2D(_OutraTex, v.uvSec);

				float combine = tex2D(_Mask, v.uvMask).x;

				float4 combinedColor = lerp(texColor, auxColor, combine);
				return combinedColor;
			}

			ENDCG
		}
	}
}