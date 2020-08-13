
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;
const highp vec3 grayColor = vec3(0.2125,0.7154,0.0721);

void main()
{
    
    vec4 textureColor = texture2D(un_texture,var_textureCoords);
    
    float luminance  = dot(textureColor.rgb,grayColor);
    
    gl_FragColor = vec4(vec3(luminance),1.0);
    
}
