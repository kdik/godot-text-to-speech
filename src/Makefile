ifeq ($(OS),Windows_NT)
  OS_NAME=win32
  DLL_SUFFIX=dll
else ifeq ($(shell uname -s),Linux)
  OS_NAME=linux
  DLL_SUFFIX=so
endif
BUILD_DIRECTORY=../addons/texttospeech/lib/$(OS_NAME)

CC=gcc
INCLUDE_FLAGS=-I../include/godot_headers -I../include/flite
LDFLAGS=-L../lib/$(OS_NAME)
LIBS=-lflite_cmu_us_awb -lflite_cmu_us_kal -lflite_cmu_us_kal16 -lflite_cmu_us_slt -lflite_usenglish -lflite_cmulex -lflite -lm
ifeq ($(OS),Windows_NT)
  LIBS+= -lwinmm
endif
ifeq ($(shell uname -s),Linux)
  CFLAGS=-fPIC
endif

tts:
	$(CC) $(CFLAGS) -c $@.c $(INCLUDE_FLAGS) -o $(BUILD_DIRECTORY)/$@.o -Wno-implicit-function-declaration -Wno-int-conversion
	$(CC) $(CFLAGS) -shared $(BUILD_DIRECTORY)/$@.o $(LDFLAGS) $(LIBS) -o $(BUILD_DIRECTORY)/lib$@.$(DLL_SUFFIX)
	rm -r $(BUILD_DIRECTORY)/$@.o
clean:
	rm -r $(BUILD_DIRECTORY)/libtts.$(DLL_SUFFIX)