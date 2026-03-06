; ================================================================
; Name:        Mariia Vanaga
; Student ID:  c00313153
; Module:      Assembly and C
; Date:        6 March 2026
;
; Project Title: GALACTIC SURVIVAL COMMAND
;
; Description:
; Text-based RPG in 68K Assembly.
; Player fights progressively stronger bosses with health, energy,
; gold, weapons, shop, critical hits, boss abilities, healing.
; ================================================================

        ORG $1000                 ; Set program start address in memory
        
START:
        MOVE.B #100,$4000        ; Initialize player health to 100
        MOVE.B #1,$4002          ; Initialize player level to 1
        MOVE.B #0,$4004          ; Reset heal counter (tracks fights before auto-heal)
        MOVE.B #0,$4006          ; Store last weapon used (0 = none yet)
        MOVE.B #50,$4008         ; Initialize player energy to 50
        MOVE.W #0,$4010          ; Initialize player gold/credits to 0
        MOVE.B #0,$4012          ; Boss ID variable (will store which boss appears)
        MOVE.B #0,$4014          ; Pilot bonus counter (reduces damage for next 2 fights)
        MOVE.B #0,$4016          ; Parasite effect flag (0 = no parasite effect active)
        ; $4018 stores game mode
        ; 0 = endless survival mode
        ; 1 = campaign mode (7 levels)

        BSR WELCOME              ; Call subroutine to display welcome screen
        BSR CHOOSE_MODE          ; Ask player to choose game mode
        BSR LEVEL_LOOP           ; Start the main game loop
        SIMHALT                  ; Stop simulator when program ends

; --------------------------------
WELCOME:
        LEA WELCOME_MSG,A1       ; Load address of welcome message into address register A1
        MOVE.B #14,D0            ; TRAP function 14 = print string
        TRAP #15                 ; Call system service to display the message
        RTS                      ; Return from subroutine

; --------------------------------
CHOOSE_MODE:
        LEA MODE_MSG,A1          ; Load address of game mode selection message
        MOVE.B #14,D0            ; TRAP function to print string
        TRAP #15                 ; Display mode selection text

        MOVE.B #4,D0             ; TRAP function 4 = read integer input from user
        TRAP #15                 ; User input is stored in register D1

        CMP.B #1,D1              ; Compare input with option 1
        BEQ SET_INFINITE         ; If input = 1, jump to endless mode setup

        CMP.B #2,D1              ; Compare input with option 2
        BEQ SET_CAMPAIGN         ; If input = 2, jump to campaign mode setup

        LEA INVALID_MSG,A1       ; Load address of invalid input message
        MOVE.B #14,D0            ; Print error message
        TRAP #15
        BRA CHOOSE_MODE          ; Repeat mode selection until valid input

SET_INFINITE:
        CLR.B $4018              ; Set game mode to 0 (endless survival)
        RTS                      ; Return to caller

SET_CAMPAIGN:
        MOVE.B #1,$4018          ; Set game mode to 1 (campaign with 7 levels)
        RTS                      ; Return to caller

; --------------------------------
LEVEL_LOOP                      ; Main loop controlling the entire game progression

NEXT_LEVEL:
        BSR PARASITE_EFFECT      ; Apply parasite damage effect if parasite is active

        BSR ASK_CONTINUE         ; Ask player if they want to continue playing
        CMP.B #0,D1              ; Check if player entered 0
        BEQ END_GAME             ; If yes, exit the game

        BSR SHOW_STATS           ; Display current player statistics
        BSR RANDOM_BOSS          ; Generate which boss will appear
        BSR SHOW_BOSS            ; Display boss information
        BSR CHOOSE_WEAPON        ; Ask player to select weapon
        BSR BOSS_FIGHT           ; Execute combat logic

        MOVE.B $4000,D0          ; Load player's current health
        TST.B D0                 ; Test if health equals zero
        BEQ GAME_OVER            ; If health = 0, player loses

        BSR GIVE_REWARD          ; Give player rewards after victory
        BSR RANDOM_EVENT         ; Trigger a random event after battle

        ADDQ.B #1,$4004          ; Increase heal counter (tracks fights)
        MOVE.B $4004,D0          ; Load heal counter
        CMP.B #3,D0              ; Check if 3 fights have passed
        BNE NO_HEAL              ; If not, skip healing

        CLR.B $4004              ; Reset heal counter
        BSR HEAL_PLAYER          ; Heal the player automatically

