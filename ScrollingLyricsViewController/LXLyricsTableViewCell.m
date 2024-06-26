#import "./LXLyricsTableViewCell.h"

@implementation LXLyricsTableViewCell: UITableViewCell
    @synthesize lineLabel;
    @synthesize lineLabelTopConstraint;
    @synthesize lineLabelLeftConstraint;
    @synthesize lineHighlighted;
    @synthesize highlightedLineColor;
    @synthesize standardLineColor;
    @synthesize distanceFromHighlighted;
    @synthesize expandedViewFontSizeMultiplier;
    @synthesize shouldCenterText;
    @synthesize blurEnabled;

    - (void) setup {
        [UIView performWithoutAnimation: ^{
            [self __setup];
        }];
    }

    - (void) __setup {
        self.lineHighlighted = false;
        
        if (self.lineLabel) {
            // self.lineLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
            // self.lineLabelLeftConstraint.constant = self.shouldCenterText ? 0 : -((self.bounds.size.width - 32) * 0.1);
            self.lineLabelLeftConstraint.constant = (self.shouldCenterText || !self.blurEnabled) ? 0 : -([self blurRadius]);

            [self.lineLabel updateBlurWithRadius: [self blurRadius]];

            [self layoutIfNeeded];
            return;
        }

        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.backgroundColor = [UIColor clearColor];

        self.lineLabel = [[LXBlurredLabel alloc] init];
        self.lineLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview: self.lineLabel];
        self.lineLabel.numberOfLines = 0;
        
        self.lineLabel.clipsToBounds = false;
        self.lineLabel.layer.masksToBounds = false;
        
        self.clipsToBounds = false;
        self.layer.masksToBounds = false;
        
        self.superview.clipsToBounds = false;
        self.superview.layer.masksToBounds = false;

        HBPreferences* preferences = [[HBPreferences alloc] initWithIdentifier: @"com.thatmarcel.tweaks.lyrication.hbprefs"];
        [preferences registerDefaults: @{
            @"expandedviewfontsizemultiplier": @1,
            @"expandedviewcenterstyle": @false,
            @"expandedviewlineblurenabled": @false
        }];

        self.shouldCenterText = [preferences boolForKey: @"expandedviewcenterstyle"];
        
        self.blurEnabled = [preferences boolForKey: @"expandedviewlineblurenabled"];

        self.lineLabel.textAlignment = self.shouldCenterText ? NSTextAlignmentCenter : NSTextAlignmentLeft;

        self.expandedViewFontSizeMultiplier = [preferences doubleForKey: @"expandedviewfontsizemultiplier"];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.lineLabel setFont: [UIFont systemFontOfSize: 45.0 * self.expandedViewFontSizeMultiplier weight: UIFontWeightHeavy]];
        } else {
            [self.lineLabel setFont: [UIFont systemFontOfSize: 32.0 * self.expandedViewFontSizeMultiplier weight: UIFontWeightHeavy]];
        }

        self.lineLabelTopConstraint = [self.lineLabel.topAnchor constraintEqualToAnchor: self.topAnchor constant: 16];
        self.lineLabelTopConstraint.active = true;
        [self.lineLabel.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: 0].active = true;
        // self.lineLabelLeftConstraint = [self.lineLabel.leftAnchor constraintEqualToAnchor: self.leftAnchor constant: self.shouldCenterText ? 0 : -((self.bounds.size.width - 32) * 0.1)];
        self.lineLabelLeftConstraint = [self.lineLabel.leftAnchor constraintEqualToAnchor: self.leftAnchor constant: (self.shouldCenterText || !self.blurEnabled) ? 0 : -([self blurRadius])];
        self.lineLabelLeftConstraint.active = true;
        [self.lineLabel.rightAnchor constraintEqualToAnchor: self.rightAnchor constant: -32].active = true;

        self.lineLabel.blurredColor = self.standardLineColor;
        self.lineLabel.normalColor = self.highlightedLineColor;
        
        [self.lineLabel updateBlurWithRadius: [self blurRadius]];
        
        [self layoutIfNeeded];
    }

    - (CGFloat) blurRadius {
        double distanceMultiplier = self.expandedViewFontSizeMultiplier;
        if (distanceMultiplier > 1) {
            distanceMultiplier = 1;
        }

        CGFloat distance = (distanceFromHighlighted > 4 ? 4 : distanceFromHighlighted) * distanceMultiplier;
        CGFloat radius = distance == 0 ? 0 : distance * 2;

        return radius;
    }

    - (void) highlight {
        if (self.lineHighlighted) {
            return;
        }

        self.lineHighlighted = true;
        [UIView
            animateWithDuration: 0.4
            delay: 0.0
            options: UIViewAnimationOptionCurveEaseInOut
            animations: ^{
                // self.lineLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                // self.lineLabelLeftConstraint.constant = 0;
                self.lineLabelLeftConstraint.constant = 0;

                [self.lineLabel disableBlur];

                [self layoutIfNeeded];
            }
            completion: ^(BOOL finished) { }
        ];
    }

    - (void) unhighlight {
        if (!self.lineHighlighted) {
            [self.lineLabel updateBlurWithRadius: [self blurRadius]];
            // Needed for rotation changes
            self.lineLabelLeftConstraint.constant = (self.shouldCenterText || !self.blurEnabled) ? 0 : -([self blurRadius]);
            // self.lineLabelLeftConstraint.constant = self.shouldCenterText ? 0 : -((self.bounds.size.width - 32) * 0.1);
            // [self layoutIfNeeded];
            // return;
        }

        [UIView
            animateWithDuration: 0.4
            delay: 0.0
            options: UIViewAnimationOptionCurveEaseInOut
            animations: ^{
                // self.lineLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                // self.lineLabelLeftConstraint.constant = self.shouldCenterText ? 0 : -((self.bounds.size.width - 32) * 0.1);
                self.lineLabelLeftConstraint.constant = (self.shouldCenterText || !self.blurEnabled) ? 0 : -([self blurRadius]);

                [self.lineLabel updateBlurWithRadius: [self blurRadius]];

                [self layoutIfNeeded];
            }
            completion: ^(BOOL finished) { self.lineHighlighted = false; }
        ];
    }
@end
