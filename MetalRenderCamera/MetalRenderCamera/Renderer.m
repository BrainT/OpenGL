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

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;


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
    
    if (self.texture) {
        
        // 创建指令缓存
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        // 将MTKView作为渲染目标
        id<MTLTexture> drawingTexture = view.currentDrawable.texture;
        
        // 可以再这里处理滤镜逻辑;
        //MetalPerformanceShaders是Metal的一个滤镜集成库
        //MPSImageGaussianBlur 高斯模糊处理;sigma:值越高越模糊
        MPSImageGaussianBlur * filter = [[MPSImageGaussianBlur alloc] initWithDevice:self.device sigma:1];
        // 对采集到的输入的纹理做处理，输出到渲染目标
        [filter encodeToCommandBuffer:commandBuffer sourceTexture:self.texture destinationTexture:drawingTexture];
        
        // 显示纹理
        [commandBuffer presentDrawable:view.currentDrawable];
        // 提交命令
        [commandBuffer commit];
        // 清空当前纹理准备下次的数据读取
        self.texture = NULL;
    }
    
}






@end
