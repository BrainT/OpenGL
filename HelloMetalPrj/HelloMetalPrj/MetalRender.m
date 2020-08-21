//
//  MetalRender.m
//  HelloMetalPrj
//
//  Created by TL on 2020/8/21.
//  Copyright © 2020 tl. All rights reserved.
//

#import "MetalRender.h"

typedef struct {
    float red,green,blue,alpha;
}MyColor;

@interface MetalRender()
@property (nonatomic,strong) id<MTLDevice>  device;
@property (nonatomic,strong) id<MTLCommandQueue>  commandQueue;


@end

@implementation MetalRender



- (id)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if (self) {
        
        _device = mtkView.device;
        /**
         所以程序与GPU交互的第一个对象就是MTLCommandQueue；使用MTLCommandQueue创建的对象，需加入到MTLCommandBuffer对象中，以确保
         它们能按照正确的顺序发送到GPU，对应一帧都会创建一个MTLCommandBuffer与之相应的对象，并且填充GPU执行的指令
         */
        _commandQueue = [_device newCommandQueue];
        
    }
    return self;
}

- (MyColor)settingColor
{
    // 1.增加颜色或减少颜色时的标记
    static Boolean flag = YES;
    // 2.颜色通道值0-3
    static NSInteger primaryChannel = 0;
    // 3.颜色通道数组colorChannels--颜色值
    static float colorChannels[] = {0.3,0.4,0.5,1.0};
    // 4.调整颜色的步长
    const float DynamicColorRate = 0.02;
    
    // 5.判断
    if (flag) {
        // 动态信道索引在0，1，2，4 通道间切换
        NSUInteger dynamicChannelIndex = (primaryChannel + 1) % 3;
        
        // 按照颜色步长调整通道颜色值
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        
        // 当颜色通道对应颜色值 >= 1.0时
        if (colorChannels[dynamicChannelIndex] >= 1.0) {
            flag = NO;
            primaryChannel = dynamicChannelIndex;
        }
 
    }else{
        
        // 动态信道索引在0，1，2，4 通道间切换
        NSUInteger dynamicChannelIndex = (primaryChannel + 2) % 3;

        // 按照颜色步长调整通道颜色值
        colorChannels[dynamicChannelIndex] += DynamicColorRate;

        // 当颜色通道对应颜色值 <= 1.0时
        if (colorChannels[dynamicChannelIndex] >= 1.0) {
            flag = YES;
        }
        
    }
    
    MyColor mycolor;
    mycolor.red = colorChannels[0];
    mycolor.green = colorChannels[1];
    mycolor.blue = colorChannels[2];
    mycolor.alpha = colorChannels[3];
    
    return mycolor;
    
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view
{
    MyColor color = [self settingColor];
    
    view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, color.alpha);
    // c创建一个MTLCommandBuffer对象，添加了_commandQueue，为每个渲染传统创建一个命令缓冲区；
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    commandBuffer.label = @"Command Buffer";
    // 从视图控制中获取渲染描述符
    MTLRenderPassDescriptor * renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor) {
        // 通过描述渲染符 renderPassDescriptor 创建 MTLRenderCommandEncoder对象
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"Render Encoder";
        
        // 结束 MTLRenderCommandEncoder 的工作
        [renderEncoder endEncoding];
        
        /**
        当编码器结束工作后，命令缓存区会接到2个命令 1）present ；2）commit
         由于GPU是不会直接绘制到屏幕上，因此若不给出指令，则屏幕不会绘制内容。
        */
        
        // 添加最后一个命令来显示屏幕
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    // 完成渲染并将命令缓存区提交给GPU
    [commandBuffer commit];
    
}
/// 当MTKView视图大小改变时调用
/// @param view view description
/// @param size size description
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}


@end
