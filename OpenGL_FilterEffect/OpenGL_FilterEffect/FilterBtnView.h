//
//  FilterBtnView.h
//  OpenGL_FilterEffect
//
//  Created by Brain on 2020/8/9.
//  Copyright © 2020年 Brain. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterBtnView : UIView

@property (nonatomic,copy) void (^filterBtnBlock)(NSInteger tag);

@end

NS_ASSUME_NONNULL_END
