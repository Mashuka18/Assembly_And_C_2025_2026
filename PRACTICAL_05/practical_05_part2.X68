*-----------------------------------------------------------
* Title      :
* Written by : Mariia Vanaga
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  
    LEA PLAYER_POSITION, A1
    LEA ENEMY_POSITION, A2
    
    MOVE.B #50, D1
    MOVE.B #0, D2
    
COLLISION_CHECK:
    CMP D2, D1        ;CMP does D1 - D2
    ;It jumps to a label when the last comparison says “less than”.
    BLT NEXT_MOVE     ;Condition: D1 < D2 = FALSE
    ;BEQ jumps when two values are equal.
    BEQ COLLISION     ;BEQ becomes true later, after D2 has been incremented many times.
     
NEXT_MOVE:
    ADD.B #1, D2
    BRA COLLISION_CHECK
    
COLLISION:
    BRA GAME_OVER
    
GAME_OVER:

    SIMHALT             
PLAYER_POSITION: DC.B 10, 15
ENEMY_POSITION: DC.B 50, 55
    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
