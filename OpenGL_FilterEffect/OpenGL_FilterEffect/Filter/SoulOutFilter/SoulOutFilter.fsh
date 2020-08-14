
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

uniform float Time;

void main()
{
    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;
    
    float progress = mod(Time , duration) / duration;
    float curAlpha = maxAlpha * (1.0 - progress);
    float size = 1.0 + (maxScale - 1.0) * progress;
    
    float zoomInTextureX = 0.5 + (var_textureCoords.x - 0.5) / size;
    float zoomInTextureY = 0.5 + (var_textureCoords.y - 0.5) / size;
    
    vec2 zoomInTextureCoord = vec2(zoomInTextureX,zoomInTextureY);
    
    vec4 zoomInTextureCoordColor = texture2D(un_texture,zoomInTextureCoord);
    
    vec4 originTextureCoordColor = texture2D(un_texture,var_textureCoords);
    
    gl_FragColor = originTextureCoordColor * (1.0 - curAlpha) + zoomInTextureCoordColor * curAlpha ;
    
}
