#import "ScrollingLyricsViewControllerPresenter.h"

@implementation ScrollingLyricsViewControllerPresenter
    @synthesize viewController;

    - (id) initWithViewController:(UIViewController*)__viewController {
        self = [super init];
        [self setViewController: __viewController];
        return self;
    }

    - (void) present {
        ScrollingLyricsViewController *vc = [ScrollingLyricsViewController new];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [[self viewController] presentViewController: vc animated: true completion: nil];
    }
@end
