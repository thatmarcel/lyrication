#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import "UIView+lxFillSuperview.h"

@interface LXBlurredLabel : UILabel
    @property CGFloat blurRadius;
    @property (retain) CIFilter *blurFilter;
    @property (retain) UIColor *blurredColor;
    @property (retain) UIColor *normalColor;
    @property BOOL blurEnabled;

    - (void) disableBlur;
    - (void) updateBlurWithRadius:(CGFloat)radius;
@end