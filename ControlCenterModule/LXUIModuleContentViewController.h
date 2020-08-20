#import <UIKit/UIViewController.h>
#import <ControlCenterUIKit/CCUIContentModuleContentViewController-Protocol.h>
#import <Cephei/HBPreferences.h>
#import "../NSDistributedNotificationCenter.h"

@interface LXUIModuleContentViewController : UIViewController <CCUIContentModuleContentViewController>

@property (nonatomic,readonly) CGFloat preferredExpandedContentHeight;
@property (nonatomic,readonly) CGFloat preferredExpandedContentWidth;
@property (nonatomic,readonly) BOOL providesOwnPlatter;

@property (nonatomic, readonly) BOOL small;

@property (nonatomic) UILabel *lineLabel;

- (instancetype) initWithSmallSize:(BOOL)small;

- (void) controlCenterWillPresent;

- (void) loadLabel;
- (void) setupReceiver;

@end
