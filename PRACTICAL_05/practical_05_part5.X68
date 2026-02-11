*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
DAMAGE      EQU 10 ;Damage when collision occur
POWER_HEAL  EQU 20 ;Health increase from power-up

; D0 Trap codes / counters
; D1 Player health
; D2 Array value
; D3 Player X
; D4 Enemy count
; D5 Loop counter
; A0 Array pointer
; A1 Messages
; A2 PLAYER_X pointer
; A3 ENEMY_POSITIONS pointer
; A4 POWER_UPS pointer             
START:
        LEA PLAYER_X, A2          ; Load address of PLAYER_X into A2
        LEA ENEMY_POSITIONS, A3   ; Load address of ENEMY_POSITIONS into A3
        BRA GAME_LOOP             ; Jump to main game loop


GAME_LOOP:
        BSR COUNT_ENEMIES         ; Count number of enemies in array
        MOVE.B D0, D4             ; Store enemy count in D4

        LEA MSG_GAMELOOP, A1      ; Load address of "Game Loop" message
        BSR DRAW                  ; Display the message

        BSR UPDATE                ; Update game state
        BRA GAME_LOOP             ; Repeat game loop forever


UPDATE:
        MOVE.B PLAYER_HEALTH, D1  ; Copy player health into D1

        LEA MSG_HEALTH, A1        ; Load address of "Health :" message
        BSR DRAW                  ; Display health label

        MOVE.B #3, D0             ; Trap code 3 print number in D1
        TRAP #15                  ; Execute system call

        LEA CRLF, A1              ; Load newline characters
        BSR DRAW                  ; Print newline

        CMP #0, D1                ; Compare health with 0
        BLE GAME_OVER             ; If health <= 0 ? end game

        ADD.L #1, PLAYER_X        ; Increase player X position by 1

        BSR COLLISION             ; Check for collisions with enemies
        BSR CHECK_POWERUPS        ; Check for power-up collection

        RTS                       ; Return to GAME_LOOP


DRAW:
        MOVE.B #13, D0            ; Trap code 13, print string at A1
        TRAP #15                  ; Execute system call
        RTS                       ; Return


COLLISION:
        MOVE.B #1, D5             ; Initialize loop counter to 1
        LEA ENEMY_POSITIONS, A3   ; Point A3 to enemy positions array

ITERATE_ENEMY:
        CMP D5, D4                ; Compare loop counter with enemy count
        ADD.B #1, D5              ; Increase loop counter
        BEQ DONE_ENEMY_CHECK      ; If equal ? all enemies checked
        BNE CHECK_ENEMY           ; Otherwise check next enemy

CHECK_ENEMY:
        MOVE.L (A3)+, D2          ; Load current enemy position into D2
        MOVE.L PLAYER_X, D3       ; Load player position into D3
        CMP.L D2, D3              ; Compare enemy and player positions
        BEQ REDUCE_HEALTH         ; If equal ? collision detected
        BRA ITERATE_ENEMY         ; Otherwise continue loop

REDUCE_HEALTH:
        LEA MSG_COLLISION, A1     ; Load "Collision" message
        BSR DRAW                  ; Display message

        SUB.B #DAMAGE, PLAYER_HEALTH ; Subtract DAMAGE from health

        LEA MSG_DAMAGE, A1        ; Load "Taking Damage" message
        BSR DRAW                  ; Display damage message

DONE_ENEMY_CHECK:
        RTS                       ; Return from collision routine


CHECK_POWERUPS:
        LEA POWER_UPS, A4         ; Point A4 to power-up array

POWER_LOOP:
        MOVE.L (A4)+, D2          ; Load current power-up position
        BEQ END_POWER_CHECK       ; If value = 0 ? end of array

        MOVE.L PLAYER_X, D3       ; Load player position
        CMP.L D2, D3              ; Compare player and power-up position
        BEQ APPLY_POWERUP         ; If equal ? apply power-up

        BRA POWER_LOOP            ; Otherwise continue checking

APPLY_POWERUP:
        ADD.B #POWER_HEAL, PLAYER_HEALTH ; Increase health

        LEA MSG_POWERUP, A1       ; Load "Power Up!" message
        BSR DRAW                  ; Display message

END_POWER_CHECK:
        RTS                       ; Return from power-up routine


GAME_OVER:
        LEA MSG_GAMEOVER, A1      ; Load "Game Over" message
        BSR DRAW                  ; Display message
      
    SIMHALT            
COUNT_ENEMIES:
        MOVE.B #0, D0             ; Clear enemy counter
        LEA ENEMY_POSITIONS, A0   ; Point A0 to enemy array

COUNT_LOOP:
        TST.L (A0)+               ; Test current enemy position
        BEQ END_COUNT             ; If 0 ? end of list
        ADD.B #1, D0              ; Increase enemy counter
        BRA COUNT_LOOP            ; Repeat

END_COUNT:
        RTS                       ; Return with count in D0


PLAYER_X        DC.L 1            ; Player starting X position
PLAYER_HEALTH   DC.B 100          ; Player starting health

POWER_UPS       DC.L 10, 55, 220, 0 ; Power-up positions 

ENEMY_POSITIONS DC.L 20,30,40,50,60,70,80,90,200,300,500,0 ; Enemy positions

MSG_HEALTH      DC.B 'Health : ',0
MSG_GAMELOOP    DC.B 'Game Loop',0
MSG_COLLISION   DC.B 'Collision',0
MSG_DAMAGE      DC.B 'Taking Damage',0
MSG_POWERUP     DC.B 'Power Up!',0
MSG_GAMEOVER    DC.B 'Game Over',0
CRLF            DC.B $0D,$0A,0    ; Newline characters
    END    START       


