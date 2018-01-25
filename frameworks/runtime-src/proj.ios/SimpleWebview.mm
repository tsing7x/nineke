#import <UIKit/UIKit.h>

#import "SimpleWebview.h"

#import "CCLuaEngine.h"

@implementation WebView_iOS

- (void)onClickClose
{
	[self removeWebView];
	
	lua_State * L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
	lua_getglobal(L, "__G__TRACKBACK__");
	lua_rawgeti(L, LUA_REGISTRYINDEX, m_close);
	lua_pcall(L, 0, 0, 1);
}

- (void)showWebView_x:(float)x y:(float)y width:(float) width height:(float)height
{
	if (!m_webview)
	{
		UIWindow* window = [[UIApplication sharedApplication] keyWindow];
		if (!window) return;
		
		float scale = [[UIScreen mainScreen] scale];
		x /= scale; y /= scale; width /= scale; height /= scale;
		
		m_webview = [[UIWebView alloc] initWithFrame:CGRectMake(x, y, width , height)];
		[m_webview setDelegate:self];
		
		float bx, by, bw, bh;
		bx = width - 32;
		by = 0;
		bw = 32;
		bh = 32;
		m_closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[m_closeBtn setFrame:CGRectMake(bx, by, bw, bh)];
		[m_closeBtn setTitle:@"X" forState:UIControlStateNormal];
		[m_closeBtn addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
		[m_webview addSubview:m_closeBtn];
		
		
		if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
		{
			[window addSubview:m_webview];
		}
		else
		{
			// use this method on ios6
			[window.rootViewController.view addSubview:m_webview];
		}
		[m_webview release];
		
		m_webview.backgroundColor = [UIColor whiteColor];
		m_webview.opaque = YES;
		
		for (UIView *aView in [m_webview subviews])
		{
			if ([aView isKindOfClass:[UIScrollView class]])
			{
				UIScrollView* scView = (UIScrollView *)aView;
				
				// 是否显示右侧的滚动条 （水平的类似）
				// [(UIScrollView *)aView setShowsVerticalScrollIndicator:NO];
				[scView setShowsHorizontalScrollIndicator:NO];
				// scView.bounces = NO;
				
				for (UIView *shadowView in aView.subviews)
				{
					if ([shadowView isKindOfClass:[UIImageView class]])
					{
						// 隐藏上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
						// hide black background when webpage is out of border.
						shadowView.hidden = YES;
					}
				}
			}
		}
	}
}

- (void)updateURL:(const char*)url
{
	NSURL * nsUrl = [NSURL URLWithString:[NSString stringWithUTF8String:url]];
	[m_webview loadRequest:[NSURLRequest requestWithURL:nsUrl
											cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										timeoutInterval:60]];
}

- (void)removeWebView
{
	if (m_webview)
	{
		[m_webview removeFromSuperview];
		m_webview = NULL;
	}
}

- (void)setCloseBtnVisible:(bool) visible
{
	if (m_closeBtn) {
		m_closeBtn.hidden = (visible == true)?NO:YES;
	}
}

- (void)setBackgroundColor_r:(float)r g:(float)g b:(float)b a:(float)a
{
	if (r < 0 || r > 1) return;
	if (g < 0 || g > 1) return;
	if (b < 0 || b > 1) return;
	if (a < 0 || a > 1) return;
	if(m_webview)
	{
		if(r == 0 && g == 0 && b == 0 && a == 0)
		{
			m_webview.opaque = NO;
		}
		else
		{
			m_webview.opaque = YES;
		}
		
		UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
		[m_webview setBackgroundColor:color];
	}
	
}

- (void)setLuaCallback_start:(int) start finish:(int)finish fail:(int)fail close:(int)close shouldStartLoad:(int)shouldStartLoad
{
	m_start_load  = start;
	m_finish_load = finish;
	m_fail_load   = fail;
	m_close		  = close;
	m_should_start_load = shouldStartLoad;
}

- (void)getLuaCallback_start:(int*) start finish:(int*)finish fail:(int*)fail close:(int*)close shouldStartLoad:(int*)shouldStartLoad
{
	*start = m_start_load;
	*finish = m_finish_load;
	*fail = m_fail_load;
	*close = m_close;
	*shouldStartLoad = m_should_start_load;
}

#pragma mark - WebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL* url = request.URL;
	NSString* urlStr = [url absoluteString];
	
	lua_State * L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
	lua_getglobal(L, "__G__TRACKBACK__");
	lua_rawgeti(L, LUA_REGISTRYINDEX, m_should_start_load);
	const char * urlStr_info = [ urlStr UTF8String];
	lua_pushstring(L, urlStr_info);
	lua_pcall(L, 1, 1, -3);
	const bool isContinue = lua_toboolean(L, -1);
	lua_settop(L, 0);
	
	return isContinue;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	lua_State * L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
	lua_getglobal(L, "__G__TRACKBACK__");
	lua_rawgeti(L, LUA_REGISTRYINDEX, m_start_load);
	lua_pcall(L, 0, 0, -2);
	lua_settop(L, 0);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	lua_State * L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
	lua_getglobal(L, "__G__TRACKBACK__");
	lua_rawgeti(L, LUA_REGISTRYINDEX, m_finish_load);
	lua_pcall(L, 0, 0, -2);
	lua_settop(L, 0);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	lua_State * L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
	lua_getglobal(L, "__G__TRACKBACK__");
	lua_rawgeti(L, LUA_REGISTRYINDEX, m_fail_load);
	const char * error_info = [[error localizedDescription] UTF8String];
	lua_pushstring(L, error_info);
	lua_pcall(L, 1, 0, -3);
	lua_settop(L, 0);
}

@end
