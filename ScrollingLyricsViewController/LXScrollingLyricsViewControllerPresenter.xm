#import "./LXScrollingLyricsViewController.h"
#import "./LXScrollingLyricsViewControllerPresenter.h"

@implementation LXScrollingLyricsViewControllerPresenter
    @synthesize overlayWindow;
    @synthesize overlayViewController;
    @synthesize notifyToken;
    @synthesize twitterAlertAllowed;
    @synthesize necessaryProgressDelay;

    - (instancetype) init {
        self = [super init];

        notify_register_dispatch(
            "com.apple.springboard.hasBlankedScreen",
            &notifyToken,
            dispatch_get_main_queue(), ^(int t) {
                if (!self.overlayViewController || !self.overlayWindow) {
                    return;
                }
                
                [self.overlayViewController dismissViewControllerAnimated: false completion: nil];
                self.overlayWindow.hidden = true;
                self.overlayWindow = nil;
                self.overlayViewController = nil;
            }
        );

        return self;
    }

    - (void) present {
        NSLog(@"Lyrication presenting");
        BOOL shouldShowAlert = [[%c(SBLockStateAggregator) sharedInstance] lockState] <= 1 && self.twitterAlertAllowed && ![[NSUserDefaults standardUserDefaults] boolForKey: @"com.thatmarcel.tweaks.lyrication.defaultprefs.showntwtalertonceV2"];

        LXScrollingLyricsViewController *vc = [LXScrollingLyricsViewController new];

        vc.necessaryProgressDelay = self.necessaryProgressDelay;

        self.overlayViewController = [[UIViewController alloc] init];

        if ([[%c(SBLockStateAggregator) sharedInstance] lockState] > 1) { // Locked
            if (@available(iOS 16, *)) {
                for (UIScene *scene in [[UIApplication sharedApplication] connectedScenes]) {
                    if ([scene isKindOfClass: [UIWindowScene class]]) {
                        self.overlayWindow = [[%c(LXSecureWindow) alloc] initWithWindowScene: scene rootViewController: self.overlayViewController role: 0 debugName: @"Lyrication"];
                    }
                }
                
                if (!self.overlayWindow) {
                    return;
                }
            } else {
                self.overlayWindow = [[%c(LXSecureWindow) alloc] initWithScreen: UIScreen.mainScreen debugName: @"Lyrication" rootViewController: self.overlayViewController];
            }
        } else if (@available(iOS 13, *)) {
            for (UIScene *scene in [[UIApplication sharedApplication] connectedScenes]) {
                if ([scene isKindOfClass: [UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene*) scene;
                    self.overlayWindow = [[UIWindow alloc] initWithWindowScene: windowScene];
                    self.overlayWindow.rootViewController = self.overlayViewController;
                    break;
                }
            }
        } else {
            self.overlayWindow = [[UIWindow alloc] init];
            self.overlayWindow.rootViewController = self.overlayViewController;
        }
        self.overlayWindow.backgroundColor = [UIColor clearColor];
        self.overlayWindow.userInteractionEnabled = true;
        self.overlayWindow.windowLevel = UIWindowLevelAlert;
        [self.overlayWindow makeKeyAndVisible];

        vc.presenter = self;

        if (shouldShowAlert) {
            [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"com.thatmarcel.tweaks.lyrication.defaultprefs.showntwtalertonceV2"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle: @"Receive the newest tweak updates & more"
                                 message: @"Lyrication is (and will always stay) free. Maintaining the tweak and the required servers is a lot of work, so I'd really appreciate if you could check out my Twitter (@thatmarcelbraun) to get the newest updates :)"
                                 preferredStyle: UIAlertControllerStyleAlert];

            [alert addAction: [UIAlertAction
                                actionWithTitle: @"Rather not"
                                style: UIAlertActionStyleDestructive
                                handler: ^(UIAlertAction * action) {
                                    [alert dismissViewControllerAnimated: false completion: ^{
                                    [[self overlayViewController] presentViewController: vc animated: true completion: nil];
                                }];
            }]];

            [alert addAction: [UIAlertAction
                                actionWithTitle: @"Take a look at my twitter"
                                style: UIAlertActionStyleDefault
                                handler: ^(UIAlertAction * action) {
                                    [self.overlayViewController dismissViewControllerAnimated: false completion: nil];
                                    self.overlayWindow.hidden = true;
                                    self.overlayWindow = nil;
                                    self.overlayViewController = nil;
                                    pid_t pid;
	                                const char *args[] = {"uiopen", "twitter://user?screen_name=thatmarcelbraun", NULL};
	                                posix_spawn(&pid, "/usr/bin/uiopen", NULL, NULL, (char *const *)args, NULL);
                                }]];

            [[self overlayViewController] presentViewController: alert animated: true completion: nil];

            return;
        }

        [[self overlayViewController] presentViewController: vc animated: true completion: nil];

        return;
    }

    - (BOOL) isPresenting {
        return self.overlayViewController != nil;
    }
@end
