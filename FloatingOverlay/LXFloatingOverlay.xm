#import <Cephei/HBPreferences.h>
#import "LXFloatingOverlayViewController.h"
#import "LXFloatingOverlaySecureWindow.h"
#import "ActivatorSupport/ToggleAction.h"
#import "ActivatorSupport/ShowAction.h"
#import "ActivatorSupport/HideAction.h"

LXFloatingOverlaySecureWindow *overlayWindow;
LXFloatingOverlayViewController *overlayViewController;

LyricationOverlayToggleAction *toggleAction;
LyricationOverlayShowAction *showAction;
LyricationOverlayHideAction *hideAction;

BOOL showOverlayInLL = true;
BOOL hideOverlayOutsideLL = false;
BOOL autoPositionOverlayInLL = true;

@interface LastLookManager: NSObject
    - (BOOL) isActive;

    + (instancetype) sharedInstance;
@end

@interface NSObject (WG)
    - (id) safeValueForKey:(id)arg1;
@end

%hook SpringBoard

    - (void) applicationDidFinishLaunching:(id)application {
        %orig;

        HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.lyrication.hbprefs"];
        [preferences registerDefaults:@{
            @"showlyricsoverlay": @false
        }];
        BOOL shouldShowLyricsOverlay = [preferences boolForKey: @"showlyricsoverlay"];

        LastLookManager *lastLookManager = [%c(LastLookManager) sharedInstance];

        BOOL lastLookLyricationEnabled = lastLookManager && [[lastLookManager safeValueForKey: @"lyricationTweakStayOnEnabled"] boolValue];

        if (!shouldShowLyricsOverlay && !lastLookLyricationEnabled) {
            return;
        }

        showOverlayInLL = lastLookLyricationEnabled;
        hideOverlayOutsideLL = !shouldShowLyricsOverlay && lastLookLyricationEnabled;

        overlayViewController = [[LXFloatingOverlayViewController alloc] init];
        
        if (@available(iOS 16, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    overlayWindow = [[%c(LXFloatingOverlaySecureWindow) alloc] initWithWindowScene: scene rootViewController: overlayViewController role: 0 debugName: @"LyricationOverlay"];
                }
            }
            
            if (!overlayWindow) {
                return;
            }
        } else {
            overlayWindow = [[%c(LXFloatingOverlaySecureWindow) alloc] initWithScreen: UIScreen.mainScreen debugName: @"LyricationOverlay" rootViewController: overlayViewController];
        }

        if (hideOverlayOutsideLL) {
            overlayViewController.view.hidden = true;
            overlayViewController.overlayLyricLabel.textColor = [UIColor whiteColor];
            overlayViewController.overlayVisualEffectView.alpha = 0;
        }
        
        overlayWindow.userInteractionEnabled = true;
        overlayWindow.backgroundColor = [UIColor clearColor];
	    overlayWindow.windowLevel = UIWindowLevelAlert + 1;
        [overlayWindow makeKeyAndVisible];

        if (NSClassFromString(@"LAActivator")) {
            toggleAction = [[LyricationOverlayToggleAction alloc] init];
            showAction = [[LyricationOverlayShowAction alloc] init];
            hideAction = [[LyricationOverlayHideAction alloc] init];

            toggleAction.overlayViewController = overlayViewController;
            showAction.overlayViewController = overlayViewController;
            hideAction.overlayViewController = overlayViewController;

            [[%c(LAActivator) sharedInstance] registerListener: toggleAction forName: @"ToggleLyricationFloatingOverlay"];
            [[%c(LAActivator) sharedInstance] registerListener: showAction forName: @"ShowLyricationFloatingOverlay"];
            [[%c(LAActivator) sharedInstance] registerListener: hideAction forName: @"HideLyricationFloatingOverlay"];
        }
    }

%end

// LastLook

%hook LastLookManager
    - (void) setIsActive:(BOOL)active {
       %orig;

        if (!overlayViewController) {
           return;
        }

        overlayViewController.showingInLastLook = active && showOverlayInLL;

        if (active) {
            if (showOverlayInLL) {
                overlayViewController.overlayLyricLabel.textColor = [UIColor whiteColor];

                [overlayViewController hideBackground];

                // Fix alignment animation by setting the start alpha to 0
                if (hideOverlayOutsideLL && autoPositionOverlayInLL) {
                    overlayViewController.overlayLyricLabel.alpha = 0;
                }

                if (autoPositionOverlayInLL) {
                    [overlayViewController alignOverlayAnimated];
                }

                overlayViewController.view.hidden = false;
            } else {
                overlayViewController.view.hidden = true;
            }
        } else {
            if (hideOverlayOutsideLL) {
                overlayViewController.view.hidden = true;
            } else {
                if (@available(iOS 13, *)) {
                    overlayViewController.overlayLyricLabel.textColor = [UIColor labelColor];
                } else {
                    overlayViewController.overlayLyricLabel.textColor = [UIColor blackColor];
                }

                [overlayViewController showBackground];

                if (autoPositionOverlayInLL) {
                    [overlayViewController revertOverlayAlignAnimated];
                }

                overlayViewController.view.hidden = overlayViewController.userActivatedShouldHideOverlay;
            }
        }
    }
%end