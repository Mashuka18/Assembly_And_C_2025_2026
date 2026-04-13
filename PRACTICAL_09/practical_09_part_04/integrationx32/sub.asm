section .text
global sub

sub:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]     ; a
    sub eax, [ebp+12]    ; b

    mov esp, ebp
    pop ebp
    ret

section .note.GNU-stack noalloc noexec nowrite progbits