include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PokemonGoTransport
PokemonGoTransport_FILES = Tweak.xm
PokemonGoTransport_FRAMEWORKS = UIKit CoreLocation
ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 pokemongo"
