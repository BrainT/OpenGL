//
//  ViewController.m
//  GLSL_DIY_ShaderWithTexture
//
//  Created by Brain on 2020/7/30.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>

@interface ViewController ()

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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.初始化layer图层，以备绘制
    [self initSubLayer];
    // 2.设置上下文
    [self setContext];
    // 3.清空缓存区：framebuffer & render buffer
    [self deleteRenderBufferAndFrameBuffer];
    // 4.设置frameBuffer
    [self setFrameBuffer];
    // 5.设置renderBuffer
    [self setRenderBuffer];
    // 6.渲染显示
    [self renderDisplay];
}

/**
 1.初始化layer图层
 */
- (void)initSubLayer
{
    
    // 1.创建图层
    self.mEaglLayer = [[CAEAGLLayer alloc] init];
    [self.view.layer addSublayer:self.mEaglLayer];
    
    // 2.设置scale
    [self.view setContentScaleFactor:[[UIScreen mainScreen]scale]];
    
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
{  // 1.申请一个缓存区标志
    glGenBuffers(1, &_mRenderBuffer);
    
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
    // 1.申请一个缓存区标志
    glGenBuffers(1, &_mFrameBuffer);
    
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
    CGPoint orign = self.view.frame.origin;
    CGSize size = self.view.frame.size;
    glViewport(orign.x * scaleF, orign.y * scaleF, size.width * scaleF, size.height * scaleF);;
    
    // 3.s读取顶点着色程序 + 片元着色程序
    NSString * fragmentFile = [[NSBundle mainBundle] pathForResource:@"shader_fragment" ofType:@"fsh"];
    NSString * vertexFile = [[NSBundle mainBundle] pathForResource:@"shader_vertex" ofType:@"vsh"];
    
    NSLog(@"fsh path: %@ \n vsh path:%@",fragmentFile,vertexFile);
    
    // 4.给程序对象句柄加载两个着色器
    self.mPrograme = [self loadShdersWithFragmentFile:fragmentFile WithVextexFile:vertexFile];
    
    
    
    
    
}
/**
 加载顶点着色程序+片元着色程序，返回一个程序program

 @param fragFile 片元着色器文件路径
 @param vertexFile 顶点着色器文件路径
 @return program
 */
- (GLuint)loadShdersWithFragmentFile:(NSString *)fragFile WithVextexFile:(NSString *) vertexFile
{
    
    
    
    return 0;
}

@end
