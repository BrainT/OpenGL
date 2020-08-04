precision highp float;

varying lowp vec4 varyColor;
varying lowp vec2 varyTextCoor;
uniform sampler2D colorMap;

void main()
{
    // 1.
//    gl_FragColor = varyColor;
    
    // color mix texture
    vec4 weakMask = texture2D(colorMap,varyTextCoor);
    vec4 mask = varyColor;
    float alpha = 0.5;
    
    vec4 tempColor = mask * (1.0 - alpha) + weakMask * alpha;
    
    gl_FragColor = tempColor;
    
}
