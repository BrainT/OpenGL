attribute vec4 position;
attribute vec4 positionColor;

uniform mat4 projectMatrix;
uniform mat4 modelViewMatrix;

varying lowp vec4 varyColor;

void main()
{
    varyColor = positionColor;
    vec4 vPosition;
    // 4x4 =  4x4 x 4x1
    vPosition = projectMatrix * modelViewMatrix * position;
    
    // error: vPosition = position * projectMatrix * modelViewMatrix ;
    gl_Position = vPosition;
    
}


