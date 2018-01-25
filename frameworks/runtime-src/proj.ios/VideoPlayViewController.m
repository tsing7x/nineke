//
//  VideoPlayViewController.m
//  nineke
//
//  Created by Quinn Nie on 7/8/15.
//
//

#import "VideoPlayViewController.h"

@interface VideoPlayViewController ()
{
	MPMoviePlayerController * theMoviePlayer;
}

//@property (strong, nonatomic) MPMoviePlayerController * theMoviePlayer;

@end

@implementation VideoPlayViewController

-(void) setAppController:(id) ac
{
	appController = ac;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"view did load");
	// Do any additional setup after loading the view, typically from a nib.
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *moviePath = [bundle pathForResource:@"res/logo_1280_720_en" ofType :@"mp4"];
	if (!moviePath) {
		NSLog(@"video media file not found, please check resource file before play movie!");
		return;
	}
	theMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL fileURLWithPath:moviePath]];
	
	theMoviePlayer.fullscreen = YES;
	theMoviePlayer.controlStyle = MPMovieControlStyleNone;
	
	//[theMoviePlayer.view setFrame: self.view.bounds]; // frame会被transform
	// 2015.7.17 Friday 暂时采用此方法解决 在iPad mini上面视频显示不正确的问题。
	CGRect view_frame = self.view.frame;
	if (view_frame.size.width < view_frame.size.height) {
		CGFloat t = view_frame.size.height;
		view_frame.size.height = view_frame.size.width;
		view_frame.size.width = t;
	}
	//[theMoviePlayer.view setFrame: self.view.frame];
	[theMoviePlayer.view setFrame: view_frame]; // frame会被transform
	
	//MPMovieScalingModeFill 会拉伸
	//MPMovieScalingModeAspectFit] 全部显示，留黑边
	//MPMovieScalingModeNone]
	[theMoviePlayer setScalingMode: MPMovieScalingModeAspectFill]; // 最合适的效果，按照分辨率缩放，会截断一个方向上内容，画面不会变形
	
	[theMoviePlayer prepareToPlay];
	[theMoviePlayer play];
	
	[self.view addSubview:theMoviePlayer.view];
	
	[[NSNotificationCenter defaultCenter] addObserver:appController
											 selector:@selector(videoPlayDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:theMoviePlayer];
	
}

- (void) viewDidUnload {
	[super viewDidUnload];
	NSLog(@"view did unload");
}

- (void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	NSLog(@"View Did Appear....");
}

- (void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	NSLog(@"View will Disappear...");
}

// 此3个方法解决在iOS7/iPhone4上面的视频播放异常
- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
