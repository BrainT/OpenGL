//
//  TextureView.m
//  GLSL_DIY_ShaderWithTexture
//
//  Created by TL on 2020/7/31.
//  Copyright © 2020 Brain. All rights reserved.
//

#import "TextureView.h"
#import <OpenGLES/ES2/gl.h>
@interface TextureView()

/**
 CALayer 的图层
 */
@property (nonatomic,strong) CAEAGLLayer * mEaglLayer;
@property (nonatomic,strong) EAGLContext * context;

/**
 渲染缓存区
 */
@property (nonatomic,assign) GLuint mRenderBuffer;
/**
 帧缓存区
 */
@property (nonatomic,assign) GLuint mFrameBuffer;

/**
 创建一个程序对象句柄，用来作为信息链接的载体
 */
@property (nonatomic,assign) GLuint mPrograme;


@end


@implementation TextureView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews
{
// 1.初始化layer图层，以备绘制
    [self initSubLayer];
    // 2.设置上下文
    [self setContext];
    // 3.清空缓存区：framebuffer & render buffer
    [self deleteRenderBufferAndFrameBuffer];
    
    // 4.设置renderBuffer
    [self setRenderBuffer];
    
    // 5.设置frameBuffer
    [self setFrameBuffer];
    
    // 6.渲染显示
    [self renderDisplay];
}

/**
 1.初始化layer图层
 */
- (void)initSubLayer
{
    
    // 1.创建图层
    self.mEaglLayer = (CAEAGLLayer *)self.layer;
    
    // 2.设置scale
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    
    /**
    3.设置描述属性——不维持渲染内容，颜色格式为RGBA8
     kEAGLDrawablePropertyRetainedBacking  表示绘图表面显示后，是否保留其内容。
     kEAGLDrawablePropertyColorFormat
     可绘制表面的内部颜色缓存区格式，这个key对应的值是一个NSString指定特定颜色缓存区对象。默认是kEAGLColorFormatRGBA8；
     
     kEAGLColorFormatRGBA8：32位RGBA的颜色，4*8=32位
     kEAGLColorFormatRGB565：16位RGB的颜色，
     kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。
    */
    self.mEaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO,
                                           kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                                           };
    
}
+(Class)layerClass
{
    return [CAEAGLLayer class];
}

/**
 2.设置上下文
 */
- (void)setContext
{
    // 1.创建上下文
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        NSLog(@"init context failed");
        return;
    }
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"setCurrentContext failed");
        return;
    }
}


/**
 3、先清空一下缓存区
 */
- (void)deleteRenderBufferAndFrameBuffer
{
    /*
     buffer 分为 frame buffer 和 render buffer2个大类。
     其中frame buffer 相当于render buffer的管理者。
     frame buffer object即称FBO，是收集颜色、深度、模板缓存区的附着点对象。
     render buffer则又可分为3类。colorBuffer、depthBuffer、stencilBuffer 模板。
     */
    glDeleteBuffers(1,&_mFrameBuffer);
    self.mFrameBuffer = 0;
    
    glDeleteBuffers(1, &_mRenderBuffer);
    self.mRenderBuffer = 0;
    
    
}

/**
 4.设置渲染缓存区
 */
- (void)setRenderBuffer
{
     GLuint buffer;
    // 1.申请一个缓存区标志
    glGenRenderbuffers(1, &buffer);
    self.mRenderBuffer = buffer;
    // 2.绑定renderBUffer
    glBindRenderbuffer(GL_RENDERBUFFER, self.mRenderBuffer);
    
    // 3.将CAEAGLLayer的对象存储绑定到OpenGL ES的FreameBuffer对象上
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEaglLayer];
    
}

/**
 5.设置帧缓存区
 */
