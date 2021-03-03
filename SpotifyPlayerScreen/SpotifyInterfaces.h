@interface SPTNowPlayingCoverArtCell : UIView
@end

@interface SPTNowPlayingCoverArtImageView : UIView
@end

@interface SPTLyricsV2TextView : UITextView
@end

@interface SPTLyricsV2Colors : NSObject
	- (SPTLyricsV2Colors*) initWithActiveColor:(UIColor*)arg1 brightColor:(UIColor*)arg2 darkColor:(UIColor*)arg3;
@end

@interface SPTLyricsLineSet : NSObject
	- (SPTLyricsLineSet*) initWithDictionary:(NSDictionary*)arg1;
@end

@interface SPTLyricsV2Model : NSObject
	- (SPTLyricsV2Model*) initWithDictionary:(NSDictionary*)arg1;
@end

@interface SPTPlayerTrack : NSObject
	- (NSString*) artistName;
	- (NSString*) trackTitle;
@end

@interface SPTPlayerState
	- (BOOL) isPlaying;
	- (BOOL) isPaused;
	- (SPTPlayerTrack*) track;

    - (double) position;
@end

@interface SPTPlayerImpl : NSObject
	- (SPTPlayerState*) state;

	- (void) play;
	- (void) pause;
@end

@interface SPTNowPlayingToggleViewController : UIViewController
    - (SPTPlayerImpl*) player;
@end

@interface SPTLyricsV2LyricsView : UIView
	- (id) addLabelWithTopAnchor:(NSLayoutYAxisAnchor*)topAnchor bottomAnchor:(NSLayoutYAxisAnchor*)bottomAnchor leftAnchor:(NSLayoutXAxisAnchor*)leftAnchor rightAnchor:(NSLayoutXAxisAnchor*)rightAnchor centerYAnchor:(NSLayoutYAxisAnchor*)centerYAnchor;

	- (void) lxLongPressRecognized:(UIGestureRecognizer*)sender;
@end