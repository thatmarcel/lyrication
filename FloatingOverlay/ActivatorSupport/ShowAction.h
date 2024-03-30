#include "libactivator/libactivator.h"
#import "../LXFloatingOverlayViewController.h"

@interface LyricationOverlayShowAction : NSObject <LAListener>
    @property (retain) LXFloatingOverlayViewController* overlayViewController;
@end