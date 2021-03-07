#import "../ScrollingLyricsViewController/LXScrollingLyricsViewControllerPresenter.h"
#import <Cephei/HBPreferences.h>

@interface SBCoverSheetPrimarySlidingViewController: UIViewController
@end

@interface MediaControlsVolumeContainerView: UIView
    @property (retain) UIViewController* _viewDelegate;
@end

@interface MRUNowPlayingVolumeControlsView: UIView
    @property (retain) UIViewController* _viewDelegate;
@end

UIButton *lyricsButton;
LXScrollingLyricsViewControllerPresenter *presenter;
UIViewController *lockscreenViewController;

HBPreferences *preferences;
%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.lyrication.hbprefs"];
    [preferences registerDefaults:@{
        @"showonlockscreen": @true,
        @"showinsidespotify": @true,
        @"showexpandbuttoninspotify": @true,
        @"expandedviewlineblurenabled": @true
    }];
}

// Disable screen locking on lock screen
// SBIdleTimerProxy

/* %hook SBDashBoardIdleTimerProvider
    - (BOOL) isIdleTimerEnabled {
        BOOL shouldDisableTimer = [preferences boolForKey: @"showonlockscreen"] && presenter && [presenter isPresenting];
        return shouldDisableTimer ? false : %orig;    
    }

    * - (void) idleTimerDidExpire:(id)timer {
        return;
        BOOL shouldIgnoreTimer = [preferences boolForKey: @"showonlockscreen"] && presenter && [presenter isPresenting];
        
        if (shouldIgnoreTimer) {
            return;
        }
        
        %orig;
    } *
%end */

%hook SBIdleTimerService
    - (BOOL) handleIdleTimerDidExpire {
        BOOL shouldIgnoreIdleTimer = presenter && [presenter isPresenting];
        
        if (shouldIgnoreIdleTimer) {
            return true;
        }

        return %orig;
    }
%end

// Juin

UILongPressGestureRecognizer *juinPlayPauseButtonLongPressGestureRecognizer;

@interface CSCoverSheetView: UIView
    - (void) lxJuinPlayPauseButtonLongPressRecognized:(UIGestureRecognizer*)sender;
@end

@interface UIControlTargetAction: NSObject
@end

%hook CSCoverSheetView

    - (void) didMoveToWindow {
        %orig;

        UIView *juinView;
        for (UIView *subview in [self subviews]) {
            int marqueeLabelsCount = 0;
            for (UIView *subviewSubview in [subview subviews]) {
                if ([subviewSubview isKindOfClass: %c(MarqueeLabel)]) {
                    marqueeLabelsCount += 1;
                }
            }

            if (marqueeLabelsCount == 2) {
                juinView = subview;
            }
        }

        if (!juinView || juinPlayPauseButtonLongPressGestureRecognizer) {
            return;
        }

        if (!presenter) {
            presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
            presenter.twitterAlertAllowed = true;
        }

        for (UIView *subview in [juinView subviews]) {
            if (![subview isKindOfClass: [UIButton class]]) {
                continue;
            }

            UIButton *button = (UIButton*) subview;
            NSMutableArray *targetActions = MSHookIvar<NSMutableArray*>(button, "_targetActions");

            if (!targetActions) {
                continue;
            }

            for (UIControlTargetAction *action in targetActions) {
                SEL selector = MSHookIvar<SEL>(action, "_action");
                if (selector && [NSStringFromSelector(selector) isEqual: @"pausePlaySong"]) {
                    juinPlayPauseButtonLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
                    [juinPlayPauseButtonLongPressGestureRecognizer addTarget: self action: @selector(lxJuinPlayPauseButtonLongPressRecognized:)];
                    juinPlayPauseButtonLongPressGestureRecognizer.minimumPressDuration = 0.5;
                    [button addGestureRecognizer: juinPlayPauseButtonLongPressGestureRecognizer];
                }
            }
        }
    }

    %new
    - (void) lxJuinPlayPauseButtonLongPressRecognized:(UIGestureRecognizer*)sender {
        if (sender.state != UIGestureRecognizerStateBegan) {
            return;
        }

        [presenter present];
    }

%end

// Flow

@interface MMScrollView: UIView
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender;
@end

UILongPressGestureRecognizer *flowLongPressGestureRecognizer;

