#import "Lyrication.h"
#import "ControlCenterUI-Structs.h"
#import <objc/runtime.h>

@implementation Lyrication
    - (instancetype) init {
        if ((self = [super init])) {
            _contentViewController = [[LXUIModuleContentViewController alloc] initWithSmallSize: false];
	    }
        return self;
    }

    - (CCUILayoutSize) moduleSizeForOrientation:(int)orientation {
        return (CCUILayoutSize) { 2, 4 };
    }
@end
