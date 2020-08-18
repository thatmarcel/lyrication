#import "SpotifyInterfaces.h"

%hook SPTLyricsV2LyricsView

- (void) setHidden:(BOOL)hidden {
	%orig(NO);
}

- (void) setAlpha:(double)alpha {
	%orig(1.0);
}

%end

%hook SPTLyricsV2Service

-(BOOL) lyricsAvailableForTrack:(id)arg1 {
	return YES;
}

-(void) fetchForTrack:(id)arg1 imageURL:(id)arg2 completion:(void (^)(SPTLyricsV2Model*))arg3 {
	%orig;
}

%end

%hook SPTLyricsV2TestManagerImplementation

- (BOOL) isFeatureEnabled {
	return YES;
}

%end

%hook SPTLyricsV2TextView

- (void) setHidden:(BOOL)hidden {
	%orig(YES);
}

- (void) setAlpha:(double)alpha {
	%orig(0.0);
}

%end

%hook SPTLyricsV2ErrorView

- (void) setHidden:(BOOL)hidden {
	%orig(YES);
}

- (void) setAlpha:(double)alpha {
	%orig(0.0);
}

%end
