//
//  ViewController.m
//  HelloMetalPrj
//
//  Created by TL on 2020/8/21.
//  Copyright © 2020 tl. All rights reserved.
//

#import "ViewController.h"
#import <MetalKit/MetalKit.h>
#import "MetalRender.h"

@interface ViewController ()
@property (nonatomic,strong) MetalRender * mtlRender;
@property (nonatomic,strong) MTKView * mtkView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mtkView = [[MTKView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_mtkView];
    // 为mtkView 设置 MTLDevice
    _mtkView.device = MTLCreateSystemDefaultDevice();
    if (_mtkView.device == nil) {
        NSLog(@"该设备不支持metal");
        return;
    }
    
    _mtlRender = [[MetalRender alloc]initWithMetalKitView:_mtkView];
    // 设置MTKView 的代理(由MetalRender来实现MTKView 的代理方法)
    _mtkView.delegate = _mtlRender;
    // 视图可以根据视图属性上设置帧速率(指定时间来调用drawInMTKView方法--视图需要渲染时调用)
    _mtkView.preferredFramesPerSecond = 60;
    
}

@end
