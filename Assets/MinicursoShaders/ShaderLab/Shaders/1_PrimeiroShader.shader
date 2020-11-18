Shader "Minicurso/PrimeiroShader" {

	Properties{
		_Color("Cor do objeto", Color) = (0, 1, 0, 1)
	}

	SubShader{

		Pass {

			CGPROGRAM
			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			#include "UnityCG.cginc"

			float4 _Color;

			float4 VertexProgram(float4 vertexPosition : POSITION) : SV_POSITION {
				return UnityObjectToClipPos(vertexPosition);
			}

			float4 FragmentProgram() : SV_TARGET {
				return _Color;
			}

			ENDCG
		}
	}
}