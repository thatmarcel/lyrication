#import <UIKit/UIKit.h>

@interface SBSecureWindow: UIWindow
    - (instancetype) initWithScreen:(UIScreen*)screen debugName:(NSString*)debugName rootViewController:(UIViewController*)rootViewController;
    
    - (instancetype) initWithWindowScene:(id)arg1 rootViewController:(id)arg2 role:(id)arg3 debugName:(id)arg4;
@end

@interface LXFloatingOverlaySecureWindow: SBSecureWindow
@end