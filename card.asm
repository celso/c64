.var music = LoadSid("music.sid")
// more on LoadBinary http://theweb.dk/KickAssembler/webhelp/content/ch12s02.html
.var picture1 = LoadBinary("screen1.koa", BF_KOALA)
.var picture2 = LoadBinary("screen2.koa", BF_KOALA)

:BasicUpstart2(start)

// START

start:
    // the address $0001 holds and sets the 6510 CPU's on-chip port register
    // %x10: RAM visible at $A000-$BFFF; KERNAL ROM visible at $E000-$FFFF
    // what we're saying here is we don't need the BASIC ROM after we start
    // see https://www.c64-wiki.com/wiki/Zeropage
    lda #%00110110
    sta $0001

    // playing SID music has 3 parts:
    // 1. you use use Kick Assembler's LoadSid to import the .sid file
    // 2. you call music.init
    // 3. you call music.play in every raster interrupt
    // see http://www.theweb.dk/KickAssembler/webhelp/content/ch12s03.html and the README.md
    lda #music.startSong-1 // set up the music
    jsr music.init


    // clear screen subroutine
    // http://sta.c64.org/cbm64scrfunc.html
    jsr $e544 // clear screen. See http://sta.c64.org/cbm64scrfunc.html

    // the recolor() subroutine will set the background, border color, and character colors (for the scrolling message)
    // see below for more information
    jsr recolor

    // crop the bottom of the screens off to create space for the scroll message
    // 320 pixels ($ff + $40)
    ldx #$ff
!fill:  lda #0
    sta bitMap_1 + picture1.getBitmapSize() - 640,x
    dex
    bne !fill-
    ldx #$40
!fill:  lda #0
    sta bitMap_1 + picture1.getBitmapSize() - 384,x
    dex
    bne !fill-
    ldx #$ff
!fill:  lda #0
    sta bitMap_2 + picture2.getBitmapSize() - 640,x
    dex
    bne !fill-
    ldx #$40
!fill:  lda #0
    sta bitMap_2 + picture2.getBitmapSize() - 384,x
    dex
    bne !fill-

    // disable the interrupts
    sei
    // first interrupt will be irq1 at scan line 240
    setupirq(240, irq1);
    // interrupt control - enable all interrupts with $7b
    // see http://sta.c64.org/cbm64mem.html
    lda #%01111011
    sta $dc0d
    // interrupt control register - enable raster interrupt with $81
    // see http://sta.c64.org/cbm64mem.html
    lda #%10000001
    sta $d01a
    // enable interrupts now
    cli

// SPRITES

    // $D01C/53276 sprites can be high resolution or multicolor mode - bits at 0 sets them to high res
    // see https://www.c64-wiki.com/wiki/Sprite
    lda #%00000000
    sta $d01c // all sprites are of type 'single color'

    // $D015/53269  acts like a "switch" that turns one of the eight sprites "on" or "off"
    // see https://www.c64-wiki.com/wiki/Sprite
    lda #%11111111
    sta $d015 // all eight sprites on (all bits set)

    // the location of the sprite pointers (see sprites.asm) follows that of the text screen plus 1016/$3F8
    // this will iterate the 8 sprite pointers, load their values (see sprites.asm) and set screen addresses with them
    // see https://www.c64-wiki.com/wiki/Sprite#Sprite_pointers
    ldx #$7
!loop:
    lda spritePtrs,x
    sta screenRam_1 + 1016,x
    lda 0
    // this hides sprites on screen 2
    sta screenRam_2 + 1016,x

    // loads a random number from 0 to $F into the accumulator
    rndGen(%1111);
    // $D027-$D02E sets each sprite color
    // see https://www.c64-wiki.com/wiki/Sprite
    sta $d027,x

    dex
    bpl !loop-

    // fixed horizontal coordinates for the sprites
    // $D000 (sprite 0), $D002, $D004, $D006, $D008, $D00A, $D00C, $D00E (sprite 7)
    // $D010 sets which sprites x coordinates go over the 256 byte limit
    // see https://www.c64-wiki.com/wiki/Sprite#Sprite_locations
    lda #10
    sta $d000
    lda #52
    sta $d002
    lda #94
    sta $d004
    lda #136
    sta $d006
    lda #178
    sta $d008
    lda #220
    sta $d00a
    // sprites 6 and 7 are over 256
    lda #%11000000
    sta $d010
    lda #6
    sta $d00c
    lda #48
    sta $d00e

