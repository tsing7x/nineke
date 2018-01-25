
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <AdSupport/ASIdentifierManager.h>
#import <MediaPlayer/MediaPlayer.h>

#import <FacebookSDK/FacebookSDK.h>


#import "cocos2d.h"
#import "platform/ios/CCEAGLView-ios.h"


#import "LuaOCBridge.h"

#import "XGSetting.h"
#import "XGPush.h"
#import "BoyaaADSDK.h"

#import "RootViewController.h"
#import "VideoPlayViewController.h"
#import "AppNotificationCenter.h"

#import "AppController.h"
#import "AppDelegate.h"


@interface AppController ()
{
	VideoPlayViewController * videoPlayer;
    BOOL cocosStarted;
}

- (void) startCocos2dx;
- (void) videoPlayDidFinish:(NSNotification *) notification;
- (void) dispatchRemoteNotification:(NSDictionary *) userInfo;

@end


@implementation AppController

- (void) videoPlayDidFinish:(NSNotification *) notification
{
	NSLog(@"video play over");
	[self startCocos2dx];
}

- (void) startCocos2dx
{
	NSLog(@"start cocos2dx");
    cocos2d::Application *app = cocos2d::Application::getInstance();
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();
    
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame: [window bounds]
                                         pixelFormat: (NSString*)cocos2d::GLViewImpl::_pixelFormat
                                         depthFormat: cocos2d::GLViewImpl::_depthFormat
                                  preserveBackbuffer: NO
                                          sharegroup: nil
                                       multiSampling: NO
                                     numberOfSamples: 0 ];
    
    [eaglView setMultipleTouchEnabled:YES];
	
	// Use RootViewController manage EAGLView
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	viewController.view = eaglView;
	
    // Set RootViewController to window
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        [window addSubview: viewController.view];
    } else {
        [window setRootViewController:viewController];
    }
	
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    cocosStarted = true;
	cocos2d::Application::getInstance()->run();
}

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	
	//广告统计sdk
	[[BoyaaADSDK instance]initAppFlyerWithKey:@"x7Px3ea6x8SZpwFf7xSWJg" andAppleItunesID:@"933218146"];
	[BoyaaADSDK instance].isDebug = YES;
	
	NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	NSLog(@"IDFA = %@", adId);
	[LuaOCBridge setiOSIDFA:adId];
	
    // Add the view controller's view to the window and display.

    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

// xcode调试时,选择nineke.dev时会开启IS_DEV_BUILD=1宏

#if (IS_DEV_BUILD && CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	[self startCocos2dx];
#else
	videoPlayer = [[VideoPlayViewController alloc] initWithNibName:nil bundle:nil];
	[videoPlayer setAppController:self];
	
    [window setRootViewController:videoPlayer];

    // Set RootViewController to window
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        [window addSubview: videoPlayer.view];
    }
    cocosStarted = false;
#endif

