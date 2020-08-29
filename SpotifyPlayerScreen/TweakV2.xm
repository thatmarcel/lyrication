#import <UIKit/UIKit.h>
#include <CoreFoundation/CoreFoundation.h>

#import "SpotifyInterfaces.h"

#import "../ScrollingLyricsViewController/LXScrollingLyricsViewControllerPresenter.h"

LXScrollingLyricsViewControllerPresenter *presenter;

// The main class
@interface LCSTW : NSObject
    // The Spotify player
    @property (retain) SPTPlayerImpl *player;
    // The main timer
    @property (retain) NSTimer *timer;
    // The lyrics of the currently playing song or NULL if nothing is playing
    @property (retain) NSArray *lyrics;
    // The song that played on the last execution of the timer function
    @property (retain) NSString *lastSong;
    // The text view inside the lyrics card
    @property (retain) SPTLyricsV2TextView *lyricsView;
    // Indicates if the app is in background (And the tweak should pause fetching and updating lyrics)
    @property BOOL appIsInBackground;

    // The 1st label inside the bottom lyrics card
    @property (retain) UILabel *bottomLyricsCardLabel1;
    // The 2nd label inside the bottom lyrics card
    @property (retain) UILabel *bottomLyricsCardLabel2;
    // The 3rd label inside the bottom lyrics card
    @property (retain) UILabel *bottomLyricsCardLabel3;
    // The 4rd label inside the bottom lyrics card
    @property (retain) UILabel *bottomLyricsCardLabel4;

    // The center y constraint of the current lyrics label (2nd label)
    @property (retain) NSLayoutConstraint *bottomLyricsCardLabel2CenterYConstraint;

    // The bottom anchor constraint of the 1st label inside the bottom lyrics card
    @property (retain) NSLayoutConstraint *bottomLyricsCardLabel1BottomConstraint;

    // The container view of the bottom lyrics card
    @property (retain) SPTLyricsV2LyricsView *bottomLyricsCardView;

    @property (retain) NSTimer *lyricsTimer;

    // Starts the timer
    - (void) start;
    // Called every x seconds by the timer
    - (void) fire;
    // Fetch the lyrics for the currently playing song
    - (void) fetchLyricsForSong:(NSString*)song byArtist:(NSString*)artist;
    // Show a message that no lyrics are available for the currently playing song
    - (void) showNoLyricsAvailable;
    // Update the displayed lyrics (assumes lyrics != NULL)
    - (void) updateLyricsForProgress:(double)progress;
    // Set the texts of the lables, apply styles (font and color) and do line changing animations
    - (void) setLyricsTextsLine1:(NSString*)line1 line2:(NSString*)line2 line3:(NSString*)line3 line4:(NSString*)line4;
    // Set one line of text (Loading... or No lyrics available)
    - (void) setText:(NSString*)text;
@end

