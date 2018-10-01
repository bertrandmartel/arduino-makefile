############################################################################
# The MIT License (MIT)
#
# Copyright (c) 2018 Bertrand Martel
#
############################################################################
#!/bin/bash
#title         : init.sh
#author		   : Bertrand Martel
#date          : 30/09/2018
#description   : extract toolchain / check build cmds 
############################################################################

function check_exists {

	if [ ! -f "$1" ]; then
		echo -ne "\x1B[31m"
		echo "[ ERROR ] $1 is missing"
		echo -ne "\x1B[0m"
		exit 1
	fi
}

TOOLCHAIN_VERSION="avr-gcc-5.4.0-atmel3.6.1-arduino2-x86_64-pc-linux-gnu"
AVRDUDE_VERSION="avrdude-6.3.0-arduino14-x86_64-pc-linux-gnu"

echo -ne "\x1B[0m"
echo "checking toolchain"

CORE_DIR=./avr
TOOLCHAIN_DIR=./toolchain/avr
TOOLCHAIN_BIN_DIR=${TOOLCHAIN_DIR}/bin
TOOLCHAIN_ARCHIVE=./toolchain/$TOOLCHAIN_VERSION.tar.bz2
AVRDUDE_DIR=./avrdude/avrdude
AVRDUDE_BIN_DIR=${AVRDUDE_DIR}/bin
AVRDUDE_ARCHIVE=./avrdude/$AVRDUDE_VERSION.tar.bz2

if [ ! -d ${CORE_DIR} ]; then
	echo -ne "\x1B[31m"
	echo "[ ERROR ] Core(avr) directory is missing"
	echo -ne "\x1B[0m"
	exit 1
fi

if [ ! -d ${TOOLCHAIN_DIR} ]; then

	if [ ! -f ${TOOLCHAIN_ARCHIVE} ]; then
		echo "downloading toolchain"
		wget -P ./toolchain "http://downloads.arduino.cc/tools/avr-gcc-5.4.0-atmel3.6.1-arduino2-x86_64-pc-linux-gnu.tar.bz2"
	fi
	echo "extracting toolchain"
	tar -xvjf ${TOOLCHAIN_ARCHIVE} -C ./toolchain/
fi

if [ ! -d ${AVRDUDE_DIR} ]; then

	if [ ! -f ${AVRDUDE_ARCHIVE} ]; then
		echo "downloading avrdude"
		wget -P ./avrdude "http://downloads.arduino.cc/tools/avrdude-6.3.0-arduino14-x86_64-pc-linux-gnu.tar.bz2"
	fi
	echo "extracting avrdude"
	tar -xvjf ${AVRDUDE_ARCHIVE} -C ./avrdude/ 
fi

GCC=${TOOLCHAIN_BIN_DIR}/avr-gcc
#ELF2HEX=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-g++
GXX=${TOOLCHAIN_BIN_DIR}/avr-g++
AR=${TOOLCHAIN_BIN_DIR}/avr-ar
OBJCOPY=${TOOLCHAIN_BIN_DIR}/avr-objcopy
AVRDUDE=${AVRDUDE_BIN_DIR}/avrdude
#ELF2HEX_COPY=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-objcopy
#SIZE=${TOOLCHAIN_BIN_DIR}/arm-none-eabi-size
#LOADER=${RFDUINO_DIR}/RFDLoader_linux

check_exists ${GCC}
#check_exists ${ELF2HEX}
check_exists ${GXX}
check_exists ${AR}
check_exists ${OBJCOPY}
check_exists ${AVRDUDE}
#check_exists ${ELF2HEX_COPY}
#check_exists ${SIZE}
#check_exists ${LOADER}