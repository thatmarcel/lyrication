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

THEOS_USE_PARALLEL_BUILDING = 0

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += FetchingAgent
SUBPROJECTS += SpotifyPlayerScreen
SUBPROJECTS += ControlCenterModule
SUBPROJECTS += LockscreenButton
SUBPROJECTS += MultiplaWidget
SUBPROJECTS += FloatingOverlay
SUBPROJECTS += Prefs

include $(THEOS_MAKE_PATH)/aggregate.mk

# The version of libroot included with Theos is not compatible
# with the arm64e ABI we use so we have to compile it ourselves
# (this might soon be unnecessary: https://github.com/opa334/libroot/commit/48e76f29f22a40ab2866b55c0d8f14baa0a4335e)
before-all::
    cd libroot && git apply -q ../libroot.patch || :