NO_HEAL:
        ADDQ.B #1,$4002          ; Increase player level by 1

        ; --- Campaign mode check (maximum 7 levels) ---
        MOVE.B $4018,D0          ; Load game mode
        BEQ SKIP_MODE_CHECK      ; If endless mode, skip campaign check

        CMP.B #7,$4002           ; Compare current level with 7
        BLE SKIP_MODE_CHECK      ; If level ? 7 continue game

        ; Campaign completed (player passed level 7)
        BSR VICTORY              ; Display victory message
        RTS                      ; Exit main level loop

SKIP_MODE_CHECK:

        MOVE.B $4002,D0          ; Load current level
        AND.B #1,D0              ; Check if level is odd/even
        BNE SKIP_SHOP            ; If odd level, skip shop

        BSR SHOP                 ; Open shop on even levels

SKIP_SHOP:
        BRA NEXT_LEVEL           ; Jump to start next level cycle

END_GAME:
        RTS                      ; Return to main program (game finished)

; --------------------------------
SHOP                           ; Shop routine where player can buy upgrades

SHOP_PROMPT:
        LEA SHOP_MSG,A1        ; Load address of shop menu message into A1
        MOVE.B #14,D0          ; TRAP function 14 = print string
        TRAP #15               ; Display shop menu

        MOVE.B #4,D0           ; TRAP function 4 = read integer input
        TRAP #15               ; Player choice stored in D1

        CMP.B #1,D1            ; Check if player selected option 1
        BEQ BUY_HP             ; If yes, go to buy health

        CMP.B #2,D1            ; Check if player selected option 2
        BEQ BUY_EN             ; If yes, go to buy energy

        BRA SHOP_SKIP          ; Any other input = skip shop

BUY_HP                         ; Purchase health upgrade
        MOVE.W $4010,D2        ; Load player gold into D2
        CMP.W #100,D2          ; Check if player has at least 100 credits
        BLT SHOP_NOT_ENOUGH    ; If less than 100, show "not enough gold"

        SUB.W #100,$4010       ; Deduct 100 credits from player's gold
        ADD.B #50,$4000        ; Increase player health by 50

        CMP.B #100,$4000       ; Check if health exceeds maximum (100)
        BLS SHOP_SKIP          ; If ?100 continue
        MOVE.B #100,$4000      ; Cap health at maximum value 100
        RTS                    ; Return from shop routine
        
BUY_EN                         ; Purchase energy upgrade
        MOVE.W $4010,D2        ; Load player gold
        CMP.W #30,D2           ; Check if player has at least 30 credits
        BLT SHOP_NOT_ENOUGH    ; If not enough, display error

        SUB.W #30,$4010        ; Deduct 30 credits
        ADD.B #10,$4008        ; Increase energy by 10

        CMP.B #100,$4008       ; Check if energy exceeds maximum (100)
        BLS SHOP_SKIP_EN       ; If ?100 continue
        MOVE.B #100,$4008      ; Cap energy at maximum value
SHOP_SKIP_EN
        RTS                    ; Return from energy purchase
        
SHOP_NOT_ENOUGH                ; Handle insufficient gold
        LEA NO_GOLD_MSG,A1     ; Load "not enough credits" message
        MOVE.B #14,D0          ; Print string
        TRAP #15
        BRA SHOP_PROMPT        ; Return to shop menu

SHOP_SKIP
        RTS                    ; Exit shop without buying anything

; --------------------------------
SHOW_STATS                     ; Routine to display player's current stats

        LEA LEVEL_MSG,A1       ; Load message "Sector/Level"
        MOVE.B #14,D0          ; Print string
        TRAP #15

        CLR.L D1               ; Clear register D1 before printing number
        MOVE.B $4002,D1        ; Load current player level
        MOVE.B #3,D0           ; TRAP function 3 = print number
        TRAP #15

        LEA STATS_MSG,A1       ; Load "Ship Status" message
        MOVE.B #14,D0
        TRAP #15

        CLR.L D1               ; Clear register for printing
        MOVE.B $4000,D1        ; Load player health
        MOVE.B #3,D0           ; Print number
        TRAP #15

        MOVE.B $4000,D0        ; Load health value
        CMP.B #20,D0           ; Check if health is critically low (?20)
        BHI SAFE_HP            ; If health >20 skip warning

        LEA LOW_HP_MSG,A1      ; Load critical health warning message
        MOVE.B #14,D0
        TRAP #15

