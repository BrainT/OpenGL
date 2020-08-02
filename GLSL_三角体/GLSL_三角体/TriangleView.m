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
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL boolX;
    BOOL boolY;
    BOOL boolZ;
    
    NSTimer * mTimer;
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
    
    glGenRenderbuffers(1, &_mRenderBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.mRenderBuffer);
    [self.mContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mEaglLayer];
    
}
- (void)setFrameBuffer
{
    // 申请一个缓存标志
    glGenFramebuffers(GL_FRAMEBUFFER, &_mFrameBuffer);
    // 绑定帧缓存区
    glBindFramebuffer(GL_FRAMEBUFFER, self.mFrameBuffer);
    // 将_mRenderBuffer 装配到GL_COLOR_ATTACHMENT0 附着点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.mRenderBuffer);
    
}
- (void)renderDisplay
{
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.4, 0.6, 0.7, 1);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    // 设置视口
    CGPoint orgin = self.frame.origin;
    CGSize size = self.frame.size;
    glViewport(orgin.x, orgin.y, size.width, size.height);
    
    // 获取顶点着色程序、片元着色程序文件文职
    
    // 判断program是否存在，否则清空program
    
    // 加载程序到program中来
    
    // 链接程序与着色器
    
    // 获取链接状态,为true 则glUseProgram
    
    //====准备顶点数据 & 索引数组=====
    
    
    
}


@end
