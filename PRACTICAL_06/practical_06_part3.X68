    ORG    $1000
START:                 

    LEA $4000, A7    ; Load Effective Address
                     ; A7 (stack pointer) is set to address $4000
                     ; Stack is now empty and starts at memory location $4000

    MOVE.B #1, -(A7) ; Push value 1 onto the stack
                     ; A7 becomes $3FFF
                     ; Memory[$3FFF] = 1
    MOVE.B #2, -(A7) ; Push value 2 onto the stack
    MOVE.B #3, -(A7) ; Push value 3 onto the stack
    MOVE.B #4, -(A7) ; Push value 4 onto the stack
                     ; Memory[$3FFC] = 4
    
    MOVE.B (A7)+, D1 ; Pop top value from stack into D1
                     ; 1. Read value at address in A7
                     ; 2. Then increment A7 by 1
                     ; D1 = 4
                     ; A7 becomes $3FFD
    MOVE.B (A7)+, D1 ; D1 = 3
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1 ; D1 = 1
                     ; A7 becomes $4000
                     ; Stack is now empty again
    
    SIMHALT           

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
