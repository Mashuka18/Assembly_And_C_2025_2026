;------------------------------------------------------------------------------
; Name: Mariia Vanaga
; StudentID: C00313153
; Title: Expert-Level Secure Parameter Passing (x86_64)
; Description: Ported from Motorola 68000. Replicates a 3-loop running sum.
; Features: Full input validation, alphabet rejection, rejection of 
; negative/decimal numbers, and overflow recovery.
;------------------------------------------------------------------------------

section .data                           ; This section holds variables that are already set
    PROMPT      db "Enter number: ", 0  ; db = 'define bytes'. The 0 is a null terminator
    PROMPT_L    equ $ - PROMPT          ; Calculate length: Current address ($) minus start address
    RESULT      db "The sum is: ", 0    ; Message for each loop
    RESULT_L    equ $ - RESULT
    FINAL_RES   db "Final sum is: ", 0  ; Message for the end
    FINAL_L     equ $ - FINAL_RES
    
    ; Error messages
    ERR_ALPHA   db "Error: Invalid input! Please enter digits only.", 10, 0
    ERR_ALPHA_L equ $ - ERR_ALPHA
    ERR_OVF     db "Error: Arithmetic Overflow! Number too large.", 10, 0
    ERR_OVF_L   equ $ - ERR_OVF
    ERR_SPEC    db "Error: Invalid input! Negative numbers and decimals are not allowed.", 10, 0
    ERR_SPEC_L  equ $ - ERR_SPEC
    
    CRLF        db 10, 0                ; 10 is the ASCII code for a New Line

section .bss                            ; Section for empty buffers (space we reserve)
    NUM_BUF     resb 64                 ; Reserve 64 bytes for user typing
    STR_BUF     resb 64                 ; Reserve 64 bytes for building strings to print

section .text                           ; This is where the actual logic starts
    global _start                       ; Tell the OS where the entry point is
    global register_adder               ; Make this function visible to our C test script

_start:
    xor r12, r12            ; Clear R12 (set to 0). This will hold our running total.
    mov r13, 3              ; Put 3 into R13. This is our loop counter.

GAME_LOOP:
.get_n1:                    ; Local label for first number
    mov rsi, PROMPT         ; Put the prompt address into RSI (source index)
    mov rdx, PROMPT_L       ; Put the length into RDX (data register)
    call print_string       ; Call our helper to show the prompt on screen
    call read_int_secure    ; Call our helper to get a number from the user
    
    cmp rax, -1             ; Did the user type a letter? (RAX = -1)
    je .invalid_alpha       ; jump if equal to the alphabet error handler
    cmp rax, -2             ; Is the number too big? (RAX = -2)
    je .invalid_ovf         ; jump if equal to the overflow error handler
    cmp rax, -3             ; Did they type - or .? (RAX = -3)
    je .invalid_special     ; jump if equal to the special character handler
    
    mov r14, rax            ; No errors! Move the first number into R14 to save it
    jmp .get_n2             ; Proceed to get the second number

.get_n2:                    ; Local label for second number
    mov rsi, PROMPT         ; Load prompt again
    mov rdx, PROMPT_L
    call print_string
    call read_int_secure    ; Get the second number
    
    cmp rax, -1             ; Check for errors again
    je .invalid_alpha
    cmp rax, -2
    je .invalid_ovf
    cmp rax, -3
    je .invalid_special
    
    mov rdi, r14            ; Put first number in RDI (1st argument for adder)
    mov rsi, rax            ; Put second number in RSI (2nd argument for adder)
    call register_adder     ; Call our math function
    jo .invalid_ovf_res     ; If the addition overflowed, jump to error
    
    add r12, rax            ; Add the result of the addition to our running total (R12)
    jo .invalid_ovf_res     ; If the running total overflowed, jump to error

    push rax                ; Save the addition result on the stack
    mov rsi, RESULT         ; Load "The sum is: " string
    mov rdx, RESULT_L       
    call print_string       ; Print the label
    pop rdi                 ; Take the addition result off the stack into RDI
    call print_int          ; Print the actual number
    call print_newline      ; Print a new line

    dec r13                 ; Subtract 1 from our loop counter (R13)
    jnz GAME_LOOP           ; If R13 is not zero, go back to GAME_LOOP

    mov rsi, FINAL_RES      ; All loops done! Load "Final sum is: "
    mov rdx, FINAL_L
    call print_string
    mov rdi, r12            ; Put our running total into RDI
    call print_int          ; Print the final total
    call print_newline

    mov rax, 60             ; Syscall number 60 is 'exit'
    xor rdi, rdi            ; Set exit code to 0 (Success)
    syscall                 ; Tell the Linux kernel to close the program

