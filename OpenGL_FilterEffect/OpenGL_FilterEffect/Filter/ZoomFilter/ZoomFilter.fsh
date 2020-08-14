precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

void main()
{
    vec4 mask = texture2D(un_texture,var_textureCoords);
    gl_FragColor = vec4(mask.rgb, 1.0);
    
}
