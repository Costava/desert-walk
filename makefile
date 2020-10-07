NAME:=desertwalk

build: $(NAME).bin

$(NAME).bin: $(NAME).asm lib.asm
	nasm -f bin $(NAME).asm -o $(NAME).bin -l listing.txt

run: $(NAME).bin
	qemu-system-x86_64 -drive format=raw,file=$(NAME).bin

clean:
	rm -f ./$(NAME).bin
