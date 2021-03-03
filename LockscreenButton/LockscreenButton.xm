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
        BOOL shouldIgnoreIdleTimer = [preferences boolForKey: @"showonlockscreen"] && presenter && [presenter isPresenting];
        
        if (shouldIgnoreIdleTimer) {
            return true;
        }

        return %orig;
    }
%end

// Flow

@interface MMScrollView: UIView
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender;
@end

BOOL addedFlowGestureRecognizer = false;
UILongPressGestureRecognizer *flowLongPressGestureRecognizer;

%hook MMScrollView
    - (void) updateArtworks {
        %orig;

        if (addedFlowGestureRecognizer) {
            return;
        }

        addedFlowGestureRecognizer = true;

        self.userInteractionEnabled = true;

        presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
        presenter.twitterAlertAllowed = true;

        flowLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        [flowLongPressGestureRecognizer addTarget: self action: @selector(lxLongPressRecognized:)];
        flowLongPressGestureRecognizer.minimumPressDuration = 0.5;
        [self addGestureRecognizer: flowLongPressGestureRecognizer];

        addedFlowGestureRecognizer = true;
    }

    %new
    - (void) lxLongPressRecognized:(UIGestureRecognizer*)sender {
        if (sender.state != UIGestureRecognizerStateBegan) {
            return;
        }

        [presenter present];
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