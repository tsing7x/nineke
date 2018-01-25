//
//  FacebookBridge.m
//  NineKe
//
//  Created by 李强 on 14-8-27.
//
//

#import "FacebookBridge.h"

static FacebookBridge* sharedInstance = nil;

static int FBLoginCallbackId = -1;
static int shareFeedCallbackId = -1;
static int getInvitableFriendsCallbackId = -1;

static FBFrictionlessRecipientCache *frictionlessFriendCache;


@implementation FacebookBridge

- (void) callLoginLuaCallback:(NSString*)accessToken errorInfo:(NSString*) error
{
    LuaBridge::pushLuaFunctionById(FBLoginCallbackId);
	
    LuaBridge::getStack()->pushString([accessToken UTF8String]);
	
	if (error) {
		LuaBridge::getStack()->pushString([error UTF8String]);
	} else {
		LuaBridge::getStack()->pushNil();
	}
	
    LuaBridge::getStack()->executeFunction(2);
	
    LuaBridge::releaseLuaFunctionById(FBLoginCallbackId);
    FBLoginCallbackId = -1;
}

- (void) requestInvitableFriends:(NSString*) limit
{
	
	NSDictionary *parametersDic  = [NSDictionary dictionaryWithObject:limit forKey:@"limit"];
	
    [FBRequestConnection startWithGraphPath:@"/me/invitable_friends"
                                 parameters:parametersDic
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
							  if(error) {
								  NSLog(@"requestInvitableFriends faild check the permissions.");
								  LuaBridge::pushLuaFunctionById(getInvitableFriendsCallbackId);
								  LuaBridge::getStack()->pushString([@"faild" UTF8String]);
								  LuaBridge::getStack()->executeFunction(1);
								  LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
								  getInvitableFriendsCallbackId = -1;
								  return;
							  }
                              NSArray* friends = [result objectForKey:@"data"];
                              auto friendNum = friends.count;
                              if (friendNum > 0)
                              {
                                  LuaValueArray friendList;
                                  for (int i = 0; i < friendNum; i++)
                                  {
                                      NSDictionary<FBGraphUser>* friendData = [friends objectAtIndex:i];
                                      id pictureData = [[friendData objectForKey:@"picture"] objectForKey:@"data"];
                                      
                                      LuaValueDict friendItem;
                                      friendItem["name"] = LuaValue::stringValue([friendData.name UTF8String]);
                                      friendItem["id"]   = LuaValue::stringValue([friendData.objectID UTF8String]);
                                      friendItem["url"]  = LuaValue::stringValue([[pictureData objectForKey:@"url"] UTF8String]);
                                      friendList.push_back(LuaValue::dictValue(friendItem));
                                  }
                                  
                                  FBSession *session = [FBSession activeSession];
                                  NSString * token = session.accessTokenData.accessToken;
                                LuaValueDict friendItem;
                                friendItem["token"] = LuaValue::stringValue([token UTF8String]);
                                friendList.push_back(LuaValue::dictValue(friendItem));

                                LuaBridge::pushLuaFunctionById(getInvitableFriendsCallbackId);
                                LuaBridge::getStack()->pushLuaValueArray(friendList);
                                LuaBridge::getStack()->executeFunction(1);
                                LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
                                  getInvitableFriendsCallbackId = -1;
							  } else {
                            LuaValueArray friendList;
                            FBSession *session = [FBSession activeSession];
                            NSString * token = session.accessTokenData.accessToken;
                            LuaValueDict friendItem;
                            friendItem["token"] =  LuaValue::stringValue([token UTF8String]);
                            friendList.push_back(LuaValue::dictValue(friendItem));

                            LuaBridge::pushLuaFunctionById(getInvitableFriendsCallbackId);
                            LuaBridge::getStack()->pushLuaValueArray(friendList);
                            LuaBridge::getStack()->executeFunction(1);
                            LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
                            getInvitableFriendsCallbackId = -1;
							  }
                          }];
}

