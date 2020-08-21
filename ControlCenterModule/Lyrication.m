#import "Lyrication.h"
#import <ControlCenterUI/ControlCenterUI-Structs.h>
#import <objc/runtime.h>

@implementation Lyrication

    - (instancetype) init {
        if ((self = [super init])) {
            _contentViewController = [[LXUIModuleContentViewController alloc] initWithSmallSize:NO];
	    }
        return self;
    }

    - (CCUILayoutSize) moduleSizeForOrientation:(int)orientation {
        return (CCUILayoutSize){2, 4};
    }
@end
