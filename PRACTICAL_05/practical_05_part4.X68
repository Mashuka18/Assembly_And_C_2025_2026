*-----------------------------------------------------------
* Title      :
* Written by :Mariia Vanaga
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
    
;D0 Used for Trap codes, And Counting ENEMIES
;D1 Used for Players Health 
;D2 Used for enemy positions
;D4 Used for Enenmy Count
;A0 for counting Enemied 
;A1 for progress messages
;A2 used for PLAYER_X
;A3 used for ENEMY_POSITIONS

DAMAGE      EQU 10           ;Damage when collision occur

START:                 
    LEA PLAYER_X, A2         ;Player will move along X axis
    LEA ENEMY_POSITIONS, A3  ;Enemy possitions or spawn points 
    BRA GAME_LOOP
    
GAME_LOOP:
    BSR COUNT_ENEMIES        ;Size of the ENEMY_POSITIONS Array 
    MOVE.B D0, D4            ;Reset Enemy count at begining of loop 
    
    LEA MSG_GAMELOOP, A1     ;load and Draw Gameloop Message
    BSR DRAW                 
    
    BSR UPDATE               ;Call UPDATE
    BRA GAME_LOOP            ;Call GAME_LOOP
    
UPDATE:
    MOVE.B PLAYER_HEALTH, D1 ;Move Payer health into D1
    
    LEA MSG_HEALTH, A1       ;Load and Draw Health message
    BSR DRAW                 ;print whatever string A1 is pointing at right now
    
    MOVE.B #3, D0            ;Display signed number in D1.L in decimal in smallest field
    TRAP #15
    
    ;Put the memory address of CRLF into register A1 ($0D,$0A,0)
    LEA CRLF, A1             ;Load and Carriage Return and Line Feed
    BSR DRAW
    
    CMP #0, D1               ;Chech if Health is 0
    ;Branch if Less or Equal if D1 is 0 or negative, go to GAME_OVER
    BLE GAME_OVER            ;Game Over 
    ADD.L #1, (A2)           ;Change X position of Player 
    BSR COLLISION            ;Check for collisions with ENEMIES
    RTS
    
DRAW: 
    MOVE.B #13, D0
    TRAP #15
    RTS
    
COLLISION:
    MOVE.B #1, D5          ;Loop through Array
    LEA ENEMY_POSITIONS, A3  ;Load ENEMY_POSITIONS Array
    
ITERATE:
    CMP D5, D4             ;Counter for ENEMY_POSITIONS 
    ADD.B #1, D5           ;Subtract one
    BEQ GAME_LOOP          ;If 0 goto GAME_LOOP
    ;BNE - jump to label if the last comparison was not equal
    BNE CHECK_ENEMIES      ;If not Check for Enemy collisions
    RTS
    
CHECK_ENEMIES:
    MOVE.L (A3)+, D2       ;Move ENMIES POSITIONS TO d2
    MOVE.L (A2), D3        ;Move Player position to D3
    
    CMP.L D2, D3           ;Compare Player and Enemy position
    BEQ REDUCE_HEALTH      ; If Equal reduce Health
    BNE ITERATE            ;iterateto next Enemy
    
REDUCE_HEALTH:
    LEA MSG_COLLISION, A1  ;Load and Draw Collision Message
    BSR DRAW
    
    SUB.B #DAMAGE, PLAYER_HEALTH  
    
    LEA MSG_DAMAGE, A1     ;Load and Draw Damage message
    BSR DRAW
    
    BRA GAME_LOOP
    
GAME_OVER:
    LEA MSG_GAMEOVER, A1
    BSR DRAW
    SIMHALT             
COUNT_ENEMIES:
    MOVE.B #0, D0         ;Initialize counter to 0
    LEA ENEMY_POSITIONS, A0  ;load the address of the array into A0
    
COUNT_ENEMIES_LOOP:
    ;looks at the long value in memory, increments A0, sets flags
    TST.L (A0)+           ;Test the byte at the address iin A0 (check if 0) and increment A0
    ;if that value was 0, stop counting
    BEQ END_COUNTING      ;If the byte is zero, it's the end of the array
 
    ADD.B #1, D0          ; Increment the counter
    BRA COUNT_ENEMIES_LOOP  ;Repead the loop

END_COUNTING:
    RTS

PLAYER_X DC.L 1
PLAYER_HEALTH DC.B 100
MSG_HEALTH DC.B 'Health : ', 0
MSG_GAMELOOP DC.B 'Game Loop', 0
MSG_COLLISION DC.B 'Collision', 0
MSG_GAMEOVER DC.B 'Game Over', 0
MSG_DAMAGE DC.B 'Taking Damage', 0
CRLF DC.B $0D,$0A,0
ENEMY_POSITIONS DC.L 20, 30, 40 ,50 ,60, 70, 80, 90, 200, 300, 500, 0  ;Terminate Array with a 0

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
