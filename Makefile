############################################################################
# The MIT License (MIT)
#
# Copyright (c) 2018 Bertrand Martel
#
############################################################################
#title         : Makefile
#author        : Bertrand Martel
#date          : 30/09/2018
#description   : Makefile for Arduino
############################################################################
RFDUINO_DIR=./avr
TOOLCHAIN_DIR=./toolchain/avr
TOOLCHAIN_BINDIR=$(TOOLCHAIN_DIR)/bin
AVRDUDE_DIR=./avrdude/avrdude
AVRDUDE_BINDIR=$(AVRDUDE_DIR)/bin
ARDUINO_PATH=avr/cores/arduino
CXX=$(TOOLCHAIN_BINDIR)/avr-g++
CC=$(TOOLCHAIN_BINDIR)/avr-gcc
AR=$(TOOLCHAIN_BINDIR)/avr-gcc-ar
ELF=$(CC)
OBJCOPY=$(TOOLCHAIN_BINDIR)/avr-objcopy
AVRDUDE=$(AVRDUDE_BINDIR)/avrdude
AVRDUDE_CONF=$(AVRDUDE_DIR)/etc/avrdude.conf

FREQ_CPU=16000000L
MCU=atmega328p
CXX_FLAGS+=-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto
CC_FLAGS+=-c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects
ELF_FLAGS+=-w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=$(MCU)

EXTRA_FLAGS=-DARDUINO=10805 -DARDUINO_ARCH_AVR -mmcu=$(MCU) -DF_CPU=$(FREQ_CPU)

ifdef BOARD
EXTRA_FLAGS+=$(BOARD)
else
EXTRA_FLAGS+=-DARDUINO_AVR_UNO
endif

CORE_LIB=core.a
LIB_OBJECTS= $(ARDUINO_PATH)/abi.o $(ARDUINO_PATH)/HardwareSerial3.o $(ARDUINO_PATH)/new.o $(ARDUINO_PATH)/USBCore.o $(ARDUINO_PATH)/wiring_pulse.o \
		$(ARDUINO_PATH)/CDC.o $(ARDUINO_PATH)/HardwareSerial.o $(ARDUINO_PATH)/PluggableUSB.o $(ARDUINO_PATH)/WInterrupts.o $(ARDUINO_PATH)/wiring_shift.o \
		$(ARDUINO_PATH)/HardwareSerial0.o $(ARDUINO_PATH)/hooks.o $(ARDUINO_PATH)/Print.o $(ARDUINO_PATH)/wiring_analog.o $(ARDUINO_PATH)/WMath.o \
		$(ARDUINO_PATH)/HardwareSerial1.o $(ARDUINO_PATH)/IPAddress.o $(ARDUINO_PATH)/Stream.o $(ARDUINO_PATH)/wiring.o $(ARDUINO_PATH)/WString.o \
		$(ARDUINO_PATH)/HardwareSerial2.o $(ARDUINO_PATH)/Tone.o $(ARDUINO_PATH)/wiring_digital.o $(ARDUINO_PATH)/wiring_pulse.S.o

ifndef PORT
PORT=/dev/ttyACM0
endif
BAUDRATE=115200

#OBJECTS=main.o
#OBJECTS_SRC:=$(patsubst %,./%,$(OBJECTS))
OBJECTS_SRC:=$(patsubst %,../%,$(OBJECTS))
DEPENDS_SRC:=$(patsubst %.o,../%.d,$(OBJECTS))
HEADERS_SRC:=$(patsubst -I%,-I../%,$(HEADERS))

INCLUDES=-I./avr/cores/arduino \
		 -I./avr/variants/standard \
		 $(HEADERS_SRC)

$(shell bash init.sh>&2)

default: arduino_lib build upload

arduino_lib: $(LIB_OBJECTS)
	$(AR) rcs $(CORE_LIB) $^

build: target.hex

%.a: $(OBJECTS_SRC)
	$(AR) rcs $@ $^

clean:
	@echo "cleaning"
	$(shell rm $(OBJECTS_SRC) 2> /dev/null)
	$(shell rm $(DEPENDS_SRC) 2> /dev/null)
	$(shell rm *.elf 2> /dev/null)
	$(shell rm *.hex 2> /dev/null)
	$(shell rm *.map 2> /dev/null)
	$(shell rm *.d 2> /dev/null)
	$(shell rm *.o 2> /dev/null)
	$(shell rm *.a 2> /dev/null)
	$(shell rm $(ARDUINO_PATH)/*.o 2> /dev/null)

distclean:
	@echo "complete cleaning"
	$(shell rm -rf $(TOOLCHAIN_DIR))

%.o: %.cpp
	$(CXX) $(CXX_FLAGS) $(EXTRA_FLAGS) $(INCLUDES) $< -o $@

%.o: %.c
	$(CC) $(CC_FLAGS) $(EXTRA_FLAGS) $(INCLUDES) $< -o $@

%.S.o: %.S
	$(CC) -c -g -x assembler-with-cpp -flto -MMD $(EXTRA_FLAGS) $(INCLUDES) $< -o $@

target.elf: $(OBJECTS_SRC)
	$(ELF) $(ELF_FLAGS) -o target.elf $(OBJECTS_SRC) $(STATIC_LIB) $(CORE_LIB) -L. -lm

target.eep: target.elf
	$(OBJCOPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load \
	--no-change-warnings --change-section-lma .eeprom=0 target.elf target.eep

target.hex: target.elf
	$(OBJCOPY) -O ihex -R .eeprom target.elf target.hex

upload: 
	$(AVRDUDE) -C$(AVRDUDE_CONF) -v -p$(MCU) -carduino -P$(PORT) -b$(BAUDRATE) -D -Uflash:w:target.hex:i