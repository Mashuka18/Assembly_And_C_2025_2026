*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  

    MOVE.L #ACHIEVEMENT_POINTS, A1  ;Load the address of the ACHIEVEMENT_POINTS(array) INTO A1
    MOVE.L #0, D0                    ;D0 to 0 will hold total sum, sets D0 to value 0
; Add first 5 values, summation of first 5 values  
    MOVE.L (A1)+, D2                ; Load value pointed by A1 into D2, then increment A1 by 4(because .L = 4 bytes)
    ADD.L D2, D0                    ; Adds the value in D2 to D0. Accumulates the total sum of the points.
;Each MOVE.L (A1)+, D2 moves the next value into D2, and ADD.L D2, D0 adds it to the total. Loops (manually, unrolled) through the 5 values, adding each to D0.
    MOVE.L (A1)+, D2
    ADD.L D2, D0
    
    MOVE.L (A1)+, D2
    ADD.L D2, D0
    
    MOVE.L (A1)+, D2
    ADD.L D2, D0
    
    MOVE.L (A1)+, D2
    ADD.L D2, D0

; Data: 5 long values (32-bit each. At the end, D0 contains the total sum: 5 + 10 + 15 + 20 + 30 = 80            
ACHIEVEMENT_POINTS: DC.L 5, 10, 15, 20, 30
    END    START        


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