@implementation LCSTW
    @synthesize player;
    @synthesize timer;
    @synthesize lyrics;
    @synthesize lastSong;
    @synthesize lyricsView;
    @synthesize appIsInBackground;
    @synthesize bottomLyricsCardLabel1;
    @synthesize bottomLyricsCardLabel2;
    @synthesize bottomLyricsCardLabel3;
    @synthesize bottomLyricsCardLabel4;
    @synthesize bottomLyricsCardLabel2CenterYConstraint;
    @synthesize bottomLyricsCardView;
    @synthesize bottomLyricsCardLabel1BottomConstraint;
    @synthesize lyricsTimer;

    // Store one instance of the main class
    static LCSTW *LCSTWInstance;

    // Starts the timer
    - (void) start {
        [self fire];
        self.lyricsTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                 target: self
                 selector: @selector(fire)
                 userInfo: nil
                 repeats: true];
    }

    // Called every x seconds by the timer
    - (void) fire {
        if ([LCSTWInstance appIsInBackground] == YES) {
            return;
        }

        SPTPlayerState *state = [[self player] state];
        SPTPlayerTrack *track = [state track];

        double progress = [state position];
        BOOL isPlaying = [state isPlaying];
        NSString *artistName = [track artistName];
        NSString *trackTitle = [track trackTitle];
        NSString *song = [NSString stringWithFormat: @"%@%@%@",  trackTitle, @" ", artistName];
        NSString *savedLastSong = [self lastSong];
        [self setLastSong:song];

        if (isPlaying == NO) {
            [self setLyrics:NULL];
            return;
        }

        if ([self lyrics] != NULL && [song isEqual:savedLastSong]) {
            if ([[self lyrics] count] < 1) {
                [self showNoLyricsAvailable];
                return;
            }
            [self updateLyricsForProgress:progress + 0.3];
            return;
        } else if ([song isEqual:savedLastSong]) {
            [self showNoLyricsAvailable];
            return;
        }

        [self setLyrics:NULL];
        [self setText:@"Loading..."];
        [self fetchLyricsForSong: trackTitle byArtist: artistName];
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

        NSString *line1 = NULL;
        NSString *line2 = NULL;
        NSString *line3 = NULL;
        NSString *line4 = NULL;

		if (smallestdistanceindex > 0) {
			NSDictionary *item = [[self lyrics] objectAtIndex:smallestdistanceindex - 1];
			line1 = [item objectForKey:@"lyrics"];
		}

		NSDictionary *item = [self lyrics][smallestdistanceindex];
		line2 = [item objectForKey:@"lyrics"];

		if ([[self lyrics] count] > smallestdistanceindex + 1) {
			NSDictionary *item = [self lyrics][smallestdistanceindex + 1];
			line3 = [item objectForKey:@"lyrics"];
        }

        if ([[self lyrics] count] > smallestdistanceindex + 2) {
			NSDictionary *item = [self lyrics][smallestdistanceindex + 2];
			line4 = [item objectForKey:@"lyrics"];
        }

        [self setLyricsTextsLine1:line1 line2:line2 line3:line3 line4:line4];
    }

    - (void) setText:(NSString*)text {
        [self setLyricsTextsLine1:NULL line2:text line3:NULL line4:NULL];
    }

    - (void) setLyricsTextsLine1:(NSString*)line1 line2:(NSString*)line2 line3:(NSString*)line3 line4:(NSString*)line4 {
        [self.bottomLyricsCardLabel1 setFont:[UIFont boldSystemFontOfSize:28]];
        [self.bottomLyricsCardLabel2 setFont:[UIFont boldSystemFontOfSize:28]];
        [self.bottomLyricsCardLabel3 setFont:[UIFont boldSystemFontOfSize:28]];
        [self.bottomLyricsCardLabel4 setFont:[UIFont boldSystemFontOfSize:28]];

        [self.bottomLyricsCardLabel1 setTextColor:[UIColor whiteColor]];
        [self.bottomLyricsCardLabel2 setTextColor:[UIColor whiteColor]];
        [self.bottomLyricsCardLabel3 setTextColor:[UIColor whiteColor]];
        [self.bottomLyricsCardLabel4 setTextColor:[UIColor whiteColor]];

        self.bottomLyricsCardLabel1.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.bottomLyricsCardLabel2.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.bottomLyricsCardLabel3.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.bottomLyricsCardLabel4.transform = CGAffineTransformMakeScale(0.8, 0.8);

        if ([[bottomLyricsCardLabel2 text] isEqual:@"Loading..."] || [[bottomLyricsCardLabel2 text] isEqual:@"No lyrics available"] || line3 == NULL || line4 == NULL || [[bottomLyricsCardLabel2 text] isEqual:line2]) {
            [self.bottomLyricsCardLabel1 setText:@""];
            [self.bottomLyricsCardLabel2 setText:@""];
            [self.bottomLyricsCardLabel3 setText:@""];
            [self.bottomLyricsCardLabel4 setText:@""];

            if (line1 != NULL) { [self.bottomLyricsCardLabel1 setText:line1]; }
            if (line2 != NULL) { [self.bottomLyricsCardLabel2 setText:line2]; }
            if (line3 != NULL) { [self.bottomLyricsCardLabel3 setText:line3]; }
            if (line4 != NULL) { [self.bottomLyricsCardLabel4 setText:line4]; }

            self.bottomLyricsCardLabel1.alpha = 0.4;
            self.bottomLyricsCardLabel2.alpha = 1;
            self.bottomLyricsCardLabel3.alpha = 0.4;
            self.bottomLyricsCardLabel4.alpha = 0;

            return;
        }

        if (line2 != NULL) { [self.bottomLyricsCardLabel2 setText:line1]; }
        if (line3 != NULL) { [self.bottomLyricsCardLabel3 setText:line2]; }
        if (line4 != NULL) { [self.bottomLyricsCardLabel4 setText:line3]; }

        [UIView animateWithDuration:0.3
            animations:^{
                self.bottomLyricsCardLabel2CenterYConstraint.active = NO;
                self.bottomLyricsCardLabel2CenterYConstraint = [self.bottomLyricsCardLabel3.centerYAnchor
                                                                    constraintEqualToAnchor:self.bottomLyricsCardView.centerYAnchor];
                self.bottomLyricsCardLabel2CenterYConstraint.active = YES;

                self.bottomLyricsCardLabel1.alpha = 0;
                self.bottomLyricsCardLabel2.alpha = 0.4;
                self.bottomLyricsCardLabel3.alpha = 1.0;
                self.bottomLyricsCardLabel4.alpha = 0.4;

                self.bottomLyricsCardLabel2.transform = CGAffineTransformMakeScale(0.8, 0.8);
                self.bottomLyricsCardLabel3.transform = CGAffineTransformMakeScale(1.0, 1.0);

                [self.bottomLyricsCardView layoutIfNeeded];
            }
            completion:^(BOOL finished){
                if (!finished) { return; }

                UILabel *oldLabel = self.bottomLyricsCardLabel1;

                self.bottomLyricsCardLabel1 = self.bottomLyricsCardLabel2;
                self.bottomLyricsCardLabel2 = self.bottomLyricsCardLabel3;
                self.bottomLyricsCardLabel3 = self.bottomLyricsCardLabel4;

                self.bottomLyricsCardLabel4 = [self.bottomLyricsCardView addLabelWithTopAnchor:self.bottomLyricsCardLabel3.bottomAnchor bottomAnchor:NULL leftAnchor:self.bottomLyricsCardView.leftAnchor rightAnchor:self.bottomLyricsCardView.rightAnchor centerYAnchor:NULL];
                [self.bottomLyricsCardLabel4 setAlpha:0];

                [oldLabel removeFromSuperview];

                if (line1 != NULL) { [self.bottomLyricsCardLabel1 setText:line1]; }
            }];
    }

    - (void) showNoLyricsAvailable {
        [self setText:@"No lyrics available"];
    }

    - (void) fetchLyricsForSong:(NSString*)song byArtist:(NSString*)artist {
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
@end

%hook UIApplicationDelegate

-(void)applicationWillEnterForeground:(id)arg1 {
	%orig;

	if (LCSTWInstance != NULL) {
        [LCSTWInstance setAppIsInBackground:NO];
    }
}

-(void)applicationDidEnterBackground:(id)arg1 {
    %orig;

	if (LCSTWInstance != NULL) {
        [LCSTWInstance setAppIsInBackground:YES];
    }
}

%end

BOOL addedBottomLyricsCardLabel = NO;

%hook SPTLyricsV2LyricsView

%new
- (UILabel*) addLabelWithTopAnchor:(NSLayoutYAxisAnchor*)topAnchor bottomAnchor:(NSLayoutYAxisAnchor*)bottomAnchor leftAnchor:(NSLayoutXAxisAnchor*)leftAnchor rightAnchor:(NSLayoutXAxisAnchor*)rightAnchor centerYAnchor:(NSLayoutYAxisAnchor*)centerYAnchor {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];

    if (topAnchor != NULL) {
        [label.topAnchor constraintEqualToAnchor:topAnchor constant:16].active = YES;
    }
    if (leftAnchor != NULL) {
        [label.leftAnchor constraintEqualToAnchor:leftAnchor].active = YES;
    }
    if (rightAnchor != NULL) {
        [label.rightAnchor constraintEqualToAnchor:rightAnchor].active = YES;
    }
    if (bottomAnchor != NULL) {
        LCSTWInstance.bottomLyricsCardLabel1BottomConstraint = [label.bottomAnchor constraintEqualToAnchor:bottomAnchor constant:-16];
        LCSTWInstance.bottomLyricsCardLabel1BottomConstraint.active = YES;
    }
    if (centerYAnchor != NULL) {
        LCSTWInstance.bottomLyricsCardLabel2CenterYConstraint = [label.centerYAnchor constraintEqualToAnchor:centerYAnchor];
        LCSTWInstance.bottomLyricsCardLabel2CenterYConstraint.active = YES;
    }

    [self bringSubviewToFront:label];

    return label;
}

