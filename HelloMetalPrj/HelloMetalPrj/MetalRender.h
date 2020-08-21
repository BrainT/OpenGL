//
//  MetalRender.h
//  HelloMetalPrj
//
//  Created by TL on 2020/8/21.
//  Copyright © 2020 tl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalRender : NSObject<MTKViewDelegate>

- (id)initWithMetalKitView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
