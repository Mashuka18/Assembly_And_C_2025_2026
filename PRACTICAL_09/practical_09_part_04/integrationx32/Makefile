EXECUTABLE=IntegratingCandASM

all:
	nasm -f elf add.asm -o add.o
	nasm -f elf sub.asm -o sub.o
	gcc -m32 -c main.c
	gcc -m32 main.o add.o sub.o -o $(EXECUTABLE)
	./$(EXECUTABLE)

clean:
	rm -rf *.o *.lst $(EXECUTABLE)