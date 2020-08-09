//
//  ViewController.m
//  OpenGL_FilterEffect
//
//  Created by Brain on 2020/8/9.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "ViewController.h"
#import "FilterBtnView.h"
#import <GLKit/GLKit.h>


typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;

@interface ViewController ()
// 用于刷新屏幕
@property (nonatomic, strong) CADisplayLink *displayLink;
// 开始的时间戳
@property (nonatomic, assign) NSTimeInterval startTimeInterval;

@property (nonatomic, strong) EAGLContext * mContext;
@property (nonatomic, strong) CAEAGLLayer * mEagaLayer;
// 着色器程序
@property (nonatomic, assign) GLuint programID;
// 顶点缓存
@property (nonatomic, assign) GLuint vertexBuffer;
// 纹理 ID
@property (nonatomic, assign) GLuint textureID;
// 顶点&纹理数组
@property (nonatomic, assign) SenceVertex * mVertices;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加按钮View
    [self addFilterView];
    
    // 初始化
    [self initContextAndCALayer];
    // 开始一个动画
    [self startFilerAnimation];
}
- (void)addFilterView
{
    
    FilterBtnView * filterView = [[FilterBtnView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 130, self.view.frame.size.width, 130)];
    [self.view addSubview:filterView];
    __weak typeof(self) weakSelf = self;
    filterView.filterBtnBlock = ^(NSInteger tag) {
        [weakSelf filterBtnClicked:tag];
    };
}
/**
 分屏按钮

 @param btnTag 按钮标志
 */
- (void)filterBtnClicked:(NSInteger)btnTag
{
//    NSArray * btnArr = @[@"无",@"二分屏",@"三分屏",
//                         @"四分屏",@"六分屏",@"九分屏",];
    NSLog(@"%ld",btnTag);
    switch (btnTag) {
        case 0:
            [self setupShaderProgramWithName:@"normalShader"];
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        case 5:
            
            break;
            
        default:
            break;
    }
}

/// 开始一个滤镜动画
- (void)startFilerAnimation {
    //1.判断displayLink 是否为空
    //CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    //2. 设置displayLink 的方法
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    
    //3.将displayLink 添加到runloop 运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}
- (void)timeAction
{
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
        
    }
    // 使用program
    glUseProgram(self.programID);
    // 绑定buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    //  传入时间
    CGFloat currentTime = self.displayLink.timestamp - self.startTimeInterval;
    GLuint time = glGetUniformLocation(self.programID, "Time");
    glUniform1f(time, currentTime);
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.2, 0.2, 0.2, 1);
    
    // 重绘
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
    
    
    
}

#pragma mark - 初始化something
-(void)initContextAndCALayer
{
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (![EAGLContext setCurrentContext:self.mContext]) {
        NSLog(@"setCurrentContext failed");
        return;
    }
    
    //2.开辟顶点数组内存空间
    self.mVertices = malloc(sizeof(SenceVertex) * 4);
    
    //3.初始化顶点(0,1,2,3)的顶点坐标以及纹理坐标
    self.mVertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    self.mVertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    self.mVertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}};
    self.mVertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    
    // 创建CAEAGLayer图层
    self.mEagaLayer = [[CAEAGLLayer alloc] init];
    self.mEagaLayer.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.width);
    self.mEagaLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.view.layer addSublayer:self.mEagaLayer];
    
    //=====绑定渲染缓冲区 & 帧缓冲区======
    // 渲染缓存区,帧缓存区对象
    GLuint renderBuffer,frameBuffer;
    // 获取帧渲染缓存区名称,绑定渲染缓存区以及将渲染缓存区与layer建立连接
    glGenBuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEagaLayer];
    // 获取帧缓存区名称,绑定帧缓存区以及将渲染缓存区附着到帧缓存区上
    glGenBuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    //=====加载纹理======
    //
    self.textureID = [self createTextureIDWithImage];
    
    // 设置视口
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    // 设置顶点缓冲区
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.mVertices, GL_STATIC_DRAW);
    
    // 设置默认着色器
//    [self setupNormalShaderProgram]; // 一开始选用默认的着色器
    [self setupShaderProgramWithName:@"normalShader"];
    
    //10.将顶点缓存保存，退出时才释放
    self.vertexBuffer = vertexBuffer;

}
/**
 加载纹理，

 @return 返回的纹理ID
 */
