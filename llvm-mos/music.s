# SID music section
# see --section-start=.sid=0x1000 in Makefile for sid address
# R flag is needed to avoid linker garbage collection
# see https://sourceware.org/binutils/docs/as/Section.html
#
# First 126 bytes of music.sid are header, so skip them
# .incbin "file"[,skip[,count]]
#  https://www.hvsc.c64.org/download/C64Music/DOCUMENTS/SID_file_format.txt

.global sid
.type       sid,@object
.section    .sid,"awR",@progbits
sid:
.incbin "music.sid", 126
