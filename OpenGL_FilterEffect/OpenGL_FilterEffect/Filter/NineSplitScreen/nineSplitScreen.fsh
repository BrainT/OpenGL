
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

void main()
{
    vec2 var_xy = var_textureCoords.xy;
    
    if (var_xy.x > 0.0 && var_xy.x <= 1.0/3.0) {
       var_xy.x = var_xy.x + 1.0/3.0;
   }else if (var_xy.x >= 2.0/3.0 ){
       var_xy.x = var_xy.x - 1.0/3.0;
   }
    if (var_xy.y > 0.0 && var_xy.y <= 1.0/3.0) {
       var_xy.y = var_xy.y + 1.0/3.0;
   }else if (var_xy.y >= 2.0/3.0 ){
       var_xy.y = var_xy.y - 1.0/3.0;
   }
    
    gl_FragColor = texture2D(un_texture,vec2( var_xy.x, var_xy.y));
    
}
