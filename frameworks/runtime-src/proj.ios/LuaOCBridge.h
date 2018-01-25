//
//  LuaOCBridge.h
//  NineKe
//
//  Created by 李强 on 14-7-29.
//
//

#import <Foundation/Foundation.h>

@class RootViewController;

@interface LuaOCBridge : NSObject

// call by oc
+ (void) setPushToken:(NSString*)token;
+ (void) setiOSIDFA:(NSString*)token;
+ (void) callLuaCallback:(int)functionId;
+ (RootViewController*) getRoomViewController;


// call by lua
+ (NSString*) getPushToken;
+ (NSString*) getiOSIDFA;
+ (NSString*) getFixedWidthText:(NSDictionary*)dict;
+ (void) showSMSView:(NSDictionary*)dict;
+ (void) canSendSMS:(BOOL)can;
+ (void) showMAILView:(NSDictionary*)dict;
+ (void) canSendMAIL:(BOOL)can;
+ (void) showLineView:(NSDictionary*)dict;
+ (void) canSendLine:(BOOL)can;
+ (void) showImagePicker:(NSDictionary*)dict;
+ (void) pickedImageCallback:(NSString*)imagePath;
+ (void) pickupPicCallback:(NSString *)imagePath;
+ (NSString*) getAppVersion;
+ (NSString*) getPriceLabel:(NSDictionary*)dict;
+ (void) pickupPic:(NSDictionary*)dict;
+ (NSString*) getDeviceInfo;

+ (NSString*) tryLoadOpenUDID:(NSString *) openUDID;
+ (void) assureSaveOpenUDID:(NSString *) openUDID;

+ (int) getBatteryInfo;
+ (void) setClipboardText:(NSString *) content;

+ (void) shareText:(NSDictionary*)dict;

@end
