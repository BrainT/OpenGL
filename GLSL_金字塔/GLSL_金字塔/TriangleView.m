//
//  TriangleView.m
//  GLSL_三角体
//
//  Created by Brain on 2020/8/2.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "TriangleView.h"
#import "GLESMath.h"
#import "GLESUtils.h"
#import <OpenGLES/ES3/gl.h>

@interface TriangleView()

@property (nonatomic,strong) CAEAGLLayer * mEaglLayer;
@property (nonatomic,strong) EAGLContext * mContext;

/**
 渲染缓冲区
 */
@property (nonatomic,assign) GLuint mRenderBuffer;

/**
 帧缓冲区
 */
@property (nonatomic,assign) GLuint * mFrameBuffer;

/**
 程序句柄（链接着色器的id）
 */
@property (nonatomic,assign) GLuint mProgram;
// 顶点数组
@property (nonatomic,assign) GLuint mVertices;

@end


@implementation TriangleView
{
    // X Y Z 旋转角度
    float xDegree;
    float yDegree;
    float zDegree;
    // X Y Z 是否旋转
    BOOL boolX;
    BOOL boolY;
    BOOL boolZ;
    // GCD
    dispatch_source_t timer;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews
{
    // 初始化Layer
    [self initLayer];
    // 设置上下文
    [self initContext];
    // 删除缓存区
    [self deleteBuffer];
    // 设置渲染缓存区
    [self setRenderBuffer];
    // 设置帧缓存区
    [self setFrameBuffer];
    // 渲染显示
    [self renderDisplay];
    
}

/**
 初始化图层
 */
- (void)initLayer
{
    
    self.mEaglLayer = (CAEAGLLayer *)self.layer;
    //[[CAEAGLLayer alloc] init];
    
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    self.mEaglLayer.opaque = YES;
    
    self.mEaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};

}
+ (Class)layerClass{
    return [CAEAGLLayer class];
}
/**
 初始化Context
 */
- (void)initContext
{
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!self.mContext) {
        NSLog(@"EAGLContext init failed");
        return;
    }
    if (![EAGLContext setCurrentContext:self.mContext]) {
        NSLog(@"setCurrentContext failed");
        return;
    }
}
-(void)deleteBuffer
{
    glDeleteBuffers(1, &_mRenderBuffer);
    _mRenderBuffer = 0;
    glDeleteBuffers(1, &_mFrameBuffer);
    _mFrameBuffer = 0;
    
}

- (void)setRenderBuffer
{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.mRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.mRenderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEaglLayer];
    
}
- (void)setFrameBuffer
{
    GLuint buffer;
    // 申请一个缓存标志
    glGenFramebuffers(1, &buffer);
    self.mFrameBuffer = buffer;
    // 绑定帧缓存区
    glBindFramebuffer(GL_FRAMEBUFFER, self.mFrameBuffer);
    // 将_mRenderBuffer 装配到GL_COLOR_ATTACHMENT0 附着点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.mRenderBuffer);
    
}

/**
 渲染显示
 */
- (void)renderDisplay
{
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.4, 0.6, 0.7, 1);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    // 设置视口
    CGPoint orgin = self.frame.origin;
    CGSize size = self.frame.size;
    glViewport(orgin.x * scale, orgin.y * scale, size.width * scale, size.height * scale);
    
    // 获取顶点着色程序、片元着色程序文件文职
    NSString * shaderVertex = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"glsl"];
    NSString * shaderFragment = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"glsl"];
    // 判断program是否存在，否则清空program
    if (self.mProgram) {
        glDeleteProgram(self.mProgram);
        self.mProgram = 0;
    }
    
    // 加载程序到program中来
    self.mProgram = [self loadShaderV:shaderVertex frag:shaderFragment];
    // 链接程序与着色器
    glLinkProgram(self.mProgram);
    // 获取链接状态,为true 则glUseProgram
    GLint linkStatus;
    glGetProgramiv(self.mProgram, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(self.mProgram, sizeof(message), 0, &message[0]);
        NSString * messageInfo = [NSString stringWithUTF8String:message];
        NSLog(@"program link error:%@",messageInfo);
        return;
    }
    NSLog(@"program link success");
    glUseProgram(self.mProgram);
    
    //==== 无纹理： 准备顶点数据 & 索引数组=====