%hook MMScrollView
    - (void) updateArtworks {
        %orig;

        if (flowLongPressGestureRecognizer) {
            return;
        }

        self.userInteractionEnabled = true;

        if (!presenter) {
            presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
            presenter.twitterAlertAllowed = true;
        }

        flowLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [flowLongPressGestureRecognizer addTarget: self action: @selector(lxLongPressRecognized:)];
        flowLongPressGestureRecognizer.minimumPressDuration = 0.5;
        [self addGestureRecognizer: flowLongPressGestureRecognizer];
    }

    %new
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender {
        if (sender.state != UIGestureRecognizerStateBegan) {
            return;
        }

        [presenter present];
    }
%end

// MRUArtworkView
// MPUArtworkView

@interface MPUArtworkView: UIView
    @property (retain) UILongPressGestureRecognizer *artworkLongPressGestureRecognizer;

    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender;
@end

@interface MRUArtworkView: UIView
    @property (retain) UILongPressGestureRecognizer *artworkLongPressGestureRecognizer;
    
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender;
@end

%hook MRUArtworkView
    %property (retain) UILongPressGestureRecognizer *artworkLongPressGestureRecognizer;

    - (id) initWithFrame:(CGRect)frame {
        self = %orig;

        if (self.artworkLongPressGestureRecognizer) {
            return self;
        }

        self.userInteractionEnabled = true;

        if (!presenter) {
            presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
            presenter.twitterAlertAllowed = true;
        }

        self.artworkLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [self.artworkLongPressGestureRecognizer addTarget: self action: @selector(lxLongPressRecognized:)];
        self.artworkLongPressGestureRecognizer.minimumPressDuration = 0.5;
        [self addGestureRecognizer: self.artworkLongPressGestureRecognizer];

        return self;
    }

    %new
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender {
        if (sender.state != UIGestureRecognizerStateBegan) {
            return;
        }

        [presenter present];
    }

    - (void) setUserInteractionEnabled:(BOOL)enabled {
        %orig(true);
    }

%end

%hook MPUArtworkView
    %property (retain) UILongPressGestureRecognizer *artworkLongPressGestureRecognizer;

    - (id) initWithFrame:(CGRect)frame {
        self = %orig;

        if (self.artworkLongPressGestureRecognizer) {
            return self;
        }

        self.userInteractionEnabled = true;

        if (!presenter) {
            presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
            presenter.twitterAlertAllowed = true;
        }

        self.artworkLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [self.artworkLongPressGestureRecognizer addTarget: self action: @selector(lxLongPressRecognized:)];
        self.artworkLongPressGestureRecognizer.minimumPressDuration = 0.5;
        [self addGestureRecognizer: self.artworkLongPressGestureRecognizer];

        return self;
    }

    %new
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender {
        if (sender.state != UIGestureRecognizerStateBegan) {
            return;
        }

        [presenter present];
    }

    - (void) setUserInteractionEnabled:(BOOL)enabled {
        %orig(true);
    }

%end

// iOS 14

%hook MRUNowPlayingVolumeControlsView

%new
- (void) lxColorizeUI:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    UIColor *primaryColor = userInfo[@"PrimaryColor"];

    if (lyricsButton) {
        [lyricsButton setTitleColor: primaryColor forState: UIControlStateNormal];
    }
}

%new
- (void) lxRevertUI:(NSNotification *)notification {
    if (lyricsButton) {
        [lyricsButton setTitleColor: [UIColor labelColor] forState: UIControlStateNormal];
    }
}

- (id) initWithFrame:(CGRect)frame {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview.superview || ![self.superview.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        self = %orig;
        return self;
    }
    self = %orig(CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 70 - 32, frame.size.height));

    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(lxRevertUI:)
                                            name:@"ColorFlowLockScreenColorReversionNotification"
                                            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(lxColorizeUI:)
                                            name:@"ColorFlowLockScreenColorizationNotification"
                                            object:nil];

    return self;
}

- (void) setFrame:(CGRect)frame {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview.superview || ![self.superview.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        %orig;
        return;
    }
    %orig(CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 70 - 32, frame.size.height));
}

- (void) setBounds:(CGRect)bounds {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview.superview || ![self.superview.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        %orig;
        return;
    }
    %orig(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width - 70 - 32, bounds.size.height));
}

