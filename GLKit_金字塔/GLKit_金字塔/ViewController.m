//
//  ViewController.m
//  GLKit_金字塔
//
//  Created by TL on 2020/8/4.
//  Copyright © 2020 tl. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
@interface ViewController ()<GLKViewDelegate>

@property (nonatomic,strong) EAGLContext * mContext;

@property (nonatomic,strong) GLKView * glkView;

@property (nonatomic,strong) GLKBaseEffect * mEffect;

@property (nonatomic,strong) dispatch_source_t  timer;

@property (nonatomic,assign) NSInteger count;
//旋转的度数
@property(nonatomic,assign)float XDegree;
@property(nonatomic,assign)float YDegree;
@property(nonatomic,assign)float ZDegree;

//是否旋转X,Y,Z
@property(nonatomic,assign) BOOL XBool;
@property(nonatomic,assign) BOOL YBool;
@property(nonatomic,assign) BOOL ZBool;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 初始化上下文
    [self initContext];

    // 绘制显示
    [self renderDisplay];
    // 开启定时器
    [self setGCDTimer];
}

- (void)initContext
{
    self.view.backgroundColor = [UIColor whiteColor];
    // 初始化上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    // 初始化GLKView实例
    self.glkView = (GLKView *)self.view;
    self.glkView.frame = self.view.frame;
    self.glkView.context = self.mContext;
    // 设置代理
    self.glkView.delegate = self;
    self.glkView.backgroundColor = [UIColor whiteColor];
    // 设置颜色、深度格式
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    // 设置当前上下文
    if (![EAGLContext setCurrentContext:self.mContext]) {
        NSLog(@"setCurrentContext failed");
    }
    
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
    
}

/**
 渲染显示
 */
- (void)renderDisplay
{
//    单使用颜色渐变时，替换顶点数据 + 设置读取方式更改步长
//    GLfloat attrArr[] =
//    {
//        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上
//        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上
//        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下
//
//        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下
//        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f, //顶点
//    };
    // 顶点数据，颜色值，纹理坐标
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f,       0.0f, 1.0f,//左上
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f,       1.0f, 1.0f,//右上
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f,       0.0f, 0.0f,//左下

        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f,       1.0f, 0.0f,//右下
        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f,       0.5f, 0.5f,//顶点
    };
    
    //2.绘图索引
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
      
    self.count = sizeof(indices) / sizeof(GLuint);
    
    // 处理顶点数据
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);

    // 创建一个索引绘图的缓存标志 并绑定它
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    // 将数据从CPU内存copy只GPU显存
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
    // 打开顶点数据通道
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    // 设置顶点数据读取方式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+3);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);
    // 加载纹理
    [self loadTexture];
    
}
/**
 加载纹理
 */
- (void)loadTexture
{
    // 获得图片路径
    NSString * imgFilePath = [[NSBundle mainBundle] pathForResource:@"miao" ofType:@"jpg"];
    UIImage * image = [UIImage imageWithContentsOfFile:imgFilePath];
    
    NSDictionary * options = @{GLKTextureLoaderOriginBottomLeft:@YES};
    // 加载纹理数据
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:nil];
    // 设置着色实例
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
    
    // 设置透视矩阵
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 100.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    // 设置模型视图矩阵
    self.mEffect.transform.modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -3);
    
}

/**
 设置GCD定时器
 */
- (void)setGCDTimer
{
    double seconds = 0.1;
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(_timer, ^{
       
        self.XDegree += 0.1f * self.XBool;
      
        self.YDegree += 0.1f * self.YBool;
      
        self.ZDegree += 0.1f * self.ZBool ;
        
        [self reRender];
    });
    dispatch_resume(_timer);
}
#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // 设置清屏颜色
    glClearColor(0.3, 0.4, 0.5, 1);
    // 清楚深度、颜色缓存区
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    // 准备绘制
    [self.mEffect prepareToDraw];
    // 绘制
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
    
}
/**
 重新渲染
 */
- (void)reRender
{
    // 平移模型
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2.5);
    // 旋转
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.YDegree);
    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.ZDegree);
    // 设置效果
    self.mEffect.transform.modelviewMatrix = modelViewMatrix;
    
    [self.glkView display];
}
- (IBAction)X_Clicked:(id)sender {
    
    self.XBool = !self.XBool;
}

- (IBAction)Y_Clicked:(id)sender {
    
    self.YBool = !self.YBool;
}
- (IBAction)Z_Clicked:(id)sender {
    
    self.ZBool = !self.ZBool;
}


@end
