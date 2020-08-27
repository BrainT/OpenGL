//
//  Renderer.m
//  MetalRenderCamera
//
//  Created by Brain on 2020/8/28.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "Renderer.h"
#import <Metal/Metal.h>
@interface Renderer()

//纹理
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;

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
//命令队列

@end

@implementation Renderer

- (instancetype)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if (self) {
        _device = mtkView.device;
        // 创建命令队列
        _commandQueue = [mtkView.device newCommandQueue];
    }
    return self;
}


#pragma mark - MTKView Delegate

//视图大小发生改变时.会调用此方法
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

//视图渲染则会调用此方法
- (void)drawInMTKView:(MTKView *)view {
    MTKView * mtkView = view;
    //1.判断是否获取了AVFoundation 采集的纹理数据
    if (self.texture) {
        
        //2.创建指令缓冲
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        //3.将MTKView 作为目标渲染纹理
        id<MTLTexture> drawingTexture = mtkView.currentDrawable.texture;
        
        //4.设置滤镜
        /*
         MetalPerformanceShaders是Metal的一个集成库，有一些滤镜处理的Metal实现;
         MPSImageGaussianBlur 高斯模糊处理;
         */

        //创建高斯滤镜处理filter
        //注意:sigma值可以修改，sigma值越高图像越模糊;
        MPSImageGaussianBlur *filter = [[MPSImageGaussianBlur alloc] initWithDevice:view.device sigma:1];
        
        //5.MPSImageGaussianBlur以一个Metal纹理作为输入，以一个Metal纹理作为输出；
        //输入:摄像头采集的图像 self.texture
        //输出:创建的纹理 drawingTexture(其实就是view.currentDrawable.texture)
        [filter encodeToCommandBuffer:commandBuffer sourceTexture:self.texture destinationTexture:drawingTexture];
        
        //6.展示显示的内容
        [commandBuffer presentDrawable:view.currentDrawable];
        
        //7.提交命令
        [commandBuffer commit];
        
        //8.清空当前纹理,准备下一次的纹理数据读取.
        self.texture = NULL;
    }
}






@end
