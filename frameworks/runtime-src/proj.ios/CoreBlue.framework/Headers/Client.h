//
//  Client.h
//  BluePay
//
//  Created by guojianmin on 16/1/9.
//  Copyright © 2016年 alvin. All rights reserved.
//

#ifndef Client_h
#define Client_h
//#import <Foundation/Foundation.h>
#import "InitSDKProtocol.h"
#endif /* Client_h */


#define  INIT_RESULT_SUCCESS 1
#define  INIT_RESULT_FAILED_KEY 0
#define  INIT_RESULT_FAILED_PARAMS -1
#define  INIT_RESULT_FAILED_KEY_PARAMS -2




@interface Client : NSObject 
{
    id<InitSDKProtocal> _initDelegate;
}
@property (nonatomic,retain) id<InitSDKProtocal> initDelegate;


/*!
 * @discription init the BluePay sdk, you must call this method at first.
 * @param int productionId  
 * @param NSString promotionId
 * @param NSString key
 * @param NSString lan
 * @return void
 */
-(void )initSDK:(int) productId promotion:(NSString*) promotionId key:(NSString *)key language:(NSString*) lan showLoading:(BOOL)showLoading;
/**
 * @discription  init sdk with BluePay.ref file.
 * @param showLoading  if true,will show a loding dialog.
 */
-(void) initSDK:(BOOL)showLoading;

/*!
 * @return NSString *  return the promotionId;
 */
+(NSString*) promotionId;

/*!
 * @return int return the productId
 */
+(int) productId;
+(void) setProductId:(NSInteger) productId;
+(void)setPromotionId:(NSString*) promotionId;

+(NSString*) key;
+(void) setKey:(NSString*)key;
+(id)getInstance;
+(bool) isInit;

@end

