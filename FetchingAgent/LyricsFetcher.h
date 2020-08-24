#include <MediaRemote/MediaRemote.h>
#import "../NSDistributedNotificationCenter.h"

@interface LyricsFetcher : NSObject

    // The lyrics of the currently playing song or NULL if nothing is playing
    @property (retain) NSArray *lyrics;
    // The song that played on the last execution
    @property (retain) NSString *lastSong;
    // The current progress of the current music playback in seconds (e.g. 204.34 seconds)
    @property double playbackProgress;

    @property (retain) NSTimer *lyricsTimer;

    - (void) start;
    - (void) fire;
    - (void) fetchCurrentPlayback;
    - (void) fetchLyricsForSong:(NSString*)song;
    - (void) updateLyricsForProgress:(double)progress;
    - (void) showNoLyricsAvailable;
    - (void) broadcastText:(NSString*)text;

@end
