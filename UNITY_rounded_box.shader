Shader "Unlit/rounded box"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} //texture needed for texture uv space bs
        _Color ("Color", Color) = (0.2, 0.7, 1)
        _Rounding ("Rounding", Range(0,0.5)) = 0.25
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            ZWrite Off
            Blend One Zero
            AlphaToMask On  

            CGPROGRAM

            float4 _Color;
            float _Rounding;

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float rounded_box_sdf(float2 p, float2 dimensions, float rounding) {
                p += -0.5; p *= 2;
                
                float2 d = abs(p) - dimensions * 0.5 + rounding;
                return 1 - length(max(d, 0)) - rounding;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = _Color;
                
                float dimension = 2;
                float2 dimensions = float2(dimension, dimension);
                _Rounding *= dimensions.x;

                float alpha = rounded_box_sdf(i.uv.xy, dimensions, _Rounding);

                col.a *= alpha >= 1 - _Rounding * 2 ? 1 : 0;

                return col;
            }
            ENDCG
        }
    }
}
