#import "LXScrollingLyricsViewController+TableViewDelegate.h"

@implementation LXScrollingLyricsViewController (TableViewDelegate)
    - (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        if (!self.lyrics || [self.lyrics count] < 5) {
            return;
        }

        NSDictionary *item = self.lyrics[indexPath.row];
		NSNumber *_seconds = [item objectForKey: @"seconds"];
        int seconds        = (int) [_seconds doubleValue];

        MRMediaRemoteSetElapsedTime(seconds);

        [self updateLyricsForProgress: ((double) seconds) + 0.5];

        self.updatesPaused = true;

        // Wait for the playing app to (hopefully) have skipped to the tapped line
        [NSTimer scheduledTimerWithTimeInterval: 0.7
                                    repeats: false
                                    block: ^(NSTimer *timer) {
                                        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
                                            NSDictionary *info = (__bridge NSDictionary*) information;

                                            CFAbsoluteTime absoluteTime = CFAbsoluteTimeGetCurrent();
                                            CFAbsoluteTime timestamp = CFDateGetAbsoluteTime((CFDateRef)[info objectForKey:@"kMRMediaRemoteNowPlayingInfoTimestamp"]);
                                            double timeIntervalifPause = [[info objectForKey:@"kMRMediaRemoteNowPlayingInfoElapsedTime"] doubleValue];
                                            NSTimeInterval timeInterval = (absoluteTime - timestamp) + timeIntervalifPause;
                                            if (isnan(timeInterval)) {
                                                timeInterval = 0;
                                            }
                                            // Set current playback progress (e.g. 204.34 seconds)
                                            self.playbackProgress = timeInterval + 0.4;

                                            self.updatesPaused = false;
                                        });
                                    }];
    }
@end
