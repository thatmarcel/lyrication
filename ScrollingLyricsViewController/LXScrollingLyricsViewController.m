#import "LXScrollingLyricsViewController.h"
#import "LXScrollingLyricsViewController+TableViewDataSource.h"
#import "LXScrollingLyricsViewController+TableViewDelegate.h"

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
    @synthesize updatesPaused;
    @synthesize closeButton;
    @synthesize preferences;
    @synthesize shouldScrollLineToMiddle;
    @synthesize lyricsViewsContainerGradientLayer;
    @synthesize lyricsViewsContainer;
    @synthesize shouldShowSyncedLyrics;

    - (BOOL) _canShowWhileLocked {
        return true;
    }

    - (void) setupView {
        self.preferences = [[HBPreferences alloc] initWithIdentifier: @"com.thatmarcel.tweaks.lyrication.hbprefs"];
        [preferences registerDefaults: @{
            @"expandedviewshowclosebutton": @false,
            @"expandedviewcenterstyle": @false,
            @"expandedviewshowsongname": @true,
            @"expandedviewshowsongartist": @true,
            @"expandedviewfadeoutgradient": @true,
            @"expandedviewsynced": @true
        }];

        BOOL shouldShowCloseButton = [preferences boolForKey: @"expandedviewshowclosebutton"];
        self.shouldScrollLineToMiddle = [preferences boolForKey: @"expandedviewcenterstyle"];

        BOOL shouldShowSongName = [preferences boolForKey: @"expandedviewshowsongname"];
        BOOL shouldShowSongArtist = [preferences boolForKey: @"expandedviewshowsongartist"];

        BOOL shouldShowFadeoutGradient = [preferences boolForKey: @"expandedviewfadeoutgradient"];

        self.shouldShowSyncedLyrics = [preferences boolForKey: @"expandedviewsynced"];

        if (@available(iOS 13, *)) { } else {
            shouldShowCloseButton = true;
        }

        self.view.backgroundColor = [UIColor whiteColor];

        self.artworkImageView = [[UIImageView alloc] init];
        self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.artworkImageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view insertSubview: self.artworkImageView atIndex: 0];
        [self.artworkImageView lxFillSuperview];

        if (self.shouldHideBackground) {
            self.artworkImageView.hidden = true;
        } else {
            UIVisualEffect *effect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleSystemChromeMaterial];

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
        if (@available(iOS 13, *)) {
            [self.songNameLabel setTextColor: [UIColor labelColor]];
        } else {
            [self.songNameLabel setTextColor: [UIColor blackColor]];
        }
        [self.view addSubview: self.songNameLabel];
        [self.songNameLabel.topAnchor constraintEqualToAnchor: self.view.topAnchor constant: 32].active = YES;
        [self.songNameLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.songNameLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -32 - (shouldShowCloseButton ? 50 : 0)].active = YES;

        if (!shouldShowSongName) {
            [self.songNameLabel.heightAnchor constraintEqualToConstant: 0].active = YES;
        }

        self.songNameLabel.minimumScaleFactor = 0.8;
        self.songNameLabel.adjustsFontSizeToFitWidth = true;

        self.songArtistLabel = [[UILabel alloc] init];
        self.songArtistLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.songArtistLabel.numberOfLines = 1;
        [self.songArtistLabel setFont: [UIFont systemFontOfSize: 26 weight: UIFontWeightHeavy]];
        [self.songArtistLabel setTextColor: [[UIColor blackColor] colorWithAlphaComponent: 0.8]];
        if (@available(iOS 13, *)) {
            [self.songArtistLabel setTextColor: [[UIColor labelColor] colorWithAlphaComponent: 0.8]];
        } else {
            [self.songArtistLabel setTextColor: [[UIColor blackColor] colorWithAlphaComponent: 0.8]];
        }
        [self.view addSubview: self.songArtistLabel];
        [self.songArtistLabel.topAnchor constraintEqualToAnchor: self.songNameLabel.bottomAnchor constant: 0].active = YES;
        [self.songArtistLabel.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 32].active = YES;
        [self.songArtistLabel.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -32 - (shouldShowCloseButton ? 50 : 0)].active = YES;

        if (!shouldShowSongArtist) {
            [self.songArtistLabel.heightAnchor constraintEqualToConstant: 0].active = YES;
        }

        self.lyricsViewsContainer = [[UIView alloc] init];
        self.lyricsViewsContainer.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview: self.lyricsViewsContainer];
        [self.lyricsViewsContainer.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 0].active = YES;
        [self.lyricsViewsContainer.leftAnchor constraintEqualToAnchor: self.view.leftAnchor constant: 0].active = YES;
        [self.lyricsViewsContainer.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: 0].active = YES;

        self.tableView = [[UITableView alloc] init];
        self.tableView.translatesAutoresizingMaskIntoConstraints = false;
        [self.lyricsViewsContainer addSubview: self.tableView];
        [self.tableView.topAnchor constraintEqualToAnchor: self.lyricsViewsContainer.topAnchor constant: 0].active = YES;
        [self.tableView.bottomAnchor constraintEqualToAnchor: self.lyricsViewsContainer.bottomAnchor constant: 0].active = YES;
        [self.tableView.leftAnchor constraintEqualToAnchor: self.lyricsViewsContainer.leftAnchor constant: 32].active = YES;
        [self.tableView.rightAnchor constraintEqualToAnchor: self.lyricsViewsContainer.rightAnchor constant: 0].active = YES;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass: LXLyricsTableViewCell.class forCellReuseIdentifier: @"LXLyricsTableViewCell"];
        [self.tableView setContentInset: UIEdgeInsetsMake(shouldShowFadeoutGradient ? 8 : 0, 0, 32, 0)];
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 300;
        self.tableView.showsHorizontalScrollIndicator = false;
        self.tableView.showsVerticalScrollIndicator = false;

        self.staticLyricsTextView = [[UITextView alloc] init];
        self.staticLyricsTextView.translatesAutoresizingMaskIntoConstraints = false;
        [self.lyricsViewsContainer addSubview: self.staticLyricsTextView];
        [self.staticLyricsTextView.topAnchor constraintEqualToAnchor: self.lyricsViewsContainer.topAnchor constant: 0].active = YES;
        [self.staticLyricsTextView.bottomAnchor constraintEqualToAnchor: self.lyricsViewsContainer.bottomAnchor constant: 0].active = YES;
        [self.staticLyricsTextView.leftAnchor constraintEqualToAnchor: self.lyricsViewsContainer.leftAnchor constant: 0].active = YES;
        [self.staticLyricsTextView.rightAnchor constraintEqualToAnchor: self.lyricsViewsContainer.rightAnchor constant: 0].active = YES;
        self.staticLyricsTextView.text = @"";
        self.staticLyricsTextView.editable = false;
        self.staticLyricsTextView.selectable = false;
        self.staticLyricsTextView.backgroundColor = [UIColor clearColor];
        [self.staticLyricsTextView setFont: [UIFont systemFontOfSize: 20]];
        if (@available(iOS 13, *)) {
            [self.staticLyricsTextView setTextColor: [[UIColor labelColor] colorWithAlphaComponent: 0.8]];
        } else {
            [self.staticLyricsTextView setTextColor: [[UIColor blackColor] colorWithAlphaComponent: 0.8]];
        }
        [self.staticLyricsTextView setContentInset: UIEdgeInsetsMake(shouldShowFadeoutGradient ? 16 : 0, 32, 32, 32)];
        self.staticLyricsTextView.showsHorizontalScrollIndicator = false;
        self.staticLyricsTextView.showsVerticalScrollIndicator = false;

        self.tableView.hidden = true;
        self.staticLyricsTextView.hidden = true;

        if (shouldHideNameAndArtist) {
            self.songNameLabel.hidden = true;
            self.songArtistLabel.hidden = true;
            [self.lyricsViewsContainer.topAnchor constraintEqualToAnchor: self.view.bottomAnchor constant: 32].active = YES;
        } else {
            [self.lyricsViewsContainer.topAnchor constraintEqualToAnchor: self.songArtistLabel.bottomAnchor constant: 8].active = YES;
        }

        if (!self.highlightedLineColor) {
            if (@available(iOS 13, *)) {
                self.highlightedLineColor = [UIColor labelColor];
            } else {
                self.highlightedLineColor = [UIColor blackColor];
            }
        }

        if (!self.standardLineColor) {
            if (@available(iOS 13, *)) {
                self.standardLineColor = [[UIColor labelColor] colorWithAlphaComponent: 0.5];
            } else {
                self.standardLineColor = [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.7];
            }
        }

        if (shouldShowCloseButton) {
            self.closeButton = [[UIButton alloc] init];
            self.closeButton.translatesAutoresizingMaskIntoConstraints = false;
            [self.view addSubview: self.closeButton];

            if (@available(iOS 13, *)) {
                UIImage *closeButtonImage = [[UIImage systemImageNamed: @"xmark" withConfiguration: [UIImageSymbolConfiguration configurationWithScale: UIImageSymbolScaleLarge]] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
                [self.closeButton setImage: closeButtonImage forState: UIControlStateNormal];
                [self.closeButton setTintColor: [UIColor labelColor]];
            } else {
                [self.closeButton setTitle: @"x" forState: UIControlStateNormal];
                [self.closeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
            }

            [self.closeButton.topAnchor constraintEqualToAnchor: self.view.topAnchor constant: 50].active = YES;
            [self.closeButton.rightAnchor constraintEqualToAnchor: self.view.rightAnchor constant: -32].active = YES;
            [self.closeButton
                addTarget: self
                action: @selector(dismiss)
                forControlEvents: UIControlEventTouchUpInside
            ];
        }

        if (shouldShowFadeoutGradient) {
            self.lyricsViewsContainerGradientLayer = [CAGradientLayer layer];
            self.lyricsViewsContainerGradientLayer.frame = self.lyricsViewsContainer.bounds;
            self.lyricsViewsContainerGradientLayer.colors = @[
                (id) [UIColor clearColor].CGColor,
                (id) [UIColor blackColor].CGColor,
                (id) [UIColor blackColor].CGColor,
                (id) [UIColor clearColor].CGColor
            ];
            self.lyricsViewsContainerGradientLayer.locations = @[
                @0.0, @0.05, @0.9, @1.0
            ];
            self.lyricsViewsContainer.layer.mask = self.lyricsViewsContainerGradientLayer;
        }
    }

    - (void) viewDidLayoutSubviews {
        [super viewDidLayoutSubviews];

        if (self.lyricsViewsContainerGradientLayer) {
            self.lyricsViewsContainerGradientLayer.frame = self.lyricsViewsContainer.bounds;
        }
    }

    - (void) fetchStaticLyricsForSong:(NSString*)song byArtist:(NSString*)artist {
        self.staticLyricsTextView.text = @"Loading...";

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	    dispatch_async(queue, ^{
		    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    	    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
		    NSString *escapedSong = [song stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString *escapedArtist = [artist stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
		    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://prv.textyl.co/api/staticlyrics?name=%@&artist=%@", escapedSong, escapedArtist]];
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
        if (self.updatesPaused) {
            return;
        }

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
            cell.distanceFromHighlighted = cell.index - smallestdistanceindex;
            if (cell.distanceFromHighlighted < 0) {
                cell.distanceFromHighlighted = 1;
            }
            
            if (cell.index == smallestdistanceindex) {
                [cell highlight];
            } else /* if (cell.index - 1 == smallestdistanceindex) */ {
                [cell unhighlight];
            }
        }

        [self.tableView endUpdates];

        [UIView animateWithDuration: 0.4 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
            animations:^{
                if (self.shouldScrollLineToMiddle) {
                    [self.tableView
                        scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: (smallestdistanceindex + ((smallestdistanceindex < [[self lyrics] count] - 1) ? 1 : 0)) inSection: 0]
                        atScrollPosition: UITableViewScrollPositionMiddle
                        animated: true];
                } else {
                    [self.tableView
                        scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: smallestdistanceindex inSection: 0]
                        atScrollPosition: UITableViewScrollPositionTop
                        animated: true];
                }
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

        [self fetchStaticLyricsForSong: song byArtist: artist];

        if (!shouldShowSyncedLyrics) {
            self.tableView.hidden = true;
            self.staticLyricsTextView.hidden = false;
            return;
        }

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
        NSString *name = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoTitle"];
        if ([[name lowercaseString] containsString: @"nightcore"]) {
            name = [name stringByReplacingOccurrencesOfString: @"Nightcore" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"nightcore" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"-" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"➥" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"|" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"「" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"」" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"◊" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"♪" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"✪" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"♫" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"↬" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"【" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"】" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"→" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"NMV" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"AMV" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"MMV" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"NV" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"LYRICS" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"Lyrics" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"lyrics" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"CLEAN" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"Clean" withString: @""];
            name = [name stringByReplacingOccurrencesOfString: @"clean" withString: @""];
            name = [name componentsSeparatedByString: @"("][0];
            name = [name componentsSeparatedByString: @"["][0];
            name = [name stringByReplacingOccurrencesOfString: @"  " withString: @" "];
            name = [name stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        self.songNameLabel.text = name;
        self.songArtistLabel.text = (NSString *) info[@"kMRMediaRemoteNowPlayingInfoArtist"];
        // stringByReplacingOccurrencesOfString
    }

    - (void) viewWillAppear:(BOOL)animated {
        [super viewWillAppear: animated];

        if (self.artworkImageView) {
            return;
        }

        [self setupView];
        [self start];

        [UIApplication sharedApplication].idleTimerDisabled = true;

        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        [userInfo setObject: @"viewWillAppear" forKey: @"event"];
        [[NSDistributedNotificationCenter defaultCenter]
            postNotificationName: @"com.thatmarcel.tweaks.lyrication/expandEvents"
            object: nil
            userInfo: userInfo
        ];
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

        [UIApplication sharedApplication].idleTimerDisabled = false;

        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        [userInfo setObject: @"viewDidDisappear" forKey: @"event"];
        [[NSDistributedNotificationCenter defaultCenter]
            postNotificationName: @"com.thatmarcel.tweaks.lyrication/expandEvents"
            object: nil
            userInfo: userInfo
        ];
    }

    - (void) dismiss {
        [self dismissViewControllerAnimated: true completion: nil];
    }

@end
