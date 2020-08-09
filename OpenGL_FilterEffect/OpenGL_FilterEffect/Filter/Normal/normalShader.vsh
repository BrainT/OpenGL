attribute vec4 att_position;
attribute vec2 att_textuteCoords;
varying vec2 var_textureCoords;

void main()
{
    gl_Position = att_position;
    var_textureCoords = att_textuteCoords;
}