- (void) openFeedDialog:(NSDictionary *)dict
{
	NSString* message = [dict objectForKey:@"message"];
	NSString* link = [dict objectForKey:@"link"];
	NSString* picture = [dict objectForKey:@"picture"];
	NSString* name = [dict objectForKey:@"name"];
	NSString* caption = [dict objectForKey:@"caption"];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							message, @"message",
							link, @"link",
							picture, @"picture",
							name, @"name",
							caption, @"caption",
							nil
							];

	[FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession] parameters:params
	 handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
		 if (error)
		 {
			 // Error launching the dialog or sending the request.
			 NSLog(@"Error sending request.");
             LuaBridge::pushLuaFunctionById(shareFeedCallbackId);
             LuaBridge::getStack()->pushString([@"failed" UTF8String]);
             LuaBridge::getStack()->executeFunction(1);
             LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
		 }
		 else
		 {
			 if (result == FBWebDialogResultDialogNotCompleted)
			 {
				 // User clicked the "x" icon
				 NSLog(@"User canceled request. Request not completed.");
				 LuaBridge::pushLuaFunctionById(shareFeedCallbackId);
				 LuaBridge::getStack()->pushString([@"canceled" UTF8String]);
				 LuaBridge::getStack()->executeFunction(1);
				 LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
			 }
			 else
			 {
				 NSLog(@"result:%@", [resultURL query]);
				 // Handle the send request callback
				 NSArray *pairs = [[resultURL query] componentsSeparatedByString:@"&"];
				 NSString* postId = nil;
				 for (NSString *pair in pairs)
				 {
					 NSArray *kv = [pair componentsSeparatedByString:@"="];
					 NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					 if ([[kv objectAtIndex:0] isEqual: @"post_id"])
					 {
						 postId = val;
						 break;
					 }
				 }
				 
				 if (!postId)
				 {
					 // User clicked the Cancel button
					 NSLog(@"User canceled request.");
					 LuaBridge::pushLuaFunctionById(shareFeedCallbackId);
					 LuaBridge::getStack()->pushString([@"canceled" UTF8String]);
					 LuaBridge::getStack()->executeFunction(1);
					 LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
				 }
				 else
				 {
					 LuaBridge::pushLuaFunctionById(shareFeedCallbackId);
					 LuaBridge::getStack()->pushString([postId UTF8String]);
					 LuaBridge::getStack()->executeFunction(1);
					 LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
				 }
			 }
		 }
		 LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
	 }];
}

- (void) sendFeed:(NSDictionary *)dict
{
    NSString* message = [dict objectForKey:@"message"];
    NSString* link = [dict objectForKey:@"link"];
    NSString* picture = [dict objectForKey:@"picture"];
    NSString* name = [dict objectForKey:@"name"];
    NSString* caption = [dict objectForKey:@"caption"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            message, @"message",
                            link, @"link",
                            picture, @"picture",
                            name, @"name",
                            caption, @"caption",
                            nil
                            ];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSString* status;
                              if (error)
                              {
                                  status = @"error";
                              }
                              else
                              {
                                  status = @"success";
                              }
                              LuaBridge::pushLuaFunctionById(shareFeedCallbackId);
                              LuaBridge::getStack()->pushString([status UTF8String]);
                              LuaBridge::getStack()->executeFunction(1);
                              LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
                              shareFeedCallbackId = -1;
                          }];
}

- (BOOL) canPresentDialog
{
    // dummy params, they don't influence the eligibility for native dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    BOOL canPresent = [FBDialogs canPresentShareDialogWithParams:params];
    
    return canPresent;
}

