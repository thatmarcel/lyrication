#import <UIKit/UIKit.h>

@interface LyricsTableViewCell: UITableViewCell

    @property (retain) UILabel *lineLabel;

    @property (retain) NSLayoutConstraint *lineLabelLeftConstraint;
    @property (retain) NSLayoutConstraint *lineLabelTopConstraint;

    @property int index;
    @property BOOL lineHighlighted;

    - (void) setup;
    - (void) highlight;
    - (void) unhighlight;
@end
