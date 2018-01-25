//
//  BoyaaAD.m
//  Poker
//
//  Created by RayDeng on 14-8-27.
//  Copyright (c) 2014年 Boyaa iPhone Texas Poker. All rights reserved.
//


//事件类型	事件ID
//启动	1
//注册	2
//登录	3
//玩牌	4
//付费	5
#define BYAD_APP_LAUNCH     @"start"
#define BYAD_APP_REGISTER   @"registration"
#define BYAD_APP_LOGIN      @"login"
#define BYAD_APP_PLAYGAME   @"play"
#define BYAD_APP_PURCHASE   @"purchase"


///
#define BYSDK_USER_DIC @"BYSDK_USER_DIC"

//
#import "BoyaaADSDK.h"
#import "AppsFlyerTracker.h"

@interface BoyaaADSDK ()<AppsFlyerTrackerDelegate>{
    AppsFlyerTracker *appFlyer;
    NSMutableDictionary *userDic;
    NSString *curUserId;
    
}
@end
@implementation BoyaaADSDK
-(id)init{
    if (self = [super init]) {
        _currencyCode = @"USD";
        BYRetain(_currencyCode);
    }
    return self;
}
-(NSMutableDictionary *)BYSDKDictionary{
    NSMutableDictionary *temDic;
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:BYSDK_USER_DIC];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        temDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    }else{
        temDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return temDic;
}
-(void)saveUserDictionary:(NSMutableDictionary*)dic{
    NSMutableDictionary *dataDic = [self BYSDKDictionary];
    [dataDic setObject:dic forKey:curUserId];
    [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:BYSDK_USER_DIC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)setNewRegister:(NSString *)userId{
    userDic = [NSMutableDictionary dictionaryWithCapacity:1];
    BYRetain(userDic);
    NSDate *date = [NSDate date];
    [userDic setObject:date forKey:@"date"];
    [self saveUserDictionary:userDic];
}
-(void)setLoginUserDic{
    NSMutableDictionary *dataDic = [self BYSDKDictionary];
    if ([dataDic objectForKey:curUserId] && [[dataDic objectForKey:curUserId] isKindOfClass:[NSDictionary class]]) {
        userDic = [NSMutableDictionary dictionaryWithDictionary: [dataDic objectForKey:curUserId]];
        BYRetain(userDic);
    }else{
        userDic = nil;
    }
}
-(void)setNewRegisterPlayerGame{
    [userDic setObject:@1 forKey:@"PlayGameflag"];
    [self saveUserDictionary:userDic];
}
-(BOOL)registerAndPlay{
    int flag = [[userDic objectForKey:@"PlayGameflag"] intValue];
    NSDate *registDate = [userDic objectForKey:@"date"];
    NSTimeInterval interval = [registDate timeIntervalSinceNow];
    if (userDic && flag == 0 && interval > - 24 * 60 * 60) {
        [self setNewRegisterPlayerGame];
        return YES;
    }else{
        return NO;
    }
}

-(void)debugLog:(NSString *)log{
    if (_isDebug) {
        NSLog(@"[AppsFlyer] %@",log);
    }
}
#pragma AppsFlyerTrackerDelegate methods
- (void) onConversionDataReceived:(NSDictionary*) installData{
    id status = [installData objectForKey:@"af_status"];
    if([status isEqualToString:@"Non-organic"]) {
        id sourceID = [installData objectForKey:@"media_source"];
        id campaign = [installData objectForKey:@"campaign"];
        [self debugLog:[NSString stringWithFormat:@"This is a none organic install."]];
        [self debugLog:[NSString stringWithFormat:@"Media source: %@",sourceID]];
        [self debugLog:[NSString stringWithFormat:@"Campaign: %@",campaign]];
    } else if([status isEqualToString:@"Organic"]) {
        [self debugLog:[NSString stringWithFormat:@"This is an organic install."]];
    }
}

- (void) onConversionDataRequestFailure:(NSError *)error{
    [self debugLog:[NSString stringWithFormat:@"Failed to get data from AppsFlyer's server: %@",[error localizedDescription]]];
}
- (void) onCurrentAttributionReceived:(NSDictionary*) installData{
    [self debugLog:[NSString stringWithFormat:@"currentRecieve get data from AppsFlyer's server: %@",installData]];
}
#pragma mark public
+(BoyaaADSDK*)instance{
    static BoyaaADSDK *singleton = nil;
    @synchronized(self){
		if(singleton == nil){
			singleton = [[[self class] alloc] init];
		}
	}
    return singleton;
}
-(void)initAppFlyerWithKey:(NSString *)key andAppleItunesID:(NSString*)itunesID{
    appFlyer = [AppsFlyerTracker sharedTracker];
    BYRetain(appFlyer);
    appFlyer.appsFlyerDevKey = key;
    appFlyer.appleAppID = itunesID;
    appFlyer.delegate = self;
}
-(void)setIsDebug:(BOOL)misDebug{
    _isDebug = misDebug;
    appFlyer.isDebug = misDebug;
}
-(void)setCurrencyCode:(NSString *)currencyCode{
    if (_currencyCode) {
        BYRelease(_currencyCode);
    }
    _currencyCode = currencyCode;
    BYRetain(_currencyCode);
    appFlyer.currencyCode = currencyCode;
    [self debugLog:[NSString stringWithFormat:@"now currencyCode :%@",currencyCode]];
}
-(void)appDidBecomeActive{
    [appFlyer trackAppLaunch];
    [self debugLog:[NSString stringWithFormat:@"track applicationDidBecomeActive"]];
}

-(void)start:(NSDictionary*)params {
    [self debugLog:@"start"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    NSDictionary* dict = [[NSDictionary alloc] init];
    [dict setValue:time(NULL) forKey:AFEventParamEventStart];
    [appFlyer trackEvent:BYAD_APP_LAUNCH withValues:dict];
}

-(void)registers:(NSDictionary*)params {
    [self debugLog:@"registers"];
    if(curUserId) {
        BYRelease(curUserId);
    }
    curUserId = [NSString stringWithFormat:@"%@" ,[params objectForKey:@"uid"]];
    BYRetain(curUserId);
    [self setNewRegister:curUserId];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    NSDictionary* dict = [[NSDictionary alloc] init];
    [dict setValue:time(NULL) forKey:AFEventParamEventStart];
    [dict setValue:[params objectForKey:@"userType"] forKey:AFEventParamRegistrationMethod];
    [appFlyer trackEvent:AFEventCompleteRegistration withValues:dict];
}

-(void)login:(NSDictionary*)params {
    [self debugLog:@"login"];
    if(curUserId) {
        BYRelease(curUserId);
    }
    curUserId = [NSString stringWithFormat:@"%@" ,[params objectForKey:@"uid"]];
    BYRetain(curUserId);
    [self setLoginUserDic];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
//    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:AFEventLogin withValues:params];
}

-(void)play:(NSDictionary*)params {
    [self debugLog:@"play"];
    if(![self registerAndPlay]) {
        return;
    }
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
//    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:AFEventLogin withValues:params];
}

-(void)pay:(NSDictionary*)params {
    [self debugLog:@"pay"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    NSDictionary* dict = [[NSDictionary alloc] init];
    [dict setValue:[params objectForKey:@"pay_money"] forKey:AFEventParamRevenue];
    [dict setValue:[params objectForKey:@"currencyCode"] forKey:AFEventParamCurrency];
    [appFlyer trackEvent:AFEventPurchase withValues:dict];
}

-(void)logout:(NSDictionary*)params {
    [self debugLog:@"logout"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    //    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:@"logout" withValues:params];
}

-(void)customEvent:(NSDictionary*)params {
    [self debugLog:@"customEvent"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    //    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:[params objectForKey:@"event_name"] withValues:params];
}

-(void)recall:(NSDictionary*)params {
    [self debugLog:@"recall"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    //    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:AFEventReEngage withValues:params];
}

-(void)share:(NSDictionary*)params {
    [self debugLog:@"share"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    //    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:AFEventShare withValues:params];
}

-(void)invite:(NSDictionary*)params {
    [self debugLog:@"invite"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    //    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:AFEventInvite withValues:params];
}

-(void)purchaseCancel:(NSDictionary*)params {
    [self debugLog:@"purchaseCancel"];
    [appFlyer setCustomerUserID:[params objectForKey:@"uid"]];
    //    NSDictionary* dict = [[NSDictionary alloc] init];
    [appFlyer trackEvent:@"purchase_cancel" withValues:params];
}

@end
