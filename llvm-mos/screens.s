# https://www.c64-wiki.de/wiki/Koala_Painter

.global bank0bitmap
.type       bank0bitmap,@object
.section    .bank0bitmap,"awR",@progbits
bank0bitmap:
.incbin "screen1.koa", 2, 8000

.global bank0screen
.type       bank0screen,@object
.section    .bank0screen,"awR",@progbits
bank0screen:
.incbin "screen1.koa", 8002, 1000

.global bank0color
.type       bank0color,@object
.section    .bank0color,"awR",@progbits
bank0color:
.incbin "screen1.koa", 9002, 1000

.global bank0bgcolor
.type       bank0bgcolor,@object
bank0bgcolor:
.incbin "screen1.koa", 10002, 1

.global bank1bitmap
.type       bank1bitmap,@object
.section    .bank1bitmap,"awR",@progbits
bank1bitmap:
.incbin "screen2.koa", 2, 8000

.global bank1screen
.type       bank1screen,@object
.section    .bank1screen,"awR",@progbits
bank1screen:
.incbin "screen2.koa", 8002, 1000

.global bank1color
.type       bank1color,@object
.section    .bank1color,"awR",@progbits
bank1color:
.incbin "screen2.koa", 9002, 1000

.global bank1bgcolor
.type       bank1bgcolor,@object
bank1bgcolor:
.incbin "screen2.koa", 10002, 1