// MAIN LOOP HERE

    // $D012 is a VIC-II read/write register
    // you can read it to know where the rasterbar is (0-256)
    // you can write it to set where the raster interrupt will take place
    // see https://www.c64-wiki.com/wiki/Raster_interrupt and http://sta.c64.org/cbm64mem.html

main:
    // here we wait until we reach scanline 50
    lda $d012
    cmp #50
    beq !ahead+
    jmp main
!ahead:

    // here we are going to read and increment the vertical offset for each of the eight sprites
    // the sprites y coordinates are stored in our sprite_v_offsets array (see sprites.asm)
    // VIC-II expects the vertical y sprite coordinates at
    // $D001 (sprite 0), $D003, $D005, $D007, $D009, $D00B, $D00D, $D00F (sprite 7)
    // see https://www.c64-wiki.com/wiki/Sprite#Sprite_locations
    ldx #7
    ldy #15
!loop:
    lda sprite_v_offsets,x
    sta $d000,y
    // this loads the accumulator with a random 0 or 1
    // if 0 then increments offset once
    // if 1 then increments offset twice
    // this gives a random effect on the falling snow on screen
    rndGen(1);
    beq !ahead+
    // once
    inc sprite_v_offsets,x
!ahead:
    // twice
    inc sprite_v_offsets,x

    // we don't want sprites to go below 213 (and overlap with the bottom scrolling text)
    // this avoids it. if the offset is 214 or 215, then reset it back to 0 and start over
    lda sprite_v_offsets,x
    cmp #214
    beq !reset+
    cmp #215
    beq !reset+
    jmp !ahead+
!reset:
    lda #0
    sta sprite_v_offsets,x

    // let's go ahead and randomize the sprite color every time it starts over from y zero
    // loads a random number from 0 to $F into the accumulator
    rndGen(%1111);
    // $D027-$D02E sets each sprite color
    // see https://www.c64-wiki.com/wiki/Sprite
    sta $d027,x // sprite color - info here https://www.c64-wiki.com/wiki/Sprite
!ahead:

    dey
    dey
    dex
    txa
    bne !loop-

    // jump back to the beginning of the main loop
    jmp main

// END MAIN LOOP

// ----------

// SUBROUTINES NEXT

// RECOLOR sub

    // the recolor() sub is called once at start, and once every irq2 triggers
recolor:
    // increments screen_state
    // we have two screens. if screen_state == 3, then reset it back to 1
    // should oscillate between 1 and 2
    inc screen_state
    lda screen_state
    cmp #3
    bne !skip+
    lda #1
    sta screen_state

    // if screen_state == 2 then color2, otherwise color1
!skip:
    cmp #2
    beq screen2

    // the colors of the screen always reside at the memory address $D800-$DBE7 (yet another dedicated chip, the MM2114N-3)
    // this is aka known as the color RAM and it's works the same regardless of the bank being used
    // see https://www.c64-wiki.com/wiki/Color_RAM

    // we're going to use a kick assembler macro here, to avoid writing the same code twice
    .macro recolorMacro(colormap, bg, linecolor) {
        ldx #0
        !loop:
            // the .for KA directive expands at assembly time, for easyness
            // see http://theweb.dk/KickAssembler/webhelp/content/ch05s04.html
            .for (var i=0; i<4; i++) {
                // important note: because we're in bitmap mode, this code isn't required, the color RAM isn't being used
                // however we're leaving it here for academic purposes. for a complete explanation on graphic modes and colors
                // see http://www.coding64.org/?p=164
                lda colormap+i*$100,x
                sta $d800+i*$100,x
            }
        inx
        bne !loop-
        lda #bg
        // $D020 is the border color (only bits #0-#3)
        // $D021 is the screen background color (only bits #0-#3)
        // see http://sta.c64.org/cbm64mem.html
        sta $d020
        sta $d021

        // the bottom part of our screen scrolls a line of text, and is used in character mode
        // which means that we need to set the color of the characters in that line, depending on the screen_state
        // setting the accumulator here
        lda #linecolor
    }

