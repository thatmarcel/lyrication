SDKVERSION = 13.5
SYSROOT = /opt/theos/sdks/iPhoneOS13.5.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LyricationFloatingOverlay

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk