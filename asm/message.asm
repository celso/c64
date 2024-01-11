.const msg = "this c64 demo uses vic-ii graphics, sprites, raster interrupts, a random generator and sid music - more at https://github.com/brpx/c64 "
msg_text:.text msg
msg_length: .byte msg.size()
raster_h_offset: .byte 7
msg_offset: .byte 0