screen1:
    recolorMacro(colorRam_1, picture1.getBackgroundColor(), 7);
    jmp !skip+
screen2:
    recolorMacro(colorRam_2, picture2.getBackgroundColor(), 1);
!skip:

    // takes the accumulator from the macro above, and uses it to fill the
    // bottom of the color RAM in the screen that corresponds to the scrolling text (starts at $DAE8)
    ldx #$D8
!fill:
    sta $dae8,x
    inx
    bne !fill-

    rts

// SCROLL_MESSAGE sub

    // the scroll_message() sub is called once every irq1 interrupt
scroll_message:
    // use bank 0 $0000-$3FFF, ROM chars available at $1000-$1FFF
    // see https://www.c64-wiki.com/wiki/VIC_bank
    vicbank(%00000011);
    // we need to burn some cpu cycles to get timming right - this works
    delay(54);
    // switch to Standard Character Mode now (bit 5 set to 0)
    // Bit #5: 0 = Text mode; 1 = Bitmap mode.
    // see https://www.c64-wiki.com/wiki/Standard_Character_Mode and http://sta.c64.org/cbm64mem.html
    lda #%00011011
    sta $d011
    // tells the VIC-II where to "look for graphics"
    // in this case:
    // 15 (%1111) * 1024 = $3c00 = address to screen character RAM
    // 2 (%010) * 2048 = $1000 = where to access the character set ROM address
    // see https://www.c64-wiki.com/wiki/53272
    lda #%11110100
    sta $d018

    // scroll the line by scrolling the raster
    // raster_h_offset starts at 7 on init
    dec raster_h_offset
    lda raster_h_offset
    // $D016 bits 0 to 2 sets the horizontal raster scroll to 0 to 7
    sta $d016
    // if not zero, then get out, do not print a new character just yet
    bne !exit+
    // ok, time to print a new character, but let's set the raster offset to 7 again
    lda #7
    sta raster_h_offset

    // load the x index with the message_offset
    // when the msg_offset reaches the msg_length limit, set it 0
    ldx msg_offset
    cpx msg_length
    bne !skip+
    ldx #0
    stx msg_offset
!skip:

    // get 40 chars from this offset and print them in the line, from left to right
    ldy #0
printchr:
    // load the accumulator with the corresponding character, according to the offset (stored in the x index, see above)
    lda msg_text, x
    // $3FC0 is the left side, first character of the bottom scrolling line
    // according to the $D018 setting while in text mode, see below in the irq1
    sta $3fc0, y
    // increment offset
    inx
    // are we at the end of the message array?
    cpx msg_length
    bne !skip+
    // if yes, start from offset 0
    ldx #0
    // next column
!skip: iny
    // are we at column 40 now?
    cpy #40
    bne printchr

    // increment and set msg_offset for the next round
    inc msg_offset
!exit:
    rts

// INTERRUPTS

// this is were the fun starts
// first of all let's define a few handy macros

// ack()
// everytime an interrupt triggers, we need to acknowledge it by setting the corresponding VIC interrupt flag
// if we don't ack the irq, then it will be called again after we exit it
// see http://sta.c64.org/cbm64mem.html

.macro ack() {
    lda #%11111111
    sta $d019
}

// exitirq()
// when exiting an irq, we need to restore the accumulator, and indexes y and x from the stack first

.macro exitirq() {
    // pull accumulator from stack
    pla
    // transfer accumulator to index y
    tay
    pla
    // transfer accumulator to index x
    tax
    // restore the accumulator
    pla
}

// setupirq(line, irq)
// this will set the raster line at the next irq will occur
// https://www.c64-wiki.com/wiki/Raster_interrupt and http://sta.c64.org/cbm64mem.html

.macro setupirq(line, irq) {
    lda #line
    // write: raster line to generate interrupt at (bits #0-#7).
    sta $d012
    lda #<irq
    // execution address of interrupt service routine (left)
    sta $0314
    lda #>irq
    // execution address of interrupt service routine (right)
    sta $0315
}