; --- These handle showing errors and jumping back to try again ---
.invalid_alpha:
    mov rsi, ERR_ALPHA      ; Load alphabet error message
    mov rdx, ERR_ALPHA_L
    call print_string
    jmp .get_n1             ; Try getting the numbers again

.invalid_special:
    mov rsi, ERR_SPEC       ; Load negative/decimal error message
    mov rdx, ERR_SPEC_L
    call print_string
    jmp .get_n1

.invalid_ovf:
.invalid_ovf_res:
    mov rsi, ERR_OVF        ; Load overflow error message
    mov rdx, ERR_OVF_L
    call print_string
    jmp .get_n1

; --- The math function ---
register_adder:
    mov rax, rdi    ; Take the first number (from C)
    add rax, rsi    ; Add the second number (from C)
    ret             ; Go back to C with the answer in RAX

; --- The secure input function ---
read_int_secure:
    mov rax, 0              ; Syscall 0 is 'read'
    mov rdi, 0              ; File Descriptor 0 is 'stdin' (keyboard)
    mov rsi, NUM_BUF        ; Where to save the typed characters
    mov rdx, 63             ; Max 63 characters (security: avoids buffer overflow)
    syscall                 ; Pause and wait for user to type and press Enter
    mov r8, rax             ; RAX now holds how many characters they typed
    
    cmp r8, 1               ; If they just hit Enter without typing, it's 1 byte (\n)
    jle .error_alpha        ; Error if they typed nothing

    xor rax, rax            ; Start our number at 0
    mov rcx, NUM_BUF        ; Point RCX to the first typed character
.parse_loop:
    movzx rdx, byte [rcx]   ; Load 1 character into RDX. Zero-extend (movzx) it.
    
    cmp rdx, 10             ; Is this character the 'Enter' key (\n)?
    je .done                ; If yes, we are finished reading this number
    
    cmp rdx, '-'            ; Is it a minus sign?
    je .error_special
    cmp rdx, '.'            ; Is it a dot?
    je .error_special
    
    cmp rdx, '0'            ; Is the character smaller than ASCII '0'?
    jb .error_alpha         ; If yes, it's not a digit
    cmp rdx, '9'            ; Is it larger than ASCII '9'?
    ja .error_alpha         ; If yes, it's not a digit
    
    sub rdx, '0'            ; Convert ASCII (like '5') to raw number (5)
    imul rax, 10            ; Multiply current total by 10 (moving digits left)
    jo .error_ovf           ; If it becomes too big for 64-bit, error
    add rax, rdx            ; Add our new digit
    jo .error_ovf           ; Check for overflow again
    
    inc rcx                 ; Move to the next typed character
    dec r8                  ; Reduce characters-left counter
    jnz .parse_loop         ; If characters left, repeat loop
.done:
    ret

.error_alpha:
    mov rax, -1             ; Return -1 to signal alphabet error
    ret
.error_ovf:
    mov rax, -2             ; Return -2 to signal overflow error
    ret
.error_special:
    mov rax, -3             ; Return -3 to signal negative/decimal error
    ret

; --- Helper to turn numbers into text on screen ---
print_int:
    mov rax, rdi            ; Put number to print in RAX
    mov rcx, STR_BUF + 63   ; Go to the very end of our string buffer
    mov byte [rcx], 0       ; Put a 0 there to end the string
    mov rbx, 10             ; We divide by 10 to get each digit
.loop:
    xor rdx, rdx            ; Clear RDX for division
    div rbx                 ; RAX / 10. Quotient in RAX, Remainder in RDX.
    add dl, '0'             ; Turn remainder (digit) into ASCII
    dec rcx                 ; Move buffer pointer backward
    mov [rcx], dl           ; Store the digit character
    test rax, rax           ; Is RAX 0 yet?
    jnz .loop               ; If not, keep dividing
    
    mov rsi, rcx            ; RSI now points to the first digit of our string
    mov rdx, STR_BUF + 63   ; Load the end address
    sub rdx, rcx            ; End minus Start = Total string length
    call print_string       ; Print it!
    ret

print_string:
    mov rax, 1              ; Syscall 1 is 'write'
    mov rdi, 1              ; File Descriptor 1 is 'stdout' (screen)
    syscall                 ; Tell Linux to show the string
    ret

print_newline:
    mov rsi, CRLF           ; Load address of the newline character
    mov rdx, 1              ; Length is 1 byte
    call print_string
    ret

; Security measure to prevent hackers from running code on the stack
section .note.GNU-stack noalloc noexec nowrite progbits