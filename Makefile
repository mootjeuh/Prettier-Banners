TWEAK_NAME = PrettierBanners

PrettierBanners_FILES = main.xm
PrettierBanners_FRAMEWORKS = UIKit CoreGraphics AddressBook

export TARGET = iphone:clang
export ARCHS = armv7 armv7s arm64
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.1
export SDKVERSION = 8.1
export ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"