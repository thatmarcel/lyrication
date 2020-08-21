#import "ScrollingLyricsViewController.h"
#import "ScrollingLyricsViewControllerPresenter.h"

@implementation ScrollingLyricsViewControllerPresenter
    @synthesize overlayWindow;
    @synthesize overlayViewController;
    @synthesize notifyToken;

    - (instancetype) init {
        self = [super init];

        notify_register_dispatch("com.apple.springboard.hasBlankedScreen",
                                      &notifyToken,
                                      dispatch_get_main_queue(), ^(int t) {
                                          [self.overlayViewController dismissViewControllerAnimated: false completion: nil];
                                          self.overlayWindow.hidden = true;
                                          self.overlayWindow = nil;
                                          self.overlayViewController = nil;
                                      });

        return self;
    }

    - (void) present {
        ScrollingLyricsViewController *vc = [ScrollingLyricsViewController new];

        self.overlayViewController = [[UIViewController alloc] init];

        if ([[%c(SBLockStateAggregator) sharedInstance] lockState] > 1) { // Locked
            self.overlayWindow = [[%c(LXSecureWindow) alloc] initWithScreen: UIScreen.mainScreen debugName: @"Lyrication" rootViewController: self.overlayViewController];
        } else {
            self.overlayWindow = [[UIWindow alloc] init];
            self.overlayWindow.rootViewController = self.overlayViewController;
        }
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = true;
        self.overlayWindow.windowLevel = UIWindowLevelAlert;
        [self.overlayWindow makeKeyAndVisible];

        vc.presenter = self;

        [[self overlayViewController] presentViewController: vc animated: true completion: nil];

        return;
    }
@end
