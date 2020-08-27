
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

uniform float Time;

const float PI = 3.141593653589793;

void main()
{
    float duration = 0.4;
    float timeInterval = mod(Time,duration);
    
    vec4 whiteMask = vec4(1.0,1.0,1.0,1.0);
    
    float amplitude = abs(sin(timeInterval * ( PI / duration)));
    
    vec4 texelColor = texture2D(un_texture,var_textureCoords);
    
    
    gl_FragColor = (1.0 - amplitude) * texelColor + amplitude * whiteMask;
    
}
