    ORG    $1000
START:                  

    MOVE.L #HEALTH, -(SP)   ; Push address of HEALTH onto stack (argument)
    ;JSR: Go run the code named GAME_LOOP, and when you're done there, come back here and continue.
    ;JSR = jump to a subroutine anywhere in memory.
    JSR GAME_LOOP           ; Call GAME_LOOP subroutine
    ;BSR = jump to a nearby subroutine (relative jump).
    BSR HEADS_UP_DISPLAY    ; Call HEADS_UP_DISPLAY subroutine
    BRA END                 ; Skip subroutines and go to END 
     
GAME_LOOP:
    MOVE.L 4(SP),A1         ; Get address of HEALTH from stack
                            ; Loads that value (address of HEALTH) into address register A1.
                            ;4(SP) = first argument
    SUB.B #10, (A1)         ; HEALTH = HEALTH - 10
    RTS                     ; Return to caller
    
HEADS_UP_DISPLAY:
    LEA MESSAGE, A1         ; Load address of MESSAGE string 
    MOVE.B #14, D0          ; TRAP task 14 = print string
    TRAP #15                ; Call system service
    MOVE.B HEALTH, D1       ; Load HEALTH value into D1
    MOVE.B #3, D0           ; TRAP task 3 = print number in D1 
    TRAP #15                ; Call system service
    RTS                     ; Return
    
HEALTH: DC.B 100            ; Health variable
MESSAGE: DC.B 'Health:', 0  ; Null-terminated string

    SIMHALT             

    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
