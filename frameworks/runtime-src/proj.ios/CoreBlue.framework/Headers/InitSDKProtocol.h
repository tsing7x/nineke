//
//  InitProtocol.h
//  BluePay
//
//  Created by guojianmin on 16/1/9.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef InitSDKProtocol_h
#define InitSDKProtocol_h
#import <Foundation/Foundation.h>
#endif /* InitProtocol_h */


@protocol InitSDKProtocal <NSObject>
@required
/*!
 *@discription  this functin must be impletation on the class which you want to init the BluePay SDK. this function is required .if finish init will call this function nomatter init failed or seccess.
 * @param int result    the result code
 *@param NSString* msg  the message of the result.
 */
-(void)complete:(int)code result:(NSString*) msg;


@required

@end
@interface InitResult : NSObject

enum RESULT
{
    FAIL_PARAMETER = -1,
    FAIL_KEY = -2,
    FAIL = 0,
    SUECCESS = 1
};
@end