Shader "Minicurso/PrimeiroShader" {

	SubShader {
		
		Pass {

			CGPROGRAM
			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram

			float4 VertexProgram(float4 position : POSITION) : SV_POSITION {
				return position;
			}

			float4 FragmentProgram() : SV_TARGET {
				return float4(1, 1, 1, 1);
			}

			ENDCG

		}

	}

}