- (void)setFrameBuffer
{
     GLuint buffer;
    // 1.申请一个缓存区标志
    glGenBuffers(1, &buffer);
    self.mFrameBuffer = buffer;
    // 2.绑定frameBUffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.mFrameBuffer);
    
    /**
     3.将renderBuffer 通过 glFramebufferRenderbuffer绑定到 GL_COLOR_ATTACHMENT0上
     生成帧缓存区之后，则需要将renderbuffer跟framebuffer进行绑定，
     调用glFramebufferRenderbuffer函数进行绑定到对应的附着点上，后面的绘制才能起作用
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.mRenderBuffer);

}

/**
 6.渲染显示
 */
- (void)renderDisplay
{
    // 1.设置清屏颜色以及清除颜色缓存区
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.6, 0.7, 0.8, 1);
    
    // 2.设置视口大小
    GLfloat scaleF = [[UIScreen mainScreen] scale];
    CGPoint orign = self.frame.origin;
    CGSize size = self.frame.size;
    glViewport(orign.x * scaleF, orign.y * scaleF, size.width * scaleF, size.height * scaleF);;
    
    // 3.s读取顶点着色程序 + 片元着色程序
    NSString * fragmentFile = [[NSBundle mainBundle] pathForResource:@"shader_fragment" ofType:@"fsh"];
    NSString * vertexFile = [[NSBundle mainBundle] pathForResource:@"shader_vertex" ofType:@"vsh"];
    
    NSLog(@"fsh path: %@ \n vsh path:%@",fragmentFile,vertexFile);
    
    // 4.给程序对象句柄加载两个着色器
    self.mPrograme = [self loadShdersWithFragmentFile:fragmentFile WithVextexFile:vertexFile];
    
    // 5.链接program
    glLinkProgram(self.mPrograme);
    GLint linkStatus;
    // 6.记录链接状态
    glGetProgramiv(self.mPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.mPrograme, sizeof(message), 0, &message[0]);
        NSString * messageInfo = [NSString stringWithUTF8String:message];
        NSLog(@"link error messageInfo : %@",messageInfo);
        return;
    }
    NSLog(@"program link success");
    // 7.使用program
    glUseProgram(self.mPrograme);
    
    // 8.设置顶点坐标（前3）、纹理坐标（后2）
    GLfloat attibuteArr[] = {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
       -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
       -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    
    // 9.处理顶点数据
    // 1).开启顶点缓存区，申请一个缓存区标识符
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    // 2).将attributeBuffer 绑定到GL_ARRAY_BUFFER标识符
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    // 3).将顶点数据从内存copy至显存，交由GPU操作
    glBufferData(GL_ARRAY_BUFFER, sizeof(attibuteArr), attibuteArr, GL_DYNAMIC_DRAW);
    
    // 10.将顶点数据通过program传递到顶点着色程序的position
    // 1).调用glGetAttribLocation,获取vertex attribute 中的数据，参数2必须要和 shader_vertex.vsh 中 position相同，否则无法获得
    GLuint position = glGetAttribLocation(self.mPrograme, "position");
    
    // 2).从buffer中读取数据
    glEnableVertexAttribArray(position);
    // 3).设置读取方式
    /**
       para1: index,顶点数据的索引
       para2: size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
       para3: type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
       para4: normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
       para5: stride,连续顶点属性之间的偏移量，默认为0；
       para6: 指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
     */
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL + 0);
    
    // 11.处理纹理数据
    // 1).从shader_vertex.fsh 获取textureCoordinat
    GLuint textureCoord = glGetAttribLocation(self.mPrograme, "textCoordinate");
    // 2).打开通道，从buffer中读取数据
    glEnableVertexAttribArray(textureCoord);
    // (float * )NULL,不转化为float *，图片将无法显示
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    
    // 加载图片纹理
    [self loadTexture:@"miao.jpg"];
    
    // 12.设置纹理采样器 sampler2D
    glUniform1i(glGetUniformLocation(self.mPrograme, "colorMap"), 0);
    
    // 13.绘制纹理
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // 14.从渲染缓存区显示到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
}

/// 加载纹理
/// @param imageName 纹理名称
- (GLuint)loadTexture:(NSString *)imageName
{
    // 1.将UIImage转化为CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:imageName].CGImage;
    if (!spriteImage) {
        NSLog(@"load image failed");
        return 1;
    }
    
    // 2.获得图片大小，尺寸
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    // 获取图片字节数，其中RGBA占4个八位 byteData = width * height * 4
    GLubyte * spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    /**
     3.创建上下文
       para1: data,指向要渲染的绘制图像的内存地址
       para2: width,bitmap的宽度，单位为像素
       para3: height,bitmap的高度，单位为像素
       para4: bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
       para5: bytesPerRow,bitmap的没一行的内存所占的比特数
       para6: colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA

     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    // 4.在CGContextRef 将图片绘制出来
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // 5.使用默认方式绘制
    /**
       CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
       CGContextDrawImage
       参数1：绘图上下文
       参数2：rect坐标
       参数3：绘制的图片
    */
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    // 平移到x,y
    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
    // 再平移图片高度
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    // 沿y轴翻转
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    // 再平移至原位置
    CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    // 6.画图完毕后释放上下文
    CGContextRelease(spriteContext);
    // 7.绑定纹理到默认的纹理ID
    glBindTexture(GL_TEXTURE_2D, 0);
    // 8.设置纹理属性
    /**
     参数1：纹理纬度
     参数2：线性过滤、为s，t坐标设置模式
     参数3：wrapMode，环绕模式
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fWidht = width,fHeight = height;
    
    // 9.载入纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fWidht, fHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // 10.释放spriteData
    free(spriteData);
    return 0;
    
    
}


/**
 加载顶点着色程序+片元着色程序，返回一个程序program

 @param fragFile 片元着色器文件路径
 @param vertexFile 顶点着色器文件路径
 @return program
 */
- (GLuint)loadShdersWithFragmentFile:(NSString *)fragFile WithVextexFile:(NSString *) vertexFile
{
    
    // 1.定义两个临时着色器对象
    GLuint verTexShader,fragmentShader;
    // 2.创建program
    GLuint program = glCreateProgram();
    // 3.编译顶点着色器程序 & 片元着色器程序
    [self  complieShader:&verTexShader type:GL_VERTEX_SHADER file:vertexFile];
    [self  complieShader:&fragmentShader type:GL_FRAGMENT_SHADER file:fragFile];
    
    //4. 创建最终程序,
    glAttachShader(program, verTexShader);
    glAttachShader(program, fragmentShader);
    
    // 5.释放不需要的shader
    glDeleteShader(verTexShader);
    glDeleteShader(fragmentShader);
    
    return program;
}
- (void)complieShader:(GLuint *)shader type:(GLenum)type file:(NSString *)fileName
{
    // 1.获取文件路径
    NSString * contentFile = [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    // 2.转换字符串
    const GLchar * source = (GLchar*)[contentFile UTF8String];
    // 3.根据type创建shader
    *shader = glCreateShader(type);
    /**
     4. 将着色器源码附着至着色器对象上
     para1: shader,要编译的着色器对象 *shader
     para2: numOfStrings,传递的源码字符串数量 1个
     para3: strings,着色器程序的源码（真正的着色器程序源码）
     para4: lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
     */
    glShaderSource(*shader, 1, &source, NULL);
    // 5.把着色器源码编译成目标代码
    glCompileShader(*shader);
}


@end
