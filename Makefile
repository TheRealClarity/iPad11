ARCHS = arm64
TARGET = iphone:clang:11.2:10.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ipad11
FINALPACKAGE = 1
ipad11_FILES = Tweak.xm
ipad11_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk