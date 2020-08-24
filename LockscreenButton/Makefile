include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LyricationLockscreenButton

$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard ../ScrollingLyricsViewController/*.m) $(wildcard ../ScrollingLyricsViewController/*.xm)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/HWPanModal.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Animator/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Animator/PresentingVCAnimation/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Category/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Controller/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Delegate/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/KVO/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Mediator/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Presentable/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/Presenter/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/View/*.m)
$(TWEAK_NAME)_FILES += $(wildcard ../ScrollingLyricsViewController/HWPanModal/View/PanModal/*.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
