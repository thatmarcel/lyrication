#import "ScrollingLyricsViewController.h"
#import "ScrollingLyricsViewController+TableViewDataSource.h"

@implementation ScrollingLyricsViewController
    @synthesize artworkImageView;
    @synthesize visualEffectView;
    @synthesize songNameLabel;
    @synthesize songArtistLabel;
    @synthesize tableView;
    @synthesize lyrics;
    @synthesize lastSong;
    @synthesize playbackProgress;
    @synthesize lastIndex;

    - (void) setupView {
        self.view.backgroundColor = [UIColor whiteColor];

        self.artworkImageView = [[UIImageView alloc] init];
        self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.artworkImageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view insertSubview: self.artworkImageView atIndex: 0];
        [self.artworkImageView fillSuperview];

        UIVisualEffect *effect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight];

        self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect: effect];
        self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false;
        [self.artworkImageView addSubview: self.visualEffectView];
        [self.visualEffectView fillSuperview];

        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.songNameLabel.numberOfLines = 1;
        [self.songNameLabel setFont: [UIFont systemFontOfSize: 56 weight: UIFontWeightBlack]];
        [self.songNameLabel setTextColor: [UIColor blackColor]];
        [self.view addSubview: self.songNameLabel];
        [self.songNameLabel.topAnchor constraintEqualToAnchor: self.view.topAnchor constant: 32].active = YES;
        [self.songNameLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.songNameLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: 32].active = YES;

        self.songArtistLabel = [[UILabel alloc] init];
        self.songArtistLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.songArtistLabel.numberOfLines = 1;
        [self.songArtistLabel setFont: [UIFont systemFontOfSize: 26 weight: UIFontWeightHeavy]];
        [self.songArtistLabel setTextColor: [[UIColor blackColor] colorWithAlphaComponent: 0.8]];
        [self.view addSubview: self.songArtistLabel];
        [self.songArtistLabel.topAnchor constraintEqualToAnchor: self.songNameLabel.bottomAnchor constant: 2].active = YES;
        [self.songArtistLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.songArtistLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: 32].active = YES;

        self.tableView = [[UITableView alloc] init];
        self.tableView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview: self.tableView];
        [self.tableView.topAnchor constraintEqualToAnchor: self.songArtistLabel.bottomAnchor constant: 8].active = YES;
        [self.tableView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 0].active = YES;
        [self.tableView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.tableView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: 0].active = YES;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass: LyricsTableViewCell.class forCellReuseIdentifier: @"LyricsTableViewCell"];
        [self.tableView setContentInset: UIEdgeInsetsMake(0, 0, 32, 0)];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 90;
    }

    - (void) start {
        [self performSelector: @selector(fire) withObject: NULL afterDelay: 0.5];
        [self performSelector: @selector(reloadMetadata) withObject: NULL afterDelay: 0.5];
    }

    - (void) fire {
        [self fetchCurrentPlayback];
        [self performSelector:@selector(fire) withObject:NULL afterDelay: 0.2];

        if (!lyrics || !playbackProgress || [@"" isEqual: self.lastSong]) {
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
            self.playbackProgress = timeInterval + 0.7;

            NSNumber *_rate = (NSNumber*) info[@"kMRMediaRemoteNowPlayingInfoPlaybackRate"];
			double rate = [_rate doubleValue];
			double playingRate = 1;
			BOOL isPlaying = rate == playingRate;
			NSString *infoTitle = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoTitle"];
            NSString *infoArtist = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoArtist"];
			NSString *queryString = [NSString stringWithFormat: @"%@%@%@",  infoTitle, @" ", infoArtist];

            if (![queryString isEqual: lastSong] || !self.artworkImageView.image) {
                [self updateMetadataWithInfo: info];
            }

			if (infoTitle == NULL || !isPlaying) {
                self.lastSong = @"";
                // [self broadcastText: @"Paused"];
				return;
			}

            if ([queryString isEqual: lastSong]) {
                return;
            }

            self.artworkImageView.image = nil;

            self.lastSong = queryString;

            [self fetchLyricsForSong: queryString];
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

        if (self.lastIndex && self.lastIndex == smallestdistanceindex) {
            return;
        }

        self.lastIndex = smallestdistanceindex;

        [self.tableView
            scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: smallestdistanceindex inSection: 0]
            atScrollPosition: UITableViewScrollPositionTop
            animated: true];

        for (LyricsTableViewCell* cell in [self.tableView visibleCells]) {
            if (cell.index == smallestdistanceindex) {
                [cell highlight];
            } else /* if (cell.index - 1 == smallestdistanceindex) */ {
                [cell unhighlight];
            }
        }
    }

    - (void) fetchLyricsForSong:(NSString*)song {
        self.lyrics = NULL;
        // [self broadcastText: @"Loading..."];

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
                    [self.tableView reloadData];
			    });
    	    }];
		    [dataTask resume];
	    });
    }

    - (void) showNoLyricsAvailable {
        NSMutableArray *items = [NSMutableArray array];
        NSDictionary *dict = @{ @"lyrics": @"No lyrics available", @"seconds": [NSNumber numberWithDouble: 1.0] };
        [items addObject: dict];

        self.lyrics = items;

        [self.tableView reloadData];
    }

    // Reload metadata every 5 seconds to show artwork, if the playing app took longer to load it
    - (void) reloadMetadata {
        [self performSelector: @selector(reloadMetadata) withObject: NULL afterDelay: 5.0];

        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
			NSDictionary *info = (__bridge NSDictionary*) information;

            [self updateMetadataWithInfo: info];
        });
    }

    - (void) updateMetadataWithInfo:(NSDictionary*)info {
        self.artworkImageView.image = [[UIImage alloc] initWithData: (NSData*) [info objectForKey: @"kMRMediaRemoteNowPlayingInfoArtworkData"]];
        self.songNameLabel.text = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoTitle"];
        self.songArtistLabel.text = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoArtist"];
    }

    - (void) viewDidAppear:(BOOL)animated {
        [super viewDidAppear: animated];

        if (self.artworkImageView) {
            return;
        }

        [self setupView];
        [self start];
    }

@end
