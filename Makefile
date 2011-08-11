THEOS_DEVICE_IP=192.168.1.23
GO_EASY_ON_ME=1
include theos/makefiles/common.mk

TWEAK_NAME = Hood
Hood_FILES = Tweak.xm
Hood_LDFLAGS = -lactivator
Hood_FRAMEWORKS = UIKit CoreGraphics
include $(THEOS_MAKE_PATH)/tweak.mk
