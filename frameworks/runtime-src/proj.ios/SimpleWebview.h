//  Created by Quinn Nie on 4/21/15.

#import <Foundation/Foundation.h>


@interface WebView_iOS : NSObject <UIWebViewDelegate>
{
	UIWebView * m_webview;
    UIButton * m_closeBtn;
	int m_start_load;
	int m_finish_load;
	int m_fail_load;
	int m_close;
	int m_should_start_load;
}

- (void)setLuaCallback_start:(int) start finish:(int)finish fail:(int)fail close: (int)close shouldStartLoad:(int)shouldStartLoad;
- (void)getLuaCallback_start:(int*) start finish:(int*)finish fail:(int*)fail close:(int*) close shouldStartLoad:(int*)shouldStartLoad;
- (void)showWebView_x:(float)x y:(float)y width:(float) widht height:(float)height;
- (void)updateURL:(const char*)url;
- (void)removeWebView;
- (void)onClickClose;
- (void)setCloseBtnVisible:(bool) visible;
- (void)setBackgroundColor_r:(float)r g:(float)g b:(float)b a:(float)a;

@end