//
//  GuestLoginData.h
//  Poker
//
//  Created by hudaoting on 13-11-29.
//  Copyright (c) 2013年 Boyaa iPhone Texas Poker. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVERICE_NAME_KEY_GUID   @".79VPHGRyHzUQL0TdO13L3N5"
#define BY_GUEST_GUID_PASTE_BOARD   @".PasteBoardFor9kPoker"
#define BUNDLE_ID [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
@interface GuestLoginData : NSObject

/*
 存取userDefault相关
 */
+(void)saveDataToDefault:(id)data;
+(id)loadDataFromDefault;

/*
存取keyChain相关
 */
+ (void)saveDataToKeyChain:(id)data;
+ (id)loadDataFromKeyChain;
+ (NSMutableDictionary *)getKeychainQuery;

/*
 存取剪贴版相关
 */
+ (void)saveDataToPasteboard:(id)data;
+ (id)loadDataFromPasteboard;

/*
 存取userDefault keyChain 剪贴版相关
 */
+(void)saveDataToAllCanSavePlaceWith:(id)data;
+(id)loadDataFromAllCanSavePlace;
@end
