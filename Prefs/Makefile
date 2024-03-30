ARCHS = arm64 arm64e

ifeq ($(THEOS_PACKAGE_SCHEME), rootless)
	TARGET := iphone:clang:latest:15.0
	TARGET_OS_DEPLOYMENT_VERSION = 15.0
	SYSROOT=$(THEOS)/sdks/iPhoneOS15.6.sdk
	SDKVERSION = 15.6
	INCLUDE_SDKVERSION = 15.6
else
	TARGET := iphone:clang:latest:10.0
	TARGET_OS_DEPLOYMENT_VERSION = 10.0
	OLDER_XCODE_PATH=/Applications/Xcode_11.7.app
	PREFIX=$(OLDER_XCODE_PATH)/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/
	SYSROOT=$(THEOS)/sdks/iPhoneOS13.7.sdk
	SDKVERSION = 13.7
	INCLUDE_SDKVERSION = 13.7
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LyricationPrefs

$(BUNDLE_NAME)_FILES = $(wildcard *.m)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS += UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS += Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS += CepheiPrefs Cephei
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Wno-c++11-extensions

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)