SAFE_HP
        LEA ENERGY_MSG,A1      ; Load energy label message
        MOVE.B #14,D0
        TRAP #15

        CLR.L D1               ; Clear D1 before printing
        MOVE.B $4008,D1        ; Load current energy
        MOVE.B #3,D0           ; Print energy value
        TRAP #15

        LEA GOLD_MSG,A1        ; Load credits label message
        MOVE.B #14,D0
        TRAP #15

        CLR.L D1               ; Clear register
        MOVE.W $4010,D1        ; Load player's gold amount
        MOVE.B #3,D0           ; Print numeric value
        TRAP #15
        RTS                    ; Return to caller
        
; --------------------------------
CHOOSE_WEAPON                 ; Routine that allows the player to select a weapon

SELECT_WEAPON
        LEA WEAPON_MSG,A1     ; Load address of weapon selection menu text
        MOVE.B #14,D0         ; TRAP function 14 = print string
        TRAP #15              ; Display weapon menu

        MOVE.B #4,D0          ; TRAP function 4 = read integer input
        TRAP #15              ; User choice stored in D1

        CMP.B #1,D1           ; Check if player chose weapon 1 (Laser)
        BEQ CHECK_REPEAT      ; If yes, verify weapon usage rules

        CMP.B #2,D1           ; Check if player chose weapon 2 (Missiles)
        BEQ CHECK_REPEAT      ; If yes, verify weapon usage rules

        CMP.B #3,D1           ; Check if player chose weapon 3 (Plasma)
        BEQ CHECK_REPEAT      ; If yes, verify weapon usage rules

        LEA INVALID_MSG,A1    ; If input is not 1, 2, or 3 > invalid input
        MOVE.B #14,D0         ; Print error message
        TRAP #15
        BRA SELECT_WEAPON     ; Ask player again

CHECK_REPEAT
        CMP.B $4006,D1        ; Compare chosen weapon with last used weapon
        BEQ SAME_WEAPON       ; If same weapon as last fight > not allowed

        CMP.B #3,D1           ; Check if player selected weapon 3 (Plasma)
        BEQ CHECK_MAGIC       ; Plasma requires energy check

        MOVE.B D1,$4006       ; Store selected weapon as last used weapon
        RTS                   ; Return to main program

CHECK_MAGIC                  ; Plasma weapon energy validation
        MOVE.B $4008,D2       ; Load player's current energy
        CMP.B #10,D2          ; Check if at least 10 energy is available
        BLT NO_ENERGY         ; If energy <10 > cannot use Plasma

        SUB.B #10,D2          ; Deduct 10 energy for Plasma weapon
        MOVE.B D2,$4008       ; Store updated energy value

        MOVE.B D1,$4006       ; Save Plasma as last used weapon
        RTS                   ; Return to main program

NO_ENERGY
        LEA NO_ENERGY_MSG,A1  ; Load "not enough energy" message
        MOVE.B #14,D0         ; Print message
        TRAP #15
        BRA SELECT_WEAPON     ; Ask player to choose weapon again

SAME_WEAPON
        LEA SAME_WEAPON_MSG,A1 ; Load weapon overheat warning message
        MOVE.B #14,D0          ; Print message
        TRAP #15
        BRA SELECT_WEAPON      ; Force player to choose a different weapon

; --------------------------------
RANDOM_BOSS                  ; Routine that determines which boss appears

        MOVE.B $4002,D0      ; Load player level
        ADD.B $4000,D0       ; Add player health (used as pseudo-random factor)
        AND.B #3,D0          ; Limit value to range 0–3
        ADD.B #1,D0          ; Convert range to 1–4
        MOVE.B D0,$4012      ; Store generated boss ID
        RTS                  ; Return

; --------------------------------
SHOW_BOSS                    ; Displays the boss that the player will fight

        MOVE.B $4012,D0      ; Load boss ID

        CMP.B #1,D0          ; Check if boss ID = 1
        BEQ B1               ; If yes > jump to Goblin/Drone boss

        CMP.B #2,D0          ; Check if boss ID = 2
        BEQ B2               ; Raider ship

        CMP.B #3,D0          ; Check if boss ID = 3
        BEQ B3               ; Battle cruiser

        CMP.B #4,D0          ; Check if boss ID = 4
        BEQ B4               ; War dreadnought

        BRA B5               ; Otherwise show final boss (Alien mothership)

