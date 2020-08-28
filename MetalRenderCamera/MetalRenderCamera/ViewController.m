//
//  ViewController.m
//  MetalRenderCamera
//
//  Created by Brain on 2020/8/28.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "ViewController.h"
#import "Renderer.h"
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MetalKit/MetalKit.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>



@interface ViewController ()<MTKViewDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) Renderer * render;

@property (nonatomic,strong) MTKView * mtkView;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;

//负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *mCaptureSession;
//负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureDeviceInput *mCaptureDeviceInput;
//输出设备
@property (nonatomic, strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput;
//处理队列
@property (nonatomic, strong) dispatch_queue_t mProcessQueue;
//纹理缓存区
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self createMetalKitView];
    
    [self setCaptureSession];
    
}
- (void)createMetalKitView
{
    
     _mtkView= [[MTKView alloc] initWithFrame:self.view.frame];
    _mtkView.device = MTLCreateSystemDefaultDevice();
    [self.view addSubview:_mtkView];
    //
//    self.commandQueue = [self.mtkView.device newCommandQueue];
    _render = [[Renderer alloc] initWithMetalKitView:_mtkView];
    _mtkView.delegate = _render;
    // 允许读写操作
    _mtkView.framebufferOnly = NO;
    /**
     创建纹理缓存区
     参数1: allocator 内存分配器.默认即可.NULL
     参数2: cacheAttributes 缓存区行为字典.默认为NULL
     参数3: metalDevice
     参数4: textureAttributes 缓存创建纹理选项的字典. 使用默认选项NULL
     参数5: cacheOut 返回时，包含新创建的纹理缓存。
     */
    CVMetalTextureCacheCreate(NULL, NULL, _mtkView.device, NULL, &_textureCache);
}

- (void)setCaptureSession
{
    // 1.创建mCaptureSession
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    
    // 2.设置视频采集分辨率
    self.mCaptureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // 3.创建串行队列
    self.mProcessQueue = dispatch_queue_create("the process queue", DISPATCH_QUEUE_SERIAL);
    
    // 4.获取摄像头设备-前置or后置
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice * inputCamera = nil;
    for (AVCaptureDevice * device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            inputCamera = device;
        }
    }
    // 5.将AVCaptureDevice 转换为AVCaptureDeviceInput
    self.mCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    // 6.将设备添加到MCaptureSession中
    if ([self.mCaptureSession canAddInput:self.mCaptureDeviceInput]) {
        
        [self.mCaptureSession addInput:self.mCaptureDeviceInput];
    }
    
    // 7.创建AVCaptureVideoDataOutput对象
    self.mCaptureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 8.设置视频延迟是否采取丢帧策略
    // yes: 处理现有帧的调度队列在captureOutput:didOutputSampleBuffer:FromConnection:Delegate方法中被阻止时，对象会立即丢弃捕获的帧。
    // NO:在丢弃新帧之前，允许委托有更多的时间处理旧帧，但这样可能会内存增加.
    [self.mCaptureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    // 9.设置BGRA格式，
    
    NSDictionary * videoDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [self.mCaptureDeviceOutput setVideoSettings:videoDic];
    
    // 10.设置视频捕捉输出的代理方法
    [self.mCaptureDeviceOutput setSampleBufferDelegate:self queue:self.mProcessQueue];
    
    // 11.添加输出
    if ([self.mCaptureSession canAddOutput:self.mCaptureDeviceOutput]) {
        
        [self.mCaptureSession addOutput:self.mCaptureDeviceOutput];
    }
    
    // 12.连接输入输出
    AVCaptureConnection * connection = [self.mCaptureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    // 13.设置视频方向 - 必要的设置
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    // 14.开始捕捉
    [self.mCaptureSession startRunning];
    
}

#pragma mark - AVFoundation Delegate
/// 视频采集方法，采集一次回调一次
/// @param output <#output description#>
/// @param sampleBuffer <#sampleBuffer description#>
/// @param connection <#connection description#>
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // 1.从samplerBuffer 获取视频像素缓存区对象
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 获取捕捉视频的宽高
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
 
    // 3.根据视频像素缓存区，创建metal纹理缓存区
    
    CVMetalTextureRef tmpTexture = NULL;
    /**
     从现有图像缓冲区创建核心视频Metal纹理缓冲区。
     参数1: allocator 内存分配器,默认kCFAllocatorDefault
     参数2: textureCache 纹理缓存区对象
     参数3: sourceImage 视频图像缓冲区
     参数4: textureAttributes 纹理参数字典.默认为NULL
     参数5: pixelFormat 图像缓存区数据的Metal 像素格式常量.注意如果MTLPixelFormatBGRA8Unorm和摄像头采集时设置的颜色格式不一致，则会出现图像异常的情况；
     参数6: width,纹理图像的宽度（像素）
     参数7: height,纹理图像的高度（像素）
     参数8: planeIndex.如果图像缓冲区是平面的，则为映射纹理数据的平面索引。对于非平面图像缓冲区忽略。
     参数9: textureOut,返回时，返回创建的Metal纹理缓冲区。
     */
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    
    if (status == kCVReturnSuccess) {
        // 设置可绘制纹理的当前大小
        self.mtkView.drawableSize = CGSizeMake(width, height);
        
        // 返回纹理缓冲区的metal对象
        self.render.texture = CVMetalTextureGetTexture(tmpTexture);
        // 使用完毕，释放tmpTexture
        CFRelease(tmpTexture);
    }
    
    
}

@end
