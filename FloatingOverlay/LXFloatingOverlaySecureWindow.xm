#import "LXFloatingOverlaySecureWindow.h"

%subclass LXFloatingOverlaySecureWindow: SBSecureWindow
    - (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
	    UIView *viewAtPoint = [self.rootViewController.view hitTest: point withEvent: event];
	    return !(!viewAtPoint || (viewAtPoint.alpha != 0 && viewAtPoint == self.rootViewController.view));
    }

    + (BOOL) _isSecure {
        return true;
    }
%end