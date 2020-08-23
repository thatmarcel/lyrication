#import "LXScrollingLyricsViewController.h"
#import "LXScrollingLyricsViewControllerPresenter.h"

@implementation LXScrollingLyricsViewControllerPresenter
    @synthesize overlayWindow;
    @synthesize overlayViewController;
    @synthesize notifyToken;
    @synthesize twitterAlertAllowed;

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
        BOOL shouldShowAlert = [[%c(SBLockStateAggregator) sharedInstance] lockState] <= 1 && self.twitterAlertAllowed && ![[NSUserDefaults standardUserDefaults] boolForKey: @"com.thatmarcel.tweaks.lyrication.defaultprefs.showntwtalertonce"];

        LXScrollingLyricsViewController *vc = [LXScrollingLyricsViewController new];

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

        if (shouldShowAlert) {
            [[NSUserDefaults standardUserDefaults] setBool: true forKey:@"com.thatmarcel.tweaks.lyrication.defaultprefs.showntwtalertonce"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle: @"Twitter?"
                                 message: @"Heyy, this message is from Marcel, the developer of this tweak. If you wouldn't mind following on Twitter, I'd really appreciate it. If not, that's absolutely fine too. No matter what you choose, this message will never show again."
                                 preferredStyle: UIAlertControllerStyleAlert];

            [alert addAction: [UIAlertAction
                                actionWithTitle: @"Rather not"
                                style: UIAlertActionStyleDefault
                                handler: ^(UIAlertAction * action) {
                                [alert dismissViewControllerAnimated: false completion: ^{
                                        [[self overlayViewController] presentViewController: vc animated: true completion: nil];
                                    }];
                                }]];

            [alert addAction: [UIAlertAction
                                actionWithTitle: @"Sure"
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
@end
