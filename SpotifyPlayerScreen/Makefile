include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LyricationSpotifyPlayerScreen

$(TWEAK_NAME)_FILES = EnableSpotifyLyricsView.xm TweakV2.xm $(wildcard ../ScrollingLyricsViewController/*.m) $(wildcard ../ScrollingLyricsViewController/*.xm)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
