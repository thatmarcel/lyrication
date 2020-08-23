#import "LXLyricsTableViewCell.h"

@implementation LXLyricsTableViewCell: UITableViewCell
    @synthesize lineLabel;
    @synthesize lineLabelTopConstraint;
    @synthesize lineLabelLeftConstraint;
    @synthesize lineHighlighted;

    - (void) setup {
        if (self.lineLabel) {
            self.lineLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self.lineLabelLeftConstraint.constant = -((self.bounds.size.width - 32) * 0.1);
            [self.lineLabel setTextColor: [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.7]];

            [self layoutIfNeeded];
            return;
        }

        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.backgroundColor = [UIColor clearColor];

        self.lineLabel = [[UILabel alloc] init];
        self.lineLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self addSubview: self.lineLabel];
        self.lineLabel.numberOfLines = 0;
        [self.lineLabel setFont: [UIFont systemFontOfSize: 50 weight: UIFontWeightHeavy]];
        [self.lineLabel setTextColor: [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.7]];

        self.lineLabelTopConstraint = [self.lineLabel.topAnchor constraintEqualToAnchor: self.topAnchor constant: 16];
        self.lineLabelTopConstraint.active = YES;
        [self.lineLabel.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: 0].active = YES;
        self.lineLabelLeftConstraint = [self.lineLabel.leftAnchor constraintEqualToAnchor: self.leftAnchor constant: -((self.bounds.size.width - 32) * 0.1)];
        self.lineLabelLeftConstraint.active = YES;
        [self.lineLabel.rightAnchor constraintEqualToAnchor: self.rightAnchor constant: -32].active = YES;

        [self layoutIfNeeded];

        self.lineHighlighted = false;
    }

    - (void) highlight {
        if (self.lineHighlighted) {
            return;
        }

        self.lineHighlighted = true;
        [UIView animateWithDuration: 0.2
            animations:^{
                self.lineLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.lineLabelLeftConstraint.constant = 0;
                [self.lineLabel setTextColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0]];

                [self layoutIfNeeded];
            }
            completion:^(BOOL finished){ }];
    }

    - (void) unhighlight {
        if (!self.lineHighlighted) {
            // Needed for rotation changes
            self.lineLabelLeftConstraint.constant = -((self.bounds.size.width - 32) * 0.1);
            [self layoutIfNeeded];
            return;
        }

        self.lineHighlighted = false;

        [UIView animateWithDuration: 0.2
            animations:^{
                self.lineLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                self.lineLabelLeftConstraint.constant = -((self.bounds.size.width - 32) * 0.1);
                [self.lineLabel setTextColor: [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.7]];

                [self layoutIfNeeded];
            }
            completion:^(BOOL finished){ }];
    }
@end
