# Get git commit version and date
GIT_VERSION := $(shell git --no-pager describe --tags --always --dirty)
GIT_DATE := $(firstword $(shell git --no-pager show --date=short --format="%ai" --name-only))

# uncomment the line below to include support for psk31
PSK_INCLUDE=PSK

# uncomment the line to below include support for FreeDV codec2
FREEDV_INCLUDE=FREEDV

#uncomment the line below for the platform being compiled on
UNAME_N=raspberrypi
#UNAME_N=odroid
#UNAME_N=up
#UNAME_N=pine64
#UNAME_N=x86

CC=gcc
LINK=gcc

# uncomment the line below for various debug facilities
#DEBUG_OPTION=-D DEBUG

# uncomment the line below for LimeSDR (uncomment line below)
#LIMESDR_INCLUDE=LIMESDR

ifeq ($(LIMESDR_INCLUDE),LIMESDR)
LIMESDR_OPTIONS=-D LIMESDR
SOAPYSDRLIBS=-lSoapySDR
LIMESDR_SOURCES= \
lime_discovery.c \
lime_protocol.c
LIMESDR_HEADERS= \
lime_discovery.h \
lime_protocol.h
LIMESDR_OBJS= \
lime_discovery.o \
lime_protocol.o
endif


ifeq ($(PSK_INCLUDE),PSK)
PSK_OPTIONS=-D PSK
PSKLIBS=-lpsk
PSK_SOURCES= \
psk.c \
psk_waterfall.c
PSK_HEADERS= \
psk.h \
psk_waterfall.h
PSK_OBJS= \
psk.o \
psk_waterfall.o
endif


ifeq ($(FREEDV_INCLUDE),FREEDV)
FREEDV_OPTIONS=-D FREEDV
FREEDVLIBS=-lcodec2
FREEDV_SOURCES= \
freedv.c
FREEDV_HEADERS= \
freedv.h
FREEDV_OBJS= \
freedv.o
endif

#required for MRAA GPIO
#MRAA_INCLUDE=MRAA

ifeq ($(MRAA_INCLUDE),MRAA)
  GPIO_OPTIONS=-D GPIO
  GPIO_LIBS=-lmraa
  GPIO_SOURCES= \
  gpio_mraa.c
  GPIO_HEADERS= \
  gpio.h
  GPIO_OBJS= \
  gpio_mraa.o
else
  ifeq ($(UNAME_N),raspberrypi)
  GPIO_OPTIONS=-D GPIO
  GPIO_LIBS=-lwiringPi -lpigpio
  endif
  ifeq ($(UNAME_N),odroid)
  GPIO_LIBS=-lwiringPi
  endif
  GPIO_SOURCES= \
  gpio.c
  GPIO_HEADERS= \
  gpio.h
  GPIO_OBJS= \
  gpio.o
endif


GTKINCLUDES=`pkg-config --cflags gtk+-3.0`
GTKLIBS=`pkg-config --libs gtk+-3.0`

AUDIO_LIBS=-lasound

OPTIONS=-g -D $(UNAME_N) $(GPIO_OPTIONS) $(LIMESDR_OPTIONS) $(FREEDV_OPTIONS) $(PSK_OPTIONS) -D GIT_DATE='"$(GIT_DATE)"' -D GIT_VERSION='"$(GIT_VERSION)"' $(DEBUG_OPTION) -O3

LIBS=-lrt -lm -lwdsp -lpthread $(AUDIO_LIBS) -lpulse $(PSKLIBS) $(GTKLIBS) $(GPIO_LIBS) $(SOAPYSDRLIBS) $(FREEDVLIBS)
INCLUDES=$(GTKINCLUDES)

COMPILE=$(CC) $(OPTIONS) $(INCLUDES)

PROGRAM=pihpsdr

SOURCES= \
audio.c \
band.c \
configure.c \
frequency.c \
discovered.c \
filter.c \
main.c \
menu.c \
meter.c \
mode.c \
old_discovery.c \
new_discovery.c \
old_protocol.c \
new_protocol.c \
new_protocol_programmer.c \
panadapter.c \
property.c \
radio.c \
signal.c \
splash.c \
toolbar.c \
sliders.c \
version.c \
vfo.c \
waterfall.c \
wdsp_init.c


HEADERS= \
audio.h \
agc.h \
alex.h \
band.h \
configure.h \
frequency.h \
bandstack.h \
channel.h \
discovered.h \
filter.h \
menu.h \
meter.h \
mode.h \
old_discovery.h \
new_discovery.h \
old_protocol.h \
new_protocol.h \
panadapter.h \
property.h \
radio.h \
signal.h \
splash.h \
toolbar.h \
sliders.h \
version.h \
vfo.h \
waterfall.h \
wdsp_init.h \
xvtr.h


OBJS= \
audio.o \
band.o \
configure.o \
frequency.o \
discovered.o \
filter.o \
version.o \
main.o \
menu.o \
meter.o \
mode.o \
old_discovery.o \
new_discovery.o \
old_protocol.o \
new_protocol.o \
new_protocol_programmer.o \
panadapter.o \
property.o \
radio.o \
signal.o \
splash.o \
toolbar.o \
sliders.o \
vfo.o \
waterfall.o \
wdsp_init.o

all: prebuild $(PROGRAM) $(HEADERS) $(LIMESDR_HEADERS) $(FREEDV_HEADERS) $(GPIO_HEADERS) $(PSK_HEADERS) $(SOURCES) $(LIMESDR_SOURCES) $(FREEDV_SOURCES) $(GPIO_SOURCES) $(PSK_SOURCES)

prebuild:
	rm -f version.o

$(PROGRAM): $(OBJS) $(LIMESDR_OBJS) $(FREEDV_OBJS) $(GPIO_OBJS) $(PSK_OBJS)
	$(LINK) -o $(PROGRAM) $(OBJS) $(GPIO_OBJS) $(LIMESDR_OBJS) $(FREEDV_OBJS) $(PSK_OBJS) $(LIBS)

.c.o:
	$(COMPILE) -c -o $@ $<


clean:
	-rm -f *.o
	-rm -f $(PROGRAM)

install:
	cp pihpsdr ../pihpsdr
	cp pihpsdr ./release/pihpsdr
	cd release; tar cvf pihpsdr.tar pihpsdr

