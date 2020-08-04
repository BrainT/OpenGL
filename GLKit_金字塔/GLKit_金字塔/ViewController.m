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

    [self renderDisplay];
    
    [self gcdTimer];
}
- (void)initContext
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    
    self.glkView = (GLKView *)self.view;
    self.glkView.frame = self.view.frame;
    self.glkView.context = self.mContext;
    
    self.glkView.delegate = self;
    self.glkView.backgroundColor = [UIColor whiteColor];
    
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.mContext];
    
    glEnable(GL_DEPTH_TEST);
    
}

- (void)renderDisplay
{
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

    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, NULL);

    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+3);

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL+6);
    
    [self loadTexture];
    
    
    
}
- (void)loadTexture
{
    NSString * imgFilePath = [[NSBundle mainBundle] pathForResource:@"miao" ofType:@"jpg"];
    UIImage * image = [UIImage imageWithContentsOfFile:imgFilePath];
    
    NSDictionary * options = @{GLKTextureLoaderOriginBottomLeft:@YES};
    
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:nil];
    
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
//    self.mEffect.texture2d0.target = textureInfo.target;
    
    CGSize size = self.view.bounds.size;
    float aspect = fabs(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1, 100.0f);
    self.mEffect.transform.projectionMatrix = projectionMatrix;
    
    self.mEffect.transform.modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -3);
    
}

- (void)gcdTimer
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
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.3, 0.4, 0.5, 1);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    [self.mEffect prepareToDraw];
    
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
    
}
- (void)reRender
{
    GLKMatrix4 modelViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -2.5);
       
   modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.XDegree);
   modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.YDegree);
   modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, self.ZDegree);
   
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
