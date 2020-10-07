NAME:=desertwalk
LISTING:=listing.txt

build: $(NAME).bin

$(NAME).bin: $(NAME).asm lib.asm
	nasm -f bin $(NAME).asm -o $(NAME).bin -l $(LISTING)

run: $(NAME).bin
	qemu-system-x86_64 -drive format=raw,file=$(NAME).bin

clean:
	rm -f ./$(NAME).bin
	rm -f ./$(LISTING)
