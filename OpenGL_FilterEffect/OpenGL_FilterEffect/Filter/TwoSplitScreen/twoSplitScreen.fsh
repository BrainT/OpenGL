
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

void main()
{
    vec2 var_xy = var_textureCoords.xy;
    
    if (var_xy.y > 0.0 && var_xy.y < 0.5) {
        var_xy.y = var_xy.y + 0.25;
    }else{
        var_xy.y = var_xy.y - 0.25;
    }
    
    gl_FragColor = texture2D(un_texture,vec2( var_xy.x, var_xy.y));
    
}
