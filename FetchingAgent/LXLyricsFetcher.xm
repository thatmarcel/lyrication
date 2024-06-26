#import "LXLyricsFetcher.h"

@interface SBLockScreenManager: NSObject {
    BOOL _isScreenOn;
}
    + (id) sharedInstanceIfExists;
@end

@interface LastLookManager: NSObject
    - (BOOL) isActive;

    + (instancetype) sharedInstance;
@end

@interface AVRoutingSessionManager: NSObject
    @property (atomic, assign, readonly) id currentRoutingSession;

    + (AVRoutingSessionManager*) longFormVideoRoutingSessionManager; // doesn't return the same AVRoutingSessionManager instance as the SB original one, it probably returns a new one for video, but the original one doesn't have a sharedInstance, and both have same destination, so I'm using this one!
@end

@interface SBApplication: NSObject 
    @property (nonatomic, readonly) NSString* bundleIdentifier;
@end

@interface SBMediaController: NSObject
    @property (nonatomic, readonly) SBApplication* nowPlayingApplication;

    - (instancetype) sharedInstance;
@end

BOOL isPlayingFromSpotify() {
    NSString *nowPlayingBundleId = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];
    return [nowPlayingBundleId isEqualToString: @"com.spotify.client"];
}

BOOL isAirPlaying() {
    return [%c(AVRoutingSessionManager) longFormVideoRoutingSessionManager].currentRoutingSession != nil;
}

@implementation LXLyricsFetcher
    @synthesize lyrics;
    @synthesize lastSong;
    @synthesize playbackProgress;
    @synthesize lyricsTimer;

    // Store one instance of the main class
    static LXLyricsFetcher *LXLyricsFetcherInstance;

    - (void) start {
        [self fire];
        self.lyricsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2
                 target: self
                 selector: @selector(fire)
                 userInfo: nil
                 repeats: true];
    }

    - (void) fire {
        LastLookManager *lastLookManager = [%c(LastLookManager) sharedInstance];
        SBLockScreenManager *manager = [%c(SBLockScreenManager) sharedInstanceIfExists];
        
        if ((!lastLookManager || (lastLookManager && ![lastLookManager isActive])) && manager) {
            BOOL isScreenOn = MSHookIvar<BOOL>(manager, "_isScreenOn");
            if (!isScreenOn) {
                return;
            }
        }

        [self fetchCurrentPlayback];

        if (!lyrics || !playbackProgress) {
            return;
        }

        [self updateLyricsForProgress: playbackProgress];
    }

    - (void) fetchCurrentPlayback {
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
            self.playbackProgress = timeInterval;

            if (isAirPlaying() && isPlayingFromSpotify() && self.playbackProgress > 1.5) {
                self.playbackProgress -= 1.5;
            }

            NSNumber *_rate = (NSNumber*) info[@"kMRMediaRemoteNowPlayingInfoPlaybackRate"];
			double rate = [_rate doubleValue];
			double playingRate = 1;
			BOOL isPlaying = rate == playingRate;
			NSString *infoTitle = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoTitle"];
			if (infoTitle == NULL || !isPlaying) {
                self.lyrics = NULL;
                self.lastSong = @"";
                [self broadcastText: @"Paused"];
				return;
			}
			NSString *infoArtist = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoArtist"];
			NSString *queryString = [NSString stringWithFormat: @"%@%@%@",  infoTitle, @" ", infoArtist];

            if ([queryString isEqual: lastSong]) {
                return;
            }

            self.lastSong = queryString;

            [self fetchLyricsForSong: infoTitle byArtist: infoArtist];
        });
    }

    - (void) fetchLyricsForSong:(NSString*)song byArtist:(NSString*)artist {
        self.lyrics = NULL;
        [self broadcastText: @"Loading..."];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	    dispatch_async(queue, ^{
		    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    	    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
		    NSString *escapedSong = [song stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString *escapedArtist = [artist stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://prv.textyl.co/api/lyrics?name=%@&artist=%@", escapedSong, escapedArtist]];
		    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL: url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			    dispatch_async(dispatch_get_main_queue(), ^{
				    if (![[self lastSong] isEqual: [NSString stringWithFormat: @"%@%@%@",  song, @" ", artist]]) {
					    return;
				    }

				    NSInteger statusCode = 0;

				    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
    				    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    				    statusCode = httpResponse.statusCode;
				    }

				    if (statusCode != 200 || data == nil) {
					    [self showNoLyricsAvailable];
					    return;
				    }

				    NSError* errorr;
				    NSArray* json = (NSArray*) [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorr];
				    if (errorr != nil || [json count] < 1) {
					    [self showNoLyricsAvailable];
					    return;
				    }

				    NSMutableArray *items = [NSMutableArray array];

	                for (NSDictionary *dict in json) {
		                NSString *line = [dict objectForKey:@"lyrics"];
		                NSNumber *seconds = [NSNumber numberWithDouble:[[dict objectForKey:@"seconds"] doubleValue]];

		                NSDictionary *newDict = @{ @"lyrics": line, @"seconds": seconds };
		                [items addObject:newDict];
	                }

	                [self setLyrics:items];
			    });
    	    }];
		    [dataTask resume];
	    });
    }

    - (void) updateLyricsForProgress:(double)progress {
        double smallestdistance = 999999;
		int smallestdistanceindex = 0;

		int index = 0;

		for (NSDictionary *dict in [self lyrics]) {
			double seconds = [[dict objectForKey:@"seconds"] doubleValue];

			double itemsmallestdistance = seconds - progress;

			if (itemsmallestdistance < 0) {
				itemsmallestdistance = -itemsmallestdistance;
			} else {
                continue;
            }

			if (smallestdistance < itemsmallestdistance) {
				continue;
			}

			smallestdistanceindex = index;
			smallestdistance = itemsmallestdistance;

			index += 1;
		}

        NSDictionary *item = [self lyrics][smallestdistanceindex];
		NSString *line = [item objectForKey:@"lyrics"];

        [self broadcastText: line];
    }

    - (void) showNoLyricsAvailable {
        [self broadcastText: @"No lyrics available"];
    }

    - (void) broadcastText:(NSString*)text {
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        [userInfo setObject: text forKey: @"line"];
        [[NSDistributedNotificationCenter defaultCenter]
            postNotificationName: @"com.thatmarcel.tweaks.lyrication/updateLine"
            object: nil
            userInfo: userInfo
        ];
    }

@end

%ctor {
    LXLyricsFetcherInstance = [[LXLyricsFetcher alloc] init];
    [LXLyricsFetcherInstance start];
}
