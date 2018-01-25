//
//  GuestLoginData.m
//  Poker
//
//  Created by hudaoting on 13-11-29.
//  Copyright (c) 2013年 Boyaa iPhone Texas Poker. All rights reserved.
//

#import "GuestLoginData.h"

@implementation GuestLoginData

+(void)saveDataToDefault:(id)data
{
    if(data == nil)
    {
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:data forKey:[NSString stringWithFormat:@"%@%@", BUNDLE_ID,SERVERICE_NAME_KEY_GUID]];
    [userDefault synchronize];
}

+(id)loadDataFromDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@%@", BUNDLE_ID,SERVERICE_NAME_KEY_GUID];
    id resultData = [userDefault valueForKey:key];
    return resultData;
}

+ (void)saveDataToKeyChain:(id)data
{
    if(data == nil)
    {
        return ;
    }
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    //删除keychain以前的存储
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //把数据存到keychain
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    if(status == noErr) {
        if(status == errSecSuccess) {
            NSLog(@"Save to keyChain success");
        }
        else {
			NSLog(@"Save to keyChain Failed");
        }
    } else {
        NSLog(@"Save to keyChain Failed");
    }
}

+ (id)loadDataFromKeyChain
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    //获取keychain中存的东西
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData);
    if (status == noErr) {
        if(status == errSecSuccess){
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        else{
            NSLog(@"status error type = %d",(int)status);
        }
    }
    if (keyData != nil)
    {
        CFRelease(keyData);
    }
    return ret;
}

+ (NSMutableDictionary *)getKeychainQuery
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
                                  [NSString stringWithFormat:@"%@%@", BUNDLE_ID,SERVERICE_NAME_KEY_GUID], (__bridge id)kSecAttrService,
                                  [NSString stringWithFormat:@"%@%@", BUNDLE_ID,SERVERICE_NAME_KEY_GUID], (__bridge id)kSecAttrAccount,
                                  (__bridge id)kSecAttrAccessibleWhenUnlocked,(__bridge id)kSecAttrAccessible,
                                  nil];
    return dict;
}

+ (void)saveDataToPasteboard:(id)data
{
    if(data == nil)
    {
        return;
    }
    UIPasteboard* pboard = [UIPasteboard pasteboardWithName:[NSString stringWithFormat:@"%@%@", BUNDLE_ID,BY_GUEST_GUID_PASTE_BOARD] create:YES];
    [pboard setPersistent:YES];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:data] forPasteboardType:[NSString stringWithFormat:@"%@%@", BUNDLE_ID,SERVERICE_NAME_KEY_GUID]];
    
    
}
+ (id)loadDataFromPasteboard
{
    UIPasteboard* pboard = [UIPasteboard pasteboardWithName:[NSString stringWithFormat:@"%@%@", BUNDLE_ID,BY_GUEST_GUID_PASTE_BOARD] create:YES];
    [pboard setPersistent:YES];
    id data = [pboard dataForPasteboardType:[NSString stringWithFormat:@"%@%@", BUNDLE_ID,SERVERICE_NAME_KEY_GUID]];
    id resultData = nil;
    if(data != nil)
    {
        resultData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return resultData;
}

+(void)saveDataToAllCanSavePlaceWith:(id)data
{
#ifdef DEBUG_MODE
    NSString *serverType = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentSelectServerTypeForDebugMode"];
    if([serverType isEqualToString:@"Demo"])
    {
        if(data == nil)
        {
            return;
        }
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:data forKey:[NSString stringWithFormat:@"%@%@DEMO", BUNDLE_ID,SERVERICE_NAME_KEY_GUID]];
        [userDefault synchronize];
    }else{
        //先存keychain
        [self saveDataToKeyChain:data];
        //存 userdeault
        [self saveDataToDefault:data];
        //存 剪贴版
        [self saveDataToPasteboard:data];
    }
#else
    //先存keychain
    [self saveDataToKeyChain:data];
    //存 userdeault
    [self saveDataToDefault:data];

    //存 剪贴版
    [self saveDataToPasteboard:data];
#endif
}
+(id)loadDataFromAllCanSavePlace
{
#ifdef DEBUG_MODE
    id defaultData = nil;
    NSString *serverType = [[NSUserDefaults standardUserDefaults] stringForKey:@"CurrentSelectServerTypeForDebugMode"];
    if([serverType isEqualToString:@"Demo"])
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        defaultData = [userDefault  objectForKey:[NSString stringWithFormat:@"%@%@DEMO", BUNDLE_ID,SERVERICE_NAME_KEY_GUID]];
        if (defaultData != nil) {
            return defaultData;
        }
         return @"";
    }
    defaultData = [self loadDataFromDefault];
    if(defaultData != nil)
    {
        return defaultData;
    }
    else
    {
        id keychainData = [self loadDataFromKeyChain];
        if(keychainData != nil)
        {
            [self saveDataToDefault:keychainData];
            [self saveDataToPasteboard:keychainData];
            return keychainData;
        }
        else
        {
            id PboardData = [self loadDataFromPasteboard];
            if(PboardData != nil)
            {
                [self saveDataToDefault:PboardData];
                [self saveDataToKeyChain:PboardData];
                return PboardData;
            }
            else
            {
                return @"";
            }
        }
    }
#else
    id defaultData = [self loadDataFromDefault];
    if(defaultData != nil)
    {
        return defaultData;
    }
    else
    {
        id keychainData = [self loadDataFromKeyChain];
        if(keychainData != nil)
        {
            [self saveDataToDefault:keychainData];
            [self saveDataToPasteboard:keychainData];
            return keychainData;
        }
        else
        {
            id PboardData = [self loadDataFromPasteboard];
            if(PboardData != nil)
            {
                [self saveDataToDefault:PboardData];
                [self saveDataToKeyChain:PboardData];
                return PboardData;
            }
            else
            {
                return @"";
            }
        }
    }
#endif
}

@end
