attribute vec4 att_position;
attribute vec2 att_textuteCoords;
varying vec2 var_textureCoords;

uniform float Time;

const float PI = 3.141592654;

void main()
{
    float duration = 0.4;
    float maxAmplitude = 0.2;
    
    float timeInterval = mod(Time,duration);
    
    float amplitude = 1.0 + maxAmplitude * abs(sin(timeInterval * (PI / duration)));
    
    gl_Position = vec4(att_position.x * amplitude , att_position.y * amplitude, att_position.zw);
    var_textureCoords = att_textuteCoords;
}
