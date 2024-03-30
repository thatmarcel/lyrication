#import "LXBlurredLabelLayer.h"

@implementation LXBlurredLabelLayer
    @dynamic blurRadius;
    
    + (BOOL) needsDisplayForKey:(NSString *)key {
        if ([key isEqualToString: @"blurRadius"]) {
            return true;
        }
        
        return [super needsDisplayForKey: key];
    }
    
    - (id<CAAction>) actionForKey:(NSString*) key {
        if (![key isEqualToString: @"blurRadius"]) {
            return [super actionForKey: key];
        }
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: key];
        [animation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFromValue: @([self.presentationLayer blurRadius])];
        
        return animation;
    }
@end