B1  LEA GOBLIN,A1            ; Load text for boss type 1
    BRA PRINT_BOSS           ; Jump to print routine

B2  LEA ORC,A1               ; Load text for boss type 2
    BRA PRINT_BOSS

B3  LEA KNIGHT,A1            ; Load text for boss type 3
    BRA PRINT_BOSS

B4  LEA DRAGON,A1            ; Load text for boss type 4
    BRA PRINT_BOSS

B5  LEA DEMON,A1             ; Load text for boss type 5 (strongest enemy)

PRINT_BOSS
        MOVE.B #14,D0        ; TRAP function 14 = print string
        TRAP #15             ; Display boss message
        RTS                  ; Return to caller
        
; --------------------------------
BOSS_FIGHT                      ; Main combat routine where boss deals damage to the player

        MOVE.B $4002,D2         ; Load player level
        MULU #6,D2              ; Calculate base damage (level * 6)

        MOVE.B $4006,D3         ; Load selected weapon from previous choice

        CMP.B #1,D3             ; Check if weapon 1 (Laser Cannons) was used
        BEQ W1                  ; Jump to weapon 1 damage adjustment

        CMP.B #2,D3             ; Check if weapon 2 (Missile Barrage) was used
        BEQ W2                  ; Jump to weapon 2 damage adjustment

        CMP.B #3,D3             ; Check if weapon 3 (Plasma Cannon) was used
        BEQ W3                  ; Jump to weapon 3 damage adjustment

        BRA APPLY_DAMAGE        ; If none matched, apply base damage

W1
        SUB.B #5,D2             ; Laser Cannons reduce incoming damage by 5
        BRA CHECK_DAMAGE        ; Continue to damage validation

W2
        SUB.B #10,D2            ; Missile Barrage reduces damage by 10
        BRA CHECK_DAMAGE        ; Continue to damage validation

W3
        SUB.B #15,D2            ; Plasma Cannon reduces damage by 15

        MOVE.B $4014,D5         ; Load pilot bonus counter (if pilot was rescued)
        BEQ CHECK_DAMAGE        ; If no pilot bonus active, skip bonus

        SUB.B #10,D2            ; Pilot provides additional 10 damage reduction
        SUBQ.B #1,$4014         ; Decrease pilot bonus counter (one fight used)

CHECK_DAMAGE
        TST.B D2                ; Test if damage value is negative
        BPL DAMAGE_OK           ; If damage >= 0 continue
        CLR.B D2                ; If damage < 0 set damage to 0 (no negative damage)

DAMAGE_OK

APPLY_DAMAGE
        MOVE.B $4000,D0         ; Load current player health
        SUB.B D2,D0             ; Apply calculated damage to health

        BPL OK_HP               ; If health >= 0 continue
        CLR.B D0                ; Prevent negative health (set to 0)

OK_HP
        MOVE.B D0,$4000         ; Store updated health value
        
        SUB.B #5,D2             ; Reduce stored damage value by 5 (used for balancing)
        BPL OK_DMG              ; If still positive continue
        CLR.B D2                ; Otherwise set to 0

OK_DMG

; --- Enemy special ability (energy drain) ---

        MOVE.B $4002,D6         ; Load player level
        AND.B #2,D6             ; Check specific bit to determine if ability triggers
        BNE END_FIGHT           ; If condition not met skip enemy special ability

        MOVE.B $4008,D7         ; Load player's energy
        SUB.B #5,D7             ; Enemy drains 5 energy

        BPL OK_EN               ; If energy still positive continue
        CLR.B D7                ; Prevent negative energy

OK_EN
        MOVE.B D7,$4008         ; Store updated energy value

        LEA BOSS_SPECIAL,A1     ; Load message describing enemy special ability
        MOVE.B #14,D0           ; Print string
        TRAP #15                ; Display enemy special message

END_FIGHT
        RTS                     ; Return from combat routine
        
