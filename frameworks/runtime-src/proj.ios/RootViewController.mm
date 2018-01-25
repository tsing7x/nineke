/****************************************************************************
 Copyright (c) 2010-2011 cocos2d-x.org
 Copyright (c) 2010      Ricardo Quesada

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#import "LuaOCBridge.h"
#import "cocos2d.h"

@implementation RootViewController

// GKLeaderboardViewControllerのDelegate
-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// GKAchievementViewControllerのDelegate
-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// For ios6.0 and higher, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations
{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskLandscape;
#endif
}

- (BOOL) shouldAutorotate {
    return YES;
}

//fix not hide status on ios7
- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

// 调出短信
- (void) showSMSView:(NSString*)content
{
    // 判断设备能不能发送短信
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController* picker = [[[MFMessageComposeViewController alloc] init] autorelease];
        // 设置委托
        picker.messageComposeDelegate = self;
        // 默认信息内容
        picker.body = content;
        // 调出视图
        [self presentModalViewController:picker animated:YES];
        
        [LuaOCBridge canSendSMS:YES];
    }
    else
    {
        [LuaOCBridge canSendSMS:NO];
    }
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
}

// 调出邮箱
- (void) showMAILView:(NSString*)subject content:(NSString*)content
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController* picker = [[[MFMailComposeViewController alloc] init] autorelease];
        // 设置委托
        picker.mailComposeDelegate = self;
        // 设置主题
        [picker setSubject:subject];
        // 设置内容
        [picker setMessageBody:content isHTML:NO];
        // 调出试图
        [self presentModalViewController:picker animated:YES];
        
        [LuaOCBridge canSendMAIL:YES];
    }
    else
    {
        [LuaOCBridge canSendMAIL:NO];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) viewDidAppear:(BOOL)animated{
	NSLog(@"View Did Appear....");
	cocos2d::Director::getInstance()->resume();
	cocos2d::Director::getInstance()->startAnimation();
}
- (void) viewWillDisappear:(BOOL)animated{
	NSLog(@"View will Disappear...");
	cocos2d::Director::getInstance()->pause();
	cocos2d::Director::getInstance()->stopAnimation();
}

@end
