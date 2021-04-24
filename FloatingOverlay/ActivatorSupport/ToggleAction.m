#import "ToggleAction.h"

@implementation LyricationOverlayToggleAction
	@synthesize overlayViewController;

	- (void) activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{
		if (overlayViewController.userActivatedShouldHideOverlay) {
            [overlayViewController userActivatedShow];
        } else {
            [overlayViewController userActivatedHide];
        }
	}

	- (NSString *) activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
		return @"Toggle Lyrication Floating Overlay";
	}

	- (NSString *) activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
		return @"Toggles the lyrics overlay";
	}

@end
