#include "macros.h"
#include <6502.h>
#include <c64.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern unsigned bank0bgcolor;
extern unsigned bank1bgcolor;
extern char bank0bitmap;
extern char bank1bitmap;

extern char *message;
extern unsigned char messageLength;

unsigned char screen_state = 0;
unsigned char counter = 254;

unsigned char raster_h_offset = 7;
unsigned char msg_offset = 0;

void background(unsigned char color) {
  poke(&VIC.bordercolor, color);
  poke(&VIC.bgcolor0, color);
}

void recolor() {
  // switch to Standard Bitmap Mode now (bit 5 set to 1)
  // Bit #5: 0 = Text mode; 1 = Bitmap mode.
  // see https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
  poke(&VIC.ctrl1, 0b00111011);
  // tells the VIC-II where to "look for graphics"
  // in this case:
  // 3 (%0011) * 1024 = $0c00 = address to start of color information
  // bit 3 is set, then the bitmap starts at vic bank address + $2000 = $2000 or
  // $6000 see https://www.c64-wiki.com/wiki/53272
  poke(&VIC.addr, 0b00111000);
  // bit 5 must be cleared to enter Standard Bitmap Mode
  // see https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
  poke(&VIC.ctrl2, 0b11011000);
  if (screen_state == 0) {
    background(bank1bgcolor);
    vic_bank(0b0000010);
  } else {
    background(bank0bgcolor);
    vic_bank(0b0000011);
  }
  counter++;
  if (counter == 255) {
    counter = 0;
    screen_state = screen_state == 1 ? 0 : 1;
  }
}

void scrollMessage() {
  // use bank 0 $0000-$3FFF, ROM chars available at $1000-$1FFF
  // see https://www.c64-wiki.com/wiki/VIC_bank
  vic_bank(0b00000011);
  // switch to Standard Character Mode now (bit 5 set to 0)
  // Bit #5: 0 = Text mode; 1 = Bitmap mode.
  // see https://www.c64-wiki.com/wiki/Standard_Character_Mode and
  // http://sta.c64.org/cbm64mem.html
  poke(&VIC.ctrl1, 0b00011011);
  // tells the VIC-II where to "look for graphics"
  // in this case:
  // 15 (%1111) * 1024 = $3c00 = address to screen character RAM
  // 2 (%010) * 2048 = $1000 = where to access the character set ROM address
  // see https://www.c64-wiki.com/wiki/53272
  poke(&VIC.addr, 0b11110100);

  raster_h_offset--;
  poke(&VIC.ctrl2, raster_h_offset);
  if (raster_h_offset == 0) {
    raster_h_offset = 7;

    if (msg_offset == messageLength) {
      msg_offset = 0;
    }

    for (uint8_t i = 0; i < 40; i++) {
      poke(0x3fc0 + i, message[msg_offset + i]);
    }

    msg_offset++;
  }
}

void clearBitmapLines(char *bitmap, uint16_t start, uint16_t end) {
  for (uint16_t i = start; i < end; i = i + 1) {
    bitmap[i] = 0;
  }
}

// see https://llvm-mos.org/wiki/C_interrupts
__attribute__((interrupt, no_isr)) void play() {
  interrupt_ack();
  scrollMessage();
  sid_play($1021);
  recolor();
  interrupt_exit();
}

int main(void) {
  // we don't need the BASIC ROM after we start
  // see https://www.c64-wiki.com/wiki/Zeropage
  poke(0x0001, 0b00110110);

  // initialize the SID song
  sid_init($1048);

  cls();

  // C64 bitmaps are 320x200 pixels, or 8000 bytes. Each line is 40 bytes.
  clearBitmapLines(&bank0bitmap, 8000 - 40 * 16, 8000);
  clearBitmapLines(&bank1bitmap, 8000 - 40 * 16, 8000);

  SEI();
  poke(&VIC.rasterline, 240);
  pokew(IRQVec, (unsigned int)&play);
  // interrupt control - enable all interrupts with $7b (icr=$DC0D)
  // see http://sta.c64.org/cbm64mem.html
  poke(&CIA1.icr, 0b01111011);
  // interrupt control register - enable raster interrupt with $81 ($d01a)
  // see http://sta.c64.org/cbm64mem.html
  poke(&VIC.imr, 0b10000001);
  CLI();

  while (1) {
    /*
      if (raster_line == 255) {
        recolor();
        // call sid play routing
        sid_play($1021);
      }
    */
  }
}
