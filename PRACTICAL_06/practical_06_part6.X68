    ORG    $1000
START:                 

    MOVE.L #HEALTH, -(SP) 
    
    MOVE.B #14, D0
    MOVE.B #14, D1
    
    MOVE.L D0, -(SP)
    MOVE.L D1, -(SP)
    
    JSR GAME_LOOP
    BSR HEADS_UP_DISPLAY
    BRA END_GAME
    
GAME_LOOP:                     ;0(SP)  = return address
                               ;4(SP)  = D1
                               ;8(SP)  = D0
                               ;12(SP) = HEALTH address

    MOVE.L 4(SP),D1
    MOVE.L 8(SP),D0
    
    CMP D0, D1
    BEQ DAMAGE               ;Branch if equal = YES = go to DAMAGE
    BRA NO_DAMAGE
    
DAMAGE: 
    
    MOVE.L 12(SP),A1        ;So A1 now points to HEALTH.
                            ;12(SP) contains HEALTH address.
    SUB.B #10, (A1)
    
NO_DAMAGE:

    RTS
    
HEADS_UP_DISPLAY:

    MOVE.B HEALTH, D1
    MOVE.B #3, D0          ;D0 = 3 = print number in D1
    TRAP #15
    RTS

END_GAME
    SIMHALT          

HEALTH: DC.B 100

    END    START        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
