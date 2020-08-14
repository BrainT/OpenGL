
precision highp float;

uniform sampler2D un_texture;
varying vec2 var_textureCoords;

uniform float Time;


void main()
{
    float duration = 0.4;
    float offset = 0.02;
    float maxSize = 1.5;
    
    float progress = mod(Time,duration);
    vec2 offsetCoord = vec2(offset,offset) * progress;
    
    float size = 1.0 + (maxSize - 1.0) * progress;
    
    vec2 sizeTextureCoord = vec2(0.5, 0.5) + (var_textureCoords - vec2(0.5,0.5)) / size;
    
    vec4 colorTexelR = texture2D(un_texture, sizeTextureCoord + offsetCoord);
    
    vec4 colorTexelG = texture2D(un_texture, sizeTextureCoord - offsetCoord);
    
    vec4 colorTexel = texture2D(un_texture, sizeTextureCoord);
    
    gl_FragColor = vec4(colorTexelR.r , colorTexelG.g, colorTexel.b, colorTexel.a);
    
    
}
