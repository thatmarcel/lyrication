export ARCHS = arm64 armv7 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LyricationMultiplaModuleBundle

$(BUNDLE_NAME)_BUNDLE_EXTENSION = bundle
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_FILES = $(wildcard *.m) $(wildcard *.xm)
$(BUNDLE_NAME)_INSTALL_PATH = /Library/Multipla/Widgets/

include $(THEOS_MAKE_PATH)/bundle.mk
