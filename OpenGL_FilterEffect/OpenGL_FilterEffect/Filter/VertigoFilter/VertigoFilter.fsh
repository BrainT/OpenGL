
precision highp float;
uniform sampler2D un_texture;
varying vec2 var_textureCoords;


uniform float Time;

const float PI = 3.141592653589793;

const float duration = 2.0;

vec4 getTexelLevel(float time, vec2 textureCoords, float padding){
    
    vec2 translation = vec2(sin(time * (PI * 2.0 / duration)));
    
    vec2 translationTextureCoord = textureCoords + padding * translation;
    
    return texture2D(un_texture, translationTextureCoord);
    
}

float levelAlphaProgress(float curTime, float hideTime ,float startTime){
    
    float beforeTime = duration + curTime - startTime;
    
    float laterTime = mod(beforeTime, duration);
    
    return min(laterTime, beforeTime);
    
}

void main()
{
    float timeInterval = mod(Time,duration);
    
    float zoomSize = 1.3;
    
    float padding = 0.5 * (1.0 - 1.0 / zoomSize);
    
    vec2 textureCoords = vec2(0.5,0.5) + (var_textureCoords - vec2(0.5,0.5)) / zoomSize;
   
    float hideTime = 0.9;
    
    float timeGap = 0.2;
    
    float maxAlphaR = 0.5;
    float maxAlphaG = 0.05;
    float maxAlphaB = 0.06;
    
    vec4 texelLevel = getTexelLevel(timeInterval,textureCoords,padding);
    float alphaR = 1.0;
    float alphaG = 1.0;
    float alphaB = 1.0;
    
    vec4 lastLevel = vec4(0,0,0,0);
    
    for(float f = 0.0; f < duration; f += timeGap){
        
        float tmpTime = f;
        vec4 tmpLevel = getTexelLevel(tmpTime,textureCoords,padding);
        
        float tmpAlphaR = maxAlphaR - maxAlphaR * levelAlphaProgress(timeInterval,hideTime,tmpTime)/hideTime;
        float tmpAlphaG = maxAlphaG - maxAlphaG * levelAlphaProgress(timeInterval,hideTime,tmpTime)/hideTime;
        float tmpAlphaB = maxAlphaB - maxAlphaB * levelAlphaProgress(timeInterval,hideTime,tmpTime)/hideTime;
      
        lastLevel  = lastLevel + vec4(tmpLevel.r * tmpAlphaR,tmpLevel.g * tmpAlphaG,tmpLevel.b * tmpAlphaB,1.0);
        
        alphaR = alphaR - tmpAlphaR;
        alphaG = alphaG - tmpAlphaG;
        alphaB = alphaB - tmpAlphaB;
        
        
    }
    
    lastLevel = lastLevel + vec4(texelLevel.r * alphaR,texelLevel.g * alphaG,texelLevel.b * alphaB,1.0);
    gl_FragColor = lastLevel;
    
}
