.data

    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words
    FrameBuffer: .space 0x80000  # allocate space for 512 x 256 bitmap
   
    RED: .word 0x00FF0000  # card numbers / letters and losing screen
    GREEN: .word 0x00006400  # poker table middle
    BROWN: .word 0x006B3410  # poker table edges
    BLACK: .word 0x00000000  # card borders
    WHITE: .word 0x00FFFFFF  # card backgrounds
    LIME: .word 0x0000FF00  # winning screen
    GRAY: .word 0x00D3D3D3  # push (tie) screen
    GOLD: .word 0x00FFD700
    BLUE: .word 0x000000CD  # ^ denotes split
   
    InitialMessage1: .asciiz "\n\n\nOnly integers are accepted as wagers.\n YOUR STARTING CHIP COUNT: 1000"
    EndMessage: .asciiz "\n YOU SUCK AT GAMBLING\n"
    
    PromptWager: .asciiz "\nEnter your wager: "
    FaultyWager: .asciiz "Insufficient funds, try again."
    
    HSDP: .asciiz "\nPress 'h' to hit, 's' to stand, 'p' to split, or 'd' to double down: "
    LHSD: .asciiz "\nOn your first (left) hand: Press 'h' to hit, 's' to stand, or 'd' to double down: "
    RHSD: .asciiz "\nOn your second (right) hand: Press 'h' to hit, 's' to stand, or 'd' to double down: "
    HSD: .asciiz "\nPress 'h' to hit, 's' to stand, or 'd' to double down: "
    LHS: .asciiz "\nOn your first (left) hand: Press 'h' to hit, or 's' to stand: "
    RHS: .asciiz "\nOn your second (right) hand: Press 'h' to hit, or 's' to stand: "
    HS: .asciiz "\nPress 'h' to hit or 's' to stand: "
    FaultyAction: .asciiz "\nInvalid key. Retry."
    
    WinMessage: .asciiz "\nYou Win!\n YOUR CHIP COUNT: "
    WonLeftLostRight: .asciiz "\nYou won your first hand, but lost your second.\n YOUR CHIP COUNT: "
    LostLeftWonRight: .asciiz "\nYou lost your first hand, but won your second.\n YOUR CHIP COUNT: "
    LossMessage: .asciiz "\nYou Lose!\n YOUR CHIP COUNT: "
    TieMessage: .asciiz "\nPush!\n YOUR CHIP COUNT: "
    PushedLeftWonRight: .asciiz "\nYour first hand pushed, but you won your second.\n YOUR CHIP COUNT: "
    WonLeftPushedRight: .asciiz "\nYour won your first hand, but your second pushed.\n YOUR CHIP COUNT: "
    PushedLeftLostRight: .asciiz "\nYour first hand pushed, but you lost your second.\n YOUR CHIP COUNT: "
    LostLeftPushedRight: .asciiz "\nYour lost your first hand, but your second pushed.\n YOUR CHIP COUNT: "
    
    ReshuffleMessage1: .asciiz "\nPrevious Deck >> "
    ReshuffleMessage2: .asciiz " (11 - J | 12 - Q | 13 - K | 14 - A)"
    ReshuffleMessage3: .asciiz "\nDeck has been reshuffled\n"
    ReshuffleMessage4: .asciiz "\n YOUR CHIP COUNT: "
   
    .align 2
    BaseDeck: .space 208  # stores unshuffled deck
    UserDeck: .space 208  # stores shuffled deck
    DeckFlags: .space 52  # 52 bool toggles used when filling the shuffled deck
    
    UserBustAddr1: .word 0  # stores addr of the users card count (over 21 is a bust)
    UserBustAddr2: .word 0  # stores addr of the right hand after the user splits (left hand goes to addr1)
    DealerBustAddr: .word 0  # stores addr of dealers card count
    UserAceCountAddr1: .word 0  # stores addr of user ace count; needed when aces have to go low (from 11 to 1)
    UserAceCountAddr2: .word 0  # if the user splits, this takes the right half (left goes to addr1)
    DealerAceCountAddr: .word 0  # stores addr of dealer ace count
    
    CardType: .word 0  
    Card1: .word 0  # ^ both used to identify a user pair
    
    Bank: .word 1000  # chip count
    Wager1: .word 0
    Wager2: .word 0  # in case of split
    
    ReshuffleBool: .word 0  # toggled when we want to reshuffle (~34 dealt cards)
    DealerOffset: .word 0  # if the dealer has more than 6 cards, we use this to stagger 7, 8, ...
    
    LeftOrRight: .word 0
    SplitDoubleCount: .word 0  # allows us to check doubling availability on split hands 
    SplitBool: .word 0  # set to 1 when we are splitting. alloows us to hijack other protocols instead of rebuilding them
    LeftSplitResult: .word 0  # used for the end screen; 0 is a loss, 1 a push (tie), 2 a win
    SplitOffset: .word 0  # used for hijacking functions from split
    DoubleBustBool: .word 0  # if we bust on both hands of the split, we dont want to see the dealers cards
   
.text
.globl main
main:

    la $s7, FrameBuffer  # $s7 = base addr of frame buffer
    ## $s7 CANNOT BE OVERRIDDEN / OVERWRITTEN

    initial_message:
    	li $v0, 4
    	la $a0, InitialMessage1
    	syscall

## Shuffle Block
##############################################################################################################################################################################
    j shuffle_deck  # first time through, we do not want to run reshuffle
    reshuffle_deck: 
        ## Print previous deck
        li $v0, 4  # print string
        la $a0, ReshuffleMessage1
        syscall
        
        la $t0, UserDeck
        li $t1, 0
        li $t4, 52
        print_loop:
            mul $t2, $t1, 4
            add $t3, $t0, $t2 # card addr = deck base addr ($t0) + index (^ bytes to words)
            lw  $a0, 0($t3)  # load card type into print slot ($a0)
            li  $v0, 1  # print int
            syscall
            li  $a0, 32  # ascii for space
            li  $v0, 11  # print char
            syscall
            addi $t1, $t1, 1
            blt  $t1, $t4, print_loop  # loop for every card
            
        li $v0, 4
        la $a0, ReshuffleMessage2
        syscall
        la $a0, ReshuffleMessage3
        syscall
        la $a0, ReshuffleMessage4
        syscall
        li $v0, 1
        la $t0, Bank
        lw $t1, 0($t0)
        move $a0, $t1  # print value in bank
        syscall
            
        la $t0, ReshuffleBool
        sw $zero, 0($t0)  # ^ reset reshufflebool to 0
        
    shuffle_deck:
        li $s6, -4  # we iterate through this when pulling from our shuffled deck; once it reaches 140 (35 * 4) we toggle a reshuffle
        ## $s6 CANNOT BE OVERRIDDEN / OVERWRITTEN PAST THIS POINT (here we reset it everytime we shuffle a new deck)
        
        # Fill an ordered deck
        la $t0, BaseDeck
        li $t1, 2  # deck inputs
        li $t2, 0  # i = 0
        li $t3, 4  # four of each card
        li $t4, 15  # we stop at aces (14)
        unshuffled_loop:
            sw $t1, 0($t0)  # load $t1 into the deck
            addi $t0, $t0, 4  # move to the next index (words i.e. 4 bytes)
            addi $t2, $t2, 1  # i += 1
            bne $t2, $t3, unshuffled_loop  # input the same value 4 times
            addi $t2, $t2, -4  # reset count
            addi $t1, $t1, 1  # after four loops increment the input (4 cards of each value)
            bne $t1, $t4, unshuffled_loop  # once we have put in all of our aces (14) we are done
        # ^ initialize an unshuffled deck with four of each card. 11 = J, 12 = Q, 13 = K, 14 = A
        
        # Load base addr of deck flags (booleans for each card; ensures 4 cards of each type will be in the shuffled deck
        la $t0, DeckFlags 
        li $t1, 0  # i += 1
        li $t2, 52
        flag_loop:
            sb $zero, 0($t0)
            addi $t0, $t0, 1  # move to next byte in the flag
            addi $t1, $t1, 1  # i += 1
            bne $t1, $t2, flag_loop
        # ^ initialize all deck flags to 0, indicating their slots are filled
        
        addi $t7, $zero, 0
        addi $t8, $zero, 204  # (51 * 4) -- (bytes to words)
        shuffle_loop:
            li $v0, 42  # generate random integer
            li $a0, 0
            li $a1, 52  # ^ between 0 and 51
            syscall
            move $t9, $a0  # store it in $t9
            
            la $t0, DeckFlags
            add $t1, $t0, $t9  # random index from deck flags stored in $t1
            lb $t2, 0($t1)  # load random bit from deck flags
            bne $t2, $zero, shuffle_loop  # try again if we have already used it (no longer 0)
            li $t2, 1 
            sb $t2, 0($t1)  # ^ mark index as used (1)
            
            la $t0, BaseDeck
            mul $t2, $t9, 4  # btyes to words
            add $t3, $t0, $t2  # store the random index of our base deck in $t3
            lw $t4, 0($t3)  # store the random value from our base deck in $t4
            
            la $t0, UserDeck
            add $t3, $t0, $t7  # start at the beginning of the user deck and ascend
            sw $t4, 0($t3)  # store the random value from the base deck in the user deck
            addi $t7, $t7, 4
            ble $t7, $t8, shuffle_loop
