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

TWEAK_NAME = LyricationFetchingAgent

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-module-import-in-extern-c
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
