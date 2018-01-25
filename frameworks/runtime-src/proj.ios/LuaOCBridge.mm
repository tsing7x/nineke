//
//  LuaOCBridge.m
//  NineKe
//
//  Created by limaohua on 14-7-29.
//
//

#import "LuaOCBridge.h"
#import "CCLuaBridge.h"
#import "platform/ios/CCLuaObjcBridge.h" // 使用其中的pushValue方法来传递ocvalue给Lua
#import "RootViewController.h"
#import "ImagePicker.h"
#import "sys/utsname.h"
#import "sdk/xinge/XGPush.h"
#import "GuestLoginData.h"


USING_NS_CC;

static NSString* pushToken;
static NSString* iOSIDFA;
static int cannotSendSMSLuaCallbackId;
static int cannotSendMAILLuaCallbackId;
static int cannotSendLineLuaCallbackId;
static ImagePicker* imagePicker;
static int pickedImageCallbackId;
static int pickupImgCallbackId;

@implementation LuaOCBridge


// 回调指定id的lua方法
+ (void) callLuaCallback:(int)functionId
{
    LuaBridge::pushLuaFunctionById(functionId);
    LuaBridge::getStack()->pushString("");
    LuaBridge::getStack()->executeFunction(1);
    LuaBridge::releaseLuaFunctionById(functionId);
}

// 获取rootVC
+ (RootViewController*) getRoomViewController
{
    RootViewController* rootVC = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        NSArray* array = [[UIApplication sharedApplication]windows];
        UIWindow* win = [array objectAtIndex:0];
        
        UIView* ui = [[win subviews] objectAtIndex:0];
        rootVC = (RootViewController*)[ui nextResponder];
    }
    else
    {
        // use this method on ios6
        rootVC = (RootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return rootVC;
}

#pragma mark Push
// 设置推送token
+ (void) setPushToken:(NSString*)token
{
    pushToken = token;
    [pushToken retain];
}

// lua层获取推送token
+ (NSString*) getPushToken
{
    return pushToken? pushToken : @"";
}

// 设置推送token
+ (void) setiOSIDFA:(NSString*)token
{
    iOSIDFA = token;
    [iOSIDFA retain];
}


// lua层获取推送token
+ (NSString*) getiOSIDFA
{
    return iOSIDFA? iOSIDFA : @"";
}

// 添加本地通知
+(void)addLocalNotification:(NSDictionary *)dict
{
	NSTimeInterval seconds = [[dict objectForKey:@"seconds"] doubleValue];
	NSString * str = [dict objectForKey:@"message"];
	
	NSDate * fireDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
	
	[XGPush localNotification:fireDate
					alertBody:str
						badge:2
				  alertAction:@"确定"
					 userInfo:NULL];
}


// 截短字符串
+ (NSString*) getFixedWidthText:(NSDictionary*)dict
{
    NSString* text = [dict objectForKey:@"text"];
    NSString* fontName = [dict objectForKey:@"fontName"];
    int fontSize = [[dict objectForKey:@"fontSize"] intValue];
    int fixedWidth = [[dict objectForKey:@"fixedWidth"] intValue];
	bool tooLong;
	if(fontName == nil || fontName.length == 0) {
		fontName = @"Arial";
	}
    UIFont* testFont = [UIFont fontWithName:fontName size:fontSize];
    if ([text sizeWithFont:testFont].width <= fixedWidth)
    {
        tooLong = false;
    }
    else
    {
        tooLong = true;
        while ([[text stringByAppendingString:@".."] sizeWithFont:testFont].width > fixedWidth)
        {
            text = [text substringToIndex:[text length] - 1];
        }
    }
    
    return [text stringByAppendingString:(tooLong? @".." : @"")];
}

// 调出短信
+ (void) showSMSView:(NSDictionary*)dict
{
    NSString* content = [dict objectForKey:@"content"];
    cannotSendSMSLuaCallbackId = [[dict objectForKey:@"cannotCallback"] intValue];
    [[LuaOCBridge getRoomViewController] showSMSView:content];
}

+ (void) canSendSMS:(BOOL)can
{
    if (can)
    {
        LuaBridge::releaseLuaFunctionById(cannotSendSMSLuaCallbackId);
    }
    else
    {
        [LuaOCBridge callLuaCallback:cannotSendSMSLuaCallbackId];
    }
}

// 调出邮箱
+ (void) showMAILView:(NSDictionary*)dict
{
    NSString* subject = [dict objectForKey:@"subject"];
    NSString* content = [dict objectForKey:@"content"];
    cannotSendMAILLuaCallbackId = [[dict objectForKey:@"cannotCallback"] intValue];
    [[LuaOCBridge getRoomViewController] showMAILView:subject content:content];
}

+ (void) canSendMAIL:(BOOL)can
{
    if (can)
    {
        LuaBridge::releaseLuaFunctionById(cannotSendMAILLuaCallbackId);
    }
    else
    {
        [LuaOCBridge callLuaCallback:cannotSendMAILLuaCallbackId];
    }
}

+ (void) showLineView:(NSDictionary*)dict {
	NSString* content = [dict objectForKey:@"content"];
	cannotSendLineLuaCallbackId = [[dict objectForKey:@"cannotCallback"] intValue];
	NSString* urlstr = [NSString stringWithFormat:@"line://msg/text/\"%@\"",content];
	NSString* encodeStr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"urlstr is %@",encodeStr);
	NSURL *url = [NSURL URLWithString:encodeStr];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}else {
		urlstr =[NSString stringWithFormat:@"http://line.me/R/msg/text/%@",content];
		NSString* encodeStr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSLog(@"urlstr is %@",encodeStr);
		url = [NSURL URLWithString:encodeStr];
		[[UIApplication sharedApplication] openURL:url];
	}
}

