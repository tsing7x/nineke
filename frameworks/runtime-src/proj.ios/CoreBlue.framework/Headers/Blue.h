//
//  BluePay.h
//  BluePay
//
//  Created by guojianmin on 16/1/13.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef Blue_h
#define Blue_h


#import <UIKit/UIKit.h>

#endif /* Blue_h */


enum result
{
    RESULT_FAILED,
    RESULT_SECCESS,
    RESULT_CANCEL
};
@interface Blue : NSObject

/*!
 @param id delegate the callback of payment,your must implementation PayDelegate protocol
 @param id Context  the view controller of your view
 @param NSString transactionId 
 @param NSString customerId
 @param NSString currency
 @param NSString price
 @param NSInteger  messageid
 @param NSString propsName
 @param BOOL isShowDialog
 @return if return false ,payDelegate is nil,please implete PayDelegate.
 */
+(bool) byMessage:(id _Nonnull) delegate viewController:(UIViewController*)view  transationId:(NSString*_Nonnull) transactionId  currency:(NSString* _Nullable) currency price:(NSString*_Nonnull) price messageid:(NSUInteger) messageId prpsName:(NSString*_Nonnull) propsName   isShowDialog :(BOOL) isShowDialog ;
/*!
 @param delegate id, the callback of payment.
 @param context  controller of your view.
 @param  NSString customId,
 @param  NSString transactionId,
 @param  NSString propsName, 
 @param NSString publisher,
 @param NSString cardNo, 
 @param NSString serialNo, 
 @param boolean isShowLoading
 @return bool return false ,means that your delegate  or contextis nil,please implementation PayDelegate
 */
+(bool)byCC:(id _Nonnull)delegate viewController:(UIViewController*)view  transactionId:(NSString*_Nonnull) transactionId customerId:(NSString* _Nullable) cusId  publisher:(NSString* _Nonnull) publisher prpsName:(NSString*_Nonnull) propsName
       cNo:( NSString* _Nullable) cNo sNo:(NSString*_Nullable) sNo isShowDialog :(BOOL) isShowDialog;
//+(id) getInstance;
+(bool)byBK:(id _Nonnull)delegate viewController:(UIViewController*)view   transactionId:(NSString*_Nonnull) transactionId currency:(NSString*_Nullable)currency price:(NSString* _Nonnull) price propsName:(NSString* _Nonnull)propsName isShowDialog:(BOOL)isShowDialog;
/*!
 @description
 @param delegate id, the callback of payment.
 @param context  controller of your view.
 @param  NSString customId,
 @param  NSString transactionId,
 @param  NSString propsName,
 @param NSString publisher, PUBLISHER_OFFLINE,PUBLISHER_OFFLINE_ATM,PUBLISHER_OTC,if equals PUBLISHER_OFFLINE, the msisdn will never take effect，and will show up a dialog to enter phone number and select the payment channel.
 @param NSString  msisdn phone number ,can be null
 @param boolean isShowLoading
 @return bool return false ,means that your delegate  or contextis nil,please implementation PayDelegate
 */

+(bool) byOffline:(id _Nonnull)delegate viewController:(UIViewController*)view  transactionId:(NSString * _Nonnull)transactionId customerId:(NSString *_Nullable)cstId price:(NSString * _Nullable)price propsName:(NSString *_Nonnull)propsName publisher:(NSString*_Nonnull)publisher  msisdn:(NSString* _Nullable)phone  isShowDialog:(BOOL)isShowDialog;
/**!
 @param delegate (PayDelegate --> id) the protocol for callback.
 @param transcactionId (NSString*) the transactionId for this transaction.
 @param price (NSString *) the price you want to pay.the price must be 1:1 ,for example, pay for 1THB ,the price=@"1",of cause you can use the tarrif id replace the price..
 @param propsName (NSString*) the propsName.
 @param publisher (NSString*) now that we just support PUBLISHER_LINE,if this param's value is other, will finish this payment.
 @param scheme (NSString*) the scheme for the appcation where you want to go when this payment finished.
 @param isShowDialog YES or NO.
 @return bool   true or false . if return false ,it means that delegate or context containt nil value.
 */
+(bool) byWL:(id _Nonnull)delegate viewController:(UIViewController*)view  transationId:(NSString*_Nonnull) transactionId currency:(NSString*_Nullable)currency price:(NSString*_Nullable) price prpsName:(NSString* _Nonnull) propsName  publisher:(NSString* _Nonnull)publisher schceme:(NSString* _Nonnull)scheme isShowDialog :(BOOL) isShowDialog ;
+(bool)byUI:(id _Nonnull)delegate viewController:(UIViewController*)view  transationId:(NSString* _Nonnull) transactionId cumstomerId:(NSString* _Nullable)cid currency:(NSString*_Nullable)currency price:(NSString* _Nullable) price messageid:(NSUInteger) messageId  prpsName:(NSString* _Nonnull) propsName schceme:(NSString*_Nullable)scheme isShowDialog :(BOOL) isShowDialog ;
+(void) queryTrans:(NSString*_Nonnull)transcactionId publisher:(NSString* _Nonnull)publisher num:(NSInteger) num isShow:(BOOL)isShow;
/**
 *@decription  configure the loading dialog ,
 @param BOOL  if YES ,will show the loading dialog ,else will not.
 */
+(void)setShowCardLoading:(BOOL)isOrNot;
/**
 * 是否支持横屏
 @param lanscape BOOL true 横屏，false 竖屏。 默认竖屏
 */

+(void)setCheckSum:(NSUInteger) count;
@end
