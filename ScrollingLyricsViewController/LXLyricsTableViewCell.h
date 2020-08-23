#import <UIKit/UIKit.h>

@interface LXLyricsTableViewCell: UITableViewCell

    // The color for the highlighted lyrics line
    @property UIColor *highlightedLineColor;
    // The color for the other lyrics lines
    @property UIColor *standardLineColor;

    @property (retain) UILabel *lineLabel;

    @property (retain) NSLayoutConstraint *lineLabelLeftConstraint;
    @property (retain) NSLayoutConstraint *lineLabelTopConstraint;

    @property int index;
    @property BOOL lineHighlighted;

    - (void) setup;
    - (void) highlight;
    - (void) unhighlight;
@end