// ok, we're using two interrupts here
// the first, irq1, is triggered at scanline 240
// the second, irq2, is triggered at scanline 16
// at the end irq1 we set irq2 and vice-versa

// irq1
// we use irq1 (from scanline 240 onwards) to change the VIC-II to text mode, scroll the bottom text message,
// and rewrite it with scroll_message()

irq1:
    ack();
    // keep scrolling the bottom line
    jsr scroll_message
    // keep the music playing
    jsr music.play
    // jump to irq2 at line 10
    setupirq(10, irq2);
    // over and out
    exitirq();
    rti


irq2:
    ack();

    // depending on which screen_state we are in set VIC-II memory bank accordingly
    // this will basically alternate between the two bitmaps from picture1 and picture2
    lda screen_state
    cmp #2
    beq s2

    // use bank 0 $0000-$3FFF, ROM chars available at $1000-$1FFF
    // see https://www.c64-wiki.com/wiki/VIC_bank
    vicbank(%00000011);
    jmp !ahead+
s2:
    // use bank 0 $4000-$7FFF, no ROM chars available here
    // but we don't need them, because we're in bitmap mode in the part of the screen
    // see https://www.c64-wiki.com/wiki/VIC_bank
    vicbank(%00000010); // bank1
!ahead:

    // switch to Standard Bitmap Mode now (bit 5 set to 1)
    // Bit #5: 0 = Text mode; 1 = Bitmap mode.
    // see https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
    lda #%00111011
    sta $d011
    // tells the VIC-II where to "look for graphics"
    // in this case:
    // 3 (%0011) * 1024 = $0c00 = address to start of color information
    // bit 3 is set, then the bitmap starts at vic bank address + $2000 = $2000 or $6000
    // see https://www.c64-wiki.com/wiki/53272
    lda #%00111000
    sta $d018
    // bit 5 must be cleared to enter Standard Bitmap Mode
    // see https://www.c64-wiki.com/wiki/Standard_Bitmap_Mode
    lda #%11011000
    sta $d016

    // we only recolor(), which also changes the screen_state, every 255 interrupts
    inc counter
    lda counter
    cmp #255
    bne !skip+
    jsr recolor
    lda #0
    sta counter
!skip:

    // jump to irq1 at line 240
    setupirq(240, irq1);
    // over and out
    exitirq();
    rti

// holds the index of the screen we're displaying
// 0 for screen1, 1 for screen2...
screen_state: .byte 0
counter: .byte 0

#import "message.asm"

raster_h_offset:   .byte 7
msg_offset: .byte 0

#import "sprites.asm"

// Bank 0
* = $0c00 "ScreenRam_1"; screenRam_1: .fill picture1.getScreenRamSize(), picture1.getScreenRam(i)
* = $1c00 "ColorRam_1:"; colorRam_1: .fill picture1.getColorRamSize(), picture1.getColorRam(i)
* = $2000 "Bitmap_1"; bitMap_1: .fill picture1.getBitmapSize(), picture1.getBitmap(i)

* = music.location "Music"
.fill music.size, music.getData(i)

// Bank 1
* = $4c00 "ScreenRam_2"; screenRam_2: .fill picture2.getScreenRamSize(), picture2.getScreenRam(i)
* = $6000 "Bitmap_2"; bitMap_2: .fill picture2.getBitmapSize(), picture2.getBitmap(i)
* = $7f40 "ColorRam_2:"; colorRam_2: .fill picture2.getColorRamSize(), picture2.getColorRam(i)

// Macros

// this the VIC-II chip, via the CIA-2 $DD00 register, which 16kb memory bank to use for graphics
// see https://www.c64-wiki.com/wiki/VIC_bank

.macro vicbank(pattern) {
    lda $dd00
    and #%11111100
    ora #pattern
    sta $dd00
}

// delay of N NOP CPU instructions

.macro delay(count) {
    .for (var i=0; i<=count; i++) {
        nop
    }
}

// this is a clever way to calculate a random number in a C64

.macro rndGen(mask) {
    lda $d012 // current raster line
    eor $dc04 // exclusive or with current timer value
    sbc $dc05 // substract time value
    and #mask
}

#import "sidinfo.asm"
