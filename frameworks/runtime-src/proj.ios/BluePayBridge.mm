//
//  BluePayBridge.m
//  nineke
//
//  Created by jonah on 16/3/14.
//
//

#import "BluePayBridge.h"
#import "CCLuaBridge.h"
#import "LuaOCBridge.h"
#import "platform/ios/CCLuaObjcBridge.h"
USING_NS_CC;

static int setupCompleteCallbackMethodId;
static int purchaseCompleteCallbackMethodId;
static BluePayBridge * bluepayPlugin;

@implementation BluePayBridge

+ (void) callLuaCallback:(int)functionId withString:(const char*)params
{
	LuaBridge::pushLuaFunctionById(functionId);
	LuaBridge::getStack()->pushString(params);
	LuaBridge::getStack()->executeFunction(1);
	LuaBridge::releaseLuaFunctionById(functionId);
}

+(BluePayBridge *) getPlugin
{
	if(bluepayPlugin == nil)
	{
		bluepayPlugin = [[BluePayBridge alloc] init];
	}
	return bluepayPlugin;
}

+(BOOL) isSetupComplete
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	return plugin->isSetupComplete;
}

+ (BOOL) isSupported
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	return plugin->isSupported;
}
+ (void) setup
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	[plugin startSetup];
}

+ (void) setCompleteCallback:(NSDictionary*)dict
{
	setupCompleteCallbackMethodId = [[dict objectForKey:@"setupCompleteCallback"] intValue];
	purchaseCompleteCallbackMethodId = [[dict objectForKey:@"purchaseCompleteCallback"] intValue];
}

+ (void) payBySms:(NSDictionary*)dict
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	NSString* transationId = [dict objectForKey:@"transationId"];
	NSString* currency = [dict objectForKey:@"currency"];
	NSString* price = [[dict objectForKey:@"price"] stringValue];
	NSUInteger smsId = [[dict objectForKey:@"smsId"] integerValue];
	NSString* propsName = [dict objectForKey:@"propsName"];
	BOOL isShowDialog = [[dict objectForKey:@"isShowDialog"] boolValue];
	[plugin payBySMS:transationId currency:currency price:price smsid:smsId prpsName:propsName isShowDialog:isShowDialog];
}
	
+ (void) payByBank:(NSDictionary*)dict
{
	BluePayBridge* plugin = [BluePayBridge getPlugin];
	NSString* transationId = [dict objectForKey:@"transationId"];
	NSString* currency = [dict objectForKey:@"currency"];
	NSString* price = [[dict objectForKey:@"price"] stringValue];
	NSString* propsName = [dict objectForKey:@"propsName"];
	BOOL isShowDialog = [[dict objectForKey:@"isShowDialog"] boolValue];
	[plugin payByBank:transationId currency:currency price:price prpsName:propsName isShowDialog:isShowDialog];
}

- (void) startSetup
{
	if(!isSetupComplete)
	{
		isSetuping = true;
		retryLimit = 4;
		[self initSDK];
	}
	
}

- (void) initSDK
{
	_client = [Client getInstance];
	_client.initDelegate = self;
	if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.1) {
		isSetupComplete = true;
		isSetuping = false;
		isSupported = false;
		[BluePayBridge callLuaCallback:setupCompleteCallbackMethodId withString:"false"];
		return;
	}
	[_client initSDK:295 promotion:@"1000" key:@"2_5F689284876D4C68605DBBF7E2C3407F" language:@"en" showLoading:NO];
}

- (void) payBySMS:(NSString *)transationId currency:(NSString *)currency price:(NSString *)price smsid:(NSUInteger)smsId prpsName:(NSString *)propsName isShowDialog:(BOOL)isShowDialog
{
	isPurchasing = true;
	RootViewController* rootVC = [LuaOCBridge getRoomViewController];
	[Blue byMessage:self viewController:(UIViewController *)rootVC transationId:transationId currency:currency price:price messageid:smsId prpsName:propsName isShowDialog:isShowDialog];
}

-(void) payByBank:(NSString *)transationId currency:(NSString *)currency price:(NSString *)price prpsName:(NSString *)propsName isShowDialog:(BOOL)isShowDialog
	{
		isPurchasing = true;
		RootViewController* rootVC = [LuaOCBridge getRoomViewController];
		[Blue byBK:self viewController:(UIViewController *)rootVC  transactionId:transationId currency:currency price:price propsName:propsName isShowDialog:isShowDialog ];
	}
	
-(void) complete:(int)code result:(NSString *)msg
{
	
	NSLog(@"code:%d",code);
	NSLog(@"msg:%@",msg);
	if(code == 1) {
		isSetupComplete = true;
		isSetuping = false;
		isSupported = true;
		isPurchasing = false;
		[BluePayBridge callLuaCallback:setupCompleteCallbackMethodId withString:"true"];
	}
	else
	{
		if(retryLimit-- > 0)
		{
			[self startSetup];
		}
		else
		{
			isSetupComplete = true;
			isSetuping = false;
			isSupported = false;
			[BluePayBridge callLuaCallback:setupCompleteCallbackMethodId withString:"false"];
		}
	}
}

-(void) onComplete:(int)code message:(BlueMessage *)msg
{
	NSLog(@"code:%d",code);
	NSLog(@"result code:%ld message:%@",(long)[msg code],msg.desc);
	NSString* title = @"";
	NSString* result = @"";
	isPurchasing = false;
	NSInteger bcode = 0;
	bool isSuccess = false;
	NSString* transationID = msg.transactionId;
	NSString* desc = msg.desc;
	if (code == RESULT_SECCESS) {
		title = [NSString stringWithFormat:@"购买道具：[ %@ ] 成功！", msg.propsName];
		bcode = msg.code;
		result = [NSString stringWithFormat:@"bcode:%ld 账单ID:%@", (long)bcode,transationID];
		isSuccess = true;
	}else if (code == RESULT_FAILED){
		title = [NSString stringWithFormat:@"购买道具：[ %@ ] 失败！", msg.propsName];
		bcode = msg.code;
		result = [NSString stringWithFormat:@"bcode:%ld 账单ID:%@", (long)bcode,transationID];
		isSuccess = false;
	} else if (code == RESULT_CANCEL) {
		title = [NSString stringWithFormat:@"购买道具：[ %@ ] 取消！", msg.propsName];
		bcode = msg.code;
		result = [NSString stringWithFormat:@"bcode:%ld 账单ID:%@", (long)bcode,transationID];
		isSuccess = false;
	}
	NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
	[dic setValue:result forKey:@"result"];
	[dic setValue:(isSuccess?@"true":@"false") forKey:@"isSuccess"];
	[dic setValue:title forKey:@"title"];
	[dic setValue:[NSNumber numberWithInt:code] forKey:@"code"];
	[dic setValue:desc forKey:@"desc"];
	[dic setValue:transationID forKey:@"transationID"];
	
	if([NSJSONSerialization isValidJSONObject:dic]) {
		NSError* error;
		NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
		NSString *str = [[NSString alloc]initWithData:jsondata encoding:NSUTF8StringEncoding];
		[BluePayBridge callLuaCallback:purchaseCompleteCallbackMethodId withString:[str UTF8String]];
	} else {
		[BluePayBridge callLuaCallback:purchaseCompleteCallbackMethodId withString:"{}"];
	}
	
	
}

@end
