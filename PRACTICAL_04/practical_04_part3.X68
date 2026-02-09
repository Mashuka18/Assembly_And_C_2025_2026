
    ORG    $1000
START:   
;1               
    MOVE.B #100, $3000            ;Move health to memory location $3000
    
    LEA $3000, A1                 ;Load memory Address $3000 into address Register A1
    
    ;Saves return address on the stack so it can come back later. 
    ;Jumps to TAKING_DAMAGE    
    BSR TAKING_DAMAGE             ;Branch(Branch to SubRoutine - call subroutine) to TAKING_DAMAGE
    
BACK_IN_THE_GAME:
;3
    ;Calls another subroutine     ;Lets help this player out
    BSR HEALTH_PICKUP
    ;Jump to the GAME_END code and never come back. jamp and forget the past place.
    BRA GAME_END                  ;BRA(BRanch Always - jump)No return expected
    
TAKING_DAMAGE:
;2 
                                  ;Hit by NPC. Non player character
    ;Subtract 20 health. 
    ;Player health: 80    
    SUB.B #20, (A1)
    ;BRA jumps to BACK_IN_THE_GAME.
    ;Does not return to the BSR caller
    BRA BACK_IN_THE_GAME          ;BRA(BRanch Always)
    
HEALTH_PICKUP:
;4
    ;Health: 90
    ;RTS pops the return address
    ;Execution resumes after BSR HEALTH_PICKUP  ;Pickup Health Found
    ADD.B #10, (A1)
    ;Return to where you were called from.
    RTS                           ;RTS (ReTurn from Subroutine - return)
    
GAME_END:
                                  ;Game over. Sets health to 0
    MOVE.B #$00, (A1)
    
    SIMHALT             

    END    START     


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
