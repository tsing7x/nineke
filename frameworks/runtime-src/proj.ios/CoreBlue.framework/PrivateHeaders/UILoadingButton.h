//
//  UILoadingButton.h
//  Blue
//
//  Created by wangAlvin on 16/8/26.
//  Copyright © 2016年 wangAlvin. All rights reserved.
//

#ifndef UILoadingButton_h
#define UILoadingButton_h
#import <UIKit/UIKit.h>
#import <UIKit/UIKitDefines.h>
#endif /* UILoadingButton_h */

//typedef NS_OPTIONS(NSUInteger, UILBControlState) {
//    UILBControlStateNormal       = 0,
//    UILBControlStateHighlighted  = 1 << 0,                  // used when UIControl isHighlighted is set
//    UILBControlStateDisabled     = 1 << 1,
//    UILBControlStateSelected     = 1 << 2,                  // flag usable by app (see below)
//    UILBControlStateFocused NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 3, // Applicable only when the screen supports focus
//    UILBControlStateApplication  = 0x00FF0000,              // additional flags available for application use
//    UILBControlStateReserved     = 0xFF000000,               // flags reserved for internal framework use
//    UILBControlStateLoading      = 1<<4,
//    UILBControlStateStopLoading  = 1<< 6
//    
//};

@interface UILoadingButton : UIButton

//-(void) setTitle:(NSString *)title forState:(UILBControlState)state;

-(void)setIndicatorHidden:(BOOL)hidden;
-(void)startLoading:(void (^)()) handler;
-(void)stopLoading:(void (^)()) handler;
@end