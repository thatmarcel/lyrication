SDKVERSION = 11.2
SYSROOT = /opt/theos/sdks/iPhoneOS11.2.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = FetchingAgent SpotifyPlayerScreen ControlCenterModule

include $(THEOS_MAKE_PATH)/aggregate.mk