##############################################################################################################################################################################
            
## Initializer Block    
##############################################################################################################################################################################
    # always back the background after shuffling; allow fall through           
    make_background:
        la $t0, UserBustAddr1
        sw $zero, 0($t0)
        la $t0, UserBustAddr2
        sw $zero, 0($t0)
        la $t0, DealerBustAddr
        sw $zero, 0($t0)
        la $t0, UserAceCountAddr1
        sw $zero, 0($t0)
        la $t0, UserAceCountAddr2
        sw $zero, 0($t0)
        la $t0, DealerAceCountAddr
        sw $zero, 0($t0) 
        la $t0, DealerOffset
        sw $zero, 0($t0)
        la $t0, SplitDoubleCount
        sw $zero, 0($t0)
        la $t0, LeftOrRight
        sw $zero, 0($t0)
        la $t0, SplitBool
        sw $zero, 0($t0)
        la $t0, LeftSplitResult
        sw $zero, 0($t0)
        la $t0, SplitOffset
        sw $zero, 0($t0)
        la $t0, Card1
        sw $zero, 0($t0)
        la $t0, CardType
        sw $zero, 0($t0)
        la $t0, DoubleBustBool
        sw $zero, 0($t0)
        # reset all of our bust counts, ace counts, split checks, etc
    
        la $t0, Bank
        lw $t1, 0($t0)
        bgt $t1, $zero, play_on  # if the user is not out of money, they continue
            li $v0, 4
            la $a0, EndMessage
            syscall
            li $v0, 10  # end program
            syscall
        play_on:
    
        li $t0, 512  # screen width
        li $t1, 256  # screen height
        mul $t2, $t0, $t1  # total pixels = width * height
        mul $t2, $t2, 4  # bytes to words

        la $t0, BROWN
        lw $t0, 0($t0)  # $t0 = brown
        la $t1, GREEN
        lw $t1, 0($t1)  # $t1 = green

        li $t3, 0  # i = 0; i will iterate across every pixel on the map
        fill_brown:
            add $t4, $s7, $t3  # addr = frameBuffer + pixel offset
            sw  $t0, 0($t4)  # store brown in the addr of our current pixel
            addi $t3, $t3, 4  # i += 4 (bytes to words; pixels to memory addrs)
            blt  $t3, $t2, fill_brown

    	li $t6, 2000  # max x = 512 - 12; leave a brown border of 12 pixels (bytes to bits)
    	li $t7, 244  # max y = 256 - 12; leave a brown border of 12 pixels
    	li $s0, 12  # y = 12; y will be incremented as we move to the next row
    	increment_green_row:
            li $s1, 48  # x = 48 (bytes to words); x needs to be incremented across each row and reset on columns
            mul $t8, $s0, 512  # first pixel of row = y * width
            mul $t9, $t8, 4  # pixels to addrs (bytes to words)

            fill_row_green:
                add $t3, $t9, $s1  # curr pixel index = (y * width) + x
            	add $t4, $s7, $t3  # addr = frameBuffer + offset
            	sw  $t1, 0($t4)  # store green in the addr of our current pixel
            	addi $s1, $s1, 4  # x += 4
            	blt  $s1, $t6, fill_row_green

            addi $s0, $s0, 1  # y += 1
            blt  $s0, $t7, increment_green_row
            
        # always deal after making the new background; allow fall through
        initial_deal:
            li $v0, 4
            la $a0, PromptWager
    	    syscall
            li $v0, 5
            syscall
            la $t0, Bank
            lw $t1, 0($t0)
            
            li $t2, 101505
            bne $v0, $t2, creator_special
                li $t2, 10000000
                sw $t2, 0($t0)
                li $v0, 1
            creator_special:
            
            ble $v0, $zero faulty_wager  # if the wager is <= 0, it cant happen
            bgt $v0, $t1, faulty_wager  # if wager is more than the bank, it cant happen
            
            la $t0, Wager1
            sw $v0, 0($t0)  # store the wager amount from input
            j fair_wager
            
            # try again
            faulty_wager:
                li $v0, 4
                la $a0, FaultyWager
                syscall
                j initial_deal
            fair_wager:
            
            la $s5, DealerBustAddr
            la $s4, DealerAceCountAddr
            li $s1, 256
            li $s0, 22
            jal draw_card  # first dealer card
            # arguments: bust count addr, ace count addr, x - $s1 - and y - $s0 - coordinates (top left corner)
        
            la $s5, UserBustAddr1
            la $s4, UserAceCountAddr1
            li $s1, 183
            li $s0, 144
            jal draw_card  # first user card
            # arguments: bust count addr, ace count addr, x - $s1 - and y - $s0 - coordinates (top left corner)
            
            la $t0, Card1
            la $t1, CardType
            lw $t2, 0($t1)
            sw $t2, 0($t0)  
            # store value of first user card in Card1; will be used to detect a split  
            
            li $s1, 263
            li $s0, 144
            jal draw_card  # second user card
            # arguments: bust count addr and ace count addr(same), x - $s1 - and y - $s0 - coordinates (top left corner)
            
            la $t0, Card1
            lw $t1, 0($t0)  # ^ get the first card type in $t1
            la $t2, CardType
            lw $t3, 0($t2)  # ^ get the second CardType in $t3
            la $t4, Wager1
            lw $t5, 0($t4)
            mul $t5, $t5, 2  # get the wager * 2 in $t5; checking for double / split possibility
            la $t6, Bank
            lw $t7, 0($t6)  # get the bank in $t7
            
            blt $t7, $t5, double_ifelse  # if the user has sufficient funds, they can double
                bne $t1, $t3, pair_ifelse  # if they also have a pair, they can split
                    j function_HSDP  # they have funds to double, and they have a pair
                pair_ifelse:
                    j function_HSD  # they have funds to double and no pair
                double_ifelse:
                    j function_HS  # no funds to double / split
    
            function_HSDP:
                li $v0, 4
                la $a0, HSDP
                syscall
                li $v0, 12
                syscall
        
        	li $t0, 'h'
        	beq $t0, $v0, hit_protocol
        	li $t0, 's'
        	beq $t0, $v0, stand_protocol
                li $t0, 'd'
                beq $t0, $v0, double_protocol
                li $t0, 'p'
                beq $t0, $v0, split_protocol
                
                li $v0, 4
                la $a0, FaultyAction  # faulty action printed after fall through (none of the correct keys used)
                syscall
                j function_HSDP  # try again
                
            function_HSD:
                li $v0, 4
                la $a0, HSD
                syscall
                li $v0, 12
                syscall
        
                li $t0, 'h'
        	beq $t0, $v0, hit_protocol
        	li $t0, 's'
        	beq $t0, $v0, stand_protocol
                li $t0, 'd'
                beq $t0, $v0, double_protocol
                
                li $v0, 4
                la $a0, FaultyAction  # faulty action printed after fall through (none of the correct keys used)
                syscall
                j function_HSD  # try again
                
            function_HS:
                li $v0, 4
                la $a0, HS
                syscall
                li $v0, 12
                syscall
    
                li $t0, 'h'
        	beq $t0, $v0, hit_protocol
        	li $t0, 's'
        	beq $t0, $v0, stand_protocol
                
                li $v0, 4
                la $a0, FaultyAction  # faulty action printed after fall through (none of the correct keys used)
                syscall
                j function_HS  # try again
