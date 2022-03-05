#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

#import "../ScrollingLyricsViewController/LXScrollingLyricsViewControllerPresenter.h"

@interface SPTNowPlayingScrollCell : UIView
@end

LXScrollingLyricsViewControllerPresenter *presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];;

HBPreferences *preferences;

%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.lyrication.hbprefs"];
    [preferences registerDefaults:@{
        @"showonlockscreen": @true,
        @"showinsidespotify": @true,
        @"expandedviewlineblurenabled": @true
    }];
}

BOOL hasAddedButton = false;
UIButton *expandLyricationButton = [[UIButton alloc] init];

%hook SPTNowPlayingScrollCell

    - (void) layoutSubviews {
        %orig;

        if (hasAddedButton) {
            return;
        }

        if (![preferences boolForKey: @"showinsidespotify"]) {
            return;
        }

        if (
            self.subviews.count < 1 ||
            self.subviews[0].subviews.count < 1 ||
            self.subviews[0].subviews[0].subviews.count < 2 ||
            self.subviews[0].subviews[0].subviews[1].subviews.count < 2
        ) {
            return;
        }

        UIView *singalongFeatureImplCardView = self.subviews[0].subviews[0];

        UIStackView *stackView = singalongFeatureImplCardView.subviews[1];

        UIView *existingExpandButtonView = stackView.subviews[1];

        if (!stackView) {
            return;
        }

        hasAddedButton = true;

        expandLyricationButton.translatesAutoresizingMaskIntoConstraints = false;

        [expandLyricationButton setTitle: @"LYRICATION" forState: UIControlStateNormal];

        expandLyricationButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.5];
        [expandLyricationButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];

        expandLyricationButton.layer.masksToBounds = true;
        expandLyricationButton.layer.cornerRadius = 14;

        if (expandLyricationButton.titleLabel) {
            expandLyricationButton.titleLabel.font = [UIFont systemFontOfSize: 10.0 weight: UIFontWeightBold];
        }

        [stackView addSubview: expandLyricationButton];

        [expandLyricationButton.heightAnchor constraintEqualToConstant: 28].active = true;
        [expandLyricationButton.widthAnchor constraintEqualToConstant: 100].active = true;
        [expandLyricationButton.centerYAnchor constraintEqualToAnchor: stackView.centerYAnchor].active = true;
        [expandLyricationButton.rightAnchor constraintEqualToAnchor: existingExpandButtonView.leftAnchor constant: -12].active = true;

        [expandLyricationButton
            addTarget: presenter
            action: @selector(present)
            forControlEvents: UIControlEventTouchUpInside
        ];
    }

%end