- (void) layoutSubviews {
    %orig;

    if (addedBottomLyricsCardLabel) {
        return;
    }

    addedBottomLyricsCardLabel = YES;

    UILabel *label2 = [self addLabelWithTopAnchor:NULL bottomAnchor:NULL leftAnchor:self.leftAnchor rightAnchor:self.rightAnchor centerYAnchor:self.centerYAnchor];
    [LCSTWInstance setBottomLyricsCardLabel2:label2];

    UILabel *label1 = [self addLabelWithTopAnchor:NULL bottomAnchor:label2.topAnchor leftAnchor:self.leftAnchor rightAnchor:self.rightAnchor centerYAnchor:NULL];
    [LCSTWInstance setBottomLyricsCardLabel1:label1];

    UILabel *label3 = [self addLabelWithTopAnchor:label2.bottomAnchor bottomAnchor:NULL leftAnchor:self.leftAnchor rightAnchor:self.rightAnchor centerYAnchor:NULL];
    [LCSTWInstance setBottomLyricsCardLabel3:label3];

    UILabel *label4 = [self addLabelWithTopAnchor:label3.bottomAnchor bottomAnchor:NULL leftAnchor:self.leftAnchor rightAnchor:self.rightAnchor centerYAnchor:NULL];
    [label4 setAlpha:0];
    [LCSTWInstance setBottomLyricsCardLabel4:label4];

    [LCSTWInstance setBottomLyricsCardView:self];

    UIButton *fullLyricsButton = [[UIButton alloc] init];
    fullLyricsButton.translatesAutoresizingMaskIntoConstraints = false;

    [fullLyricsButton setTitle: @"Expand" forState: UIControlStateNormal];

    fullLyricsButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.9];
    [fullLyricsButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];

    fullLyricsButton.layer.masksToBounds = true;
    fullLyricsButton.layer.cornerRadius = 8;

    if (fullLyricsButton.titleLabel) {
        fullLyricsButton.titleLabel.font = [UIFont systemFontOfSize: 16.0 weight: UIFontWeightBold];
    }

    [self addSubview: fullLyricsButton];

    [fullLyricsButton.heightAnchor constraintEqualToConstant: 30].active = YES;
    [fullLyricsButton.widthAnchor constraintEqualToConstant: 90].active = YES;
    [fullLyricsButton.bottomAnchor constraintEqualToAnchor: self.bottomAnchor constant: -16].active = YES;
    [fullLyricsButton.rightAnchor constraintEqualToAnchor: self.superview.rightAnchor constant: -24].active = YES;

    [fullLyricsButton
        addTarget: presenter
        action: @selector(present)
        forControlEvents: UIControlEventTouchUpInside
    ];
}

%end

%ctor {
    // Initialize the instance of the main class
    LCSTWInstance = [[LCSTW alloc] init];
    [LCSTWInstance setAppIsInBackground:NO];
    [LCSTWInstance start];
}

%hook SPTNowPlayingToggleViewController

- (void) viewDidLoad {
    %orig;

    // Store a reference to the player used by the Spotify app to be able to get playback / control volume etc
    [LCSTWInstance setPlayer:[self player]];

    presenter = [[LXScrollingLyricsViewControllerPresenter alloc] init];
}

%end
