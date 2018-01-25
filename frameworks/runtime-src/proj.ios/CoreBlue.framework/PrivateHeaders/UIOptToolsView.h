//
//  UIOptToolsView.h
//  Blue
//
//  Created by wangAlvin on 16/8/25.
//  Copyright © 2016年 wangAlvin. All rights reserved.
//

#ifndef UIOptToolsView_h
#define UIOptToolsView_h
#import <UIKit/UIKit.h>

#endif /* UIOptToolsView_h */
#import "BlueAlertView.h"

typedef void (^ verify)(NSString* msisdn) ;

@interface UIOptToolsView : CustomIOSAlertView
-(id)initWithBlock:(verify )handler;
-(void)show:(id) target verifyAction:(_Nonnull SEL) action;
@end