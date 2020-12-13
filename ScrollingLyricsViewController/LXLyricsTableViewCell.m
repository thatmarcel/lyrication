#import "LXLyricsTableViewCell.h"

@implementation LXLyricsTableViewCell: UITableViewCell
    @synthesize lineLabel;
    @synthesize lineLabelTopConstraint;
    @synthesize lineLabelLeftConstraint;
    @synthesize lineHighlighted;
    @synthesize highlightedLineColor;
    @synthesize standardLineColor;
    @synthesize distanceFromHighlighted;

    - (void) setup {
        self.lineHighlighted = false;
        
        if (self.lineLabel) {
            self.lineLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self.lineLabelLeftConstraint.constant = -((self.bounds.size.width - 32) * 0.1);

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
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.lineLabel setFont: [UIFont systemFontOfSize: 50 weight: UIFontWeightHeavy]];
        } else {
            [self.lineLabel setFont: [UIFont systemFontOfSize: 40 weight: UIFontWeightHeavy]];
        }

        self.lineLabelTopConstraint = [self.lineLabel.topAnchor constraintEqualToAnchor: self.topAnchor constant: 16];
        self.lineLabelTopConstraint.active = YES;
        [self.lineLabel.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: 0].active = YES;
        self.lineLabelLeftConstraint = [self.lineLabel.leftAnchor constraintEqualToAnchor: self.leftAnchor constant: -((self.bounds.size.width - 32) * 0.1)];
        self.lineLabelLeftConstraint.active = YES;
        [self.lineLabel.rightAnchor constraintEqualToAnchor: self.rightAnchor constant: -32].active = YES;

        self.lineLabel.blurredColor = self.standardLineColor;
        self.lineLabel.normalColor = self.highlightedLineColor;
        
        [self.lineLabel updateBlurWithRadius: [self blurRadius]];
        
        [self layoutIfNeeded];
    }

    - (CGFloat) blurRadius {
        CGFloat distance = distanceFromHighlighted > 3 ? 3 : distanceFromHighlighted;
        CGFloat radius = distance == 0 ? 0 : distance * 2;

        return radius;
    }

    - (void) highlight {
        if (self.lineHighlighted) {
            return;
        }

        self.lineHighlighted = true;
        [UIView animateWithDuration: 0.4 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.lineLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.lineLabelLeftConstraint.constant = 0;

                [self.lineLabel disableBlur];

                [self layoutIfNeeded];
            }
            completion:^(BOOL finished){ }];
    }

    - (void) unhighlight {
        if (!self.lineHighlighted) {
            [self.lineLabel updateBlurWithRadius: [self blurRadius]];
            // Needed for rotation changes
            self.lineLabelLeftConstraint.constant = -((self.bounds.size.width - 32) * 0.1);
            [self layoutIfNeeded];
            return;
        }

        self.lineHighlighted = false;

        [UIView animateWithDuration: 0.4 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                self.lineLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                self.lineLabelLeftConstraint.constant = -((self.bounds.size.width - 32) * 0.1);

                [self.lineLabel updateBlurWithRadius: [self blurRadius]];

                [self layoutIfNeeded];
            }
            completion:^(BOOL finished){ }];
    }
@end
