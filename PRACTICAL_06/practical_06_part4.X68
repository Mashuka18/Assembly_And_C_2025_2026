    ORG    $1000
START:                  

    LEA $4000, SP     ; Load Effective Address
                      ; Set Stack Pointer (A7) = $4000
                      ; Stack grows DOWN in memory
    
    MOVE.B #1, -(SP)  ; Push 1 onto stack
                      ; Pre-decrement:
                      ; SP = SP - 1  --> $3FFF
                      ; Memory[$3FFF] = 1
    MOVE.B #2, -(SP)
    MOVE.B #3, -(SP)
    MOVE.B #4, -(SP)  ; 4 is now at the top of the stack

    MOVE.B (SP)+, D1  ; Pop value into D1
                      ; Read Memory[$3FFC] ? 4
                      ; D1 = 4
                      ; Post-increment: SP = $3FFD
    MOVE.B (SP)+, D1
    MOVE.B (SP)+, D1
    MOVE.B (SP)+, D1  ; Pop next value
                      ; D1 = 1
                      ; SP = $4000
                      ; Stack is now empty again

    SIMHALT             

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