; --------------------------------
GIVE_REWARD                    ; Reward player after defeating a boss

        LEA REWARD_MSG,A1       ; Load victory reward message
        MOVE.B #14,D0
        TRAP #15                ; Display reward message

        MOVE.B $4002,D0         ; Load player level
        MULU #20,D0             ; Calculate gold reward (level * 20)
        ADD.W D0,$4010          ; Add reward to player's credits

        MOVE.B $4008,D0         ; Load current energy
        ADD.B #5,D0             ; Restore 5 energy after battle
        CMP.B #100,D0           ; Check if energy exceeds maximum
        BLS ENERGY_OK           ; If ?100 continue
        MOVE.B #100,D0          ; Cap energy at maximum value

ENERGY_OK
        MOVE.B D0,$4008         ; Store updated energy
        RTS                     ; Return
        
; --------------------------------
HEAL_PLAYER                    ; Automatic healing routine triggered every few fights

        LEA HEAL_MSG,A1         ; Load healing message
        MOVE.B #14,D0
        TRAP #15                ; Display repair message

        MOVE.B $4000,D0         ; Load current health
        MULU #15,D0             ; Multiply by 15
        DIVU #100,D0            ; Calculate 15% of current health
        ADD.B D0,$4000          ; Add healing amount to player's health

        CMP.B #100,$4000        ; Ensure health does not exceed maximum
        BLS OK_HEAL             ; If ?100 continue
        MOVE.B #100,$4000       ; Cap health at 100

OK_HEAL
        RTS                     ; Return
        
; --------------------------------
PARASITE_EFFECT                ; Passive damage effect from alien parasite

        MOVE.B $4016,D0         ; Load parasite flag
        BEQ NO_PARASITE         ; If flag = 0 > parasite not active

        MOVE.B $4000,D1         ; Load player health
        SUB.B #5,D1             ; Parasite drains 5 health each level

        BPL OK_PARASITE         ; If health still positive continue
        CLR.B D1                ; Prevent negative health

OK_PARASITE
        MOVE.B D1,$4000         ; Store updated health value

NO_PARASITE
        RTS                     ; Return from routine
        
; --------------------------------
ASK_CONTINUE
ASK_AGAIN
        LEA CONT_MSG,A1        ; load address of CONT_MSG string into register A1
        MOVE.B #14,D0          ; function code for printing a string
        TRAP #15               ; system call to display the text

        MOVE.B #4,D0           ; function code for reading numeric input
        TRAP #15               ; system call, user input stored in D1

        CMP.B #1,D1            ; compare entered value with 1
        BEQ VALID              ; if equal to 1 > jump to VALID

        CMP.B #0,D1            ; compare entered value with 0
        BEQ VALID              ; if equal to 0 > jump to VALID

        LEA INVALID_MSG,A1     ; load address of INVALID_MSG
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; print invalid input message
        BRA ASK_AGAIN          ; jump back to ask again

VALID
        RTS                    ; return from subroutine

; --------------------------------
GAME_OVER
        LEA OVER_MSG,A1        ; load address of GAME OVER message
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; display the message
        RTS                    ; return from subroutine

; --------------------------------
VICTORY
        LEA VICTORY_MSG,A1     ; load address of victory message
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; display the victory message
        RTS                    ; return from subroutine

; --------------------------------
RANDOM_EVENT                  ; procedure that generates a random game event

; ---- Check for parasite event every 5 levels ----

        MOVE.B $4002,D0        ; load player level from memory address $4002
        DIVU #5,D0             ; divide level by 5
        SWAP D0                ; swap high and low words (remainder moves to lower word)
        TST.W D0               ; test remainder of division
        BEQ ALIEN_PARASITE     ; if remainder is 0 > trigger parasite event

; ---- Otherwise random event ----

        MOVE.B $4002,D0        ; load player level
        ADD.B $4008,D0         ; add player's energy value
        AND.B #3,D0            ; keep only last two bits (values 0–3)

        CMP.B #0,D0            ; compare with event ID 0
        BEQ TREASURE           ; if equal > treasure event

        CMP.B #1,D0            ; compare with event ID 1
        BEQ STORM              ; if equal > storm event

        CMP.B #2,D0            ; compare with event ID 2
        BEQ STATION            ; if equal > station event

        CMP.B #3,D0            ; compare with event ID 3
        BEQ LOST_PILOT         ; if equal > lost pilot event

        RTS                    ; return if no event triggered
        
