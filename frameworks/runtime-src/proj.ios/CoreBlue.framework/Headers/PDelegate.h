//
//  PayDelegate.h
//  BluePay
//
//  Created by guojianmin on 16/1/13.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef PDelegate_h
#define PDelegate_h

#import "ASBlueMessage.h"

#endif /* PayDelegate_h */


#define RESULT_405 405 /* error in sdk inner*/
#define RESULT_403 403  /*not init*/
#define RESULT_407 407  /*send message error*/
#define RESULT_603 603  /*user cancel payment*/

@protocol PDelegate <NSObject>

/*!
 *@discription the function which will be called after finish pay nomatter pay seccess or failed.Of course thie function is required, you must implementate on your class which you want to do the payment.
 * @param code   the request result code ,1 means seccess,-1 means failed.
 * @param msg    BlueMessage, the msg contains price ,response code and request message.
 */
@required
-(void) onComplete:(int) code message:(BlueMessage*) msg;

@end