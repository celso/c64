#
# GNU Makefile
#

VICE=/Applications/vice-arm64-sdl2-3.7.1/bin/x64sc -autostartprgmode 1 -statusbar

all: demo

demo:
	@echo "Compiling demo"
	# -c Only run preprocess, compile, and assemble steps, do not link
	mos-c64-clang -c -o build/music.o music.s
	mos-c64-clang -c -o build/screens.o screens.s
	mos-c64-clang -c -o build/demo.o demo.c
	mos-c64-clang++ -std=c++20 -finput-charset=utf-8 -c -o build/strings.o strings.cpp
	mos-c64-clang++ -std=c++20 -Os -flto \
		-Wl,--section-start=.sid=0x1000, \
		-Wl,--section-start=.bank0screen=0x0c00, \
		-Wl,--section-start=.bank0bitmap=0x2000 \
		-Wl,--section-start=.bank1screen=0x4c00, \
		-Wl,--section-start=.bank1bitmap=0x6000 \
		-o build/demo.prg build/demo.o build/music.o build/screens.o build/strings.o
	mos-c64-clang++ -std=c++20 -Os -flto \
		-Wl,--section-start=.sid=0x1000 \
		-Wl,--section-start=.bank0screen=0x0c00 \
		-Wl,--section-start=.bank0bitmap=0x2000 \
		-Wl,--section-start=.bank1screen=0x4c00, \
		-Wl,--section-start=.bank1bitmap=0x6000 \
		-Wl,--lto-emit-asm -o build/demo.s build/demo.o build/music.o build/screens.o build/strings.o

run: demo
	@echo "Running demo"
	$(VICE) build/demo.prg

sid:
	@echo "SID file info"
	./tools/sidinfo.py music.sid

.PHONY: all demo run

# EOF - Makefile
