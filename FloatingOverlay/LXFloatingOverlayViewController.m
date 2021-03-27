#import "LXFloatingOverlayViewController.h"

@implementation LXFloatingOverlayViewController
    @synthesize overlayContainerView;
    @synthesize overlayVisualEffectView;
    @synthesize overlayLyricLabel;
    @synthesize overlayTopConstraint;
    @synthesize overlayRightConstraint;
    @synthesize overlayTopConstraintConstantBeforeAlign;
    @synthesize overlayRightConstraintConstantBeforeAlign;

    - (void) viewDidLoad {
        [self setupViews];
        [self setupReceivers];
    }

    - (void) setupReceivers {
        [[NSDistributedNotificationCenter defaultCenter] addObserverForName: @"com.thatmarcel.tweaks.lyrication/updateLine"
            object: nil
            queue: [NSOperationQueue mainQueue]
            usingBlock: ^(NSNotification *notification)
        {
            NSString *line = [notification.userInfo objectForKey: @"line"];

            if ([@"Paused" isEqual: line] || [@"No lyrics available" isEqual: line]) {
                self.overlayContainerView.hidden = true;
                return;
            } else {
                self.overlayContainerView.hidden = false;
            }

            [self.overlayLyricLabel setText: line];
        }];

        [[NSDistributedNotificationCenter defaultCenter] addObserverForName: @"com.thatmarcel.tweaks.lyrication/expandEvents"
            object: nil
            queue: [NSOperationQueue mainQueue]
            usingBlock: ^(NSNotification *notification)
        {
            NSString *event = [notification.userInfo objectForKey: @"event"];

            if ([@"viewWillAppear" isEqual: event]) {
                [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.overlayContainerView.alpha = 0;
                    }
                    completion:^(BOOL finished){ }];
            } else if ([@"viewDidDisappear" isEqual: event]) {
                [UIView animateWithDuration: 0.4 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.overlayContainerView.alpha = 1;
                    }
                    completion:^(BOOL finished){ }];
            }
        }];
    }

    - (void) setupViews {
        self.overlayContainerView = [[UIView alloc] init];
        self.overlayContainerView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview: self.overlayContainerView];
        self.overlayTopConstraint = [self.overlayContainerView.topAnchor constraintEqualToAnchor: self.view.topAnchor constant: 56];
        self.overlayTopConstraint.active = true;
        overlayRightConstraint = [self.overlayContainerView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -32];
        self.overlayRightConstraint.active = true;
        [self.overlayContainerView.heightAnchor constraintGreaterThanOrEqualToConstant: 90].active = true;
        [self.overlayContainerView.widthAnchor constraintEqualToConstant: 270].active = true;
        self.overlayContainerView.layer.masksToBounds = true;
        self.overlayContainerView.layer.cornerRadius = 16;

        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(overlayWasDragged:)];
        [self.overlayContainerView addGestureRecognizer: panRecognizer];


        UIVisualEffect *effect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleSystemChromeMaterial];
        self.overlayVisualEffectView = [[UIVisualEffectView alloc] initWithEffect: effect];
        self.overlayVisualEffectView.translatesAutoresizingMaskIntoConstraints = false;
        [self.overlayContainerView addSubview: self.overlayVisualEffectView];
        [self.overlayContainerView addSubview: self.overlayVisualEffectView];
        [self.overlayVisualEffectView lxFillSuperview];

        self.overlayLyricLabel = [[UILabel alloc] init];
        self.overlayLyricLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.overlayContainerView addSubview: self.overlayLyricLabel];
        [self.overlayLyricLabel.topAnchor constraintEqualToAnchor: self.overlayContainerView.topAnchor constant: 16].active = true;
        [self.overlayLyricLabel.bottomAnchor constraintEqualToAnchor: self.overlayContainerView.bottomAnchor constant: -16].active = true;
        [self.overlayLyricLabel.leftAnchor constraintEqualToAnchor: self.overlayContainerView.leftAnchor constant: 24].active = true;
        [self.overlayLyricLabel.rightAnchor constraintEqualToAnchor: self.overlayContainerView.rightAnchor constant: -24].active = true;
        self.overlayLyricLabel.numberOfLines = 0;
        self.overlayLyricLabel.textAlignment = NSTextAlignmentCenter;
        [self.overlayLyricLabel setFont: [UIFont systemFontOfSize: 18 weight: UIFontWeightBold]];

        if (@available(iOS 13, *)) {
            self.overlayLyricLabel.textColor = [UIColor labelColor];
        } else {
            self.overlayLyricLabel.textColor = [UIColor blackColor];
        }
    }

    - (void) overlayWasDragged:(UIPanGestureRecognizer *)recognizer {
        UIView *draggedView = recognizer.view;
        CGPoint translation = [recognizer translationInView: draggedView];

        overlayTopConstraint.constant += translation.y;
        overlayRightConstraint.constant += translation.x;
        
        [recognizer setTranslation: CGPointZero inView: draggedView];
    }

    - (BOOL) _canShowWhileLocked {
        return true;
    }

    - (void) hideBackground {
        [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.overlayVisualEffectView.alpha = 0;
            }
            completion:^(BOOL finished){ }];
    }

    - (void) showBackground {
        [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.overlayVisualEffectView.alpha = 1;
            }
            completion:^(BOOL finished){ }];
    }

    - (void) alignOverlay {
        self.overlayTopConstraintConstantBeforeAlign = overlayTopConstraint.constant;
        self.overlayRightConstraintConstantBeforeAlign = overlayRightConstraint.constant;
        
        overlayTopConstraint.constant = [[UIScreen mainScreen] bounds].size.height - 150;
        overlayRightConstraint.constant = -([[UIScreen mainScreen] bounds].size.width / 2 - (270 / 2));
    }

    - (void) revertOverlayAlign {
        overlayTopConstraint.constant = self.overlayTopConstraintConstantBeforeAlign;
        overlayRightConstraint.constant = self.overlayRightConstraintConstantBeforeAlign;
    }

    - (void) alignOverlayAnimated {
        [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.overlayLyricLabel.alpha = 0;
            }
            completion:^(BOOL finished){
                [self alignOverlay];

                [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.overlayLyricLabel.alpha = 1;
                    }
                    completion:^(BOOL finished){ }];
            }];
    }

    - (void) revertOverlayAlignAnimated {
        [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.overlayLyricLabel.alpha = 0;
            }
            completion:^(BOOL finished){
                [self revertOverlayAlign];

                [UIView animateWithDuration: 0.2 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.overlayLyricLabel.alpha = 1;
                    }
                    completion:^(BOOL finished){ }];
            }];
    }

@end