+ (void) canSendLine:(BOOL)can
{
	if (can)
	{
		LuaBridge::releaseLuaFunctionById(cannotSendLineLuaCallbackId);
	}
	else
	{
		[LuaOCBridge callLuaCallback:cannotSendLineLuaCallbackId];
	}
}

// 调出图库
+ (void) showImagePicker:(NSDictionary*)dict
{
    pickedImageCallbackId = [[dict objectForKey:@"pickedImageCallback"] intValue];
    if (!imagePicker)
    {
        imagePicker = [[ImagePicker alloc] init];
    }
	imagePicker.canEdit = YES;
    [imagePicker showImagePicker];
}

+ (void) pickedImageCallback:(NSString *)imagePath
{
    if (!imagePath)
    {
        LuaBridge::releaseLuaFunctionById(pickedImageCallbackId);
    }
    else
    {
        LuaBridge::pushLuaFunctionById(pickedImageCallbackId);
        LuaBridge::getStack()->pushString([imagePath UTF8String]);
        LuaBridge::getStack()->executeFunction(1);
        LuaBridge::releaseLuaFunctionById(pickedImageCallbackId);
    }
}

// change log:
// 5.26 把读取build号改成了读取版本号
+ (NSString*) getAppVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	return [infoDictionary objectForKey:@"CFBundleShortVersionString"];

}

+ (NSString*) getPriceLabel:(NSDictionary*)dict
{
	NSString* priceLocale = [dict objectForKey:@"priceLocale"];
	NSNumber* price = [[[NSNumber alloc] initWithFloat:[[dict objectForKey:@"price"] floatValue]] autorelease];
	
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:priceLocale] autorelease]];
	return [numberFormatter stringFromNumber:price];
}

+(void) pickupPic:(NSDictionary*)dict
{
	pickupImgCallbackId = [[dict objectForKey:@"pickedImageCallback"] intValue];
	if (!imagePicker)
	{
		imagePicker = [[ImagePicker alloc] init];
	}
	imagePicker.canEdit = NO;
	[imagePicker showImagePicker];
}

+ (void) pickupPicCallback:(NSString *)imagePath
{
	NSLog(@"pickupPicCallback %@", imagePath);
	if (!imagePath)
	{
		LuaBridge::releaseLuaFunctionById(pickupImgCallbackId);
	}
	else
	{
		LuaBridge::pushLuaFunctionById(pickupImgCallbackId);
		LuaBridge::getStack()->pushString([imagePath UTF8String]);
		LuaBridge::getStack()->executeFunction(1);
		LuaBridge::releaseLuaFunctionById(pickupImgCallbackId);
	}
}

+ (NSString*) getDeviceInfo
{
	struct utsname systemInfo;
	uname(&systemInfo);
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	UIDevice* device = [UIDevice currentDevice];
	//[dic setValue:[device name] forKey:@"deviceName"]; //return "xxx's iPhone"
	NSString *deviceModel = [[NSString alloc] initWithFormat:@"%@|%@", [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding], [device systemVersion]];
	[dic setValue:deviceModel forKey:@"deviceModel"];
	[dic setValue: [@"iOS " stringByAppendingString:[device systemVersion]]forKey:@"osVersion"];
	[dic setValue:@"" forKey:@"deviceName"];
	[dic setValue:@"" forKey:@"installInfo"];
	[dic setValue:@"" forKey:@"cpuInfo"];
	[dic setValue:@"" forKey:@"ramSize"];
	[dic setValue:@"" forKey:@"simNum"];
	
	if([NSJSONSerialization isValidJSONObject:dic]) {
		NSError* error;
		NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
		NSString *str = [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];
		return str;
	} else {
		return @"{}";
	}
}

+ (NSString *) tryLoadOpenUDID:(NSString*)openUDID
{
	id v = [GuestLoginData loadDataFromKeyChain];
	if (v == nil) {
		[GuestLoginData saveDataToKeyChain: openUDID];
		v = openUDID;
	}
	NSLog(@"%@", v);
	return v;
}

+ (void) assureSaveOpenUDID:(NSString *) openUDID
{
	id v = [GuestLoginData loadDataFromKeyChain];
	if (![openUDID isEqualToString:v]) {
		[GuestLoginData saveDataToKeyChain: openUDID];
	}
}

+ (int) getBatteryInfo {
	UIDevice *device = [UIDevice currentDevice];
	device.batteryMonitoringEnabled = YES;
	return (int)(device.batteryLevel * 100);
}


+ (void) setClipboardText:(NSString *) content {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = content;
}

+ (void) shareText:(NSDictionary*) dict {
	NSMutableArray *sharingItems = [NSMutableArray new];
	NSString* name = [dict objectForKey:@"name"];
	NSString* picture = [dict objectForKey:@"picture"];
	NSString* link = [dict objectForKey:@"link"];
	if(name) {
		[sharingItems addObject:name];
	}
	if(picture) {
		[sharingItems addObject:picture];
	}
	if(link) {
		[sharingItems addObject:link];
	}
	UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
	activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
	RootViewController* rootVC = [LuaOCBridge getRoomViewController];
	if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
		activityVC.popoverPresentationController.sourceView = rootVC.view;
		activityVC.popoverPresentationController.permittedArrowDirections =UIPopoverArrowDirectionRight;
	}
	[rootVC presentViewController:activityVC animated:TRUE completion:nil];
}
@end
