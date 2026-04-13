section .text
global add

add:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]    ; a
    add eax, [ebp+12]   ; b
    add eax, [ebp+16]   ; c

    mov esp, ebp
    pop ebp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits