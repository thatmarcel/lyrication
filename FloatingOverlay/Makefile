SDKVERSION = 13.7
SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LyricationFloatingOverlay

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.m) $(wildcard ActivatorSupport/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk