//
//  FilterBtnView.m
//  OpenGL_FilterEffect
//
//  Created by Brain on 2020/8/9.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import "FilterBtnView.h"

@implementation FilterBtnView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.backgroundColor = [UIColor whiteColor];
    NSArray * btnArr = @[@"无",@"二分屏",@"三分屏",
                         @"四分屏",@"六分屏",@"九分屏",
                         @"☐马赛克",@"⎔马赛克",@"△马赛克",
                         @"灰度滤镜",@"缩放滤镜",@"灵魂出窍",
                         @"抖动滤镜",@"闪白滤镜",@"毛刺滤镜",@"幻觉滤镜"
                         ];
    CGFloat btnW = 100;
    CGFloat btnH = 40;
    CGFloat SC_Width = self.frame.size.width;
    CGFloat Gap = (SC_Width - btnW * 3) / 4;
    for (int i = 0; i < btnArr.count; i ++) {
        
        UIButton * filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterBtn setTitle:btnArr[i] forState:UIControlStateNormal];

        filterBtn.frame = CGRectMake(Gap +( Gap + btnW) *(i % 3), (i / 3) * (btnH + 5) , btnW, btnH);
        [filterBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [filterBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        filterBtn.tag = 100 + i;
        filterBtn.layer.cornerRadius = 5;
        [self addSubview:filterBtn];
        if (i == 0) {
            [self btnClicked:filterBtn];
        }
    }
}
- (void)btnClicked:(UIButton *)btn
{
    for (int i = 0; i < 11; i ++) {
        UIButton * button = [self viewWithTag:100 + i];
        if (button.tag == btn.tag) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blueColor];
        }else{
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            button.backgroundColor =[UIColor whiteColor];
        }
    }
    
    if (self.filterBtnBlock) {
        self.filterBtnBlock(btn.tag);
    }
    
}



@end
