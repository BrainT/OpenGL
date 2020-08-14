
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

uniform float Time;

const float PI = 3.141592653589793;

float rand(float n){
    return fract(sin(n) * 38989.128938897);
}

void main()
{
    float maxJitter = 0.06;
    float duration = 0.3;
    float colorR_Offset = 0.01;
    float colorB_Offset = -0.025;
    
    float time = mod(Time , duration * 2.0);
    float amplitude = max(sin(time * (PI/duration)),0.0);
    
    float jitter = rand(var_textureCoords.y) * 2.0 - 1.0;
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = var_textureCoords.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    
    vec2 textureCoords = vec2(textureX, var_textureCoords.y);
    
    vec4 texel = texture2D(un_texture, textureCoords);
    vec4 texelR = texture2D(un_texture, textureCoords + vec2(colorR_Offset * amplitude, 0.0));
    vec4 texelB = texture2D(un_texture, textureCoords + vec2(colorB_Offset * amplitude, 0.0));
    
    
    gl_FragColor = vec4(texelR.r, texel.g, texelR.b, texel.a);
    
}
