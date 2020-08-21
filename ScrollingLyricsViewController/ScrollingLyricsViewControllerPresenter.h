#import <UIKit/UIKit.h>
#import <notify.h>
#import "LXSecureWindow.h"

@interface SBLockStateAggregator
    + (id) sharedInstance;
    - (unsigned long long) lockState;
@end

@interface ScrollingLyricsViewControllerPresenter: NSObject

    @property (retain) UIWindow *overlayWindow;
    @property (retain) UIViewController *overlayViewController;

    @property int notifyToken;

    - (void) present;
@end
