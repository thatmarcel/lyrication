#import "LXLyricsFetcher.h"

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
            self.playbackProgress = timeInterval + 1.0;

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

            [self fetchLyricsForSong: queryString];
        });
    }

    - (void) fetchLyricsForSong:(NSString*)song {
        self.lyrics = NULL;
        [self broadcastText: @"Loading..."];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	    dispatch_async(queue, ^{
		    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    	    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
		    NSString *query = [song stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://api.textyl.co/api/lyrics?q=%@", query]];
		    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL: url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			    dispatch_async(dispatch_get_main_queue(), ^{
				    if (![[self lastSong] isEqual:song]) {
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
