include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LyricationLockscreenButton

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard ../ScrollingLyricsViewController/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
