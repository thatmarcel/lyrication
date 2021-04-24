#import "HideAction.h"

@implementation LyricationOverlayHideAction
	@synthesize overlayViewController;

	- (void) activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{
		[overlayViewController userActivatedHide];
	}

	- (NSString *) activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
		return @"Hide Lyrication Floating Overlay";
	}

	- (NSString *) activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
		return @"Hides the lyrics overlay";
	}

@end
