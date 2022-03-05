SDKVERSION = 13.7
SYSROOT = $(THEOS)/sdks/iPhoneOS13.7.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LyricationControlCenterModuleBundle

$(BUNDLE_NAME)_BUNDLE_EXTENSION = bundle
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Iheaders
$(BUNDLE_NAME)_FILES = $(wildcard *.m) $(wildcard *.xm)
$(BUNDLE_NAME)_LDFLAGS = Frameworks/ControlCenterUIKit.tbd
$(BUNDLE_NAME)_INSTALL_PATH = /Library/ControlCenter/Bundles/

include $(THEOS_MAKE_PATH)/bundle.mk
