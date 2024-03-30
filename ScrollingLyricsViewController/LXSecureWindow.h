#import <UIKit/UIKit.h>

@interface SBSecureWindow: UIWindow
    - (id) initWithScreen:(id)arg1 debugName:(id)arg2 rootViewController:(id)arg3;
    
    - (instancetype) initWithWindowScene:(id)arg1 rootViewController:(id)arg2 role:(id)arg3 debugName:(id)arg4;
@end

@interface LXSecureWindow: SBSecureWindow
@end
