//
//  ViewController.m
//  MetalBasicBuffers
//
//  Created by TL on 2020/8/26.
//  Copyright © 2020 tl. All rights reserved.
//

#import "ViewController.h"
#import "Renderer.h"

@interface ViewController ()

@property (nonatomic,strong) Renderer * render;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MTKView * mtkView = (MTKView *)self.view;
   
    mtkView.device = MTLCreateSystemDefaultDevice();
    if (!mtkView.device) {
        NSLog(@"该设备不支持 Metal");
        return;
    }
    
    self.render = [[Renderer alloc] initWithMetalKitView:mtkView];
    if (!self.render) {
        NSLog(@"render create failed");
        return;
    }
    mtkView.delegate = self.render;
    [self.render mtkView:mtkView drawableSizeWillChange:mtkView.drawableSize];
}


@end
