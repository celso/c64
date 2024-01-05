// and https://llvm-mos.org/wiki/Character_set
// custom version - official isn't working with wide \0 terminated strings
#include <charset.h>

const char *message = U"THIS C64 DEMO USES VIC-II GRAPHICS, SPRITES, RASTER INTERRUPTS, A RANDOM GENERATOR AND SID MUSIC - MORE AT HTTPS://HITHUB.COM/CELSO/C64 "_uv;
unsigned char messageLength = 136;
