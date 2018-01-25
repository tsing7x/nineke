@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    @public RootViewController *viewController;
}


@end