; ---------- EVENT 1 ----------
TREASURE
        LEA TREASURE_MSG,A1    ; load address of treasure message
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; display treasure message

        ADD.W #30,$4010        ; add 30 gold to player's gold at memory address $4010
        RTS                    ; return from event

; ---------- EVENT 2 ----------
STORM
        LEA STORM_MSG,A1       ; load address of storm message
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; display storm message

        MOVE.B $4008,D0        ; load player's energy
        SUB.B #10,D0           ; subtract 10 energy due to storm

        BPL OK_STORM           ; if result is positive or zero > continue
        CLR.B D0               ; otherwise set energy to 0

OK_STORM
        MOVE.B D0,$4008        ; store updated energy value
        RTS                    ; return from event

; ---------- EVENT 3 ----------
STATION

STATION_MENU
        LEA STATION_MSG,A1     ; load address of station menu message
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; display station menu

        MOVE.B #4,D0           ; function code for reading numeric input
        TRAP #15               ; read player choice into D1

        CMP.B #1,D1            ; compare choice with option 1
        BEQ REPAIR             ; if 1 > repair ship

        CMP.B #2,D1            ; compare choice with option 2
        BEQ SALVAGE            ; if 2 > salvage resources

        LEA INVALID_MSG,A1     ; load invalid input message
        MOVE.B #14,D0          ; function code for printing text
        TRAP #15               ; display invalid message

        BRA STATION_MENU       ; repeat station menu

REPAIR
        MOVE.B $4000,D0        ; load player's HP
        ADD.B #15,D0           ; repair adds 15 HP
        CMP.B #100,D0          ; check if HP exceeds maximum
        BLS HP_OK2             ; if <=100 > ok
        MOVE.B #100,D0         ; otherwise cap HP at 100
HP_OK2
        MOVE.B D0,$4000        ; store updated HP
        RTS                    ; return from repair
        
SALVAGE
        ADD.W #20,$4010        ; add 20 gold for salvaged materials
        RTS                    ; return from salvage        
; --------------------------------
; LOST PILOT EVENT

LOST_PILOT                     ; label for the "lost pilot" random event

PILOT_MENU                    ; start of pilot choice menu
        LEA PILOT_MSG,A1      ; load address of pilot event message into A1
        MOVE.B #14,D0         ; function code to print a string
        TRAP #15              ; system call to display the message

        MOVE.B #4,D0          ; function code to read numeric input
        TRAP #15              ; system call, player input stored in D1

        CMP.B #1,D1           ; compare input with option 1
        BEQ RESCUE_PILOT      ; if player chose 1 > go rescue the pilot

        CMP.B #2,D1           ; compare input with option 2
        BEQ IGNORE_PILOT      ; if player chose 2 > ignore the pilot

        LEA INVALID_MSG,A1    ; load address of invalid input message
        MOVE.B #14,D0         ; function code to print message
        TRAP #15              ; display invalid input message
        BRA PILOT_MENU        ; return to pilot menu to ask again

RESCUE_PILOT
        LEA PILOT_JOIN_MSG,A1 ; load message saying the pilot joins you
        MOVE.B #14,D0         ; function code to print string
        TRAP #15              ; display join message

        MOVE.B #2,$4014       ; set pilot bonus counter to 2 fights
        RTS                   ; return from event

IGNORE_PILOT
        LEA CARGO_MSG,A1      ; load message about taking cargo
        MOVE.B #14,D0         ; function code to print message
        TRAP #15              ; display cargo message

        ADD.W #40,$4010       ; add 40 gold to player's gold
        RTS                   ; return from event
        
; --------------------------------
; ALIEN PARASITE EVENT

ALIEN_PARASITE                ; label for alien parasite event

PARASITE_MENU                 ; start of parasite decision menu
        LEA PARASITE_MSG,A1   ; load parasite event message
        MOVE.B #14,D0         ; function code to print string
        TRAP #15              ; display the message

        MOVE.B #4,D0          ; function code to read numeric input
        TRAP #15              ; read player choice into D1

        CMP.B #1,D1           ; check if player selected option 1
        BEQ ABSORB_PARASITE   ; if yes > absorb parasite

        CMP.B #2,D1           ; check if player selected option 2
        BEQ DESTROY_PARASITE  ; if yes > destroy parasite

        LEA INVALID_MSG,A1    ; load invalid input message
        MOVE.B #14,D0         ; function code to print message
        TRAP #15              ; display invalid input
        BRA PARASITE_MENU     ; repeat menu until valid choice

