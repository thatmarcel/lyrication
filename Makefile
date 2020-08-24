SDKVERSION = 11.2
SYSROOT = /opt/theos/sdks/iPhoneOS11.2.sdk
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += FetchingAgent
SUBPROJECTS += SpotifyPlayerScreen
SUBPROJECTS += ControlCenterModule
SUBPROJECTS += LockscreenButton
SUBPROJECTS += MultiplaWidget

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"
