SDKVERSION = 11.4
SYSROOT = $(THEOS)/sdks/iPhoneOS11.4.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += FetchingAgent
SUBPROJECTS += SpotifyPlayerScreen
SUBPROJECTS += ControlCenterModule
SUBPROJECTS += LockscreenButton
SUBPROJECTS += MultiplaWidget
SUBPROJECTS += FloatingOverlay
SUBPROJECTS += Prefs

include $(THEOS_MAKE_PATH)/aggregate.mk