- (NSDictionary*) parseURLParams:(NSString *)query
{
    NSLog(@"query %@", query);
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

+ (FacebookBridge*) sharedInstance
{
    if (!sharedInstance)
    {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

// 初始化FB
+ (void) initFB
{
    FBSession *session = [[FBSession alloc] init];
    [FBSession setActiveSession:session];
    
    // opening session from cached token
    if (session.state == FBSessionStateCreatedTokenLoaded)
    {
		[session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(
                                                                                                      FBSession *session,
                                                                                                      FBSessionState status,
                                                                                                      NSError *error) {
            if (status == FBSessionStateOpen) {
                if (frictionlessFriendCache == NULL) {
                    frictionlessFriendCache = [[FBFrictionlessRecipientCache alloc] init];
                }
                [frictionlessFriendCache prefetchAndCacheForSession:nil];
                NSLog(@"Session opened with permissions: %@", [session.permissions componentsJoinedByString:@", "]);
            }
            else if (status == FBSessionStateClosed)
            {
                NSLog(@"Session closed");
            }
        }];
    }
}

// FB登录
+ (void) login:(NSDictionary*)dict
{
    if (FBLoginCallbackId != -1)
    {
        LuaBridge::releaseLuaFunctionById(FBLoginCallbackId);
        FBLoginCallbackId = -1;
    }
    FBLoginCallbackId = [[dict objectForKey:@"listener"] intValue];
    
    // session未打开或token过期或token值为空，重新打开新的session
    FBSession *session = [FBSession activeSession];
    if (![session isOpen] ||
        [session.accessTokenData.expirationDate timeIntervalSince1970] <= time(NULL) ||
        !session.accessTokenData.accessToken)
    {
        NSLog(@"Session is not opened!");
        session = [[FBSession alloc] initWithPermissions:@[@"email", @"user_friends"]];
        [FBSession setActiveSession:session];
        
        // open session
		[session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session,
																								  FBSessionState status,
																								  NSError *error) {
            if (status == FBSessionStateOpen || status == FBSessionStateOpenTokenExtended) {
                // do login callback
				NSString * token = session.accessTokenData.accessToken;
				[[FacebookBridge sharedInstance] callLoginLuaCallback: token
															errorInfo: nil];
				
                if (frictionlessFriendCache == NULL) {
                    frictionlessFriendCache = [[FBFrictionlessRecipientCache alloc] init];
                    [frictionlessFriendCache prefetchAndCacheForSession:nil];
                }
                NSLog(@"Session opened with permissions: %@", [session.permissions componentsJoinedByString:@", "]);
            }
            else if (status == FBSessionStateClosed)
            {
                NSLog(@"Session closed");
                [[FacebookBridge sharedInstance] callLoginLuaCallback:@""
															errorInfo:[error localizedDescription]];
            }
			else if (status == FBSessionStateClosedLoginFailed) {
				NSLog(@"closed login failed");
                [[FacebookBridge sharedInstance] callLoginLuaCallback:@""
															errorInfo:[error localizedDescription]];
			} else {
				NSLog(@"status is %lu", (unsigned long)status);
			}
        }];
    }
    else
    {
        NSLog(@"Session is opened!");
        [[FacebookBridge sharedInstance] callLoginLuaCallback:session.accessTokenData.accessToken
													errorInfo:nil];
    }
}

+ (void) logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [frictionlessFriendCache release];
    frictionlessFriendCache = nil;
}

+ (void) shareFeed:(NSDictionary *)dict
{
    if (shareFeedCallbackId != -1)
    {
        LuaBridge::releaseLuaFunctionById(shareFeedCallbackId);
        shareFeedCallbackId = -1;
    }
    shareFeedCallbackId = [[dict objectForKey:@"listener"] intValue];
    FBSession *session = [FBSession activeSession];
	/*
    if (![session hasGranted:@"publish_actions"])
    {
        NSLog(@"Not granted publish_actions permission!");
        [session requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
            if (!error)
            {
                [[FacebookBridge sharedInstance] sendFeed:dict];
            }
        }];
    }
    else
    {
        NSLog(@"Granted publish_actions permission!");
        [[FacebookBridge sharedInstance] sendFeed:dict];
    }*/
	if (![session isOpen] ||
		[session.accessTokenData.expirationDate timeIntervalSince1970] <= time(NULL) ||
		!session.accessTokenData.accessToken)
	{
		NSLog(@"Session is not opened!");
		session = [[FBSession alloc] initWithPermissions:@[@"email", @"user_friends"]];
		[FBSession setActiveSession:session];
		
		// open session
		[session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(
																									  FBSession *session,
																									  FBSessionState status,
																									  NSError *error) {
			if (status == FBSessionStateOpen) {
				NSLog(@"Session is opened!");
				[[FacebookBridge sharedInstance] openFeedDialog:dict];
			}
			else if (status == FBSessionStateClosed)
			{
				NSLog(@"Session closed");
			}
		}];
	}
	else
	{
		NSLog(@"Session is opened!");
		[[FacebookBridge sharedInstance] openFeedDialog:dict];
	}

}

+ (void) getInvitableFriends:(NSDictionary*)dict
{
    if (getInvitableFriendsCallbackId != -1)
    {
        LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
        getInvitableFriendsCallbackId = -1;
    }
    getInvitableFriendsCallbackId = [[dict objectForKey:@"listener"] intValue];
	NSString * limit = [dict objectForKey:@"limit"];
    FBSession *session = [FBSession activeSession];
    if (![session isOpen] ||
        [session.accessTokenData.expirationDate timeIntervalSince1970] <= time(NULL) ||
        !session.accessTokenData.accessToken)
    {
        NSLog(@"Session is not opened!");
        session = [[FBSession alloc] initWithPermissions:@[@"email", @"user_friends"]];
        [FBSession setActiveSession:session];
        
        // open session
        [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent completionHandler:^(
                                                                                                      FBSession *session,
                                                                                                      FBSessionState status,
                                                                                                      NSError *error) {
			if(error) {
				NSLog(@"requestInvitableFriends faild check the permissions.");
				LuaBridge::pushLuaFunctionById(getInvitableFriendsCallbackId);
				LuaBridge::getStack()->pushString([@"faild" UTF8String]);
				LuaBridge::getStack()->executeFunction(1);
				LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
				getInvitableFriendsCallbackId = -1;
				return;
			}
            if (status == FBSessionStateOpen) {
                NSLog(@"Session is opened!");
                
                // init frictionlessFriendCache
                if (frictionlessFriendCache == NULL) {
                    frictionlessFriendCache = [[FBFrictionlessRecipientCache alloc] init];
                    [frictionlessFriendCache prefetchAndCacheForSession:nil];
                }
				[[FacebookBridge sharedInstance] requestInvitableFriends:limit];
            }
            else if (status == FBSessionStateClosed)
            {
                NSLog(@"Session closed");
				LuaBridge::pushLuaFunctionById(getInvitableFriendsCallbackId);
				LuaBridge::getStack()->pushString([@"faild" UTF8String]);
				LuaBridge::getStack()->executeFunction(1);
				LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
				getInvitableFriendsCallbackId = -1;
				return;
			}else {
				NSLog(@"requestInvitableFriends faild check the permissions.");
				LuaBridge::pushLuaFunctionById(getInvitableFriendsCallbackId);
				LuaBridge::getStack()->pushString([@"faild" UTF8String]);
				LuaBridge::getStack()->executeFunction(1);
				LuaBridge::releaseLuaFunctionById(getInvitableFriendsCallbackId);
				getInvitableFriendsCallbackId = -1;
				return;
			}
        }];
    }
    else
    {
        NSLog(@"Session is opened!");
        [[FacebookBridge sharedInstance] requestInvitableFriends:limit];
    }
}

// 发送邀请
+ (void) sendInvites:(NSDictionary*)dict
{
    int luaCallbackId = [[dict objectForKey:@"listener"] intValue];
    NSString * data = [dict objectForKey:@"data"];
    NSString * toIds = [dict objectForKey:@"toIds"];
    NSString * message = [dict objectForKey:@"message"];
    NSString * title = [dict objectForKey:@"title"];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:toIds, @"to", data, @"data", nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:message
     title:title
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error)
         {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         }
         else
         {
             if (result == FBWebDialogResultDialogNotCompleted)
             {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request. Request not completed.");
             }
             else
             {
                 // Handle the send request callback
                 NSArray *pairs = [[resultURL query] componentsSeparatedByString:@"&"];
                 NSMutableDictionary *urlParams = [[[NSMutableDictionary alloc] init] autorelease];
                 NSString *toIds = @"";
                 for (NSString *pair in pairs)
                 {
                     NSArray *kv = [pair componentsSeparatedByString:@"="];
                     NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                     if ([[kv objectAtIndex:0] isEqual: @"request"])
                     {
                         [urlParams setObject:val forKey:@"request"];
                     }
                     else if([[kv objectAtIndex:0] rangeOfString: @"to"].location == 0)
                     {
                         toIds = [[toIds stringByAppendingString:val] stringByAppendingString:@","];
                     }
                 }
                 [urlParams setObject:toIds forKey:@"to"];
                 
                 if (![urlParams valueForKey:@"request"])
                 {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 }
                 else
                 {
                     // User clicked the Send button
                     LuaValueDict item;
                     item["requestId"] = LuaValue::stringValue([[urlParams valueForKey:@"request"] UTF8String]);
                     item["toIds"] = LuaValue::stringValue([[urlParams valueForKey:@"to"] UTF8String]);
                     LuaBridge::pushLuaFunctionById(luaCallbackId);
                     LuaBridge::getStack()->pushLuaValueDict(item);
                     LuaBridge::getStack()->executeFunction(1);
                 }
             }
         }
         LuaBridge::releaseLuaFunctionById(luaCallbackId);
     }
     friendCache:frictionlessFriendCache];
}

