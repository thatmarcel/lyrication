#import "ShowAction.h"

@implementation LyricationOverlayShowAction
	@synthesize overlayViewController;

	- (void) activator:(LAActivator*)activator receiveEvent:(LAEvent*)event forListenerName:(NSString*)listenerName{
		[overlayViewController userActivatedShow];
	}

	- (NSString*) activator:(LAActivator*)activator requiresLocalizedTitleForListenerName:(NSString*)listenerName {
		return @"Show Lyrication Floating Overlay";
	}

	- (NSString*) activator:(LAActivator*)activator requiresLocalizedDescriptionForListenerName:(NSString*)listenerName {
		return @"Shows the lyrics overlay";
	}

@end
