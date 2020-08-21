#import <UIKit/UIKit.h>
#import "ScrollingLyricsViewController.h"

@interface ScrollingLyricsViewControllerPresenter: NSObject

    @property (retain) UIViewController *viewController;

    - (void) present;
    - (id) initWithViewController:(UIViewController*)__viewController;
@end
