*-----------------------------------------------------------
* Title      :
* Written by :Mariia Vanaga
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
DAMAGE EQU 100                        ;Whenever you see the name DAMAGE, replace it with the value 100
START:                  
GAME_LOOP:
    LEA MSG_GAME_LOOP, A1
    MOVE.B #13, D0                   ;tells the system what function to run
    TRAP #15
    ;If PLAYER_HEALTH is 0, trigger GAME_OVER. Otherwise, continue.
    CMP.B #0, PLAYER_HEALTH          ;The result is NOT stored, only the condition flags 
    BEQ GAME_OVER                    ;BEQ jumps when two values are equal.
    BSR UPDATE                       ;Saves return address on the stack so it can come back later.
    BSR COLLISION_CHECK
    BRA GAME_LOOP
    
UPDATE:
    ;The value in memory increases by 1. Move the player forward by 1 unit.
    ADD.B #1, PLAYER_POSITION
    RTS ;Back to BSR UPDATE
    
COLLISION_CHECK:
    MOVE.B PLAYER_POSITION, D1  ;Copies the value from memory PLAYER_POSITION into register D1
    ;We want to compare the player’s current position with something else like the enemy. 
    ;Using a register is faster than memory.
    CMP.B D2, D1
    BEQ COLLISION  ;BEQ jumps when two values are equal.
    RTS
    
COLLISION:
    ;Reduce the player’s health by the DAMAGE amount. If health reaches zero, the player dies
    SUB.B #DAMAGE, PLAYER_HEALTH
    BRA GAME_LOOP
    
GAME_OVER:
    LEA MSG_GAME_OVER, A1    ;Load address of string
    MOVE.B #13, D0
    TRAP #15
    
    SIMHALT             
PLAYER_POSITION: DC.B 10
ENEMY_POSITION: DC.B 50
PLAYER_HEALTH: DC.B 100

MSG_GAME_LOOP DC.B 'Game Loop........',0
MSG_GAME_OVER DC.B 'Game Over!',0

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
