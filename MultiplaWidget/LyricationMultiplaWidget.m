#import "LyricationMultiplaWidget.h"

@implementation LyricationMultiplaWidget
    @synthesize lineLabel;

    - (instancetype) initWithFrame:(CGRect)frame {
        self = [super initWithFrame: frame];

        if (self) {
            [self loadLabel];
            [self setupReceiver];
        }

        return self;
    }

    - (void) updateWidget { }

    - (void) loadLabel {
        self.lineLabel = [[UILabel alloc] init];
        self.lineLabel.numberOfLines = 0;
        self.lineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.lineLabel.textAlignment = NSTextAlignmentCenter;

        [self.lineLabel setFont: [UIFont boldSystemFontOfSize: 28]];
        [self.lineLabel setTextColor: [UIColor whiteColor]];

        [self addSubview: self.lineLabel];

        [self.lineLabel.topAnchor constraintEqualToAnchor: self.topAnchor constant: 16].active = YES;
        [self.lineLabel.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: -16].active = YES;
        [self.lineLabel.leftAnchor constraintEqualToAnchor: self.leftAnchor constant: 24].active = YES;
        [self.lineLabel.rightAnchor constraintEqualToAnchor: self.rightAnchor constant: -24].active = YES;
    }

    - (void) setupReceiver {
        [[NSDistributedNotificationCenter defaultCenter] addObserverForName: @"com.thatmarcel.tweaks.lyrication/updateLine"
            object: nil
            queue: [NSOperationQueue mainQueue]
            usingBlock: ^(NSNotification *notification)
        {
            NSString *line = [notification.userInfo objectForKey: @"line"];

            [self.lineLabel setText: line];
        }];
    }

@end
