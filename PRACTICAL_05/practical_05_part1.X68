
    ORG    $1000
START:                  
INITIALISE:
    MOVE.B #3, D0
    MOVE.B #0, D1
    
GAME_LOOP:
    ;CMP compares two values by subtracting them, but does NOT store the result anywhere
    CMP.B #1, D0
    ;If the last comparison was not equal, jump.
    BNE GAME_POINTS    ;It jumps to a label if the Zero (Z) flag is NOT set.
    ;If the last comparison was equal, jump.
    BEQ GAME_OVER      ;It jumps to a label when the Zero (Z) flag is set.
    
GAME_POINTS:
    ADD.B #10, D1
    SUB.B #1, D0
    BRA GAME_LOOP      ;jamps back to compare
    
GAME_OVER: 

    SIMHALT             

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
