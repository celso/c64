# C64 Assembly Demo

This is a pure 6510 assembly program for the Commodore 64 made by Bright Pixel in 2019, because why not.

The C64 was a famous 8-bit machine in the 80s and the highest-selling single computer model ever.

Its hardware and architecture set it appart from other 8-bit personal computers at the time. Unlike most of the others, the C64 had dedicated advanced chips for graphics and sprites (the VIC-II), sound (the SID), and I/O (the CIA).

These chips were not only powerful for the time, but they would perform their tasks autonomously, independently of what the main CPU, a MOS technology 6510 microprocessor, was doing. The CPU and the other chips also shared common data and memory BUSes. This was impressive in the 80s, for a relatevily cheap mass-market personal computer. 

Programming the C64 was a lot of fun too, and an art. Because of all this hardware packed together, handling the machine meant knowing its memory map and registers by heart, and dominating a quite a collection of tricks, some of which weren't documented at all. What ended up being written for the C64 by the global talented fervent community of developers went way beyond the imagination of Jack Tramiel.

Today, in 2019, the cult is still alive. There are vast groups of developers still writing C64 games and demos, restoring and using old machines, or using emulators. The SID sound chip was so revolutionary that it still drives a community of chiptune artists all over the world. The [High Voltage SID Collection][1] has more than 50,000 songs archived and growing.

At Bright Pixel, we like to go low-level, and we think that understanding how things work down there, even if we're talking about a 40 years old machine, is enriching, helps us become better computer engineers and better problem solvers. This is especially important in a time when we're flooded with hundreds of high-level frameworks that just "do the job." Until they don't.

This is a simple demo for the C64:

* It was coded entirely in 6510 assembly.
* It makes use of the VIC-II graphics, character ROM and sprites.
* It plays music using the SID chip.
* Uses raster-based interrupts, perfectly timed.
* Implements a random number generator.

You can download the source code for it in [this repository][3], change it and run it a real machine or an emulator. The code is all annotated, and you can use the issue tracker to ask us questions or make suggestions, we'll be listening.

## Setup

### Assembler

We used the Kick Assembler to build the PRG from the source. KA is still maintained up until today, with regular releases launched every couple of months. It supports MOS 65xx assembler, macros, pseudo commands and has a couple of helpers to load SID and graphics files into memory. Unfortunately, you need Java to run it. Here's the setup in OSX.

Install Java

```
brew update
brew install homebrew/cask/java
```

Install Kick Assembler

```
curl http://theweb.dk/KickAssembler/KickAssembler.zip -o /tmp/KickAssembler.zip
sudo unzip /tmp/KickAssembler.zip -d /usr/local/KickAssembler
```

This should be the contents of /usr/local/KickAssembler/KickAss.cfg

```
-showmem
-vicesymbols
```

And we have this alias in our ~/.bash_profile

```
alias kick="java -jar /usr/local/KickAssembler/KickAss.jar"
```

### C64 emulator


There are plenty of Commodore 64 emulators out there. 

* [VICE][4], the Versatile Commodore Emulator, is a program that runs on a Unix, Win32, or Mac OS X machines and emulates the C64 (and every other 65xx Commodore machine too).
* [VirtualC64][5] is an interesting alternative for OSX written from scratch using C++ and native Cocoa and provides a real-time graphical inspector of the CPU, Memory, and the other Chips, while it's running.

We used VICE. One more bash alias:

```
alias c64="/Applications/x64.app/Contents/MacOS/x64"
```

### Debugging

Debugging assembly when things go south can be challenging. Back in the 80s, debugging meant spending hours doing trial and error, rebooting the machine, reload the code from the cassette (or disk drive, if you were lucky), and writing code to paper just in case you'd lose it in the process.

Luckily, now we have way better tools.

* The [C64 65XE Debugger][6] is a C64 and Atari XL/XE code and memory debugger that works in real-time and embeds the VICE emulator in the same graphical interface. It allows you to see what's happening with every chip, register, memory block; you can set breakpoints, run the program instruction by instruction, and see what's happening right in the embedded emulator.

* The VICE emulator [built-in monitor][7] can also be used to examine, disassemble, and assemble machine language programs, as well as debug them through breakpoints. It has loads of powerful features.

Where were these tools in 1986?

### Graphics

Dealing with graphics is a lot easier now too.

* [Retropixels][8] is a cross-platform command-line tool to convert any image to Commodore 64 graphical modes and file formats, including Koala (.kla or .koa), which is supported by the Kick Assembler load helpers.

* [Spritemate][9] is an online browser-based Commodore 64 sprite editor and supports importing and exporting of the most common file formats, as well as direct Kick Assembler hexadecimal arrays.




[1]: https://www.hvsc.c64.org/
[2]: http://theweb.dk/KickAssembler/
[3]: https://github.com/brpx/c64
[4]: http://vice-emu.sourceforge.net/
[5]: http://www.dirkwhoffmann.de/virtualc64/
[6]: https://sourceforge.net/projects/c64-debugger/
[7]: http://vice-emu.sourceforge.net/vice_12.html#SEC271
[8]: https://github.com/micheldebree/retropixels
[9]: https://github.com/Esshahn/spritemate

