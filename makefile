brain_game: brain_game.asm
	nasm brain_game.asm -f elf64 -g -F dwarf -o brain_game.o
	ld brain_game.o -o brain_game
	mv brain_game ../bin
	rm brain_game.o
	@echo Finished, type ./brain_game to play !
