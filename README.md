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

You can download the source code for it in this repository, change it and run it a real machine or an emulator. The code is all annotated, and you can use the issue tracker to ask us questions or make suggestions, we'll be listening.

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


[1]: https://www.hvsc.c64.org/
[2]: http://theweb.dk/KickAssembler/
