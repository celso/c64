.include "c64.inc"

.global ack
.type  ack,@function
ack:
STA VIC_IRR
RTS
