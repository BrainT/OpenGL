//
//  ViewController.m
//  GLSL_DIY_ShaderWithTexture
//
//  Created by Brain on 2020/7/30.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import "TextureView.h"

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TextureView * textureV = [[TextureView alloc] init];
    textureV = (TextureView *)self.view;
    
    
}

@end
