#import "UIView+fillSuperview.h"

@implementation UIView (FillSuperview)
    - (void) fillSuperview {
        [self.topAnchor constraintEqualToAnchor: self.superview.topAnchor constant: 0].active = YES;
        [self.bottomAnchor constraintEqualToAnchor: self.superview.bottomAnchor constant: 0].active = YES;
        [self.leftAnchor constraintEqualToAnchor: self.superview.leftAnchor constant: 0].active = YES;
        [self.rightAnchor constraintEqualToAnchor: self.superview.rightAnchor constant: 0].active = YES;
    }
@end
