#import <UIKit/UIKit.h>
#include <MediaRemote/MediaRemote.h>
#import "UIView+lxFillSuperview.h"
#import "LXLyricsTableViewCell.h"
#import "LXScrollingLyricsViewControllerPresenter.h"

@interface LXScrollingLyricsViewController: UIViewController

    // Hides the background image & blur effect views
    @property BOOL shouldHideBackground;
    // Hides the name and artist bar and gives the tableview full height
    @property BOOL shouldHideNameAndArtist;
    // The color for the highlighted lyrics line
    @property UIColor *highlightedLineColor;
    // The color for the other lyrics lines
    @property UIColor *standardLineColor;

    // The presenter of the view controller, used to remove the window on viewDidDisappear,
    // if NULL / nil, the view controller won't crash, viewDidDisappear will just do nothing
    @property (retain) LXScrollingLyricsViewControllerPresenter *presenter;

    // The background image view
    @property (retain) UIImageView *artworkImageView;
    // The background blur effect view, subview of the image view
    @property (retain) UIVisualEffectView *visualEffectView;

    @property (retain) UILabel *songNameLabel;
    @property (retain) UILabel *songArtistLabel;
    @property (retain) UITableView *tableView;

    @property (retain) UITextView *staticLyricsTextView;

    // The lyrics of the currently playing song
    @property (retain) NSArray *lyrics;
    // The song that was playing on the last execution of the timer
    @property (retain) NSString *lastSong;
    // The current progress of the current music playback in seconds (e.g. 204.34 seconds)
    @property double playbackProgress;

    // The index of the last line that was shown, checked, so that animations are only done when a new line appears
    @property int lastIndex;

    @property (retain) NSTimer *metadataTimer;
    @property (retain) NSTimer *lyricsTimer;

    // If set to true, lyrics won't update
    // Used to make skipping to a line more smooth
    @property BOOL updatesPaused;

    // Configurates the view, called by viewDidLoad
    - (void) setupView;
    // Updates the artwork, song name and artist
    - (void) updateMetadataWithInfo:(NSDictionary*)info;

    // Starts the timer, called by viewDidLoad
    - (void) start;
    // Called by the timer, updates things
    - (void) fire;
    // Gets the current playback and passes it to the method below
    - (void) fetchCurrentPlayback;
    // Fetches the lyrics from the server
    - (void) fetchLyricsForSong:(NSString*)song byArtist:(NSString*)artist;
    // Updates the current lyrics line and does the animation / scrolling
    - (void) updateLyricsForProgress:(double)progress;
    // Just makes "No lyrics available" the only lyrics line
    - (void) showNoLyricsAvailable;
    // Reload metadata every 5 seconds to show artwork, if the playing app took longer to load it
    - (void) reloadMetadata;
    // Fetch unsynchronized lyrics
    - (void) fetchStaticLyricsForSong:(NSString*)song byArtist:(NSString*)artist;

    - (BOOL) _canShowWhileLocked;
@end
