Shader "Hidden/ShockwaveEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Magnitude ("Magnitude", Float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			uniform sampler2D _ImageEffectLayer;
			float _Magnitude;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 imageEffectCol = tex2D(_ImageEffectLayer, i.uv);

				float2 newPos = i.uv.rg + (imageEffectCol.rg * _MainTex_TexelSize.xy * _Magnitude);
                fixed4 col = tex2D(_MainTex, newPos);

                return col;
            }
            ENDCG
        }
    }
}
