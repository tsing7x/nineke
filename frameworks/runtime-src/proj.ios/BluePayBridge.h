//
//  BluePayBridge.h
//  nineke
//
//  Created by jonah on 16/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreBlue/CoreBlue.h>

@interface BluePayBridge : NSObject<InitSDKProtocal,PDelegate>
{
	Client* _client;
	BOOL isSetupComplete;
	BOOL isSetuping;
	BOOL isSupported;
	BOOL isPurchasing;
	int retryLimit;
}

+ (void) callLuaCallback:(int)functionId withString:(const char*)params;
+ (BluePayBridge*) getPlugin;
+ (BOOL) isSetupComplete;
+ (BOOL) isSupported;
+ (void) setup;
+ (void) setCompleteCallback:(NSDictionary*)dict;
+ (void) payBySms:(NSDictionary*)dict;

- (void) startSetup;
- (void) initSDK;
- (void) payBySMS:(NSString*) transationId currency:(NSString*) currency price:(NSString*) price smsid:(NSUInteger) smsId prpsName:(NSString*) propsName   isShowDialog :(BOOL) isShowDialog;


@property(nonatomic ,retain) Client* client;
@end
