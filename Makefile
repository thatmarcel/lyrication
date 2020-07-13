SDKVERSION = 11.2
SYSROOT = /opt/theos/sdks/iPhoneOS11.2.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Lyrication

$(TWEAK_NAME)_FILES = EnableSpotifyLyricsView.xm TweakV2.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
	
include $(THEOS_MAKE_PATH)/tweak.mk
