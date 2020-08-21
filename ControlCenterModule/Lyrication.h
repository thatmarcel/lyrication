#import <ControlCenterUIKit/CCUIContentModule-Protocol.h>
#import "LXUIModuleContentViewController.h"

@interface Lyrication : NSObject <CCUIContentModule>
// This is what controls the view for the default UIElements that will appear before the module is expanded
@property (nonatomic, readonly) LXUIModuleContentViewController* contentViewController;
// This is what will control how the module changes when it is expanded
@property (nonatomic, readonly) UIViewController* backgroundViewController;
@end
