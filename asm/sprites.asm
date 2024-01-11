// horizontal offsets (0-256) for each of the 8 sprites we use for the snow - these are the initial values
// they will be incremented randomly as the program runs

sprite_v_offsets:
.byte 62, 124, 0, 186, 31, 215, 93, 155

// this is macro (used at assembly time by the kick assembler) to calculate the content of the sprite pointers
// we strip the left bits ($3FFF mask) because the address of the sprite is always relative to the beginning of the video block
// the c64 has four video blocks $0000-$3fff, $4000-$7fff, $8000-$bfff, $c000-$ffff
// see https://www.c64-wiki.com/wiki/Sprite#Sprite_pointers

.function toSpritePtr(addr) {
   .return (addr&$3FFF)/64
}

spritePtrs:
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)
.byte toSpritePtr(snow_sprite_small), toSpritePtr(snow_sprite_big)

// you can use http://spritemate.com/ to edit these
// just press file->save file->kick ass(hex) once you designed your sprite


// be carefull with the address you chose for your sprites. two notes:
// 1. it needs to be divisible by 64 - see above - you can use the .align 64 if it helps
// 2. it needs to be in the same video block where you want to display them
//    the c64 has four video blocks $0000-$3fff, $4000-$7fff, $8000-$bfff, $c000-$ffff

* = $b60 "Sprites"; // address $b60 means that this sprites can only be used with the screen on block $0000-$3fff

.align 64

snow_sprite_big:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $08,$00,$00,$88,$80,$00,$5d,$00
.byte $00,$3e,$00,$00,$7f,$00,$01,$ff
.byte $c0,$00,$7f,$00,$00,$3e,$00,$00
.byte $5d,$00,$00,$88,$80,$00,$08,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$03

// memory for sprite patterns needs to be divisible by 64 - see above why

snow_sprite_small:

.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$08,$00
.byte $00,$41,$00,$00,$2a,$00,$00,$00
.byte $00,$00,$aa,$80,$00,$00,$00,$00
.byte $2a,$00,$00,$41,$00,$00,$08,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$03

