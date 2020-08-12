
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;

const float MosaicSize = 0.02;

void main()
{
    float length = MosaicSize;
    const float PI6 = 0.523599;
    float TR = 0.866025;
    float TB = 1.5;
    
    float texCoordX = var_textureCoords.x;
    float texCoordY = var_textureCoords.y;
    
    int matrix_X = int( texCoordX / (TB * length));
    int matrix_Y = int( texCoordY / (TR * length));
    
    vec2 curTexelCoord1, curTexelCoord2, curTexelCoordReslut;
    
    if (matrix_X / 2 * 2 == matrix_X) {
        if (matrix_Y /2  * 2 == matrix_Y) {
            curTexelCoord1 = vec2(length * TB * float(matrix_X),length * TR * float(matrix_Y));
            
            curTexelCoord2 = vec2(length * TB * float(matrix_X + 1),length * TR * float(matrix_Y + 1));
        }else{
            curTexelCoord1 = vec2(length * TB * float(matrix_X),length * TR * float(matrix_Y + 1));
            
            curTexelCoord2 = vec2(length * TB * float(matrix_X + 1),length * TR * float(matrix_Y));
        }
        
    }else{
        if (matrix_Y /2  * 2 == matrix_Y) {
            curTexelCoord1 = vec2(length * TB * float(matrix_X),length * TR * float(matrix_Y + 1));
            
            curTexelCoord2 = vec2(length * TB * float(matrix_X + 1),length * TR * float(matrix_Y ));
        }else{
            curTexelCoord1 = vec2(length * TB * float(matrix_X),length * TR * float(matrix_Y));
            
            curTexelCoord2 = vec2(length * TB * float(matrix_X + 1),length * TR * float(matrix_Y + 1));
        }
    }
    
    float distance1 = sqrt(pow(curTexelCoord1.x - texCoordX, 2.0) + pow(curTexelCoord1.y - texCoordY, 2.0));
    float distance2 = sqrt(pow(curTexelCoord2.x - texCoordX, 2.0) + pow(curTexelCoord2.y - texCoordY, 2.0));
    
    if (distance1 < distance2) {
        curTexelCoordReslut = curTexelCoord1;
    }else{
        curTexelCoordReslut = curTexelCoord2;
    }
    
    float agnleV = atan((texCoordX - curTexelCoordReslut.x) / (texCoordY - curTexelCoordReslut.y));
    
    vec2 area1 = vec2(curTexelCoordReslut.x, curTexelCoordReslut.y + length * TR / 2.0);
    vec2 area2 = vec2(curTexelCoordReslut.x + length / 2.0, curTexelCoordReslut.y - length * TR / 2.0);
    vec2 area3 = vec2(curTexelCoordReslut.x + length / 2.0, curTexelCoordReslut.y - length * TR / 2.0);
    vec2 area4 = vec2(curTexelCoordReslut.x, curTexelCoordReslut.y + length * TR / 2.0);
    vec2 area5 = vec2(curTexelCoordReslut.x - length / 2.0, curTexelCoordReslut.y - length * TR / 2.0);
    vec2 area6 = vec2(curTexelCoordReslut.x - length / 2.0, curTexelCoordReslut.y + length * TR / 2.0);

    if (agnleV >= PI6 && agnleV < PI6 * 3.0) {
      curTexelCoordReslut = area1;
    }else if (agnleV >= PI6 * 3.0 && agnleV < PI6 * 5.0){
      curTexelCoordReslut = area2;
    }else if ((agnleV >= PI6 * 5.0 && agnleV <= PI6 * 6.0) || (agnleV < -PI6 * 5.0 && agnleV > -PI6 * 6.0)){
      curTexelCoordReslut = area3;
    }else if (agnleV < -PI6 * 3.0 && agnleV >= -PI6 * 5.0){
      curTexelCoordReslut = area4;
    }else if (agnleV <= -PI6 && agnleV > -PI6 * 3.0){
      curTexelCoordReslut = area5;
    }else if (agnleV > -PI6 && agnleV < PI6){
      curTexelCoordReslut = area6;
    }

    gl_FragColor = texture2D(un_texture, curTexelCoordReslut);

}
