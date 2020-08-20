#import "LXUIModuleContentViewController.h"

@implementation LXUIModuleContentViewController
    @synthesize lineLabel;

    - (instancetype) initWithSmallSize:(BOOL)small {
        _small = small;
        return [self init];
    }

    // This is where you initialize any controllers for objects from ControlCenterUIKit
    - (instancetype) initWithNibName:(NSString*)name bundle:(NSBundle*)bundle {
        self = [super initWithNibName:name bundle:bundle];
        if (self) {
            [self loadLabel];
            [self setupReceiver];
        }

        return self;
    }

    - (void) loadLabel {
        self.lineLabel = [[UILabel alloc] init]; // WithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.856, 150)
        self.lineLabel.numberOfLines = 0;
        self.lineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.lineLabel.textAlignment = NSTextAlignmentCenter;

        [self.lineLabel setFont: [UIFont boldSystemFontOfSize: 28]];
        [self.lineLabel setTextColor: [UIColor whiteColor]];

        [self.view addSubview: self.lineLabel];

        [self.lineLabel.topAnchor constraintEqualToAnchor: self.view.topAnchor constant: 16].active = YES;
        [self.lineLabel.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: -16].active = YES;
        [self.lineLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 24].active = YES;
        [self.lineLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -24].active = YES;
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

    -(void)viewDidLoad {
        [super viewDidLoad];

        // Calculate expanded size
        _preferredExpandedContentWidth = [UIScreen mainScreen].bounds.size.width * 0.856;
        _preferredExpandedContentHeight = 150;
    }

    - (void) viewWillAppear:(BOOL)animated { [super viewWillAppear:animated]; }

    - (void) controlCenterWillPresent { }

    - (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator { }

    - (BOOL) _canShowWhileLocked {
	    return YES;
    }
@end
