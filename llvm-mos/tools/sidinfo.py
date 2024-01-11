#!/opt/homebrew/bin/python3.12

import sys
import os

if len(sys.argv) <= 1:
    print(f"{sys.argv[0]} sid_file.sid")
    sys.exit()

try:
    f = open(sys.argv[1], 'rb')
except FileNotFoundError:
    print(f"file {sys.argv[1]} does not exist")
else:
    with f:
        data = f.read(126)
        fs = os.stat(sys.argv[1])
        print(f"00-03, magicID: ", end="")
        print(f"{data[0:4].hex()} ({data[0:4]})")
        version = int.from_bytes(data[4:6], byteorder='big')
        print(f"04-05, version: {data[4:6].hex()}")
        dataOffset = int.from_bytes(data[6:8], byteorder='big')
        print(f"06-07, dataOffset: {dataOffset} (0x{data[6:8].hex()})")
        loadAddress = int.from_bytes(data[8:10], byteorder='big')
        print(f"08-09, loadAddress: ", end="")
        if(loadAddress==0):
            print(f"0 - specified in the two first two bytes of the data: (0x{data[dataOffset:dataOffset+2][::-1].hex()})")
        else:
            print(f"{loadAddress} (0x{data[8:10].hex()})")
        initAddress = int.from_bytes(data[0xa:0xc], byteorder='big')
        print(f"0A-0B, initAddress: ", end="")
        if(initAddress==0):
            print(f"0 - same as loadAddress")
        else:
            print(f"0x{data[0xa:0xc].hex()}")
        playAddress = int.from_bytes(data[0xc:0xd], byteorder='big')
        print(f"0C-0D, playAddress: ", end="")
        if(initAddress==0):
            print(f"0 - init sub installs interrupt handler")
        else:
            print(f"0x{data[0xc:0xe].hex()}")
        print(f"0E-0F, # of songs: {int.from_bytes(data[0xe:0x10], byteorder='big')} 0x{data[0xe:0x10].hex()}")
        print(f"10-11, startSong: {int.from_bytes(data[0x10:0x12], byteorder='big')} 0x{data[0x10:0x12].hex()}")
        speed = int.from_bytes(data[0x12:0x16], byteorder='big')
        print(f"12-15, speed: { speed }")
        print(f"16-35, name: {data[0x16:0x36]}")
        print(f"36-55, author: {data[0x36:0x56]}")
        print(f"56-75, released: {data[0x56:0x76]}")
        if(version==1):
            print(f"76-{ hex(fs.st_size-1)[2:] }, data from 0x76 (118) to { hex(fs.st_size-1) } ({ fs.st_size })")
        else:
            flags = int.from_bytes(data[0x76:0x78],'big')
            print(f"76-77, flags: { bin(flags) }")
            print(f"       bit 0 (musPlayer): { 'Compute Sidplayer MUS data' if (flags & 0b1) else 'built-in player' }")
            print(f"       bit 1 (compatiblity): { 'PlaySID specific or C64 Basic' if (flags & 0b10) else 'C64 compatible' }")
            print(f"       bit 2-3 (clock): ", end="")
            v = (flags & 0b1100)>>2
            match v:
                case 0b00: print("Unknown")
                case 0b01: print("PAL")
                case 0b10: print("NTSC")
                case 0b11: print("PAL & NTSC")
            print(f"       bit 4-5 (sidModel): ", end="")
            v = (flags & 0b110000)>>4
            match v:
                case 0b00: print("Unknown")
                case 0b01: print("MOS6581")
                case 0b10: print("MOS8580")
                case 0b11: print("MOS6581 and MOS8580")
            print(f"       bit 6-7 (sidModel 2): ", end="")
            v = (flags & 0b11000000)>>6
            match v:
                case 0b00: print("Unknown")
                case 0b01: print("MOS6581")
                case 0b10: print("MOS8580")
                case 0b11: print("MOS6581 and MOS8580")
            print(f"       bit 8-9 (sidModel 3): ", end="")
            v = (flags & 0b1100000000)>>8
            match v:
                case 0b00: print("Unknown")
                case 0b01: print("MOS6581")
                case 0b10: print("MOS8580")
                case 0b11: print("MOS6581 and MOS8580")
            startPage = int.from_bytes(data[0x78:0x79])
            print(f"78, startPage: ", end="")
            if(startPage==0):
                print("0x00 - clean (does not write outside its data range)")
            else:
                print(f"0x{ data[0x78:0x79].hex() }")
            print(f"79, pageLength: 0x{ data[0x79:0x7a].hex() }")
            print(f"7A, secondSIDAddress: 0x{ data[0x7a:0x7b].hex() }")
            print(f"7B, thirdSIDAddress: 0x{ data[0x7b:0x7c].hex() }")
            if(loadAddress==0):
                print(f"7E-{ hex(fs.st_size-1)[2:] }, data from 0x7E (126) to { hex(fs.st_size-1) } ({ fs.st_size })")
            else:
                print(f"7C-{ hex(fs.st_size-1)[2:] }, data from 0x7C (124) to { hex(fs.st_size-1) } ({ fs.st_size })")