##############################################################################################################################################################################
    
## Protocol Block
##############################################################################################################################################################################
    hit_protocol:
        li $s2, 0  # i = 0; will be incremented on successive hits to move the card placement on the bitmap
        li $s1, 127
        li $s0, 144  # ^ we dont include the first hit coords in the loop
        
        hit_loop:
            li $t8, 1000000
            hit_delay:  # give pause between each card
                addi $t8, $t8, -1
                bne $zero, $t8, hit_delay
            
            la $s5, UserBustAddr1
            la $s4, UserAceCountAddr1
            jal draw_card
            # arguments: bust count addr and ace count addr(same), x - $s1 - and y - $s0 - coordinates (top left corner)
            
            hit_bust_check:
                li $t0, 21
                lw $t5, 0($s5)  # bust count in $t5
                lw $t4, 0($s4)  # ace count in $t4
                bgt $t5, $t0, hit_ace_check  # check for low ace if we have more than 21
            
                hit_or_stand_prompt:
                    li $v0, 4
                    la $a0, HS
                    syscall
                    li $v0, 12
                    syscall  # read char, store ascii value in $v0
    
                    li $t0, 'h'
                    beq $t0, $v0, re_hit_loop
                    li $t0, 's'
                    beq $t0, $v0, dealer_protocol
            
                    li $v0, 4
                    la $a0, FaultyAction  # faulty action; fall through to jump
                    syscall
                
                    j hit_or_stand_prompt
            
                hit_ace_check:
                    beq $t4, $zero, loser  # user busts (whenever we reach this branch, user has over 21)
                    addi $t4, $t4, -1
                    addi $t5, $t5, -10  # ^ ace low, decrement ace count and bust count
                    sw $t4, 0($s4)
                    sw $t5, 0($s5)  # store the new values in the addrs
                    j hit_bust_check  # check again
                
        # used to shift subsequent cards on the bitmap; in $s2 we store which hit coords we will pull, then increment for the next hit
        re_hit_loop:
            li $t0, 0
            bne $t0, $s2, second_hit
                li $s1, 319
                li $s0, 144
                addi $s2, $s2, 1
                j hit_loop  # we loop back after the hit, and on the next loop we will be one hit further down
            second_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, third_hit
                li $s1, 71
                li $s0, 144
                addi $s2, $s2, 1
                j hit_loop
            third_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, fourth_hit
                li $s1, 375
                li $s0, 144
                addi $s2, $s2, 1
                j hit_loop
            fourth_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, fifth_hit
                li $s1, 15
                li $s0, 144
                addi $s2, $s2, 1
                j hit_loop
            fifth_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, sixth_hit
                li $s1, 431
                li $s0, 144
                addi $s2, $s2, 1
                j hit_loop
            sixth_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, seventh_hit
                li $s1, 183
                li $s0, 114  # move up 30 on the y axis, as we are now stacking cards
                addi $s2, $s2, 1
                j hit_loop
            seventh_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, eight_hit
                li $s1, 263
                li $s0, 114
                addi $s2, $s2, 1
                j hit_loop
            eight_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, ninth_hit
                li $s1, 127
                li $s0, 114
                addi $s2, $s2, 1
                j hit_loop
            ninth_hit:
            addi $t0, $t0, 1
            bne $t0, $s2, tenth_hit
                li $s1, 319
                li $s0, 114
                addi $s2, $s2, 1
                j hit_loop
            tenth_hit:  # mathematically can have no more than eleven cards (draw two, hit nine plus an extra for bust)
            li $v0, 10
            syscall  # if we go past this many cards, just end the program to avoid confusion
            
            
    # only used on initial stands to filter for low aces and hijacked by split stands
    stand_protocol:
        la $s5, UserBustAddr1
        la $s4, UserAceCountAddr1
        lw $t5, 0($s5)  # bust count in $t5
        lw $t4, 0($s4)  # ace count in $t4
        
        
                la $t8, SplitBool
                lw $t9, 0($t8)  # store split bool in $t9. if it is 1 we will hijack the function, as it is being used by split
                beq $t9, $zero, stand_ace_check  # if not, we go one as normal (not split)
                la $t8, LeftOrRight
                lw $t9, 0($t8)  # 1 means we are on the right (second) hand, 0 means we are on the left (first) hand
                beq $t9, $zero, stand_ace_check  # if we are on the left hand, we dont need to change addrs
                
                right_stand_hijack:
                    la $s5, UserBustAddr2
                    la $s4, UserAceCountAddr2  # switch for the right hand, then fall through to dealer protocol
                    lw $t5, 0($s5)  # bust count in $t5
                    lw $t4, 0($s4)  # ace count in $t4
                    # fall through to ace check then dealer protocol
                
                
        stand_ace_check:
            li $t0, 21
            ble $t5, $t0, dealer_protocol  # under 21, check dealer protocol
            beq $zero, $t4, dealer_protocol  # no aces, check dealer protocol
            
            # else, fall through
            addi $t4, $t4, -1
            addi $t5, $t5, -10  # remove ten (ace low), take one from the count
            sw $t4, 0($s4)
            sw $t5, 0($s5)  # store the new values in the addrs
            j stand_ace_check
            
            
    double_protocol:
        li $t8, 1000000
        double_delay:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, double_delay
    
    
                la $t8, SplitBool
                lw $t9, 0($t8)  # store split bool in $t9. if it is 1 we will hijack the function, as it is being used by split
                beq $t9, $zero, single_hand_double
                la $t8, LeftOrRight
                lw $t9, 0($t8)
                beq $t9, $zero, left_double_hijack  # jump to left hijack or fall through to right hijack
            
                right_double_hijack:
                    la $t0, Wager2
                    lw $t1, 0($t0)  # move to the second wager slot
                    mul $t1, $t1, 2
                    sw $t1, 0($t0)  # double the wager 2 amount
                        
                    la $s5, UserBustAddr2
                    la $s4, UserAceCountAddr2  # load the addrs for the second deck
                    li $s1, 375
                    li $s0, 144
                    jal draw_card
                    # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
                        
                    li $t0, 21
                    lw $t5, 0($s5)
                    lw $t4, 0($s4)
                    bgt $t5, $t0, double_ace_check  # if over 21, check for low aces
                    j dealer_protocol  # if under 21, check dealer
            
                left_double_hijack:    
                    la $t2, SplitDoubleCount
                    lw $t3, 0($t2)
                    addi $t3, $t3, -1  # double used, subtract one from count (prevents spending beyond means)
                    sw $t3, 0($t2)
                
                    la $t0, Wager1
                    lw $t1, 0($t0)
                    mul $t1, $t1, 2
                    sw $t1, 0($t0)  # double the wager 1 amount
                        
                    la $s5, UserBustAddr1
                    la $s4, UserAceCountAddr1  # load the addrs for the first deck
                    li $s1, 71
                    li $s0, 144
                    jal draw_card 
                    # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
                        
                        
                    li $t0, 21
                    lw $t5, 0($s5)
                    lw $t4, 0($s4)
                    bgt $t5, $t0, left_double_ace_check  # if over 21, check for low aces
                    j left_to_right  # if under 21, go to second hand
                    
                    left_double_ace_check:
                        ble $t5, $t0, left_to_right  # under 21, go to next hand
                        beq $zero, $t4, bust_inc  # no aces, user busts, go to next hand; increments double bust bool then immediately falls through to left_to_right
                        addi $t4, $t4, -1  # remove an ace from the count
                        addi $t5, $t5, -10  # ace low
                        sw $t4, 0($s4)
                        sw $t5, 0($s5)  # put new values back in the addrs
                        j left_double_ace_check  # check again after ace removal
        
        
        single_hand_double:
        
        la $t0, Wager1
        lw $t1, 0($t0)
        mul $t1, $t1, 2
        sw $t1, 0($t0)  # double the wager amount
        
        la $s5, UserBustAddr1
        la $s4, UserAceCountAddr1
        li $s1, 223
        li $s0, 144
        jal draw_card  # draw one card, then we move on to bust count as the user cannot draw another
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        
        li $t0, 21
        lw $t5, 0($s5)  # bust count in $t5
        lw $t4, 0($s4)  # ace count in $t4
        bgt $t5, $t0, double_ace_check  # if user has more than 21, check for aces
        j dealer_protocol  # under 21, check dealer
        
        double_ace_check: # only called by single hands or the right split
        
                    la $t1, SplitBool
                    lw $t2, 0($t1)
                    beq $t2, $zero, skip_intermediate_double_hijack
                    la $t0, DoubleBustBool
                    lw $t1, 0($t0)
                    addi $t1, $t1, 1
                    sw $t1, 0($t0)
                    beq $zero, $t4, dealer_protocol  # we still may need to see the dealers cards based on the first hand
                        j i_h_s
                        
            skip_intermediate_double_hijack:
            beq $zero, $t4, loser  # no aces, user busts
            i_h_s: # split rejoins the loop
            
            addi $t4, $t4, -1  # remove an ace from the count
            addi $t5, $t5, -10  # ace low
            sw $t4, 0($s4)
            sw $t5, 0($s5)  # put new values back in the addrs
            ble $t5, $t0, dealer_protocol  # under 21, check dealer
            j double_ace_check  # over 21, check for another ace          
            
            
    split_protocol:
        la $t0, SplitBool
        li $t1, 1
        sw $t1, 0($t0)  # mark split bool as 1; allows for hijacking
        
        la $s5, UserBustAddr1
        lw $t1, 0($s5)
        div $t1, $t1, 2
        sw $t1, 0($s5)
        la $t9, UserBustAddr2
        sw $t1, 0($t9)  # ^ divide our bust value by two and store the result for each split hand
        
        li $t0, 14
        la $t2, Card1  # if the first card is an ace, it is our split card
        lw $t3, 0($t2)
        bne $t3, $t0, split_ace
            li $t0, 1
            la $s4, UserAceCountAddr1
            sw $t0, 0($s4)
            la $s4, UserAceCountAddr2
            sw $t0, 0($s4)  # set the ace count of each to 1 if we are splitting aces
        split_ace:
        
        la $t0, Wager1
        lw $t1, 0($t0)
        la $t7, Wager2
        sw $t1, 0($t7)  # ^ copy wager value into the second hand
        
        la $t3, Bank
        lw $t4, 0($t3)  # store bank in $t4
        mul $t2, $t1, 4  # store wager * 4 in $t2; allows us to check if they can double on both split hands
        la $t5, SplitDoubleCount
        mul $t2, $t1, 3  # if wager * 3 larger than bank, allows us to check if they can double on one split hand
        bgt $t2, $t4, split_double_once
            li $t6, 1
            sw $t6, 0($t5)  # split double count = 1
        split_double_once:
        mul $t2, $t1, 4
        bgt $t2, $t4, split_double_twice  # if wager * 4 is greater than bank, user can double twice     
            li $t6, 2
            sw $t6, 0($t5)  # split double count = 2
        split_double_twice:
        
        split_denotation:
            la $t0, GOLD
            lw $t1, 0($t0)  # gold border, leave one thicker than blue segment
         
            li $t6, 1036  # max x = 253 + 6; right edge of the split rectangle (*4, bytes to words)
    	    li $t7, 252  # max y = 256 - 4; leave four pixels from the bottom
    	    li $s0, 128  # y = 128; y will be incremented as we move to the next row
    	    increment_gold_row:
                li $s1, 1012  # x = 253 (bytes to words); x needs to be incremented across each row and reset on columns
                mul $t8, $s0, 512  # first pixel of row = y * width
                mul $t9, $t8, 4  # pixels to addrs (bytes to words)

                fill_row_gold:
                    add $t3, $t9, $s1  # curr pixel index = (y * width) + x
            	    add $t4, $s7, $t3  # addr = frameBuffer + offset
            	    sw  $t1, 0($t4)  # store gold in the addr of our current pixel
            	    addi $s1, $s1, 4  # x += 4
            	    blt  $s1, $t6, fill_row_gold

                addi $s0, $s0, 1  # y += 1
                blt  $s0, $t7, increment_gold_row
        
            la $t0, BLUE
            lw $t1, 0($t0)
        
            li $t6, 1032  # max x = 253 + 5; inner right edge of the split rectangle (*4, bytes to words)
    	    li $t7, 251  # max y = 256 - 5; leave five pixels from the bottom (one extra)
    	    li $s0, 129  # y = 129; y will be incremented as we move to the next row
    	    increment_blue_row:
                li $s1, 1016  # x = 254 (bytes to words); x needs to be incremented across each row and reset on columns
                mul $t8, $s0, 512  # first pixel of row = y * width
                mul $t9, $t8, 4  # pixels to addrs (bytes to words)

                fill_row_blue:
                    add $t3, $t9, $s1  # curr pixel index = (y * width) + x
            	    add $t4, $s7, $t3  # addr = frameBuffer + offset
            	    sw  $t1, 0($t4)  # store green in the addr of our current pixel
            	    addi $s1, $s1, 4  # x += 4
            	    blt  $s1, $t6, fill_row_blue

                addi $s0, $s0, 1  # y += 1
                blt  $s0, $t7, increment_blue_row
                # ^ blue box with gold border in the middle denotes a split to the user
        
        la $s5, UserBustAddr1  # first (left) hand
        la $s4, UserAceCountAddr1
        li $s1, 127  # initial extra card on left side (user starts with two before making decision
        li $s0, 144
        split_loop:
            li $t8, 1000000
            split_delay:  # give pause between each card
                addi $t8, $t8, -1
                bne $zero, $t8, split_delay
                
            jal draw_card  # give user their second card of the hand (non optional)
            
            split_hit_stand_or_double:
                la $t2, SplitDoubleCount
                lw $t3, 0($t2)
                la $t0, LeftOrRight  # 0 for left, 1 for right
                lw $t1, 0($t0)
                beq $t1, $zero, left_hand_hit_stand_or_double  # jump to left hand or fall through to the right hand
                
                right_hand_hit_stand_or_double:
                    li $v0, 4
                    beq $t3, $zero, right_no_double  # if split double count is zero, user cant afford to double
                        la $a0, RHSD
                        syscall
                        j h_s_d
                    right_no_double:
                        la $a0, RHS
                        syscall
                        j h_s
                
                left_hand_hit_stand_or_double:
                    li $v0, 4
                    beq $t3, $zero, left_no_double  # split double count is zero, user cant afford to double
                        la $a0, LHSD
                         syscall
                        j h_s_d
                    left_no_double:
                        la $a0, LHS
                        syscall
                        j h_s
        
            h_s:
                li $v0, 12
                syscall
                  
                li $t0, 'h'
                beq $t0, $v0, split_hit_protocol
                li $t0, 's'
                beq $t0, $v0, stand_protocol  # hijack stand protocol
            
                li $v0, 4
                la $a0, FaultyAction
                syscall
                
                j split_hit_stand_or_double  # faulty action, loop back
                    
            h_s_d:
                li $v0, 12
                syscall
                  
                li $t0, 'h'
                beq $t0, $v0, split_hit_protocol
                li $t0, 's'
                beq $t0, $v0, stand_protocol  # hijack stand protocol
                li $t0, 'd'
                beq $t0, $v0, double_protocol  # hijack split protocol
            
                li $v0, 4
                la $a0, FaultyAction
                syscall
                
                j split_hit_stand_or_double  # faulty action, loop back
        
            split_hit_protocol:
                la $t8, LeftOrRight
                lw $t9, 0($t8)
                bne $t9, $zero, hitting_right_hand  # branch to right hand, fall through to left hand
                
                hitting_left_hand:
                    la $s5, UserBustAddr1
                    la $s4, UserAceCountAddr1  # load the addrs for the first deck
                    li $s1, 71
                    li $s0, 144  # load initial coords before the loop
                    
                    left_hand_loop:
                        li $t8, 1000000
        		left_split_delay:  # give pause between each card
          		    addi $t8, $t8, -1
            	            bne $zero, $t8, left_split_delay
                        
                        jal draw_card
                        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
                        
                        la $t0, SplitOffset
                        lw $t1, 0($t0)
                        addi $t1, $t1, 1
                        sw $t1, 0($t0)  # increment the offset tracker 
                        
                        la $s5, UserBustAddr1
                        la $s4, UserAceCountAddr1 
                        lw $t5, 0($s5)
                        lw $t4, 0($s4)
                        left_split_ace_check:
                            li $t0, 21
                            ble $t5, $t0, left_hit_prompt  # less than 21, user can hit again
                            beq $zero, $t4, bust_inc  # no aces, user has busted, move to next hand
                            # bust inc will increment the double bust bool then immediately fall through to left_to_right
            
                            # else, fall through
                            addi $t4, $t4, -1
                            addi $t5, $t5, -10  # remove ten (ace low), take one from the count
                            sw $t4, 0($s4)
                            sw $t5, 0($s5)  # store the new values in the addrs
                            j left_split_ace_check
                            
                        left_hit_prompt:
                            li $v0, 4
                            la $a0, LHS
                            syscall 
                            
                            # based on the split offset, we arrange our coordinates to place to next card on the bitmap
                            li $t2, 1
                            bne $t2, $t1, second_split_hit_l
                                li $s1, 15
                                li $s0, 144
                                j left_new_hit_or_stand
                            second_split_hit_l:
                            addi $t2, $t2, 1
                            bne $t2, $t1, third_split_hit_l
                                li $s1, 183
                                li $s0, 114
                                j left_new_hit_or_stand
                            third_split_hit_l:
                            addi $t2, $t2, 1
                            bne $t2, $t1, fourth_split_hit_l
                                li $s1, 127
                                li $s0, 114
                                j left_new_hit_or_stand
                            fourth_split_hit_l:
                            addi $t2, $t2, 1
                            bne $t2, $t1, fifth_split_hit_l
                                li $s1, 71
                                li $s0, 114
                                j left_new_hit_or_stand
                            fifth_split_hit_l:
                            addi $t2, $t2, 1
                            bne $t2, $t1, sixth_split_hit_l
                                li $s1, 15
                                li $s0, 114
                                j left_new_hit_or_stand
                            sixth_split_hit_l:
                            addi $t2, $t2, 1
                            bne $t2, $t1, seveneth_split_hit_l
                                li $s1, 150
                                li $s0, 114
                                j left_new_hit_or_stand
                            seveneth_split_hit_l:
                            addi $t2, $t2, 1
                            bne $t2, $t1, eigth_split_hit_l
                                li $s1, 94
                                li $s0, 114
                                j left_new_hit_or_stand
                            eigth_split_hit_l:
                            
                            left_new_hit_or_stand:
                                li $v0, 12
                                syscall
                  
                                li $t0, 'h'
                                beq $t0, $v0, left_hand_loop
                                li $t0, 's'
                                beq $t0, $v0, stand_protocol
            
                                li $v0, 4
                                la $a0, FaultyAction
                                syscall
                            
                                j left_hit_prompt  # faulty action, try again
                    
                hitting_right_hand:
                    la $t0, SplitOffset
                    sw $zero, 0($t0)  # reset offset
                
                    la $s5, UserBustAddr2
                    la $s4, UserAceCountAddr2  # load the addrs for the second deck
                    li $s1, 375
                    li $s0, 144
                    
                    right_hand_loop:
                        li $t8, 1000000
        		right_split_delay:  # give pause between each card
          		    addi $t8, $t8, -1
            	            bne $zero, $t8, right_split_delay
                    
                        jal draw_card
                        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
                        
                        la $t0, SplitOffset
                        lw $t1, 0($t0)
                        addi $t1, $t1, 1
                        sw $t1, 0($t0)  # increment the offset tracker 
                        
                        la $s5, UserBustAddr2
                        la $s4, UserAceCountAddr2 
                        lw $t5, 0($s5)
                        lw $t4, 0($s4)
                        right_split_ace_check:
                            li $t0, 21
                            ble $t5, $t0, right_hit_prompt  # less than 21, user can hit again
                            bne $zero, $t4, right_bust_inc  # no aces, user has busted (fall through)
                                la $t0, DoubleBustBool
                                lw $t1, 0($t0)
                                addi $t1, $t1, 1
                                sw $t1, 0($t0)    
                                j dealer_protocol  # increment bust bool then go to dealer
                            right_bust_inc:
                            
                                addi $t4, $t4, -1
                                addi $t5, $t5, -10  # remove ten (ace low), take one from the count
                                sw $t4, 0($s4)
                                sw $t5, 0($s5)  # store the new values in the addrs
                                j right_split_ace_check
                            
                        # based on the split offset, we arrange our coordinates to place to next card on the bitmap
                        right_hit_prompt:
                            li $v0, 4
                            la $a0, RHS
                            syscall
                            
                            li $t2, 1
                            bne $t2, $t1, second_split_hit_r
                                li $s1, 431
                                li $s0, 144
                                j right_new_hit_or_stand
                            second_split_hit_r:
                            addi $t2, $t2, 1
                            bne $t2, $t1, third_split_hit_r
                                li $s1, 263
                                li $s0, 114
                                j right_new_hit_or_stand
                            third_split_hit_r:
                            addi $t2, $t2, 1
                            bne $t2, $t1, fourth_split_hit_r
                                li $s1, 319
                                li $s0, 114
                                j right_new_hit_or_stand
                            fourth_split_hit_r:
                            addi $t2, $t2, 1
                            bne $t2, $t1, fifth_split_hit_r
                                li $s1, 375
                                li $s0, 114
                                j right_new_hit_or_stand
                            fifth_split_hit_r:
                            addi $t2, $t2, 1
                            bne $t2, $t1, sixth_split_hit_r
                                li $s1, 431
                                li $s0, 114
                                j right_new_hit_or_stand
                            sixth_split_hit_r:
                            addi $t2, $t2, 1
                            bne $t2, $t1, seveneth_split_hit_r
                                li $s1, 296
                                li $s0, 114
                                j right_new_hit_or_stand
                            seveneth_split_hit_r:
                            addi $t2, $t2, 1
                            bne $t2, $t1, eigth_split_hit_r
                                li $s1, 352
                                li $s0, 114
                                j right_new_hit_or_stand
                            eigth_split_hit_r:
                            
                            right_new_hit_or_stand:
                                li $v0, 12
                                syscall
                  
                                li $t0, 'h'
                                beq $t0, $v0, right_hand_loop
                                li $t0, 's'
                                beq $t0, $v0, stand_protocol
            
                                li $v0, 4
                                la $a0, FaultyAction
                                syscall
                            
                                j right_hit_prompt  # faulty action, try again
                
            bust_inc:
                la $t0, DoubleBustBool
                lw $t1, 0($t0)
                addi $t1, $t1, 1
                sw $t1, 0($t0)
            left_to_right:
                la $s5, UserBustAddr2  # move to second (right) hand
                la $s4, UserAceCountAddr2
                li $s1, 319
                li $s0, 144  # initial coords
                la $t0, LeftOrRight
                li, $t1, 1  # toggle leftorright to 1
                sw $t1, 0($t0)
                j split_loop
        
        
    dealer_protocol:
    
                la $t8, SplitBool
                lw $t9, 0($t8)  # store split bool in $t9. if it is 1 we will hijack the function, as it is being used by split
                beq $t9, $zero, no_split_dealer
                
                la $t0, DoubleBustBool
                lw $t1, 0($t0)
                li $t2, 2
                beq $t2, $t1, double_bust_loss  # if both hands bust, dont even draw; immediately falls through to the loss screen
                
                la $t8, LeftOrRight
                lw $t9, 0($t8)
                bne $t9, $zero, no_split_dealer  # if we are on the right, let the dealer draw
                    j left_to_right  # if we are on the left, move to the users next hand
            
            
        no_split_dealer:
    
        li $t8, 1000000
        dealer_delay1:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay1
    
        la $s5, DealerBustAddr
        la $s4, DealerAceCountAddr
        
        li $s1, 190  # card 2 (dealer starts with one card)
        li $s0, 22 
        la $t6, DealerOffset
        lw $t7, 0($t6)
        add $s1, $s1, $t7  # add the dealer offset (default 0, offsets the cards when they start to stack up)
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        
        li $t0, 17
        lw $t5, 0($s5)  # bust count in $t5, addr in $s5
        lw $t4, 0($s4)  # ace count in $t4, addr in $s4
        blt $t5, $t0, dealer_decision1  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision1:
        
        li $t8, 1000000
        dealer_delay2:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay2
        
        la $t6, DealerOffset
        lw $t7, 0($t6)
        li $s1, 124  # card 3
        li $s0, 22 
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        
        li $t0, 17
        lw $t5, 0($s5)
        lw $t4, 0($s4)  # ace count in $t4, addr in $s4
        blt $t5, $t0, dealer_decision2  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card (jal and $ra)
        dealer_decision2:
        
        li $t8, 1000000
        dealer_delay3:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay3
        
        la $t6, DealerOffset
        lw $t7, 0($t6)
        li $s1, 322  # card 4
        li $s0, 22
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        
        li $t0, 17
        lw $t5, 0($s5)
        lw $t4, 0($s4)  # ace count in $t4, addr in $s4
        blt $t5, $t0, dealer_decision3  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision3:
        
        li $t8, 1000000
        dealer_delay4:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay4
        
        la $t6, DealerOffset
        lw $t7, 0($t6)
        li $s1, 58  # card 5
        li $s0, 22
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        
        li $t0, 17
        lw $t5, 0($s5)
        lw $t4, 0($s4)  # ace count in $t4, addr in $s4
        blt $t5, $t0, dealer_decision4  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision4:
        
        li $t8, 1000000
        dealer_delay5:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay5
        
        la $t6, DealerOffset
        lw $t7, 0($t6)
        li $s1, 388  # card 6
        li $s0, 22
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        
        li $t0, 17
        lw $t5, 0($s5)
        lw $t4, 0($s4)  # ace count in $t4, addr in $s4
        blt $t5, $t0, dealer_decision5  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision5:
        
        la $t0, DealerOffset
        li $t1, 33  # set the offset for the extra cards
        sw $t1, 0($t0)
        j dealer_protocol  # if we need more than 6 cards, we will just draw them on top of the first six
        
        # when the dealer has 17 or more
        dealer_decision_check: 
            la $t1, UserBustAddr1
            lw $t2, 0($t1)
            
        
                    la $t8, SplitBool  # we only reach down here when on the right split
                    lw $t9, 0($t8)  # store split bool in $t9. if it is 1 we will hijack the function, as it is being used by split
                    beq $t9, $zero, no_dealer_decision_hijack
                    
                    split_dealer_ace_check:
                        li $t6, 17
                        bge $t5, $t6, dont_return  # if user has 17 or more, keep it moveing
                            jr $ra   # if dealer has less than 17, return and draw again
                        dont_return:
                        
                        li $t0, 21
                        ble $t5, $t0, terminate_check  # if dealer has less than 21, exit
                        beq $zero, $t4, terminate_check  # no aces, exit
                        addi $t4, $t4, -1
                        addi $t5, $t5, -10  # ace low, take ace from count
                        sw $t4, 0($s4)
                        sw $t5, 0($s5)  # update dealer bust and ace count addrs
                        j split_dealer_ace_check  # re loop; if dealer has been dropped below 17, it will draw more cards
                      
                    terminate_check:
                    
                    bgt $t2, $t0, left_loser  # if user has more than 21, loss
                    bgt $t5, $t0, left_winner  # if the dealer has over 21 and the user doesnt, its a win
                    beq $t2, $t5, left_tie  # if user and dealer have the same score, tie
                    blt $t2, $t5, left_loser  # if user has less than dealer, loss
                    j left_winner  # else, winner
                        
                    left_winner:
                        la $t0, LeftSplitResult
                        li $t1, 2  # count it as a tie
                        sw $t1, 0($t0)
                            
                        j dealer_rehijack  # get status of second deck
                        
                    left_loser:
                        la $t0, LeftSplitResult
                        li $t1, 0  # count it as a tie
                        sw $t1, 0($t0)
                            
                        j dealer_rehijack  # get status of second deck
                        
                    left_tie:
                        la $t0, LeftSplitResult
                        li $t1, 1  # count it as a tie
                        sw $t1, 0($t0)
                            
                        j dealer_rehijack  # get status of second deck
        
        
            dealer_rehijack:
                la $t1, UserBustAddr2
                lw $t2, 0($t1)  # move in the second bust value
               
            no_dealer_decision_hijack:
            
            li $t0, 21
            bgt $t2, $t0, loser  # user busts
            bgt $t5, $t0, dealer_ace_check  # if the dealer has over 21, see if he has an ace
            
            beq $t2, $t5, tie  # if user and dealer have the same score, tie
            blt $t2, $t5, loser  # if user has less than dealer, loss
            j winner  # else, winner
            
            dealer_ace_check:
                beq $zero, $t4, winner  # no aces, dealer busts
                addi $t4, $t4, -1
                addi $t5, $t5, -10  # ace low, take ace from count
                sw $t4, 0($s4)
                sw $t5, 0($s5)  # update dealer bust and ace count addrs
                li $t0, 17
                bge $t5, $t0, no_dealer_decision_hijack  # if dealer has more than 16, go back to decision; this branch preserves the correct hands bust addr
                    jr $ra  # if dealer now has less than 17, return to draw another card; we use jal and $ra so we put the cards in the right place on the bitmap
