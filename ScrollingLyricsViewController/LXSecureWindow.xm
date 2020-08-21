#import "LXSecureWindow.h"

%subclass LXSecureWindow: SBSecureWindow
    + (BOOL) _isSecure {
        return true;
    }
%end
