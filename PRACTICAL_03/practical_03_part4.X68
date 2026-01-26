*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

;DC.B small values (health, lives, level)
;DC.W medium values (points, X/Y positions)
;DC.L large values (scores, timers)

   ;Load addresses into A registers. Address registers do not store values, they store addresses.

    LEA PLAYER_HEALTH, A0   ;Put the memory address of PLAYER_HEALTH into A0
    MOVE.B #$64,(A0)        ;Writes value $64 into memory
    
    LEA PLAYER_POINTS, A1 
    MOVE.W #1500, (A1)
    
    LEA PLAYER_X, A2
    LEA PLAYER_Y, A3
    LEA BOSS_HEALTH, A4
    LEA BOSS_X, A5
    LEA BOSS_Y, A6

    MOVE.B #3, PLAYER_LIVES
    MOVE.B #1, LEVEL_NUMBER  
    MOVE.B PLAYER_LIVES, D0
    MOVE.B LEVEL_NUMBER, D1 
       
    MOVE.W  #120, (A2)       ;Updates memory directly 
    MOVE.W  #80, (A3)         
    MOVE.W  #300, (A4)  
    MOVE.W  #60, (A5)        
    MOVE.W  #110, (A6)  

    MOVE.L #2500, PLAYER_SCORE
    MOVE.L #3000, BOSS_SCORE
    MOVE.L PLAYER_SCORE, D2
    MOVE.L BOSS_SCORE, D3
    
    SIMHALT             
PLAYER_HEALTH   DC.B    $00          ; Player Health
PLAYER_LIVES    DC.B    0            ; Player Lives
LEVEL_NUMBER    DC.B    0            ; Current Level

PLAYER_POINTS   DC.W    0            ; Player Points
PLAYER_X        DC.W    0            ; Player X Position
PLAYER_Y        DC.W    0            ; Player Y Position

BOSS_HEALTH     DC.W    0            ; Boss Health
BOSS_X          DC.W    0            ; Boss X Position
BOSS_Y          DC.W    0            ; Boss Y Position


PLAYER_SCORE    DC.L    0            ; Player Total Score
BOSS_SCORE      DC.L    0            ; Boss Total Score
    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
