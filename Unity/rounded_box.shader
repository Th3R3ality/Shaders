Shader "Unlit/rounded box"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} //texture needed for texture uv space bs
        _Color ("Color", Color) = (0.2, 0.7, 1)
        _Rounding ("Rounding", Range(0,1)) = 0.25
        _Dimensions ("Dimensions", float) = 1
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
            float _Dimensions;

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

            float2 rounded_box_sdf(float2 p, float dimensions, float rounding) {
                p *= 2; p -= 1;
                rounding = 1-rounding;

                p = abs(p);

                if (dimensions >= 1)
                {
                    p -= float2(rounding*(1/dimensions), rounding);
                    p.x -= (1-1/dimensions);
                    p.x *= dimensions;
                }
                else
                {
                    //dimensions = 1/dimensions;
                    p -= float2(rounding, rounding*(dimensions));
                    p.y -= (1-dimensions);
                    p.y *= 1/dimensions;
                }

                p = max(p,0);
                p = length(p);
                p += rounding;
                return p-1;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = _Color;
                
                float d = rounded_box_sdf(i.uv.xy, _Dimensions, _Rounding);

                float a = d <= 0 ? 1 : -1;

                clip(a);

                return col;
            }
            ENDCG
        }
    }
}
