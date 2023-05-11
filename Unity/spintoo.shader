Shader "Unlit/spin shader" {
    Properties {
        _spinDir("Spin Direction x,y,z", int) = 1
        _xSpeed ("x Spin Speed", range(-500, 500)) = 25
        _ySpeed ("y Spin Speed", range(-500, 500)) = 50
        _zSpeed ("z Spin Speed", range(-500, 500)) = 100
        _x ("x axis", range(0, 360)) = 0
        _y ("y axis", range(0, 360)) = 0
        _z ("z axis", range(0, 360)) = 0
        [Toggle] _xSpin( "Spin Around x axis", float) = 0
        [Toggle] _ySpin( "Spin Around y axis", float) = 0
        [Toggle] _zSpin( "Spin Around z axis", float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define PI 3.14159265359

            float _Speed;
            int _spinDir;
            float _x, _y, _z;
            bool _xSpin, _ySpin, _zSpin;
            float _xSpeed, _ySpeed, _zSpeed;

            struct vertexData {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            fixed4 RGBtoHSL(fixed4 rgb) {
                fixed4 hsl = fixed4(0.0, 0.0, 0.0, rgb.w);
                
                fixed vMin = min(min(rgb.x, rgb.y), rgb.z);
                fixed vMax = max(max(rgb.x, rgb.y), rgb.z);
                fixed vDelta = vMax - vMin;
                
                hsl.z = (vMax + vMin) / 2.0;
                
                if (vDelta == 0.0) {
                    hsl.x = hsl.y = 0.0;
                }
                else {
                    if (hsl.z < 0.5) hsl.y = vDelta / (vMax + vMin);
                    else hsl.y = vDelta / (2.0 - vMax - vMin);
                    
                    float rDelta = (((vMax - rgb.x) / 6.0) + (vDelta / 2.0)) / vDelta;
                    float gDelta = (((vMax - rgb.y) / 6.0) + (vDelta / 2.0)) / vDelta;
                    float bDelta = (((vMax - rgb.z) / 6.0) + (vDelta / 2.0)) / vDelta;
                    
                    if (rgb.x == vMax) hsl.x = bDelta - gDelta;
                    else if (rgb.y == vMax) hsl.x = (1.0 / 3.0) + rDelta - bDelta;
                    else if (rgb.z == vMax) hsl.x = (2.0 / 3.0) + gDelta - rDelta;
                    
                    if (hsl.x < 0.0) hsl.x += 1.0;
                    if (hsl.x > 1.0) hsl.x -= 1.0;
                }
                
                return hsl;
            }
            fixed hueToRGB(float v1, float v2, float vH) {
                if (vH < 0.0) vH+= 1.0;
                if (vH > 1.0) vH -= 1.0;
                if ((6.0 * vH) < 1.0) return (v1 + (v2 - v1) * 6.0 * vH);
                if ((2.0 * vH) < 1.0) return (v2);
                if ((3.0 * vH) < 2.0) return (v1 + (v2 - v1) * ((2.0 / 3.0) - vH) * 6.0);
                return v1;
            }
            fixed4 HSLtoRGB(fixed4 hsl) {
                fixed4 rgb = fixed4(0.0, 0.0, 0.0, hsl.w);
                
                if (hsl.y == 0) {
                    rgb.xyz = hsl.zzz;
                }
                else {
                    float v1;
                    float v2;
                    
                    if (hsl.z < 0.5) v2 = hsl.z * (1 + hsl.y);
                    else v2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
                    
                    v1 = 2.0 * hsl.z - v2;
                    
                    rgb.x = hueToRGB(v1, v2, hsl.x + (1.0 / 3.0));
                    rgb.y = hueToRGB(v1, v2, hsl.x);
                    rgb.z = hueToRGB(v1, v2, hsl.x - (1.0 / 3.0));
                }
                
                return rgb;
            }

            float degtorad(float d){
                return d / 180 * PI;
            }
            float radtodeg(float r){
                return r * 180 / PI;
            }


            v2f vert (vertexData v) {
                v2f o; float4 newPos = v.vertex;

                //float newAngle = 0;

                float dist = 1;
                float xnewAngle = atan2(newPos.x, newPos.y);
                xnewAngle += degtorad(_x);

                if (_xSpin){
                    xnewAngle += _Time*_xSpeed;
                    if (xnewAngle < 0) xnewAngle += degtorad(360);
                    xnewAngle %= degtorad(360);
                }

                dist = sqrt(newPos.x*newPos.x + newPos.y*newPos.y);
                newPos.x = sin(xnewAngle) * dist;
                newPos.y = cos(xnewAngle) * dist;


                
                float ynewAngle = atan2(newPos.x, newPos.z);
                ynewAngle += degtorad(_y);

                if (_ySpin){
                    ynewAngle += _Time*_ySpeed;
                    if (ynewAngle < 0) ynewAngle += degtorad(360);
                    ynewAngle %= degtorad(360);
                }

                dist = sqrt(newPos.x*newPos.x + newPos.z*newPos.z);
                newPos.x = sin(ynewAngle) * dist;
                newPos.z = cos(ynewAngle) * dist;
                

                
                float znewAngle = atan2(newPos.z, newPos.y);
                znewAngle += degtorad(_z);

                if (_zSpin){
                    znewAngle += _Time*_zSpeed;
                    if (znewAngle < 0) znewAngle += degtorad(360);
                    znewAngle %= degtorad(360);
                }

                dist = sqrt(newPos.y*newPos.y + newPos.z*newPos.z);
                newPos.y = cos(znewAngle) * dist;
                newPos.z = sin(znewAngle) * dist;
                

                o.vertex = UnityObjectToClipPos(newPos);
                o.uv = v.uv;
                return o;
                
            }

            fixed4 frag (v2f i) : SV_Target {
                float4 col = HSLtoRGB(fixed4(_Time.x*5 % 1, 1, 0.7, 1));
                return col;
            }
            ENDCG
        }
    }
}