+ (void) getRequestId:(NSDictionary *)dict
{
    int luaCallbackId = [[dict objectForKey:@"listener"] intValue];
    [FBRequestConnection startWithGraphPath:@"/me/apprequests"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error)
                              {
                                  LuaBridge::releaseLuaFunctionById(luaCallbackId);
                              }
                              else
                              {
                                  NSArray* requests = [result objectForKey:@"data"];
                                  auto dataNum = requests.count;
                                  // 只拿最新的requestId
                                  if (dataNum > 0)
                                  {
                                      id requestData = [requests objectAtIndex:0];
                                      NSString *requestId = [requestData objectForKey:@"id"];
                                      [FBRequestConnection startWithGraphPath:requestId
                                                                   parameters:nil
                                                                   HTTPMethod:@"GET"
                                                            completionHandler:^(
                                                                                FBRequestConnection *connection,
                                                                                id result,
                                                                                NSError *error
                                                                                ) {
                                                                NSString* requestId = [result objectForKey:@"id"];
                                                                NSString* requestData = [result objectForKey:@"data"];
                                                                LuaValueDict item;
                                                                item["requestId"] = LuaValue::stringValue([requestId UTF8String]);
                                                                item["requestData"] = LuaValue::stringValue([requestData UTF8String]);
                                                                LuaBridge::pushLuaFunctionById(luaCallbackId);
                                                                LuaBridge::getStack()->pushLuaValueDict(item);
                                                                LuaBridge::getStack()->executeFunction(1);
                                                                LuaBridge::releaseLuaFunctionById(luaCallbackId);
                                                            }];
                                  }
                                  else
                                  {
                                      LuaBridge::releaseLuaFunctionById(luaCallbackId);
                                  }
                              }
                          }];
}

+ (void) deleteRequestId:(NSDictionary*)dict
{
    NSString * requestId = [dict objectForKey:@"requestId"];
    [FBRequestConnection startWithGraphPath:requestId
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSLog(@"Delete request id result %@", [result objectForKey:@"success"]);
                          }];
}

@end
