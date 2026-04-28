/*
 * NAME: Mariia Vanaga
 * STUDENTID: C00313153
 * PROJECT: m68k to x86_64 Porting Project
 * FILE: test_suite.c
 * DESCRIPTION: This C program acts as a "driver." It calls the 
 * assembly function to verify mathematical correctness.
 */

#include <stdio.h>   // Required for printf (printing to screen)
#include <stdint.h>  // Required for int64_t (ensures we use 64-bit integers)

/* * The 'extern' keyword tells the C compiler that 'register_adder' 
 * is NOT defined in this file, but exists in our assembly file.
 * C will pass the first argument (a) into the RDI register 
 * and the second argument (b) into the RSI register.
 */
extern int64_t register_adder(int64_t a, int64_t b);

int main() {
    // Print a header to the terminal for a professional look
    printf("=== Assembly Register Adder Test ===\n");

    // --- TEST 1: Basic Addition ---
    // We pass 100 and 250. The assembly should return 350 in the RAX register.
    int64_t res1 = register_adder(100, 250);
    
    // We check if the result is correct using a "ternary operator" (condition ? true : false)
    printf("Test 1: 100 + 250 = %ld -> %s\n", res1, (res1 == 350) ? "PASS" : "FAIL");


    // --- TEST 2: 64-bit Capacity Test ---
    // This test proves our assembly port can handle massive numbers 
    // that a 32-bit system (like the original m68k) might struggle with.
    int64_t a2 = 123456789012345;
    int64_t b2 = 987654321098765;
    
    // Call the assembly function with these large values
    int64_t res2 = register_adder(a2, b2);
    
    // Output the result. %ld is the formatter for a "long decimal" (64-bit integer).
    printf("Test 2: %ld + %ld = %ld -> %s\n", a2, b2, res2, (res2 == 1111111110111110) ? "PASS" : "FAIL");


    // --- TEST 3: Zero Identity Test ---
    // Adding 0 is a standard edge case in software testing. 
    // It ensures our logic doesn't break when a register contains zero.
    int64_t res3 = register_adder(0, 42);
    
    printf("Test 3: 0 + 42 = %ld -> %s\n", res3, (res3 == 42) ? "PASS" : "FAIL");

    // Return 0 tells the Operating System that the program finished successfully.
    return 0;
}