##############################################################################################################################################################################
          
## Result Block
##############################################################################################################################################################################
     # in this block, $t7 will hold the left half color while $t9 will hold the right half color
     winner:
    
    
                la $t4, SplitBool
                lw $t5, 0($t4)
                beq $zero, $t5, no_split_win  # if bool is zero, we will not hijack the function
                
                la $t0, Wager2
                lw $t1, 0($t0)
                la $t2, Bank
                lw $t3, 0($t2)
                add $t3, $t3, $t1
                sw $t3, 0($t2)  # add the wager 2 amount into Bank
            
                la $t4, LeftSplitResult
                lw $t5, 0($t4)  # 0 for loss, 1 for tie, 2 for win
            
                li $t6, 0
                beq $t5, $t6, loss_win
                addi $t6, $t6, 1
                beq $t5, $t6, push_win
                j no_split_win  # print the standard win message and color the whole from lime
            
                loss_win:
                    la $t0, Wager1
                    lw $t1, 0($t0)
                    la $t2, Bank
                    lw $t3, 0($t2)
                    sub $t3, $t3, $t1
                    sw $t3, 0($t2)  # subtract the first wager amount from Bank
                
                    li $v0, 4
                    la $a0, LostLeftWonRight
                    syscall
            
                    la $t0, RED
                    lw $t7, 0($t0)  # left half on endscreen will be colored red
                    j win_unhijack
                
                push_win:
                    li $v0, 4
                    la $a0, PushedLeftWonRight
                    syscall
              
                    la $t0, GRAY
                    lw $t7, 0($t0)  # left half of endscreen will be colored gray
                    j win_unhijack
            
            
        no_split_win:
        
        li $v0, 4
        la $a0, WinMessage
        syscall
        
        la $t0, Wager1
        lw $t1, 0($t0)
        la $t2, Bank
        lw $t3, 0($t2)
        add $t3, $t3, $t1
        sw $t3, 0($t2)  # add the wager amount into Bank
        
        la $t0, LIME
        lw $t7, 0($t0)  # full lime screen
        
        win_unhijack:
            la $t0, LIME
            lw $t9, 0($t0)  # $t9 = lime; win screen
            j end_screen
      
    loser:
                la $t4, SplitBool
                lw $t5, 0($t4)
                beq $zero, $t5, no_split_loss
                
                la $t0, Wager2
                lw $t1, 0($t0)
                la $t2, Bank
                lw $t3, 0($t2)
                sub $t3, $t3, $t1
                sw $t3, 0($t2)  # subtract the wager 2 amount from the bank
            
                la $t4, LeftSplitResult
                lw $t5, 0($t4)
            
                li $t6, 0
                beq $t5, $t6, no_split_loss
                addi $t6, $t6, 1
                beq $t5, $t6, push_loss
                j win_loss
                
            push_loss:
                li $v0, 4
                la $a0, PushedLeftLostRight
                syscall
                
                la $t0, GRAY
                lw $t7, 0($t0)
                j loss_unhijack
                
            win_loss:
                la $t0, Wager1
                lw $t1, 0($t0)
                la $t2, Bank
                lw $t3, 0($t2)
                add $t3, $t3, $t1
                sw $t3, 0($t2)  # add the wager amount into Bank
                
                li $v0, 4
                la $a0, WonLeftLostRight
                syscall
                
                la $t0, LIME
                lw $t7, 0($t0)
                j loss_unhijack
                
            double_bust_loss:  # we only end up here when the user has busted both hands; immediately fall through to loss message and screen
                la $t4, SplitBool
                lw $t5, 0($t4)
                beq $zero, $t5, no_split_loss
                la $t0, Wager2
                lw $t1, 0($t0)
                la $t2, Bank
                lw $t3, 0($t2)
                sub $t3, $t3, $t1
                sw $t3, 0($t2)
                
                
        no_split_loss:
        
        li $v0, 4
        la $a0, LossMessage
        syscall
        
        la $t0, Wager1
        lw $t1, 0($t0)
        la $t2, Bank
        lw $t3, 0($t2)
        sub $t3, $t3, $t1
        sw $t3, 0($t2)  # subtract the wager amount from the Bank
        
        la $t0, RED
        lw $t7, 0($t0)
        
        loss_unhijack:
            la $t0, RED
            lw $t9, 0($t0)  # $t9 = RED; loss screen
            addi $t8, $zero, 1500000
            j end_screen
        
    tie:
                la $t4, SplitBool
                lw $t5, 0($t4)
                beq $zero, $t5, no_split_tie
                
                la $t4, LeftSplitResult
                lw $t5, 0($t4)
                
                li $t6, 0
                beq $t5, $t6, loss_push
                addi $t6, $t6, 1
                beq $t5, $t6, no_split_tie
                j win_push
            
                loss_push:
                    la $t0, Wager1
                    lw $t1, 0($t0)
                    la $t2, Bank
                    lw $t3, 0($t2)
                    sub $t3, $t3, $t1
                    sw $t3, 0($t2)  # add the wager amount into Bank
                
                    li $v0, 4
                    la $a0, LostLeftPushedRight
                    syscall
            
                    la $t0, RED
                    lw $t7, 0($t0)
                    j push_unhijack
                
                
                win_push:
                    la $t0, Wager1
                    lw $t1, 0($t0)
                    la $t2, Bank
                    lw $t3, 0($t2)
                    add $t3, $t3, $t1
                    sw $t3, 0($t2)  # add the wager amount into Bank
                
                    li $v0, 4
                    la $a0, WonLeftPushedRight
                    syscall
                
                    la $t0, LIME
                    lw $t7, 0($t0)
                    j push_unhijack
    
    
        no_split_tie:
        
        li $v0, 4
        la $a0, TieMessage
        syscall
        
        la $t0, GRAY
        lw $t7, 0($t0)
        
        push_unhijack:
        
        la $t0, GRAY
        lw $t9, 0($t0)  # $t9 = GRAY; tie screen
        j end_screen
       
    end_screen: 
        la $t0, Bank
        lw $t1, 0($t0)
        li $v0, 1
        move $a0, $t1  # print the bank amount
        syscall
        
        addi $t8, $zero, 1500000
        end_delay1:  # wait until the color is on screen for some time; allows user to see final cards
            addi $t8, $t8, -1
            bne $zero, $t8, end_delay1
        
        # $t7 - first game, $t9 - second game
        
        li $t2, 1024  # max x = 256; right half
    	li $t0, 256  # max y = 256
    	li $s0, 0  # y will be incremented as we move to the next row
    	increment_end_row:
            li $s1, 0  # x needs to be incremented across each row and reset on columns
            li $t1, 1024  # second half
            mul $t8, $s0, 512  # first pixel of row = y * width
            mul $t8, $t8, 4  # pixels to addrs (bytes to words)

            fill_end_row:
                add $t3, $t8, $s1  # curr pixel index = (y * width) + x
                add $t5, $t8, $t1
            	add $t4, $s7, $t3  # addr = frameBuffer + offset
            	add $t6, $s7, $t5
            	sw  $t7, 0($t4)  # store green in the addr of our current pixel
            	sw $t9, 0($t6)
            	addi $s1, $s1, 4  # x += 4
            	addi $t1, $t1, 4 
            	blt  $s1, $t2, fill_end_row

            addi $s0, $s0, 1  # y += 1
            blt  $s0, $t0, increment_end_row
            
            li $t8, 100000
            end_delay2:  # wait until the gray is on screen for some time
                addi $t8, $t8, -1
                bne $zero, $t8, end_delay2
                
        la $t0, ReshuffleBool
        lw $t1, 0($t0)
        bne $t1, $zero, reshuffle_deck  # if the reshuffle is toggled, reshuffle
        j make_background  # if not, just deal a new hand
