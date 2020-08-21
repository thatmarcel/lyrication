#import <UIKit/UIKit.h>
#include <MediaRemote/MediaRemote.h>
#import "UIView+fillSuperview.h"
#import "LyricsTableViewCell.h"
#import "ScrollingLyricsViewControllerPresenter.h"

@interface ScrollingLyricsViewController: UIViewController

    @property (retain) ScrollingLyricsViewControllerPresenter *presenter;

    @property (retain) UIImageView *artworkImageView;
    @property (retain) UIVisualEffectView *visualEffectView;
    @property (retain) UILabel *songNameLabel;
    @property (retain) UILabel *songArtistLabel;
    @property (retain) UITableView *tableView;

    // The lyrics of the currently playing song or NULL if nothing is playing
    @property (retain) NSArray *lyrics;
    // The song that played on the last execution
    @property (retain) NSString *lastSong;
    // The current progress of the current music playback in seconds (e.g. 204.34 seconds)
    @property double playbackProgress;

    @property int lastIndex;

    - (void) setupView;
    - (void) updateMetadataWithInfo:(NSDictionary*)info;

    - (void) start;
    - (void) fire;
    - (void) fetchCurrentPlayback;
    - (void) fetchLyricsForSong:(NSString*)song;
    - (void) updateLyricsForProgress:(double)progress;
    - (void) showNoLyricsAvailable;
    // Reload metadata every 5 seconds to show artwork, if the playing app took longer to load it
    - (void) reloadMetadata;
@end
