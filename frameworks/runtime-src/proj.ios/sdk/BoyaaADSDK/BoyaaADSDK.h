//
//  BoyaaAD.h
//  Poker
//
//  Created by RayDeng on 14-8-27.
//  Copyright (c) 2014年 Boyaa iPhone Texas Poker. All rights reserved.
//

#import <Foundation/Foundation.h>



#if ! __has_feature(objc_arc)
#define BYAutorelease(__v) ([__v autorelease]);
#define BYRetain(__v) ([__v retain]);
#define BYRelease(__v) ([__v release]);
#else
#define BYAutorelease(__v)
#define BYRetain(__v)
#define BYRelease(__v)
#endif


@interface BoyaaADSDK : NSObject
@property (nonatomic)BOOL isDebug;
+(BoyaaADSDK*)instance;

/*
 * 注意要添加 appsFlyer sdk （AppsFlyerTracker.h & libAppsFlyerLib.a）
 * @param key  Use this property to set your AppsFlyer's dev key.
 * @param itunesID Use this property to set your app's Apple ID (taken from the app's page on iTunes Connect)
 */
-(void)initAppFlyerWithKey:(NSString *)key andAppleItunesID:(NSString*)itunesID;

/*
 * 设置支付币种，默认为 @"USD"
 * In case of in app purchase events, you can set the currency code your user has purchased with.
 * The currency code is a 3 letter code according to ISO standards. Example: "USD" ,"RMB"。default @"USD"
 */
@property (nonatomic,strong) NSString* currencyCode;

/*
 * applicationDidBecomeActive 时调用。调用前注意 先 初始化。
 */
-(void)appDidBecomeActive;


-(void)start:(NSDictionary*)params;
-(void)registers:(NSDictionary*)params;
-(void)login:(NSDictionary*)params;
-(void)play:(NSDictionary*)params;
-(void)pay:(NSDictionary*)params;
-(void)logout:(NSDictionary*)params;
-(void)customEvent:(NSDictionary*)params;
-(void)recall:(NSDictionary*)params;
-(void)share:(NSDictionary*)params;
-(void)invite:(NSDictionary*)params;
-(void)purchaseCancel:(NSDictionary*)params;

@end
