Desert Walk
===========

- A walking simulator with almost nothing to see
- Written in x86 assembly
- Assembled with the [Netwide Assembler (NASM)](https://en.wikipedia.org/wiki/Netwide_Assembler)
- Fits in and runs from the boot sector

How to build and run
--------------------

Install `nasm` and `qemu` through your package manager
e.g. `pamac install nasm qemu`

- Build with `make build`
- Run with `make run`
- `make clean` to remove built files
- After building, you can look at `listing.txt` to determine the size of the meaningful instructions (not counting padding and the magic bytes)

Navigate the character (`%`) with the `WASD` keys.
