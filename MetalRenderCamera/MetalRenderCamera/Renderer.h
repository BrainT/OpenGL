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


NS_ASSUME_NONNULL_BEGIN

@interface Renderer : NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(MTKView *)mtkView;

@property (nonatomic, strong) id<MTLTexture> texture;

@end

NS_ASSUME_NONNULL_END
