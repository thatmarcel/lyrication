#import <UIKit/UIKit.h>
#import <notify.h>
#import <spawn.h>
#import "LXSecureWindow.h"
#import "HWPanModal/HWPanModal.h"

@interface SBLockStateAggregator
    + (id) sharedInstance;
    - (unsigned long long) lockState;
@end

@interface LXScrollingLyricsViewControllerPresenter: NSObject

    @property (retain) UIWindow *overlayWindow;
    @property (retain) UIViewController *overlayViewController;

    @property int notifyToken;

    @property BOOL twitterAlertAllowed;

    - (void) present;
@end
