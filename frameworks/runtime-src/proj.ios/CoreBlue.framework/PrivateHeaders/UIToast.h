//
//  UIToast.h
//  Blue
//
//  Created by wangAlvin on 16/8/23.
//  Copyright © 2016年 wangAlvin. All rights reserved.
//

#ifndef UIToast_h
#define UIToast_h
#import <UIKit/UIKit.h>

#endif /* UIToast_h */


#define TOAST_SHOW_LONG 0
#define TOAST_SHOW_SHORT 1

@interface UIToast : UILabel

-(id)initWithText:(NSString*)text;

-(void)dismiss;

-(void)show:(NSInteger) shortOrLong;

+(void)show:(NSString*) text howLong:(NSInteger) showtime;

@end