ABSORB_PARASITE
        LEA PARASITE_ABSORB_MSG,A1 ; load message describing absorption
        MOVE.B #14,D0              ; function code to print string
        TRAP #15                   ; display message

        MOVE.B $4008,D0            ; load current player energy
        ADD.B #40,D0               ; increase energy by 40
        CMP.B #100,D0              ; check if energy exceeds maximum
        BLS ENERGY_OK2             ; if ?100 > ok
        MOVE.B #100,D0             ; otherwise cap energy at 100
ENERGY_OK2
        MOVE.B D0,$4008            ; store updated energy value
        MOVE.B #1,$4016            ; activate parasite effect flag
        RTS                        ; return from event
        
DESTROY_PARASITE
        LEA PARASITE_DESTROY_MSG,A1 ; load message about destroying parasite
        MOVE.B #14,D0              ; function code to print string
        TRAP #15                   ; display message

        ADD.W #10,$4010            ; reward player with 10 gold
        RTS                        ; return from event       

DATA

; ==================================================
; MAIN SCREEN / INTRO TEXT
; Messages displayed when the game starts
; ==================================================

; Game title banner
WELCOME_MSG
        DC.B 13,10
        DC.B '****************************************',13,10
        DC.B '*    GALACTIC SURVIVAL COMMAND        *',13,10
        DC.B '*        ENTER THE COSMIC ABYSS       *',13,10
        DC.B '****************************************',13,10,0

; Displays current sector (level)
LEVEL_MSG
        DC.B 13,10,'========== SECTOR ',0

; Player statistics header
STATS_MSG
        DC.B ' ==========',13,10
        DC.B '| SHIP STATUS:',13,10
        DC.B '| Integrity: ',0

; Displays current energy level
ENERGY_MSG
        DC.B 13,10,'| Power:     ',0

; Displays current gold/credits
GOLD_MSG
        DC.B 13,10,'| Credits:   ',0

; Warning message when HP becomes very low
LOW_HP_MSG
        DC.B 13,10,'| !! CRITICAL DAMAGE !!',13,10,0


; ==================================================
; COMBAT MESSAGES
; Messages related to weapon selection and battle
; ==================================================

; Weapon selection menu
WEAPON_MSG
        DC.B 13,10,'>> SELECT WEAPON SYSTEM <<',13,10
        DC.B '[1] Laser Cannons',13,10
        DC.B '[2] Missile Barrage',13,10
        DC.B '[3] Plasma Cannon (costs 10 Power)',13,10
        DC.B '> ',0

; Displayed if player tries to use plasma weapon without enough energy
NO_ENERGY_MSG
        DC.B 13,10,'!! INSUFFICIENT POWER FOR PLASMA CANNON !!',13,10,0

; Displayed if player selects the same weapon twice in a row
SAME_WEAPON_MSG
        DC.B 13,10,'!! WEAPON OVERHEAT – CHOOSE DIFFERENT SYSTEM !!',13,10,0

; Enemy special ability message (energy drain)
BOSS_SPECIAL
        DC.B 13,10,'>> ENEMY COUNTERMEASURES: -5 POWER <<',13,10,0

; Message shown after winning a fight
REWARD_MSG
        DC.B 13,10,'>> VICTORY! REWARDS ACQUIRED <<',13,10,0


; ==================================================
; ENEMIES / BOSS TYPES
; Each message represents a different enemy encounter
; ==================================================

; Weak enemy
GOBLIN
        DC.B 13,10,'>> THREAT: [SCOUT DRONE] <<',13,10,0

; Medium enemy
ORC
        DC.B 13,10,'>> THREAT: [RAIDER SHIP] <<',13,10,0

; Strong enemy
KNIGHT
        DC.B 13,10,'>> THREAT: [BATTLE CRUISER] <<',13,10,0

; Very strong enemy
DRAGON
        DC.B 13,10,'>> THREAT: [WAR DREADNOUGHT] <<',13,10,0

; Final / strongest enemy
DEMON
        DC.B 13,10,'>> THREAT: [ALIEN MOTHERSHIP] <<',13,10,0


; ==================================================
; RANDOM EVENTS
; Events that can happen between battles
; ==================================================

; Player finds treasure
TREASURE_MSG
        DC.B 13,10,'** COSMIC TREASURE FOUND! +30 CREDITS **',13,10,0

