#import "LXScrollingLyricsViewController.h"
#import "LXScrollingLyricsViewController+TableViewDataSource.h"

@implementation LXScrollingLyricsViewController
    @synthesize artworkImageView;
    @synthesize visualEffectView;
    @synthesize songNameLabel;
    @synthesize songArtistLabel;
    @synthesize tableView;
    @synthesize lyrics;
    @synthesize lastSong;
    @synthesize playbackProgress;
    @synthesize lastIndex;
    @synthesize shouldHideNameAndArtist;
    @synthesize highlightedLineColor;
    @synthesize standardLineColor;
    @synthesize shouldHideBackground;
    @synthesize metadataTimer;
    @synthesize lyricsTimer;
    @synthesize staticLyricsTextView;

    - (BOOL) _canShowWhileLocked {
        return true;
    }

    - (void) setupView {
        self.view.backgroundColor = [UIColor whiteColor];

        self.artworkImageView = [[UIImageView alloc] init];
        self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.artworkImageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view insertSubview: self.artworkImageView atIndex: 0];
        [self.artworkImageView lxFillSuperview];

        if (self.shouldHideBackground) {
            self.artworkImageView.hidden = true;
        } else {
            UIVisualEffect *effect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleExtraLight];

            self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect: effect];
            self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false;
            [self.artworkImageView addSubview: self.visualEffectView];
            [self.visualEffectView lxFillSuperview];
        }

        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.songNameLabel.numberOfLines = 1;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.songNameLabel setFont: [UIFont systemFontOfSize: 56 weight: UIFontWeightBlack]];
        } else {
            [self.songNameLabel setFont: [UIFont systemFontOfSize: 42 weight: UIFontWeightBlack]];
        }
        [self.songNameLabel setTextColor: [UIColor blackColor]];
        [self.view addSubview: self.songNameLabel];
        [self.songNameLabel.topAnchor constraintEqualToAnchor: self.view.topAnchor constant: 32].active = YES;
        [self.songNameLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.songNameLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -32].active = YES;

        self.songNameLabel.minimumScaleFactor = 0.8;
        self.songNameLabel.adjustsFontSizeToFitWidth = true;

        self.songArtistLabel = [[UILabel alloc] init];
        self.songArtistLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.songArtistLabel.numberOfLines = 1;
        [self.songArtistLabel setFont: [UIFont systemFontOfSize: 26 weight: UIFontWeightHeavy]];
        [self.songArtistLabel setTextColor: [[UIColor blackColor] colorWithAlphaComponent: 0.8]];
        [self.view addSubview: self.songArtistLabel];
        [self.songArtistLabel.topAnchor constraintEqualToAnchor: self.songNameLabel.bottomAnchor constant: 2].active = YES;
        [self.songArtistLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.songArtistLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -32].active = YES;

        self.tableView = [[UITableView alloc] init];
        self.tableView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview: self.tableView];
        [self.tableView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 0].active = YES;
        [self.tableView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.tableView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: 0].active = YES;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass: LXLyricsTableViewCell.class forCellReuseIdentifier: @"LXLyricsTableViewCell"];
        [self.tableView setContentInset: UIEdgeInsetsMake(0, 0, 32, 0)];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 90;
        self.tableView.showsHorizontalScrollIndicator = false;
        self.tableView.showsVerticalScrollIndicator = false;

        self.staticLyricsTextView = [[UITextView alloc] init];
        self.staticLyricsTextView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview: self.staticLyricsTextView];
        [self.staticLyricsTextView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 0].active = YES;
        [self.staticLyricsTextView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 0].active = YES;
        [self.staticLyricsTextView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: 0].active = YES;
        self.staticLyricsTextView.text = @"";
        self.staticLyricsTextView.editable = false;
        self.staticLyricsTextView.selectable = false;
        self.staticLyricsTextView.backgroundColor = [UIColor clearColor];
        [self.staticLyricsTextView setFont: [UIFont systemFontOfSize: 20]];
        [self.staticLyricsTextView setTextColor: [[UIColor blackColor] colorWithAlphaComponent: 0.8]];
        [self.staticLyricsTextView setContentInset: UIEdgeInsetsMake(0, 32, 32, 32)];
        self.staticLyricsTextView.showsHorizontalScrollIndicator = false;
        self.staticLyricsTextView.showsVerticalScrollIndicator = false;

        self.tableView.hidden = true;
        self.staticLyricsTextView.hidden = true;

        if (shouldHideNameAndArtist) {
            self.songNameLabel.hidden = true;
            self.songArtistLabel.hidden = true;
            [self.tableView.topAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 32].active = YES;
            [self.staticLyricsTextView.topAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 32].active = YES;
        } else {
            [self.tableView.topAnchor constraintEqualToAnchor: self.songArtistLabel.bottomAnchor constant: 8].active = YES;
            [self.staticLyricsTextView.topAnchor constraintEqualToAnchor: self.songArtistLabel.bottomAnchor constant: 8].active = YES;
        }

        if (!self.highlightedLineColor) {
            self.highlightedLineColor = [UIColor blackColor];
        }

        if (!self.standardLineColor) {
            self.standardLineColor = [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.7];
        }
    }

    - (void) fetchStaticLyricsForSong:(NSString*)song {
        self.staticLyricsTextView.text = @"Loading...";

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	    dispatch_async(queue, ^{
		    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    	    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
		    NSString *query = [song stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://api.textyl.co/api/staticlyrics?q=%@", query]];
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

                    NSString *staticLyrics = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

                    self.staticLyricsTextView.text = staticLyrics;
                    self.staticLyricsTextView.scrollEnabled = false;
                    self.staticLyricsTextView.scrollEnabled = true;
                });
            }];
            [dataTask resume];
        });
    }

    - (void) start {
        [self fire];
        self.lyricsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2
                 target: self
                 selector: @selector(fire)
                 userInfo: nil
                 repeats: true];

        [self reloadMetadata];
        self.metadataTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                 target: self
                 selector: @selector(reloadMetadata)
                 userInfo: nil
                 repeats: true];
    }

    - (void) fire {
        [self fetchCurrentPlayback];

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
            self.playbackProgress = timeInterval + 0.4;

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

            self.lastIndex = -1;
            [self fetchLyricsForSong: infoTitle byArtist: infoArtist];
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

        [self.tableView beginUpdates];

        for (LXLyricsTableViewCell* cell in [self.tableView visibleCells]) {
            if (cell.index == smallestdistanceindex) {
                [cell highlight];
            } else /* if (cell.index - 1 == smallestdistanceindex) */ {
                [cell unhighlight];
            }
        }

        [self.tableView endUpdates];

        [UIView animateWithDuration: 0.4 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                [self.tableView
                    scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: smallestdistanceindex inSection: 0]
                    atScrollPosition: UITableViewScrollPositionTop
                    animated: true];
            }
            completion:^(BOOL finished){
                // [self.tableView endUpdates];
            }];
    }

    - (void) fetchLyricsForSong:(NSString*)song byArtist:(NSString*)artist {
        self.lyrics = NULL;
        // [self broadcastText: @"Loading..."];

        self.tableView.hidden = false;
        self.staticLyricsTextView.hidden = true;

        [self fetchStaticLyricsForSong: [NSString stringWithFormat: @"%@%@%@",  song, @" ", artist]];

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

                    self.tableView.hidden = false;
                    self.staticLyricsTextView.hidden = true;

	                [self setLyrics: items];
                    [self.tableView reloadData];
                    [self updateLyricsForProgress: self.playbackProgress];
                    [self.tableView reloadData];
			    });
    	    }];
		    [dataTask resume];
	    });
    }

    - (void) showNoLyricsAvailable {
        NSMutableArray *items = [NSMutableArray array];
        NSDictionary *dict = @{ @"lyrics": @"Loading...", @"seconds": [NSNumber numberWithDouble: 1.0] };
        [items addObject: dict];

        self.lyrics = items;

        [self.tableView reloadData];

        self.tableView.hidden = true;
        self.staticLyricsTextView.hidden = false;
    }

    // Reload metadata every 5 seconds to show artwork, if the playing app took longer to load it
    - (void) reloadMetadata {
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

    - (void) viewWillAppear:(BOOL)animated {
        [super viewWillAppear: animated];

        if (self.artworkImageView) {
            return;
        }

        [self setupView];
        [self start];
    }

    - (void) viewDidDisappear:(BOOL)animated {
        [super viewDidDisappear: animated];

        [self.lyricsTimer invalidate];
        [self.metadataTimer invalidate];
        self.lyricsTimer = nil;
        self.metadataTimer = nil;

        if (self.presenter && self.presenter.overlayWindow) {
            [self.presenter.overlayViewController dismissViewControllerAnimated: false completion: nil];
            self.presenter.overlayWindow.hidden = true;
            self.presenter.overlayWindow = nil;
            self.presenter.overlayViewController = nil;
        }
    }

@end
