    ORG    $1000
START:
;1               
    MOVE.B #100, $3000            ;Move player health to memory location $3000
    
    LEA $3000, A1
    ;Load address of player health into address register A1
    MOVE.B #1, $3001            ;Player flags = Alive
    MOVE.B #0, $3002            ;Player points = 0

    
    MOVE.B #$12, D2            ;Player position: X=1, Y=2  -> 0001 0010
    MOVE.B #$22, D3            ;NPC position:    X=2, Y=2  -> 0010 0010
    
    MOVE.B #100, $3004          ;Boss health
    MOVE.B #$35, D4             ;Boss X=2, Y=2
    
    AND.B D2, D3               ;Bitwise AND D2 and D3 to detect overlap
    ;Saves return address on the stack so it can come back later. 
    ;Jumps to TAKING_DAMAGE    
    BSR TAKING_DAMAGE             ;Branch(Branch to SubRoutine - call subroutine) to TAKING_DAMAGE
    
BACK_IN_THE_GAME:
;3
    ;Calls another subroutine     ;Lets help this player out
    ;Saves return address on the stack so it can come back later. 
    BSR HEALTH_PICKUP
    ;OR turns bits on
    ;EOR toggles bits
    ;This way, you can store multiple states in a single byte
    OR.B #4, $3001                 ;Set Invincible (turn on Bit2)
    
    EOR.B #4, $3001                ;toggles Power-up Bit(flip Bit2)
    
    ;Jump to the GAME_END code and never come back. jamp and forget the past place.
    BRA GAME_END                  ;BRA(BRanch Always - jump)No return expected
    
;-----------------------------------------------------------------------------------
;Subroutines
;-----------------------------------------------------------------------------------
    
TAKING_DAMAGE:
;2 
                                  ;Hit by NPC. Non player character
    ;Subtract 40 health. 
    ;Player health: 60    
    SUB.B #40, (A1)
    ; Return to caller
    RTS
    
HEALTH_PICKUP:
;4
    ;Health: 80
    ;RTS pops the return address
    ;Execution resumes after BSR HEALTH_PICKUP  ;Pickup Health Found
    ADD.B #20, (A1)
    ; Return to caller
    RTS                           ;RTS (ReTurn from Subroutine - return)
    
;-----------------------------------------------------------------------------------
;Game Ends
;-----------------------------------------------------------------------------------  
  
GAME_END:
                                  ;Game over. Sets health to 0
    MOVE.B #$00, (A1)                 
    SIMHALT             

    END    START       


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
