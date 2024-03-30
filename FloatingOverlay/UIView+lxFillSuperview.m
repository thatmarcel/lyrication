#import "UIView+lxFillSuperview.h"

@implementation UIView (lxFillSuperview)
    - (void) lxFillSuperview {
        [self.topAnchor constraintEqualToAnchor: self.superview.topAnchor constant: 0].active = true;
        [self.bottomAnchor constraintEqualToAnchor: self.superview.bottomAnchor constant: 0].active = true;
        [self.leftAnchor constraintEqualToAnchor: self.superview.leftAnchor constant: 0].active = true;
        [self.rightAnchor constraintEqualToAnchor: self.superview.rightAnchor constant: 0].active = true;
    }
@end