- (void) setOnScreen:(BOOL)isOnScreen {
    %orig;

    if (![preferences boolForKey: @"showonlockscreen"] || lyricsButton || !self || !self.superview || !self.superview.superview.superview.superview || ![self.superview.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        return;
    }

    lyricsButton = [[UIButton alloc] init];
    lyricsButton.translatesAutoresizingMaskIntoConstraints = false;

    [lyricsButton setTitle: @"LYRICS" forState: UIControlStateNormal];

    // lyricsButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.9];
    [lyricsButton setTitleColor: [UIColor labelColor] forState: UIControlStateNormal];

    lyricsButton.layer.masksToBounds = true;
    lyricsButton.layer.cornerRadius = 8;

    if (lyricsButton.titleLabel) {
        lyricsButton.titleLabel.font = [UIFont systemFontOfSize: 16.0 weight: UIFontWeightBold];
    }

    [self.superview addSubview: lyricsButton];

    [lyricsButton.topAnchor constraintEqualToAnchor: self.topAnchor constant: 6].active = YES;
    [lyricsButton.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: -6].active = YES;
    [lyricsButton.leftAnchor constraintEqualToAnchor: self.rightAnchor constant: 16].active = YES;
    [lyricsButton.rightAnchor constraintEqualToAnchor: self.superview.rightAnchor constant: -16].active = YES;

    presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
    presenter.twitterAlertAllowed = true;

    [lyricsButton
        addTarget: presenter
        action: @selector(present)
        forControlEvents: UIControlEventTouchUpInside
    ];
}

%end

// iOS 13

%hook MediaControlsVolumeContainerView

%new
- (void) lxColorizeUI:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    UIColor *primaryColor = userInfo[@"PrimaryColor"];

    if (lyricsButton) {
        [lyricsButton setTitleColor: primaryColor forState: UIControlStateNormal];
    }
}

%new
- (void) lxRevertUI:(NSNotification *)notification {
    if (lyricsButton) {
        [lyricsButton setTitleColor: [UIColor labelColor] forState: UIControlStateNormal];
    }
}

- (id) initWithFrame:(CGRect)frame {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview || ![self.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        self = %orig;
        return self;
    }
    self = %orig(CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 70 - 32, frame.size.height));

    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(lxRevertUI:)
                                            name:@"ColorFlowLockScreenColorReversionNotification"
                                            object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(lxColorizeUI:)
                                            name:@"ColorFlowLockScreenColorizationNotification"
                                            object:nil];
    
    return self;
}

- (void) setFrame:(CGRect)frame {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview || ![self.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        %orig;
        return;
    }
    %orig(CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 70 - 32, frame.size.height));
}

- (void) setBounds:(CGRect)bounds {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview || ![self.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        %orig;
        return;
    }
    %orig(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width - 70 - 32, bounds.size.height));
}

// superview.superview.superview == CSMediaControlsView

- (void) setOnScreen:(BOOL)isOnScreen {
    %orig;

    if (![preferences boolForKey: @"showonlockscreen"] || lyricsButton || !self || !self.superview || !self.superview.superview.superview || ![self.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        return;
    }

    lyricsButton = [[UIButton alloc] init];
    lyricsButton.translatesAutoresizingMaskIntoConstraints = false;

    [lyricsButton setTitle: @"LYRICS" forState: UIControlStateNormal];

    // lyricsButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.9];
    [lyricsButton setTitleColor: [UIColor labelColor] forState: UIControlStateNormal];

    lyricsButton.layer.masksToBounds = true;
    lyricsButton.layer.cornerRadius = 8;

    if (lyricsButton.titleLabel) {
        lyricsButton.titleLabel.font = [UIFont systemFontOfSize: 16.0 weight: UIFontWeightBold];
    }

    [self.superview addSubview: lyricsButton];

    [lyricsButton.topAnchor constraintEqualToAnchor: self.topAnchor constant: 12].active = YES;
    [lyricsButton.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: -12].active = YES;
    [lyricsButton.leftAnchor constraintEqualToAnchor: self.rightAnchor constant: 16].active = YES;
    [lyricsButton.rightAnchor constraintEqualToAnchor: self.superview.rightAnchor constant: -16].active = YES;

    presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
    presenter.twitterAlertAllowed = true;

    [lyricsButton
        addTarget: presenter
        action: @selector(present)
        forControlEvents: UIControlEventTouchUpInside
    ];
}

%end