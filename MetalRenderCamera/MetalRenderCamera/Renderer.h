//
//  Renderer.h
//  MetalRenderCamera
//
//  Created by Brain on 2020/8/28.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface Renderer : NSObject<MTKViewDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

-(nonnull instancetype)initWithMetalKitView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
