//
//  AdSdkBridge.m
//  nineke
//
//  Created by 罗 崇 on 15/5/20.
//
//

#import "AdSdkBridge.h"
#import "BoyaaADSDK.h"


@implementation AdSdkBridge

//+ (void) registerNewUser:(NSDictionary*)dict
//{	
//	
//	NSString* uid = [dict objectForKey:@"uid"];
//	NSLog(@"registerNewUser %@", uid);
//	[[BoyaaADSDK instance] registerNewUser:uid];
//}
//
//+ (void) loginWithUserId:(NSDictionary*)dict
//{
//	NSString* uid = [dict objectForKey:@"uid"];
//	NSLog(@"loginWithUserId %@", uid);
//	[[BoyaaADSDK instance] loginWithUserId:uid];
//}
//
//+ (void) playGame
//{
//	NSLog(@"playGame");
//	[[BoyaaADSDK instance]playGame];
//}
//
//+ (void) purchase:(NSDictionary*)dict
//{
//	NSString* payMoney = [dict objectForKey:@"payMoney"];
//	NSString* currencyCode = [dict objectForKey:@"currencyCode"];
//	[[BoyaaADSDK instance]setCurrencyCode:payMoney];
//	[[BoyaaADSDK instance]purchase:currencyCode];
//}
//
//+ (void) trackEvent:(NSDictionary*)dict
//{
//	
//	NSString* eventName = [dict objectForKey:@"eventName"];
//	NSString* eventValue = [dict objectForKey:@"eventValue"];
//	NSLog(@"trackEvent %@", eventName);
//	
//	[[BoyaaADSDK instance] trackEvent:eventName withValue:eventValue];
//}

+ (void) report:(NSDictionary *)dict {
    int type = [[dict objectForKey:@"type"] intValue];
    NSString* uid = [dict objectForKey:@"uid"];
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithDictionary:dict];
    if(!uid) {
        [params setValue:@"" forKey:@"uid"];
    }
    switch(type) {
        case 1:
            [[BoyaaADSDK instance] start:params];
            break;
        case 2:
        {
            NSString* userType = [dict objectForKey:@"userType"];
            if(userType == nil) {
                [params setValue:@"" forKey:@"uid"];
            }
            [[BoyaaADSDK instance] registers:params];
        }
            break;
        case 3:
            [[BoyaaADSDK instance] login:params];
            break;
        case 4:
            [[BoyaaADSDK instance] play:params];
            break;
        case 5:
        {
            NSString* payMoney = [dict objectForKey:@"payMoney"];
            if(payMoney == nil) {
                [params setValue:@"0.0" forKey:@"pay_money"];
            }
            NSString* currencyCode = [dict objectForKey:@"currencyCode"];
            if(currencyCode == nil) {
                [params setValue:@"USD" forKey:@"currencyCode"];
            }
             [[BoyaaADSDK instance] pay:params];
        }
            break;
        case 6:
        {
//            [params initWithDictionary:dict];
            NSString* eventName = [dict objectForKey:@"event_name"];
            if(eventName == nil) {
                [params setValue:@"custom" forKey:@"event_name"];
            }
            [[BoyaaADSDK instance] customEvent:params];
        }
            break;
        case 7:
            [[BoyaaADSDK instance] recall:params];
            break;
        case 8:
            [[BoyaaADSDK instance] logout:params];
            break;
        case 9:
            [[BoyaaADSDK instance] share:params];
            break;
        case 10:
            [[BoyaaADSDK instance] invite:params];
            break;
        case 11:
            [[BoyaaADSDK instance] purchaseCancel:params];
            break;
        default:
        {
            NSString* eventName = [dict objectForKey:@"event_name"];
            if(eventName == nil) {
                [params setValue:@"custom" forKey:@"event_name"];
            }
            [[BoyaaADSDK instance] customEvent:params];
        }
            break;
    }
}

@end
