//
//  FacebookBridge.h
//  NineKe
//
//  Created by 李强 on 14-8-27.
//
//

#import <Foundation/Foundation.h>
#import "CCLuaBridge.h"
#import <FacebookSDK/FacebookSDK.h>

USING_NS_CC;

@interface FacebookBridge : NSObject

// call by oc
- (void) callLoginLuaCallback:(NSString*)accessToken errorInfo:(NSString*) error;
- (void) requestInvitableFriends:(NSString*) limit;
- (void) sendFeed:(NSDictionary*)dict;
- (BOOL) canPresentDialog;
- (NSDictionary*) parseURLParams:(NSString*)query;

// call by lua
+ (FacebookBridge*) sharedInstance;
+ (void) initFB;
+ (void) login:(NSDictionary*)dict;
+ (void) logout;
+ (void) shareFeed:(NSDictionary*)dict;
+ (void) getInvitableFriends:(NSDictionary*)dict;
+ (void) sendInvites:(NSDictionary*)dict;
+ (void) getRequestId:(NSDictionary*)dict;
+ (void) deleteRequestId:(NSDictionary*)dict;

@end
