#import <UIKit/UIKit.h>
#import "UIView+lxFillSuperview.h"
#import "../NSDistributedNotificationCenter.h"

@interface LXFloatingOverlayViewController: UIViewController
    @property (retain) UIView *overlayContainerView;
    @property (retain) UIVisualEffectView *overlayVisualEffectView;
    @property (retain) UILabel *overlayLyricLabel;

    @property (retain) NSLayoutConstraint *overlayTopConstraint;
    @property (retain) NSLayoutConstraint *overlayRightConstraint;

    - (void) viewDidLoad;
    - (void) setupReceivers;
    - (void) setupViews;

    - (void) overlayWasDragged:(UIPanGestureRecognizer *)recognizer;

    - (BOOL) _canShowWhileLocked;
@end