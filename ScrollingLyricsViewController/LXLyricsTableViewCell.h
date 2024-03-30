#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import "UIView+lxFillSuperview.h"
#import "./LXBlurredLabel.h"

@interface LXLyricsTableViewCell: UITableViewCell

    // The color for the highlighted lyrics line
    @property UIColor* highlightedLineColor;
    // The color for the other lyrics lines
    @property UIColor* standardLineColor;

    @property (retain) LXBlurredLabel* lineLabel;

    @property (retain) NSLayoutConstraint* lineLabelLeftConstraint;
    @property (retain) NSLayoutConstraint* lineLabelTopConstraint;

    @property double expandedViewFontSizeMultiplier;
    
    @property int index;
    @property BOOL lineHighlighted;

    @property int distanceFromHighlighted;

    @property BOOL shouldCenterText;

    - (void) setup;
    - (void) highlight;
    - (void) unhighlight;
@end
