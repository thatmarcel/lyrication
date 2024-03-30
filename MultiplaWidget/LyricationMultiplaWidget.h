#import <UIKit/UIKit.h>
#import "../NSDistributedNotificationCenter.h"

@interface LyricationMultiplaWidget: UIView

    @property (nonatomic) UILabel* lineLabel;

    - (instancetype) initWithFrame:(CGRect)arg1;
    - (void) updateWidget;

    - (void) loadLabel;
    - (void) setupReceiver;
@end
