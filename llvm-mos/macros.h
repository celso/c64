#include <c64.h>
#include <6502.h>
#include <_vic2.h>

#define IRQVec           0x0314
#define BRKVec           0x0316
#define NMIVec           0x0318

// https://github.com/cc65/cc65/blob/master/include/peekpoke.h

#define poke(addr,val)     (*(unsigned char*) (addr) = (val))
#define pokew(addr,val)    (*(unsigned*) (addr) = (val))
#define peek(addr)         (*(unsigned char*) (addr))
#define peekw(addr)        (*(unsigned*) (addr))

// various
#define sid_init(addr) __attribute__((leaf)) asm("LDA #$00\nTAX\nTAY\nJSR "#addr)
#define sid_play(addr) __attribute__((leaf)) asm("JSR "#addr)
#define raster_line (*((volatile unsigned char *)(struct __vic2 *)&VIC.rasterline))

// clear screen. See http://sta.c64.org/cbm64scrfunc.html
#define cls() __attribute__((leaf)) asm("JSR $e544")

// https://www.c64-wiki.com/wiki/VIC_bank
#define vic_bank(pattern) (*((volatile unsigned char *)(struct __6526 *)&CIA2.pra))=0b11111100|pattern

#define raster_interrupt(line, fn) \
  (*((volatile unsigned char *)(struct __vic2 *)&VIC.rasterline))=line; \
  (*(volatile unsigned char *)0x0314)=(unsigned int)fn & 0xffff; \
  (*(volatile unsigned char *)0x0315)=(unsigned int)fn >> 8;

#define interrupts_disable() __attribute__((leaf)) asm("SEI")
#define interrupts_enable() __attribute__((leaf)) asm("CLI")

// everytime an interrupt triggers, we need to acknowledge it by setting the
// corresponding VIC interrupt flag
// if we don't ack the irq, then it will be called again after we exit it
// see http://sta.c64.org/cbm64mem.html
#define interrupt_ack() (*((volatile unsigned char *)(struct __vic2 *)&VIC.irr)) = 0b11111111

// when exiting an irq, we need to restore the accumulator, and indexes y and x from the stack first
#define interrupt_exit() __attribute__((leaf)) asm("PLA\nTAY\nPLA\nTAX\nPLA\nRTI\n")