; Energy storm damages ship power
STORM_MSG
        DC.B 13,10,'** ENERGY STORM! –10 POWER **',13,10,0

; Space station event menu
STATION_MSG
        DC.B 13,10,'== ABANDONED SPACE STATION ==',13,10
        DC.B '[1] Repair ship (+15 Integrity)',13,10
        DC.B '[2] Salvage cargo (+20 Credits)',13,10
        DC.B '> ',0

; Distress signal event
PILOT_MSG
        DC.B 13,10,'=== DISTRESS SIGNAL DETECTED ===',13,10
        DC.B '[1] Rescue pilot (damage reduced for 2 fights)',13,10
        DC.B '[2] Ignore and salvage cargo',13,10
        DC.B '> ',0

; Message when pilot joins the crew
PILOT_JOIN_MSG
        DC.B 13,10,'++ PILOT JOINS CREW! DAMAGE REDUCED FOR 2 FIGHTS ++',13,10,0

; Message when cargo is salvaged
CARGO_MSG
        DC.B 13,10,'++ ABANDONED CARGO FOUND! +40 CREDITS ++',13,10,0

; Alien parasite encounter menu
PARASITE_MSG
        DC.B 13,10,'!!! ALIEN ORGANISM DETECTED !!!',13,10
        DC.B '[1] Absorb parasite (+40 Power, but –5 Integrity per level)',13,10
        DC.B '[2] Destroy parasite (+10 Credits)',13,10
        DC.B '> ',0

; Player absorbs parasite and gains energy but loses HP over time
PARASITE_ABSORB_MSG
        DC.B 13,10,'*** PARASITE ABSORBED! +40 POWER, BUT –5 HP PER LEVEL ***',13,10,0

; Player destroys parasite
PARASITE_DESTROY_MSG
        DC.B 13,10,'*** PARASITE DESTROYED! +10 CREDITS ***',13,10,0


; ==================================================
; SHOP MESSAGES
; In-game shop where player can buy upgrades
; ==================================================

SHOP_MSG
        DC.B 13,10,'=== ORBITAL TRADING POST ===',13,10
        DC.B '[1] Hull Reinforcement (+50 Integrity) – 100C',13,10
        DC.B '[2] Power Cells (+10 Power) – 30C',13,10
        DC.B '[Other] Skip',13,10
        DC.B '> ',0

; Displayed when player doesn't have enough gold
NO_GOLD_MSG
        DC.B 13,10,'!! INSUFFICIENT CREDITS !!',13,10,0


; ==================================================
; HEALING SYSTEM
; Automatic repair after several fights
; ==================================================

HEAL_MSG
        DC.B 13,10,'*** AUTOMATED REPAIR SYSTEMS ACTIVE ***',13,10
        DC.B '*** INTEGRITY RESTORED BY 15% ***',13,10,0


; ==================================================
; GAME FLOW CONTROL
; Continue / Exit prompts and game over
; ==================================================

; Ask player if they want to continue playing
CONT_MSG
        DC.B 13,10,'==========',13,10
        DC.B 'Continue mission? (1 = Yes, 0 = Exit): ',0

; Invalid input warning
INVALID_MSG
        DC.B 13,10,'!! INVALID INPUT. PLEASE CHOOSE 1 OR 0 !!',13,10,0

; Game over screen
OVER_MSG
        DC.B 13,10,'****************************************',13,10
        DC.B '*       SHIP DESTROYED – GAME OVER       *',13,10
        DC.B '*    THE VOID CLAIMS ANOTHER VESSEL...   *',13,10
        DC.B '****************************************',13,10,0


; ==================================================
; GAME MODE SELECTION
; Allows player to choose game mode
; ==================================================

; Mode selection menu
MODE_MSG
        DC.B 13,10,'=== SELECT GAME MODE ===',13,10
        DC.B '[1] Endless survival',13,10
        DC.B '[2] Campaign (7 levels)',13,10
        DC.B '> ',0

; Message shown when player wins the campaign mode
VICTORY_MSG
        DC.B 13,10,'****************************************',13,10
        DC.B '*      CONGRATULATIONS! YOU WIN!          *',13,10
        DC.B '*   You have conquered all 7 sectors!     *',13,10
        DC.B '****************************************',13,10,0

        END START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
