#import <UIKit/UIKit.h>

@interface SBSecureWindow: UIWindow
    - (id) initWithScreen:(id)arg1 debugName:(id)arg2 rootViewController:(id)arg3;
@end

@interface LXFloatingOverlaySecureWindow: SBSecureWindow
    - (id) initWithScreen:(id)arg1 debugName:(id)arg2 rootViewController:(id)arg3;
@end