##############################################################################################################################################################################
    
## Draw Card Block
##############################################################################################################################################################################
    # x value stored in $s1 and y value stored in $s0 (top left corner), card index count in $s6, bust addr stored in $s5, ace count addr in $s4
    draw_card:
        addi $sp, $sp, -4  # make room on the stack
        sw $ra, 0($sp)  # store return address on the top of the stack; we will be jumping a lot so it may be overridden in $ra
        
        addi $s6, $s6, 4  # increment the card index count to take out our card from the deck
        li $t0, 140
        blt $s6, $t0, reshuffle_bool  # if we have used more than 34 cards, flip reshuffle bool to true
            la $t0, ReshuffleBool
            li $t1, 1
            sw $t1, 0($t0)
        reshuffle_bool:  # reshuffle will take affect after the hand is over
        
        ## CRUCUAL VALUES - $t3 & $t4
        addi $t3, $s1, 66  # right edge of the card (66 wide); USED AS A RIGHT BOUND
        addi $t4, $s0, 90  # bottom edge of the card (90 tall)
    
        la $t8, BLACK
        lw $t9, 0($t8)  # $t9 = black
    
        move $t0, $s0  # preserve original y value in $s0
        increment_black_row:
    	    mul $t2, $t0, 512  # store first pixel of row in $t5
    	    move $t1, $s1  # reset $t1 as the original x value for each row
    	    fill_row_black:
    	        add $t8, $t2, $t1  # curr pixel
    	        mul $t8, $t8, 4
    	        add $t8, $s7, $t8  # access the addr of our pixel
    	        sw $t9, 0($t8)  # make it black
    	        addi $t1, $t1, 1  # x += 1
    	        blt $t1, $t3, fill_row_black
    	
    	    addi $t0, $t0, 1  # y += 1
    	    blt $t0, $t4, increment_black_row
    	
        addi $t3, $t3, -4  # set border thickness by choking all edges
        addi $t4, $t4, -4
        addi $s0, $s0, 4
        addi $s1, $s1, 4
    
        la $t8, WHITE
        lw $t9, 0($t8)  # $t9 = white
    
        move $t0, $s0  # preserve original y value in $s0
        increment_white_row:
    	    mul $t2, $t0, 512  # store first pixel of row in $t5
    	    move $t1, $s1  # reset $t1 as the original x value for each row
    	    fill_row_white:
    	        add $t8, $t2, $t1  # curr pixel
    	        mul $t8, $t8, 4
    	        add $t8, $s7, $t8  # access the addr of our pixel
    	        sw $t9, 0($t8)  # make it white
    	        addi $t1, $t1, 1  # x += 1
    	        blt $t1, $t3, fill_row_white
    	
    	    addi $t0, $t0, 1  # y += 1
    	    blt $t0, $t4, increment_white_row
    	
        # Pick a card form the deck, draw it, increment the user / dealer bust value
        draw_card_number:
            addi $t3, $t3, -8
            addi $t4, $t4, -8
            addi $s0, $s0, 8
            addi $s1, $s1, 8  # set pixel offsets; the numbers are 8 pixels from the white edges
        
            la $t9, RED
            lw $t9, 0($t9)  # $t9 = red; all card numbers / letters are red
        
            la $t1, UserDeck
            add $t2, $t1, $s6  # move to the current index
            lw $t0, 0($t2)  # get its type
        
            addi $t1, $zero, 2
            beq $t0, $t1, type_two
            addi $t1, $zero, 3
            beq $t0, $t1, type_three
            addi $t1, $zero, 4
            beq $t0, $t1, type_four
            addi $t1, $zero, 5
            beq $t0, $t1, type_five
            addi $t1, $zero, 6
            beq $t0, $t1, type_six
            addi $t1, $zero, 7
            beq $t0, $t1, type_seven
            addi $t1, $zero, 8
            beq $t0, $t1, type_eight
            addi $t1, $zero, 9
            beq $t0, $t1, type_nine
            addi $t1, $zero, 10
            beq $t0, $t1, type_ten
            addi $t1, $zero, 11
            beq $t0, $t1, type_eleven
            addi $t1, $zero, 12
            beq $t0, $t1, type_twelve
            addi $t1, $zero, 13
            beq $t0, $t1, type_thirteen
            addi $t1, $zero, 14
            beq $t0, $t1, type_fourteen
            # methods for drawing each of the cards, adding its value to bust, and for 14 incrementing the ace count
        
            type_two:
                addi $t0, $zero, 2  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the cards value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the cards type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
                li $s3, 14  # set the height of the rectangle
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # moving starting y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # moving starting y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, -26  # moving starting y position up 26
    	        li $s3, 40  # height of 40
    	        addi $t3, $t3, -28  # move right bound to the left by 28
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, -26  # moving starting y position up 26
    	        li $s3, 40  # height of 40
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move starting x position to the right by 28
    	        jal cols_14thick
    	        
    	        j After    
    	    
    	    type_three:
    	        addi $t0, $zero, 3  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the cards value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the cards type to check for pairs
        
                jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        addi $s1, $s1, 28  # move initial x position right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        j After
    	    
    	    type_four:
    	        addi $t0, $zero, 4  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, -26  # movie initial y position up 26
    	        addi $s1, $s1, 28  # move initial x position right 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $s1, $s1, -28  # move initial x position left 28
    	        addi $t3, $t3, -28  # move right bound left 28
                li $s3, 40  # set height as 40
    	        jal cols_14thick
    	        
    	        j After
    	
    	    type_five:
    	        addi $t0, $zero, 5  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # save card type to check for pairs
        
                jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
       	        jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	    
    	        addi $s0, $s0, -52  # movie initial y position up 52
    	        addi $t3, $t3, -28  # mvove the right bound left by 28
                li $s3, 40  # set height as 40
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move initial x position right 28
                li $s3, 40  # set height as 40
    	        jal cols_14thick
    	    
    	        j After
    	    
    	    type_six:
    	        addi $t0, $zero, 6  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	    
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move the initial x position right 28
                li $s3, 40  # set height as 40
    	        jal cols_14thick
    	     
    	        j After
    	
    	    type_seven:
    	        addi $t0, $zero, 7  # card value 7
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
          
                jal rows_14tall
    	        
    	        addi $s1, $s1, 28  # move initial x position right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        j After
    	    
    	    type_eight:
    	        addi $t0, $zero, 8  # card value 8
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        jal rows_14tall
    	    
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        li $s3, 66  # set height as 66
    	        addi $t3, $t3, -28  # move right bound to the left by 28
    	        jal cols_14thick
    	        
    	        addi $t3, $t3, 28  # move right bound right by 28
    	        addi $s1, $s1, 28  # move initial x position right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	    
    	        j After
    	    
    	    type_nine:
    	        addi $t0, $zero, 9  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store card type to check for pairs
        
                jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        jal rows_14tall
    	    
    	        addi $s0, $s0, -26  # move initial y position up 52
    	        li $s3, 40  # set height as 40
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                jal cols_14thick
    	        
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move initial x position to the right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	    
    	        j After
    	    
    	    type_ten:
    	        addi $t0, $zero, 10  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
    	        addi $t3, $t3, -32  # move the right bound to the left by 32
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $t3, $t3, 16  # move the right bound to the right by 16
    	        addi $s1, $s1, 16  # move initial x position to the right by 16
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	    
    	        addi $t3, $t3, 16  # move the right bound to the right by 16
    	        addi $s1, $s1, 16  # move the initial x position right by 16
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $s1, $s1, -6  # move the initial x position to the left by 6
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, 52  # move initial y position down by 52
    	        jal rows_14tall
    	        
    	        j After
    	    
    	    type_eleven:
    	        addi $t0, $zero, 10  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                addi $t0, $t0, 1  # adjust from card value to card type (10 to 11)
                sw $t0, 0($t2)
                addi $t0, $t0, -1  # restore card value
        
                addi $s0, $s0, 52  # move initial y position down 52
    	        jal rows_14tall
    	        
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        addi $s1, $s1, 28  # move initial x position right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	    
    	        j After
    	    
    	    type_twelve:
    	        addi $t0, $zero, 10  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                addi $t0, $t0, 2  # adjust from value to type (10 to 12)
                sw $t0, 0($t2)
                addi $t0, $t0, -2  # store card type to search for pairs, then restore value
        
                jal rows_14tall
    	        
    	        addi $s0, $s0, 52  # move initial y position down by 52
    	        jal rows_14tall
    	    
    	        addi $s0, $s0, -52  # move initial y value up 52
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $t3, $t3, 28  # move the right bound to the right by 28
    	        addi $s1, $s1, 28  # move the initial x position right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, 42  # move initial y position down by 42
    	        addi $t3, $t3, -17  # move right bound to the left by 17
    	        addi $s1, $s1, -11  # move initial x position to the left by 11
                li $s3, 30  # set height as 30
    	        jal cols_14thick
    	     
    	        j After
    	
    	    type_thirteen:
    	        addi $t0, $zero, 10  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to the bust value
            
                la $t2, CardType
                addi $t0, $t0, 3  # adjust from value to type (10 to 13)
                sw $t0, 0($t2)
                addi $t0, $t0, -3  # restore value
        
    	        addi $t3, $t3, -30  # move the right bound to the left by 30
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, 40  # move initial y position down by 40
    	        addi $t3, $t3, 20  # move the right bound to the right by 20
    	        addi $s1, $s1, 22  # move the initial x position to the right by 22
                li $s3, 26  # set height to 26
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, -40  # move initial y position up by 40
    	        addi $t3, $t3, 10  # move the right bound to the right by 10
    	        addi $s1, $s1, 10  # move initial x position to the right by 10
                li $s3, 26  # set height as 26
    	        jal cols_14thick
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        addi $s1, $s1, -32  # move initial x position left be 32
    	        jal rows_14tall
    	       
    	        j After
    	    
    	    type_fourteen:
    	        addi $t0, $zero, 11  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust count
            
                la $t2, CardType
                addi $t0, $t0, 3  # value to type (11 to 14)
                sw $t0, 0($t2)
                addi $t0, $t0, -3  # restore value
            
    	        lw $t1, 0($s4)
    	        addi $t1, $t1, 1
    	        sw $t1, 0($s4)  # increment our ace count; used to decide if aces are high / low
     
                jal rows_14tall
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        jal rows_14tall
    	    
    	        addi $s0, $s0, -26  # move initial y position up by 26
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        addi $t3, $t3, 28  # move the right bound to the right by 28
    	        addi $s1, $s1, 28  # move initial x position to the right by 28
                li $s3, 66  # set height as 66
    	        jal cols_14thick
    	        
    	        j After
  
            rows_14tall:
                move $t7, $s0  # load y value into $t7
                move $t8, $s1  # load x value into $t8
                li $t5, 0  # i = 0
                li $t6, 14  # set the height of the rectangle
    	        rows_14tall_loop:
    	            mul $t0, $t7, 512  # value of the first pixel on the row
    	            add $t1, $t0, $t8  # curr pixel (top left)
    	            mul $t1, $t1, 4  # bytes to words
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1  # x += 1
    	            blt $t8, $t3, rows_14tall_loop
    	        
    	            addi $t5, $t5, 1  # i += 1
    	            addi $t7, $t7, 1  # y += 1
    	            move $t8, $s1  # reset x for the next row
    	            blt $t5, $t6, rows_14tall_loop
                jr $ra
                
            # not all of the columns are actually 14 thick (but most are); thickness is set by difference between starting x coord and location of right bound ($t3)
            cols_14thick:
                move $t6, $s3  # move desired height into $t6
    	        move $t7, $s0  # move y into $t7
    	        move $t8, $s1  # move x into $t8
                li $t5, 0  # i = 0
    	        cols_14thick_loop:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel (top left)
    	            mul $t1, $t1, 4  # pixels to addrs
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1  # x += 1
    	            blt $t8, $t3, cols_14thick_loop
    	        
    	            addi $t5, $t5, 1  # i += 1
    	            addi $t7, $t7, 1  # y += 1
    	            move $t8, $s1  # reset x for next row
    	            blt $t5, $t6, cols_14thick_loop
                jr $ra
              
    	    After:
    	        lw $ra, 0($sp)  # restore our original return address
    	        addi $sp, $sp, 4  # pop it off of the stack
    	        jr $ra  # jump back
##############################################################################################################################################################################