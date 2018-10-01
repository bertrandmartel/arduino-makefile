# Arduino Makefile


Build your Arduino project with a single Makefile instead of using Arduino IDE :

* setup your own project structure
* write a very simple Makefile to build your project
* control all the build process

For now only atmega328p MCU is supported

## Prerequisites

* GNU Make (https://www.gnu.org/software/make)
* GNU Tar (https://www.gnu.org/software/tar)

## Compatibility

* Linux

## Integration

```bash
cd project_dir
git submodule add git://github.com/bertrandmartel/arduino-makefile.git
git submodule update --init --recursive
```

Then create your root `Makefile` in `project_dir` like this :

```bash
OBJECTS=some_directory/src/main.o some_directory/src2/test2.o
HEADERS=-Isome_directory/header -Isome_directory/header2

export OBJECTS
export HEADERS

.PHONY: all

all:
	$(MAKE) -C arduino-makefile

clean:
	$(MAKE) -C arduino-makefile clean

distclean:
	$(MAKE) -C arduino-makefile distclean

```

Change `OBJECTS` and `HEADERS` according to your requirements :

* `OBJECTS` contains list of object files `.o` that match your source
* `HEADERS` contains list of headers directory

Default usb port is set to `/dev/ttyACM0` by default, if you want to override this, add this to your Makefile : 

```bash
PORT=/dev/<port>
export PORT
```

You have to provide a main function like this : 

```cpp
#include "Arduino.h"

void setup() {
}

void loop() {
}

int main() {

	init();
	setup();
	while(1)
		loop();
	return 0;
}

```

Also `#include "Arduino.h"` is necessary for using Arduino framework

Note that `init()` function must be called to correctly initialize Arduino module (among other things it will initialize timer registers).

## External projects

* [Arduino hardware with JSON configuration file](https://github.com/arduino/Arduino/tree/master/hardware)
* [Arduino Core](https://github.com/arduino/ArduinoCore-avr)
* [RFduino makefile : a project in the same flavor as this one](https://github.com/bertrandmartel/rfduino-makefile)

## License

The MIT License (MIT) Copyright (c) 2018 Bertrand Martel
