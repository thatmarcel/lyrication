#import <Cephei/HBPreferences.h>
#import "LXFloatingOverlayViewController.h"
#import "LXFloatingOverlaySecureWindow.h"

LXFloatingOverlaySecureWindow *overlayWindow;
LXFloatingOverlayViewController *overlayViewController;

%hook SpringBoard

    - (void) applicationDidFinishLaunching:(id)application {
        %orig;

        HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.lyrication.hbprefs"];
        [preferences registerDefaults:@{
            @"showlyricsoverlay": @false
        }];

        BOOL shouldShowLyricsOverlay = [preferences boolForKey: @"showlyricsoverlay"];

        if (!shouldShowLyricsOverlay) {
            return;
        }

        overlayViewController = [[LXFloatingOverlayViewController alloc] init];

        overlayWindow = [[%c(LXFloatingOverlaySecureWindow) alloc] initWithScreen: UIScreen.mainScreen debugName: @"LyricationOverlay" rootViewController: overlayViewController];

        overlayWindow.userInteractionEnabled = true;
        overlayWindow.backgroundColor = [UIColor clearColor];
	    overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        [overlayWindow makeKeyAndVisible];
    }

%end