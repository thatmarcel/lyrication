#include "libactivator/libactivator.h"
#import "../LXFloatingOverlayViewController.h"

@interface LyricationOverlayHideAction : NSObject <LAListener>
    @property (retain) LXFloatingOverlayViewController *overlayViewController;
@end