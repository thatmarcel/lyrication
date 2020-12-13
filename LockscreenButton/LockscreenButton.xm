#import "../ScrollingLyricsViewController/LXScrollingLyricsViewControllerPresenter.h"
#import <Cephei/HBPreferences.h>

@interface SBCoverSheetPrimarySlidingViewController: UIViewController
@end

@interface MediaControlsVolumeContainerView: UIView
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

%hook MediaControlsVolumeContainerView

- (id) initWithFrame:(CGRect)frame {
    if (![preferences boolForKey: @"showonlockscreen"] || !self.superview.superview.superview || ![self.superview.superview.superview isKindOfClass: %c(CSMediaControlsView)]) {
        self = %orig;
        return self;
    }
    self = %orig(CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 70 - 32, frame.size.height));
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

    lyricsButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.9];
    [lyricsButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];

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
