# ---------------------------------------------------------
# Variables: These act like "shortcuts" to save typing later
# ---------------------------------------------------------

ASM = nasm             # The assembler that converts .asm to .o
ASM_FLAGS = -f elf64   # Tells nasm to create a 64-bit Linux object file
CC = gcc               # The C compiler used for the test suite
CC_FLAGS = -no-pie     # Disables "Position Independent Executable" for easier linking with ASM
LD = ld                # The Linker that creates the final standalone executable

OBJ = program.o        # The name of the intermediate object file
TARGET = program       # The name of your final main program
TEST_TARGET = test_suite # The name of the testing executable

# ---------------------------------------------------------
# Targets: These are the commands you type (like 'make test')
# ---------------------------------------------------------

# The 'all' target is what runs if you just type 'make'
all: $(TARGET)

# This creates the final 'program' executable
# It depends on the .o file being finished first
$(TARGET): $(OBJ)
	$(LD) $(OBJ) -o $(TARGET)  # Link the object file into a runnable program

# This creates the 'program.o' from your 'program.asm'
$(OBJ): program.asm
	$(ASM) $(ASM_FLAGS) program.asm -o $(OBJ)

# 'make test' - This is the most complex part of the script
test: $(OBJ)
	cp $(OBJ) program_test.o            # 1. Make a copy of your object file for testing
	objcopy -L _start program_test.o    # 2. Hide the '_start' label so it doesn't fight with C's 'main'
	$(CC) $(CC_FLAGS) test_suite.c program_test.o -o $(TEST_TARGET) # 3. Compile C and ASM together
	./$(TEST_TARGET)                    # 4. Automatically run the tests immediately

# 'make run' - A quick way to build and start your program in one go
run: all
	./$(TARGET)

# 'make clean' - Deletes all generated files to start fresh
clean:
	rm -f *.o $(TARGET) $(TEST_TARGET) program_test.o

# .PHONY tells Make that these are COMMANDS, not actual filenames
.PHONY: all test clean run