SDKVERSION = 11.4
SYSROOT = $(THEOS)/sdks/iPhoneOS11.4.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LyricationFetchingAgent

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