//    [self startCocos2dx];
	
    [window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
	[[UIApplication sharedApplication] setIdleTimerDisabled: YES];
	

	//===================
	//信鸽推送
	//===================
	NSString* bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleIdentifierKey];
	if ([@"com.boomegg.nineke" isEqualToString:bundleId] ) {
		[XGPush startApp:2200050672 appKey:@"I19X64FJ3SWF"];
	} else if ([@"com.boomegg.nineke.vn" isEqualToString:bundleId]) {
		[XGPush startApp:2200059201 appKey:@"IL68I1Q2H1HT"];
	} else if ([@"com.boomegg.nineke.en" isEqualToString:bundleId]) {
		[XGPush startApp:2200066044 appKey:@"IJIF666G81BR"];
	}
	//注销之后需要再次注册前的准备
	void (^successCallback)(void) = ^(void) {
		//如果变成需要注册状态
		if(![XGPush isUnRegisterStatus]) {
			//iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
			
			float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
			if (sysVer < 8) {
				[self registerPush];
			}
			else {
				[self registerPushForIOS8];
			}
#else
			//iOS8之前注册push方法 注册Push服务，注册后才能收到推送
			[self registerPush];
#endif
		}
	};
	[XGPush initForReregister:successCallback];
	
	void (^successBlock)(void) = ^(void){
		NSLog(@"[XGPush]handleLaunching's successBlock");
	};
	
	void (^errorBlock)(void) = ^(void){
		NSLog(@"[XGPush]handleLaunching's errorBlock");
	};
	[XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
	
	//角标清0
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	NSDictionary *notification = [launchOptions objectForKey:
								 UIApplicationLaunchOptionsRemoteNotificationKey];
	if (notification) {
		[self dispatchRemoteNotification:notification];
	}
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    if(cocosStarted) {
        cocos2d::Director::getInstance()->pause();
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActive];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[[BoyaaADSDK instance] appDidBecomeActive];
    if(cocosStarted) {
        cocos2d::Director::getInstance()->resume();
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    if(cocosStarted) {
        cocos2d::Application::getInstance()->applicationDidEnterBackground();
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    NSError *err;
    [[AVAudioSession sharedInstance] setActive:true error:&err];
    if(cocosStarted) {
        cocos2d::Application::getInstance()->applicationWillEnterForeground();
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark UIApplicationDelegate Protocol
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	//注册设备
	NSString * deviceTokenStr = [XGPush registerDevice: deviceToken];
	[LuaOCBridge setPushToken:deviceTokenStr];
	NSLog(@"Push DeviceToken: %@", deviceTokenStr);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"Receive remote Notify: %@", [userInfo description]);
	[application setApplicationIconBadgeNumber:0];
	[XGPush handleReceiveNotification:userInfo];
	[self dispatchRemoteNotification:userInfo];
}

- (void) dispatchRemoteNotification:(NSDictionary *) userInfo
{
	/*
	> sample result on July 9
	 {
		aps = {...};
		chip = 80000;
		cmd = autoPush;
		key = "201507091442_1_pay_a66c68e2";
		xg = {...};
	 
	 }
	*/
	id cmd = [userInfo objectForKey:@"cmd"];
	if ([cmd isKindOfClass:[NSString class]] && [cmd isEqualToString:@"autoPush"]) {
		if([NSJSONSerialization isValidJSONObject:userInfo]) {
			NSError* error;
			NSData *jsondata =
				[NSJSONSerialization dataWithJSONObject:userInfo
												options:NSJSONWritingPrettyPrinted
												  error:&error];
			NSString * str = [[NSString alloc]initWithData:jsondata
												  encoding:NSUTF8StringEncoding];
			AppNotificationCenter::handleDidReceiveAutoRecall([str UTF8String]);
		} else {
			NSLog(@"msg cannot convert to json %@", [userInfo description]);
		}
	} else {
		NSLog(@"other cmd %@", [userInfo description]);
	}
}

// 收到本地通知
- (void) application:(UIApplication *) application didReceiveLocalNotification:(UILocalNotification *)notification
{
	NSLog(@"Receive local notify: %@", [notification description]);
	[application setApplicationIconBadgeNumber:0];
}

#pragma mark UIApplicationDelegate : Managing the Default Interface Orientations
// 兼容竖屏vc的情况
- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
	
	//Types
	UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
	
	//Actions
	UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
	
	acceptAction.identifier = @"ACCEPT_IDENTIFIER";
	acceptAction.title = @"Accept";
	
	acceptAction.activationMode = UIUserNotificationActivationModeForeground;
	acceptAction.destructive = NO;
	acceptAction.authenticationRequired = NO;
	
	//Categories
	UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
	
	inviteCategory.identifier = @"INVITE_CATEGORY";
	
	[inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
	
	[inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
	
	NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
	
	
	UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
	
	[[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
	
	
	[[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

#pragma mark -

#pragma mark open URL & Facebook API
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//	return [FBSession.activeSession handleOpenURL:url];
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [FBSession.activeSession handleOpenURL:url];
}
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
//    if(cocosStarted) {
//        cocos2d::Director::getInstance()->purgeCachedData();
//    }
}

- (void)dealloc {
    [super dealloc];
}



@end

