#include "libactivator/libactivator.h"
#import "../LXFloatingOverlayViewController.h"

@interface LyricationOverlayToggleAction : NSObject <LAListener>
    @property (retain) LXFloatingOverlayViewController *overlayViewController;
@end