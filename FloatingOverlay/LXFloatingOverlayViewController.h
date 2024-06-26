#import <UIKit/UIKit.h>
#import "UIView+lxFillSuperview.h"
#import "../NSDistributedNotificationCenter.h"

@interface LXFloatingOverlayViewController: UIViewController
    @property (retain) UIView* overlayContainerView;
    @property (retain) UIVisualEffectView* overlayVisualEffectView;
    @property (retain) UILabel* overlayLyricLabel;

    @property (retain) NSLayoutConstraint* overlayTopConstraint;
    @property (retain) NSLayoutConstraint* overlayRightConstraint;

    @property CGFloat overlayTopConstraintConstantBeforeAlign;
    @property CGFloat overlayRightConstraintConstantBeforeAlign;

    // Controls if the user chose to hide the overlay via Activator action (does not apply to LastLook)
    @property BOOL userActivatedShouldHideOverlay;

    @property BOOL showingInLastLook;

    - (void) viewDidLoad;
    - (void) setupReceivers;
    - (void) setupViews;

    - (void) overlayWasDragged:(UIPanGestureRecognizer*)recognizer;

    - (BOOL) _canShowWhileLocked;

    - (void) hideBackground;
    - (void) showBackground;

    - (void) alignOverlay;
    - (void) revertOverlayAlign;
    - (void) alignOverlayAnimated;
    - (void) revertOverlayAlignAnimated;

    - (void) userActivatedHide;
    - (void) userActivatedShow;
@end