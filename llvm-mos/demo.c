#include "macros.h"
#include <6502.h>
#include <c64.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern char sid[];
extern unsigned bank0bgcolor;
extern unsigned bank1bgcolor;

unsigned char screen_state = 0;
unsigned char counter = 254;

void background(unsigned char color) {
  poke(&VIC.bordercolor, color);
  poke(&VIC.bgcolor0, color);
}

void recolor() {
  counter++;
  if (counter == 255) {
    counter = 0;
    if (screen_state == 0) {
      screen_state = 1;
      background(bank1bgcolor);
      // https://www.c64-wiki.com/wiki/VIC_bank
      vic_bank(0b0000010);
    } else {
      screen_state = 0;
      background(bank0bgcolor);
      vic_bank(0b0000011);
    }
  }
}

// see https://llvm-mos.org/wiki/C_interrupts
__attribute__((interrupt,no_isr)) void play() {
  interrupt_ack();
  recolor();
  sid_play($1021);
  interrupt_exit();
}

int main(void) {
  // we don't need the BASIC ROM after we start
  // see https://www.c64-wiki.com/wiki/Zeropage
  poke(0x0001, 0b00110110);

  // initialize the SID song
  sid_init($1048);

  cls();

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

  SEI();
  poke(&VIC.rasterline, 255);
  pokew(IRQVec,(unsigned int)&play);
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
