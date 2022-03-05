#import "LXBlurredLabel.h"

@implementation LXBlurredLabel
    @synthesize blurRadius;
    @synthesize blurFilter;
    @synthesize blurredColor;
    @synthesize normalColor;
    @synthesize blurEnabled;

    - (void) initializeBlur {
        self.blurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
        [self.blurFilter setDefaults];
        [self.blurFilter setValue:@(self.blurRadius) forKey:@"inputRadius"];

        self.layer.opaque = false;
        self.layer.contentsScale = [UIScreen mainScreen].scale;

        self.contentMode = UIViewContentModeRedraw;

        HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier: @"com.thatmarcel.tweaks.lyrication.hbprefs"];
        [preferences registerDefaults: @{
            @"showonlockscreen": @true,
            @"showinsidespotify": @true,
            @"expandedviewlineblurenabled": @true
        }];

        self.blurEnabled = [preferences boolForKey: @"expandedviewlineblurenabled"];
    }

    - (void) displayLayer:(CALayer *)layer {
        if (CGRectIsEmpty(layer.bounds)) {
            layer.contents = nil;
            return;
        }

        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.opaque, layer.contentsScale);
        [self.layer drawInContext: UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

        if (blurRadius == 0 || !self.blurEnabled) {
            layer.contents = (__bridge id) [image CGImage];
            UIGraphicsEndImageContext();
            return;
        }
    
        CIImage *imageToBlur = [CIImage imageWithCGImage: image.CGImage];
        [self.blurFilter setValue: imageToBlur forKey: kCIInputImageKey];

        CIImage *outputImage = self.blurFilter.outputImage;
        CIContext *context = [CIContext contextWithCGContext: UIGraphicsGetCurrentContext() options: nil];
        CGImageRef cgimg = [context createCGImage: outputImage fromRect: [outputImage extent]];

        layer.contents = (__bridge id) cgimg;

        UIGraphicsEndImageContext();
    }

    - (void) disableBlur {
        [self updateBlurWithRadius: 0];
    }

    - (void) updateBlurWithRadius:(CGFloat)radius {
        self.blurRadius = radius;

        if (!self.blurFilter) {
            [self initializeBlur];
        }

        self.textColor = radius == 0 ? self.normalColor : self.blurredColor;

        [self.blurFilter setValue:@(radius) forKey:@"inputRadius"];

        [self setNeedsDisplay];
    }
@end