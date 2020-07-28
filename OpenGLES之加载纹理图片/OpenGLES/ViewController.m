//
//  ViewController.m
//  OpenGLES
//
//  Created by Brain on 2020/7/26.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>


@interface ViewController ()

@property (strong,nonatomic) EAGLContext * context;

@property (nonatomic,strong) GLKBaseEffect * myEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 初始化 创建context
    [self initContext];
    
    // 使用 GLBaseEffect 加载纹理数据
    [self loadTexture];
    
    // 加载订单+纹理坐标数据
    [self initVertexDataAndTextureCoord];
    
   
    
}
- (void)initContext
{
    // 1.初始化上下文,kEAGLRenderingAPIOpenGLES3:使用3.0的OpenGL ES
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        NSLog(@"context init failed");
    }
    // 2.设置当前上下文
    [EAGLContext setCurrentContext:self.context];
    // 3.更改了self.view，让其继承自GLKView，赋值实例化
    GLKView * view = (GLKView *)self.view;
    view.context = self.context;
    
    
    /**
     4. 设置视图创建的渲染缓存区
     1). drwableColorFormat: 颜色缓存格式
     2). GLKViewDrawbleColorFormatRGBA8888 缓存区的每个像素的最小组成部分（RGBA）使用8个bit，（所以每个像素4个字节，4*8个bit）。
     */
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    
    /**
     5. 设置视图创建的渲染缓存区
     1). drawableDepthFormat: 深度缓存格式
     2). GLKViewDrawableDepthFormatNone = 0,意味着完全没有深度缓冲区
         GLKViewDrawableDepthFormat16,
         GLKViewDrawableDepthFormat24,
         ...16,...24 一般用于3D场景or游戏，差别是使用...Format16消耗更少的资源
     */
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    
    
    glClearColor(1, 0.7, 0.3, 1);
}

/**
 加载顶点数据 & 纹理坐标
 */
- (void)initVertexDataAndTextureCoord
{
    // 1.假设本地有一图片，获取其路径
    NSString * imgPath = [[NSBundle mainBundle]pathForResource:@"timg" ofType:@"jpg"];

    
    // 2.设置纹理参数  显示图片时，原点是在左上角，而对于纹理坐标，原点是从左下角开始的bottomLeft，GLKTextureLoaderOriginBottomLeft 默认为false
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:imgPath options:options error:nil];
    
    // 3.苹果使用GLKit中的GLKitBaseEffect 完成顶点+片元着色器操作
    self.myEffect = [[GLKBaseEffect alloc]init];
    self.myEffect.texture2d0.enabled = GL_TRUE;
    self.myEffect.texture2d0.name = textureInfo.name;
    
#warning ====
    // 设置透视投影矩阵，并将其想深度移动5个单位；则图片就不会被拉伸
    CGFloat aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0), aspect, 0.1, 100.0);
    self.myEffect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -5.0);
    self.myEffect.transform.modelviewMatrix = modelviewMatrix;
}

/**
 加载纹理数据
 */
- (void)loadTexture
{
    /**
     1.先设置顶点数据，它包括了顶点坐标+纹理坐标
     纹理坐标取值范围为[0,1],左下角原点为 (0,0);所以设置(0,0)为纹理图片的左下角，则右上角就是(1,1)；
       每行前3位顶点坐标，后2为纹理坐标，可以用两个数组表示，OpenGL 普遍使用一个一位数组设置；
       还可以使用结构体转载 顶点坐标 + 纹理坐标 + 法向量。
     */
    
    GLfloat vertexData[] = {
        0.5, -0.5, 0.0f,  1.0f, 0.0f, //右下
        0.5, 0.5,  0.0f,  1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,  0.0f, 1.0f, //左上
        
        0.5, -0.5, 0.0f,  1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,  0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f, 0.0f, 0.0f, //左下
    };
    
    /*
     顶点数组: 开发者可以选择设定函数指针，在调用绘制方法的时候，直接由内存传入顶点数据，也就是说这部分数据之前是存储在内存当中的，被称为顶点数组
     顶点缓存区: 性能更高的做法是，提前分配一块显存，将顶点数据预先传入到显存当中。这部分的显存，就被称为顶点缓冲区
     copy vertexData 内存 --> 显存，提示性能
     */
    
    // 2. 开辟顶点缓存区
    // 1).创建顶点缓存区标识符bufferID
    GLuint bufferID;
    glGenBuffers(1, &bufferID); // 这里开辟一个缓存区即可，传入数据的指针地址
    
    // 2).绑定顶点缓存区，为数组类型
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    
    // 3).将顶点数组中的数据拷贝到开辟的顶点缓存区
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    // 3.打开读取通道，加载顶点坐标数据 和 纹理坐标数据
    // 顶点坐标数据
    /**
     在iOS中, 默认情况下，出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的.
     意味着,顶点数据在着色器端(服务端)是不可用的. 即使你已经使用glBufferData方法,将顶点数据从内存拷贝到顶点缓存区中(GPU显存中).
     所以, 必须由glEnableVertexAttribArray 方法打开通道.指定访问属性.才能让顶点着色器能够访问到从CPU复制到GPU的数据.
     注意: 数据在GPU端是否可见，即，着色器能否读取到数据，由是否启用了对应的属性决定，这就是glEnableVertexAttribArray的功能，允许顶点着色器读取GPU（服务器端）数据。
     */
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    /**
     上传顶点数据到显存的方法（设置合适的方式从buffer里面读取数据）
     参数列表:
      index,指定要修改的顶点属性的索引值,例如
      size, 每次读取数量。（如position是由3个（x,y,z）组成，而颜色是4个（r,g,b,a）,纹理则是2个.）
      type,指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT。
      normalized,指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）
      stride,指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0
      ptr指定一个指针，指向数组中第一个顶点属性的第一个组件。初始值为0
     */
    
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    // 纹理坐标数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE ,sizeof(GLfloat) * 5 , (GLfloat*)NULL + 3);
    
    
}

#pragma mark - GLKView delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // 清理缓存区
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 准备绘制
    [self.myEffect prepareToDraw];
    
    // 开始绘制
    // 采用三角形批次绘制，从0开始，用到了上下三角，6个点
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    

}

@end
