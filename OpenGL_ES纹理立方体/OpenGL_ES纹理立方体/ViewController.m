//
//  ViewController.m
//  OpenGL_ES纹理立方体
//
//  Created by TL on 2020/7/29.
//  Copyright © 2020 tl. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

// 顶点数据结构体
typedef struct {
    GLKVector3 positionCoord; // 顶点坐标
    GLKVector2 textureCoord; // 纹理坐标
    GLKVector3 normal; // 法线向量
    
} MyVertex;

static NSInteger coordCount = 36;

@interface ViewController ()<GLKViewDelegate>


@property (nonatomic,strong) GLKView * glkView;

@property (nonatomic,strong) GLKBaseEffect * myEffect;

@property (nonatomic,assign) MyVertex * myVertex;
/// 顶点缓存区
@property (nonatomic,assign) GLuint vertexBuffer;

/// 定时器
@property (nonatomic,strong) CADisplayLink * displayLink;

/// 旋转角度
@property (nonatomic,assign) NSInteger angle;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化OpenGL ES
    [self initialize];
    // 加载纹理数据
    [self loadTextureData];
    // 初始化顶点数据以及将数据copy至显存
    [self initVertexData];
    // 创建定时器
    [self startCADisplayLink];
}
- (void)initialize
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1.创建context，并设置为当前上下文
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    // 2.创建glkView
    CGRect glkRect = CGRectMake(20, 50, self.view.frame.size.width - 40, self.view.frame.size.height - 100);
    self.glkView = [[GLKView alloc] initWithFrame:glkRect context:context];
    self.glkView.backgroundColor = [UIColor whiteColor];
    // 设置代理
    self.glkView.delegate = self;
    
    // 3.设置颜色和深度缓冲区
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    [self.view addSubview:self.glkView];
    
}



/// 获取纹理数据
- (void)loadTextureData
{
    // 1.用本地图片
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"miao.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
   
    // 2.转换图形数据以适配OpenGL左下角原点格式
    NSDictionary * option = [NSDictionary dictionaryWithObjectsAndKeys:@(YES),GLKTextureLoaderOriginBottomLeft, nil];
    // 3.设置纹理参数

     GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage] options:option error:nil];
    
    // 初始化effect
    self.myEffect = [[GLKBaseEffect alloc] init];
    _myEffect.texture2d0.name = textureInfo.name;
    _myEffect.texture2d0.target = textureInfo.target;
    
    // 开启光照
    _myEffect.light1.enabled = YES;
    // 设置漫反射颜色值
    _myEffect.light1.diffuseColor = GLKVector4Make(1, 1, 1, 1);
    // 设置光源位置，GLKVector4Make(float x, float y, float z, float w) w一般都填 1
    _myEffect.light1.position = GLKVector4Make(1, 1, -4, 1);
    
    
}

- (void)initVertexData
{
    
    /*
     如果不复用顶点，使用每 3 个点画一个三角形的方式，需要 12 个三角形，则需要 36 个顶点
     以下的数据用来绘制以（0，0，0）为中心，边长为 1 的立方体
     */
    
    // 开辟顶点数据空间(数据结构SenceVertex 大小 * 顶点个数kCoordCount)
    self.myVertex = malloc(sizeof(MyVertex) * coordCount);
    
    // 前面
    self.myVertex[0] = (MyVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 0, 1}};
    self.myVertex[1] = (MyVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.myVertex[2] = (MyVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.myVertex[3] = (MyVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.myVertex[4] = (MyVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.myVertex[5] = (MyVertex){{0.5, -0.5, 0.5}, {1, 0}, {0, 0, 1}};
    
    // 上面
    self.myVertex[6] = (MyVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 1, 0}};
    self.myVertex[7] = (MyVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.myVertex[8] = (MyVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.myVertex[9] = (MyVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.myVertex[10] = (MyVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.myVertex[11] = (MyVertex){{-0.5, 0.5, -0.5}, {0, 0}, {0, 1, 0}};
    
    // 下面
    self.myVertex[12] = (MyVertex){{0.5, -0.5, 0.5}, {1, 1}, {0, -1, 0}};
    self.myVertex[13] = (MyVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.myVertex[14] = (MyVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.myVertex[15] = (MyVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.myVertex[16] = (MyVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.myVertex[17] = (MyVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, -1, 0}};
    
    // 左面
    self.myVertex[18] = (MyVertex){{-0.5, 0.5, 0.5}, {1, 1}, {-1, 0, 0}};
    self.myVertex[19] = (MyVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.myVertex[20] = (MyVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.myVertex[21] = (MyVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.myVertex[22] = (MyVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.myVertex[23] = (MyVertex){{-0.5, -0.5, -0.5}, {0, 0}, {-1, 0, 0}};
    
    // 右面
    self.myVertex[24] = (MyVertex){{0.5, 0.5, 0.5}, {1, 1}, {1, 0, 0}};
    self.myVertex[25] = (MyVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.myVertex[26] = (MyVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.myVertex[27] = (MyVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.myVertex[28] = (MyVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.myVertex[29] = (MyVertex){{0.5, -0.5, -0.5}, {0, 0}, {1, 0, 0}};
    
    // 后面
    self.myVertex[30] = (MyVertex){{-0.5, 0.5, -0.5}, {0, 1}, {0, 0, -1}};
    self.myVertex[31] = (MyVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.myVertex[32] = (MyVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.myVertex[33] = (MyVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.myVertex[34] = (MyVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.myVertex[35] = (MyVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, 0, -1}};
    
    // 1.开辟顶点缓存区
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(MyVertex) * coordCount, self.myVertex, GL_STATIC_DRAW);
    
    // copy顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL + offsetof(MyVertex, positionCoord));
    
    // 纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL + offsetof(MyVertex, textureCoord));
    
    // 法线数据
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(MyVertex), NULL + offsetof(MyVertex, normal));
    
    
}



/// 开启定时器
- (void)startCADisplayLink
{
    self.angle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)update
{
    // 计算旋转度数
    self.angle = (self.angle + 8) % 360;
    // 旋转
    self.myEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), -0.5, 0.9, 1);
    // 重新渲染
    [self.glkView display];
}

#pragma mark - GLKViewDelegate
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // 清除颜色、深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // 开启深度测试n
    glEnable(GL_DEPTH_TEST);

    // 准备绘制
    [self.myEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, coordCount);
    
}

- (void)dealloc {
    
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_myVertex) {
        free(_myVertex);
        _myVertex = nil;
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    //displayLink 失效
    [self.displayLink invalidate];
}



@end