//    GLfloat attrArr[] =
//    {
//        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上0
//        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上1
//        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下2
//        
//        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下3
//        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f, //顶点4
//    };
    
    // 有纹理： 顶点数据，颜色值，纹理坐标
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f,       0.0f, 0.0f,//左下
        
        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f,       0.5f, 0.5f,//顶点
    };
    
    //(2).索引数组
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    // 判断顶点缓存区是否为空，如果为空则申请一个缓存区标识符
    if (self.mVertices == 0) {
        glGenBuffers(1, &_mVertices);
    }
    
    // =====处理顶点数据======
    // 将 _mVertices 绑定到 GL_ARRAY_BUFFER
    glBindBuffer(GL_ARRAY_BUFFER, _mVertices);
    // 把顶点数据从CPU内存copy到GPU显存中处理
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    // 将顶点数据通过myPrograme中的传递到顶点着色程序的position
    GLuint position = glGetAttribLocation(self.mProgram, "position");
    
    // 打开通道
    glEnableVertexAttribArray(position);
    // 设置读取方式
    NSLog(@"CGFloat %lu\n GLfloat :%lu",sizeof(CGFloat),sizeof(GLfloat));
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, NULL);
    
    // =====处理顶点颜色值=====
    GLuint positionColor = glGetAttribLocation(self.mProgram, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);

    // ======有纹理加载：======
    //  处理纹理数据
    GLuint textCoor = glGetAttribLocation(self.mProgram, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8 ,(GLfloat *)NULL + 6);
    // 加载为例
    [self loadTexture:@"miao.jpg"];
    /**
     GLint location,获取纹理位置
     GLint x，从0开始，有几个纹理，就传第几个纹理
     */
    glUniform1i(glGetUniformLocation(self.mProgram, "colorMap"), 0);
    
    // 根据program 找到 projectionMatrix、modelViewMatrix
    GLuint projectionMatrix = glGetUniformLocation(self.mProgram, "projectionMatrix");
    GLuint modelViewMatrix = glGetUniformLocation(self.mProgram, "modelViewMatrix");
    
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    // 创建4 * 4 投影矩阵
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    // 长宽比
    float aspect = width/height;
    
    // 获取透视矩阵
    /*
    参数1：矩阵
    参数2：视角，度数为单位
    参数3：纵横比
    参数4：近平面距离
    参数5：远平面距离
    */
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f);
    //将投影矩阵传递到顶点着色器
    /*
     location:指要更改的uniform变量的位置
     count:更改矩阵的个数
     transpose:是否要转置矩阵，并将它作为uniform变量的值。必须为GL_FALSE
     value:执行count个元素的指针，用来更新指定uniform变量
     */
    glUniformMatrix4fv(projectionMatrix, 1, GL_FALSE, (CGFloat *)&_projectionMatrix.m[0][0]);
    
    // 创建一个model视图矩阵
    KSMatrix4 _modelViewMatrix;
    // 获取单元矩阵
    ksMatrixLoadIdentity(&_modelViewMatrix);
    // z轴平移-10
    ksTranslate(&_modelViewMatrix,0.0,0.0,-10.0);
    // 创建一个4 * 4 矩阵，旋转矩阵
    KSMatrix4 _rotationMatrix;
    // 初始化为单元矩阵
    ksMatrixLoadIdentity(&_rotationMatrix);
    
    // 旋转
    // 绕x轴
    ksRotate(&_rotationMatrix, xDegree, 1.0, 0.0, 0.0);
    // 绕y轴
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0);
    // 绕z轴
    ksRotate(&_rotationMatrix, zDegree, 0.0, 0.0, 1.0);
    // 把变换矩阵相乘 将 _modelViewMatrix 矩阵 与 _rotationMatrix 矩阵相乘，结合到模型视图
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    //(7)将模型视图矩阵传递到顶点着色器
    /*
     location:指要更改的uniform变量的位置
     count:更改矩阵的个数
     transpose:是否要转置矩阵，并将它作为uniform变量的值。必须为GL_FALSE
     value:执行count个元素的指针，用来更新指定uniform变量
     */
    glUniformMatrix4fv(modelViewMatrix, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    
    // 开启背面剔除
    glEnable(GL_CULL_FACE);
    
    // 使用索引绘图
    /*
     void glDrawElements(GLenum mode,GLsizei count,GLenum type,const GLvoid * indices);
     参数列表：
     mode:要呈现的画图的模型
                GL_POINTS
                GL_LINES
                GL_LINE_LOOP
                GL_LINE_STRIP
                GL_TRIANGLES
                GL_TRIANGLE_STRIP
                GL_TRIANGLE_FAN
     count:绘图个数
     type:类型
             GL_BYTE
             GL_UNSIGNED_BYTE
             GL_SHORT
             GL_UNSIGNED_SHORT
             GL_INT
             GL_UNSIGNED_INT
     indices：绘制索引数组

     */
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    // 本地视口显示渲染缓冲区
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
    // 开启定时器
    [self gcdTimer];
}

- (GLuint)loadShaderV:(NSString *)vertextFile frag:(NSString *)fragmentFile
{
    // 创建2个临时变量
    GLuint verShader,FragShader;
    // 创建program
    GLuint program = glCreateProgram();
    
    // 编译顶点着色程序，片元着色程序
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vertextFile];
    [self compileShader:&FragShader type:GL_FRAGMENT_SHADER file:fragmentFile];
    
    // 创建最终的程序
    glAttachShader(program, verShader);
    glAttachShader(program, FragShader);
    
    // 释放shader
    glDeleteShader(verShader);
    glDeleteShader(FragShader);
    
    return program;
}
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    // 读取文件路径
    NSString * content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    // 获取文件路径字符串，C语言字符串
    const GLchar * source = (GLchar *)[content UTF8String];
    
    // 根据type类型创建一个shader
    *shader = glCreateShader(type);
    
    // 将顶点着色器源码附着到着色器对象上
    glShaderSource(*shader, 1, &source, NULL);
    
    // 把b着色器源代码编译成目标代码
    glCompileShader(*shader);

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

- (void)gcdTimer
{
    double seconds = 0.1;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(timer, ^{


        [self refreshAngle];
    });
    dispatch_resume(timer);
}
- (IBAction)X_Clicked:(id)sender {
   // 开启定时器
    boolX = !boolX;
    
}
- (IBAction)Y_Clicked:(id)sender {
    boolY = !boolY;
}
- (IBAction)Z_Clicked:(id)sender {
    boolZ = !boolZ;
}
- (void)refreshAngle
{
    // 更新度数
    xDegree += boolX * 5;
    yDegree += boolY * 5;
    zDegree += boolZ * 5;
    // 重新绘制
    [self renderDisplay];
    
}


@end
