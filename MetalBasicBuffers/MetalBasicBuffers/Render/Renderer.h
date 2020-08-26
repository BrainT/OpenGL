//
//  Renderer.h
//  MetalBasicBuffers
//
//  Created by TL on 2020/8/26.
//  Copyright © 2020 tl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN
//MTKViewDelegate协议:允许对象呈现在视图中并响应调整大小事件
@interface Renderer : NSObject<MTKViewDelegate>

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
