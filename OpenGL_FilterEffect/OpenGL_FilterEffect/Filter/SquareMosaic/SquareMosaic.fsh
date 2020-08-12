
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

const vec2 TextureSize = vec2(414.0,414.0);
const vec2 MosaicSize = vec2(8.0,8.0);

void main()
{
    
    vec2 TexCoords_XY = vec2(var_textureCoords.x * TextureSize.x,var_textureCoords.y * TextureSize.y);
    
    float sigleMosaicX = floor(TexCoords_XY.x / MosaicSize.x);
    float sigleMosaicY = floor(TexCoords_XY.y / MosaicSize.y);
    
    vec2 MosaicXY = vec2(sigleMosaicX * MosaicSize.x,sigleMosaicY * MosaicSize.y);
    
    vec2 TextureForMosic = vec2(MosaicXY.x / TextureSize.x, MosaicXY.y / TextureSize.y);
    
    vec4 TextureForMosicColor = texture2D(un_texture,TextureForMosic);
    
    gl_FragColor = TextureForMosicColor;
    
}
