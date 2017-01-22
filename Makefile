export THEOS_DEVICE_IP = 192.168.2.12

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PokemonGoTransport
PokemonGoTransport_FILES = Tweak.xm
PokemonGoTransport_FRAMEWORKS = UIKit CoreLocation
ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 pokemongo"