- (GLuint)createTextureIDWithImage
{
    NSString * imgPath = [[NSBundle mainBundle] pathForResource:@"kunkun" ofType:@"jpg"];
    UIImage * image = [UIImage imageWithContentsOfFile:imgPath];
    //1、将 UIImage 转换为 CGImageRef
    CGImageRef cgImageRef = [image CGImage];
    //判断图片是否获取成功
    if (!cgImageRef) {
        NSLog(@"Failed to load image");
        exit(1);
    }
    //2、读取图片的大小，宽和高
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    //获取图片的rect
    CGRect rect = CGRectMake(0, 0, width, height);
    
    //获取图片的颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //3.获取图片字节数 宽*高*4（RGBA）
    void *imageData = malloc(width * height * 4);
    //4.创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //将图片翻转过来(图片默认是倒置的)
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    
    //对图片进行重新绘制，得到一张新的解压缩后的位图
    CGContextDrawImage(context, rect, cgImageRef);
    
    //设置图片纹理属性
    //5. 获取纹理ID
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    //6.载入纹理2D数据
    /*
     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0
     参数3：纹理的颜色值GL_RGBA
     参数4：宽
     参数5：高
     参数6：border，边界宽度
     参数7：format
     参数8：type
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    //7.设置纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //8.绑定纹理
    /*
     参数1：纹理维度
     参数2：纹理ID,因为只有一个纹理，给0就可以了。
     */
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //9.释放context,imageData
    CGContextRelease(context);
    free(imageData);
    
    //10.返回纹理ID
    return textureID;
//    // 将UIImage => CGImageRef
//    CGImageRef imageRef = image.CGImage;
//    if (!imageRef) {
//        NSLog(@"can not get imageRef");
//        return 0;
//    }
//    // 获取图片的数据 大小、宽高、字节数
//    GLuint imgWidth = (GLuint)CGImageGetWidth(imageRef);
//    GLuint imgHeight = (GLuint)CGImageGetHeight(imageRef);
//    GLubyte  * imageData = (GLubyte *)calloc(imgWidth * imgHeight * 4, sizeof(GLubyte));
//    //获取图片的颜色空间
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    /** 创建上下文
//     para1: data,指向要渲染的绘制图像的内存地址
//     para2: width,bitmap的宽度，单位为像素
//     para3: height,bitmap的高度，单位为像素
//     para4: bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
//     para5: bytesPerRow,bitmap的没一行的内存所占的比特数
//     para6: colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
//     */
//    CGContextRef imgContext = CGBitmapContextCreate(imageData, imgWidth, imgHeight, 8, imgWidth * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
//
//    CGRect imgRect = CGRectMake(0, 0, imgWidth, imgHeight);
//
//    // 翻转图片
//    CGContextTranslateCTM(imgContext, 0, imgHeight);
//    CGContextScaleCTM(imgContext, 1.0f, -1.0f);
//    CGColorSpaceRelease(colorSpace);
//    CGContextClearRect(imgContext, imgRect);
//    // 重新绘制图——解压缩的位图
//    CGContextDrawImage(imgContext, imgRect, imageRef);
//
//    // 设置图片纹理属性
//    GLuint textureID;
//    glGenTextures(1, &textureID);
//    glBindTexture(GL_TEXTURE_2D, textureID);
//
//    // 载入纹理
//    /*
//     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
//     参数2：加载的层次，一般设置为0
//     参数3：纹理的颜色值GL_RGBA
//     参数4：宽
//     参数5：高
//     参数6：border，边界宽度
//     参数7：format
//     参数8：type
//     参数9：纹理数据
//     */
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imgWidth, imgHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
//
//    // 设置纹理属性  过滤方式 + 环绕方式
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//    // 绑定纹理
//    glBindTexture(GL_TEXTURE_2D, 0);
//
//    CGContextRelease(imgContext);
//    free(imageData);
//
//    // 返回纹理id
//    return textureID;
}
- (void)setupNormalShaderProgram
{
    
}
-(void)setupShaderProgramWithName:(NSString *)nameStr
{
    // 获取着色器program
    GLuint progam = [self backProgramWithShaderName:nameStr];
    
    // 2.使用program
    glUseProgram(progam);
    
    // 3.获取 att_position att_textuteCoords un_texture 的索引位置
    GLuint positionSlot = glGetAttribLocation(progam, "att_position");
    GLuint textureCoordSlot = glGetAttribLocation(progam, "att_textuteCoords");
    
    GLuint textrueSlot = glGetAttribLocation(progam, "un_texture");
    
    // 4.激活纹理，绑定纹理id
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    
    // 5.采样纹理
    glUniform1i(textrueSlot , 0);
    
    // 6.打开positionSlolt属性，并将数据传递到 att_position 中
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), (GLfloat *)NULL + offsetof(SenceVertex, positionCoord));
    
    // 7.打开positionSlolt属性，并将数据传递到 att_position 中
    glEnableVertexAttribArray(textureCoordSlot);
    glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), (GLfloat *)NULL + offsetof(SenceVertex, textureCoord));
    
    // 8.保存program
    self.programID = progam;
}

/**
 返回program

 @param nameStr shaderName
 @return 返回对应的program
 */
- (GLuint)backProgramWithShaderName:(NSString *)nameStr
{
    // 1.编译顶点、片元着色器
    GLuint vertexShader = [self compileShaderWithName:nameStr WithType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:nameStr WithType:GL_FRAGMENT_SHADER];
    
    // 2.将顶点、片元着色程序着到program
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 3.链接program
    glLinkProgram(program);
    
    // 4.获取链接program的状态
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program link err：%@", messageString);
        exit(1);
    }
    // 5.返回program
    return program;
    
}
/**
 编译shader

 @param shaderName 着色器文件名
 @param shaderType 着色器类型
 @return 返回对应的着色器
 */
- (GLuint)compileShaderWithName:(NSString *)shaderName WithType:(GLenum)shaderType
{
    // 1.获取shader的path
    NSString * shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    
    NSString * shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:nil];
    if (!shaderString) {
        NSAssert(NO, @"shader read failed");
        return 0;
    }
    
    // 2.根据shaderType 创建对应的shader
    GLuint shader = glCreateShader(shaderType);
    
    // 3.获取shader Source
    const char * shadertStrUtf8 = shaderString.UTF8String;
     int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shadertStrUtf8, &shaderStringLength);
    
    // 4.编译shader
    glCompileShader(shader);
    
    // 5.获取编译状态
    GLint complieStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complieStatus);
     if (complieStatus == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSString * messageStr = [NSString stringWithUTF8String:message];
        NSAssert(NO, @"shader compile error : %@",messageStr);
        return 0;
        
    }
    // 6.返回shader
    return shader;
    
}


//获取渲染缓存区的宽
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}
//获取渲染缓存区的高
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}




@end
