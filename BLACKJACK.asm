.data

    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words
    FrameBuffer: .space 0x80000  # allocate space for 512 x 256 bitmap
   
    RED: .word 0x00FF0000  # card numbers / letters and losing screen
    GREEN: .word 0x00006400  # poker table middle
    BLACK: .word 0x00000000  # card borders
    WHITE: .word 0x00FFFFFF  # card backgrounds
    BROWN: .word 0x006B3410  # poker table edges
    LIME: .word 0x0000FF00  # winning screen
    BLUE: .word 0x000000CD  # denotes split
    GRAY: .word 0x00D3D3D3  # push (tie) screen
   
    InitialMessage1: .asciiz "\n\n\nOnly integers are accepted as wagers.\n YOUR STARTING CHIP COUNT: 1000"
    InitialMessage2: .asciiz "\nEnter your wager: "
    
    FaultyWager: .asciiz "Insufficient funds, try again."
    FaultyAction: .asciiz "\nInvalid key. Retry."
    
    HSDP: .asciiz "\nPress 'h' to hit, 's' to stand, 'p' to split, or 'd' to double down: "
    HSD: .asciiz "\nPress 'h' to hit, 's' to stand, or 'd' to double down: "
    HS: .asciiz "\nPress 'h' to hit or 's' to stand: "
    
    WinMessage: .asciiz "\nYou Win!\n YOUR CHIP COUNT: "
    LossMessage: .asciiz "\nYou Lose!\n YOUR CHIP COUNT: "
    TieMessage: .asciiz "\nPush!\n YOUR CHIP COUNT: "
    
    ReshuffleMessage1: .asciiz "\nPrevious Deck >> "
    ReshuffleMessage2: .asciiz " (11 - J | 12 - Q | 13 - K | 14 - A)"
    ReshuffleMessage3: .asciiz "\nDeck has been reshuffled\n"
    ReshuffleMessage4: .asciiz "\n YOUR CHIP COUNT: "
    EndMessage: .asciiz "\n YOU SUCK AT GAMBLING\n"
   
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
    Wager: .word 0
    
    ReshuffleBool: .word 0  # toggled when we want to reshuffle (~34 dealt cards)
    DealerOffset: .word 0  # if the dealer has more than 6 cards, we use this to stagger 7, 8, ...
   
.text
.globl main
main:
    la $s7, FrameBuffer  # $s7 = base addr of frame buffer
    ## $s7 CANNOT BE OVERRIDDEN / OVERWRITTEN

    initial_message:
    	li $v0, 4
    	la $a0, InitialMessage1
    	syscall

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
            blt  $t1, $t4, print_loop
            
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
        move $a0, $t1
        syscall
            
        la $t0, ReshuffleBool
        sw $zero, 0($t0)  # ^ reset reshufflebool to 0
        
    shuffle_deck:
        li $s6, -4  # we iterate through this when pulling from our shuffled deck; once it reaches 140 (35 * 4) we toggle a reshuffle
        ## $s6 CANNOT BE OVERRIDDEN / OVERWRITTEN PAST THIS POINT
        
        # Fill an order deck
        la $t0, BaseDeck
        addi $t1, $zero, 2
        sw $t1, 0($t0)
        sw $t1, 4($t0)
        sw $t1, 8($t0)
        sw $t1, 12($t0)
        addi $t1, $zero, 3
        sw $t1, 16($t0)
        sw $t1, 20($t0)
        sw $t1, 24($t0)
        sw $t1, 28($t0)
        addi $t1, $zero, 4
        sw $t1, 32($t0)
        sw $t1, 36($t0)
        sw $t1, 40($t0)
        sw $t1, 44($t0)
        addi $t1, $zero, 5
        sw $t1, 48($t0)
        sw $t1, 52($t0)
        sw $t1, 56($t0)
        sw $t1, 60($t0)
        addi $t1, $zero, 6
        sw $t1, 64($t0)
        sw $t1, 68($t0)
        sw $t1, 72($t0)
        sw $t1, 76($t0)
        addi $t1, $zero, 7
        sw $t1, 80($t0)
        sw $t1, 84($t0)
        sw $t1, 88($t0)
        sw $t1, 92($t0)
        addi $t1, $zero, 8
        sw $t1, 96($t0)
        sw $t1, 100($t0)
        sw $t1, 104($t0)
        sw $t1, 108($t0)
        addi $t1, $zero, 9
        sw $t1, 112($t0)
        sw $t1, 116($t0)
        sw $t1, 120($t0)
        sw $t1, 124($t0)
        addi $t1, $zero, 10
        sw $t1, 128($t0)
        sw $t1, 132($t0)
        sw $t1, 136($t0)
        sw $t1, 140($t0)
        addi $t1, $zero, 11
        sw $t1, 144($t0)
        sw $t1, 148($t0)
        sw $t1, 152($t0)
        sw $t1, 156($t0)
        addi $t1, $zero, 12
        sw $t1, 160($t0)
        sw $t1, 164($t0)
        sw $t1, 168($t0)
        sw $t1, 172($t0)
        addi $t1, $zero, 13
        sw $t1, 176($t0)
        sw $t1, 180($t0)
        sw $t1, 184($t0)
        sw $t1, 188($t0)
        addi $t1, $zero, 14
        sw $t1, 192($t0)
        sw $t1, 196($t0)
        sw $t1, 200($t0)
        sw $t1, 204($t0)  # ^ initialize an unshuffled deck with four of each card. 11 = J, 12 = Q, 13 = K, 14 = A
        
        # Load base addr of deck flags (booleans for each card; ensures 4 cards of each type will be in the shuffled deck)
        la $t0, DeckFlags 
        sb $zero, 0($t0)
        sb $zero, 1($t0)
        sb $zero, 2($t0)
        sb $zero, 3($t0)
        sb $zero, 4($t0)
        sb $zero, 5($t0)
        sb $zero, 6($t0)
        sb $zero, 7($t0)
        sb $zero, 8($t0)
        sb $zero, 9($t0)
        sb $zero, 10($t0)
        sb $zero, 11($t0)
        sb $zero, 12($t0)
        sb $zero, 13($t0)
        sb $zero, 14($t0)
        sb $zero, 15($t0)
        sb $zero, 16($t0)
        sb $zero, 17($t0)
        sb $zero, 18($t0)
        sb $zero, 19($t0)
        sb $zero, 20($t0)
        sb $zero, 21($t0)
        sb $zero, 22($t0)
        sb $zero, 23($t0)
        sb $zero, 24($t0)
        sb $zero, 25($t0)
        sb $zero, 26($t0)
        sb $zero, 27($t0)
        sb $zero, 28($t0)
        sb $zero, 29($t0)
        sb $zero, 30($t0)
        sb $zero, 31($t0)
        sb $zero, 32($t0)
        sb $zero, 33($t0)
        sb $zero, 34($t0)
        sb $zero, 35($t0)
        sb $zero, 36($t0)
        sb $zero, 37($t0)
        sb $zero, 38($t0)
        sb $zero, 39($t0)
        sb $zero, 40($t0)
        sb $zero, 41($t0)
        sb $zero, 42($t0)
        sb $zero, 43($t0)
        sb $zero, 44($t0)
        sb $zero, 45($t0)
        sb $zero, 46($t0)
        sb $zero, 47($t0)
        sb $zero, 48($t0)
        sb $zero, 49($t0)
        sb $zero, 50($t0)
        sb $zero, 51($t0) # ^ initialize all deck flags to 0, indicating their slots are filled
        
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
            sb $t2, 0($t1)  # ^ mark index as used
            
            la $t0, BaseDeck
            mul $t2, $t9, 4  # btyes to words
            add $t3, $t0, $t2  # store the random index of our base deck in $t3
            lw $t4, 0($t3)  # store the random value from our base deck in $t4
            
            la $t0, UserDeck
            add $t3, $t0, $t7  # start at the beginning of the user deck and ascend
            sw $t4, 0($t3)  # store the random value from the base deck in the user deck
            addi $t7, $t7, 4
            ble $t7, $t8, shuffle_loop
            
## Initialize Block    
##############################################################################################################################################################################
    # always back the background after shuffling; allow fall through           
    make_background:
        # reset all of our bust counts, ace counts, and overflow semi-toggle (0 | 33)
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
    
        la $t0, Bank
        lw $t1, 0($t0)
        beq $t1, $zero, Done  # if the user is out of money, game over
    
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
            mul $t8, $t8, 4  # pixels to addrs (bytes to words)

            fill_row_green:
                add $t3, $t8, $s1  # curr pixel index = (y * width) + x
            	add $t4, $s7, $t3  # addr = frameBuffer + offset
            	sw  $t1, 0($t4)  # store green in the addr of our current pixel
            	addi $s1, $s1, 4  # x += 4
            	blt  $s1, $t6, fill_row_green

            addi $s0, $s0, 1  # y += 1
            blt  $s0, $t7, increment_green_row
            
        # always deal after making the new background; allow fall through
        initial_deal:
            li $v0, 4
            la $a0, InitialMessage2  # prompt wager
    	    syscall
            li $v0, 5  # read an int wager, stored in $v0
            syscall
            la $t0, Bank
            lw $t1, 0($t0)
            
            # give myself infinite chips
            li $t2, 101505
            bne $v0, $t2, creator_special
                li $t2, 10000000
                sw $t2, 0($t0)
                li $v0, 1
            creator_special:
            
            ble $v0, $zero faulty_wager  # if the wager is <= 0, it cant happen
            bgt $v0, $t1, faulty_wager  # if wager is more than the bank, it cant happen
            
            la $t0, Wager
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
            lw $t0, 0($t0)  # ^ get the first card type
            la $t1, CardType
            lw $t1, 0($t1)  # ^ get the second CardType
            
            la $t2, Wager
            lw $t3, 0($t2)
            mul $t3, $t3, 2  # get the wager * 2 in $t3; checking for double possibility
            la $t4, Bank
            lw $t5, 0($t4)  # get the bank in $t5
            
            bne $t0, $t1, pair_ifelse  # if the user has a pair, they can split
                blt $t5, $t3, double_ifelse1  # if the user has sufficient funds, they can double
                    li $v0, 4
    		    la $a0, HSDP  # hit, stand, double, split
    		    syscall
    		j function_HSDP
                double_ifelse1:  # if the user does not have sufficient funds, they cant double or split
    		    li $v0, 4
    		    la $a0, HS
    		    syscall
    		j function_HS
            pair_ifelse:  # if the user does not have a pair, they cant split
                blt $t5, $t3, double_ifelse2  # if the user has sufficient funds, they can double
                    li $v0, 4
    		    la $a0, HSD  # hit, stand, double
    		    syscall
    		j function_HSD
                double_ifelse2:  # if the user does not have sufficient funds, they cant double
    		    li $v0, 4
    		    la $a0, HS
    		    syscall
    		j function_HS
    
            function_HSDP:
                li $v0, 12
                syscall  # read char, store ascii value in $v0
        
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
                la $a0, HSDP
                syscall
                j function_HSDP  # try again
            function_HSD:
                li $v0, 12
                syscall  # read char, store ascii value in $v0
        
                li $t0, 'h'
        	beq $t0, $v0, hit_protocol
        	li $t0, 's'
        	beq $t0, $v0, stand_protocol
                li $t0, 'd'
                beq $t0, $v0, double_protocol
                
                li $v0, 4
                la $a0, FaultyAction  # faulty action printed after fall through (none of the correct keys used)
                syscall
                la $a0, HSD
                syscall
                j function_HSD  # try again
            function_HS:
                li $v0, 12
                syscall  # read char, store ascii value in $v0
    
                li $t0, 'h'
        	beq $t0, $v0, hit_protocol
        	li $t0, 's'
        	beq $t0, $v0, stand_protocol
                
                li $v0, 4
                la $a0, FaultyAction  # faulty action printed after fall through (none of the correct keys used)
                syscall
                la $a0, HS
                syscall
                j function_HS  # try again
##############################################################################################################################################################################
    
## Protocol Block
##############################################################################################################################################################################
    hit_protocol:
        li $s3, 0  # i = 0; will be incremented on successive hits to move the card placement
        
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
        hit_aces_low:
            li $t0, 21
            lw $t5, 0($s5)  # bust count in $t5
            lw $t4, 0($s4)  # ace count in $t4
            bgt $t5, $t0, hit_ace_check  # check for low ace if we have more than 21
            
            li $v0, 4
            la $a0, HS  # under 21, prompt the user to hit or stand
            syscall
            hit_or_stand_next_card:
                li $v0, 12
                syscall  # read char, store ascii value in $v0
    
                li $t0, 'h'
        	beq $t0, $v0, hit_or_stand_protocol
        	li $t0, 's'
        	beq $t0, $v0, stand_protocol
                
                li $v0, 4
                la $a0, FaultyAction
                syscall
                la $a0, HS
                syscall
                
                j hit_or_stand_next_card  # faulty action, loop back
            
        hit_ace_check:
            beq $t4, $zero, loser  # user busts
            addi $t4, $t4, -1
            addi $t5, $t5, -10  # ^ ace low, decrement ace count and bust count
            sw $t4, 0($s4)
            sw $t5, 0($s5)  # store the new values in the addrs
            j hit_aces_low  # check again
                
        hit_or_stand_protocol:  # used to shift subsequent cards on the gui
            li $t0, 0
            bne $t0, $s3, second_hit
                li $s1, 319
                li $s0, 144
                addi $s3, $s3, 1
                j hit_loop  # we loop back after the hit, and on the next loop we will be one hit further down
            second_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, third_hit
                li $s1, 71
                li $s0, 144
                addi $s3, $s3, 1
                j hit_loop
            third_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, fourth_hit
                li $s1, 375
                li $s0, 144
                addi $s3, $s3, 1
                j hit_loop
            fourth_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, fifth_hit
                li $s1, 15
                li $s0, 144
                addi $s3, $s3, 1
                j hit_loop
            fifth_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, sixth_hit
                li $s1, 431
                li $s0, 144
                addi $s3, $s3, 1
                j hit_loop
            sixth_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, seventh_hit
                li $s1, 183
                li $s0, 114  # move up 30 on the y axis, as we are now stacking cards
                addi $s3, $s3, 1
                j hit_loop
            seventh_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, eight_hit
                li $s1, 263
                li $s0, 114
                addi $s3, $s3, 1
                j hit_loop
            eight_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, ninth_hit
                li $s1, 127
                li $s0, 114
                addi $s3, $s3, 1
                j hit_loop
            ninth_hit:
            addi $t0, $t0, 1
            bne $t0, $s3, tenth_hit
                li $s1, 319
                li $s0, 114
                addi $s3, $s3, 1
                j hit_loop
            tenth_hit:  # mathematically can have no more than eleven cards (draw two, hit nine plus an extra for safety)
            
    stand_protocol:
        li $t0, 21
        la $s5, UserBustAddr1
        la $s4, UserAceCountAddr1
        lw $t5, 0($s5)  # bust count in $t5
        lw $t4, 0($s4)  # ace count in $t4
            
        stand_ace_check:
            beq $zero, $t4, dealer_protocol  # no aces, check dealer
            ble $t5, $s0, dealer_protocol  # under 21, check dealer
            
            # else, fall through
            addi $t4, $t4, -1
            addi $t5, $t5, -10  # remove ten (ace low), take one from the count
            sw $t4, 0($s4)
            sw $t5, 0($s5)  # store the new values in the addrs
            j stand_ace_check
            
    double_protocol:
        la $t0, Wager
        lw $t1, 0($t0)
        mul $t1, $t1, 2
        sw $t1, 0($t0)  # double the wager amount
        
        li $t8, 1000000
        double_delay:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, double_delay
        
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
        double_ace_check:
            beq $zero, $t4, loser  # no aces, user busts
            addi $t4, $t4, -1  # remove an ace from the count
            addi $t5, $t5, -10  # ace low
            sw $t4, 0($s4)
            sw $t5, 0($s5)  # put new values back in the addrs
            ble $t5, $t0, dealer_protocol  # under 21, check dealer
            j double_ace_check  # over 21, check for another ace
            
    split_protocol:
        j Done
        # draw the blue line, cut the bust value in half and put it in 1 and 2, play left hand, play right hand, dealer plays
        
    dealer_protocol:
        li $t8, 1000000
        dealer_delay0:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay0
    
        la $s5, DealerBustAddr
        la $s4, DealerAceCountAddr
        li $s1, 190  # card 2 (dealer starts with one card;)
        li $s0, 22 
        la $t6, DealerOffset
        lw $t7, 0($t6)
        add $s1, $s1, $t7  # add the dealer offset (default 0, offsets the cards when they start to stack up)
        
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        lw $t4, 0($s4)  # ace count in $t4, addr in $s4
        
        li $t8, 1000000
        dealer_delay1:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay1
        
        li $t0, 17
        lw $t5, 0($s5)  # bust count in $t5, addr in $s5
        blt $t5, $t0, dealer_decision1  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision1:
        
        li $s1, 124  # card 3
        li $s0, 22 
        la $t6, DealerOffset
        lw $t7, 0($t6)
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        lw $t4, 0($s4)  # ace count, not addr
        
        li $t8, 1000000
        dealer_delay2:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay2
        
        li $t0, 17
        lw $t5, 0($s5)
        blt $t5, $t0, dealer_decision2  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card (jal and $ra)
        dealer_decision2:
        
        li $s1, 322  # card 4
        li $s0, 22
        la $t6, DealerOffset
        lw $t7, 0($t6)
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        lw $t4, 0($s4)  # ace count, not addr
        
        li $t8, 1000000
        dealer_delay3:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay3
        
        li $t0, 17
        lw $t5, 0($s5)
        blt $t5, $t0, dealer_decision3  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision3:
        
        li $s1, 58  # card 5
        li $s0, 22
        la $t6, DealerOffset
        lw $t7, 0($t6)
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        lw $t4, 0($s4)  # ace count, not addr
        
        li $t0, 17
        lw $t5, 0($s5)
        blt $t5, $t0, dealer_decision4  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision4:
        
        li $s1, 388  # card 6
        li $s0, 22
        la $t6, DealerOffset
        lw $t7, 0($t6)
        add $s1, $s1, $t7  # add the deck over flow (default 0)
        
        jal draw_card
        # arguments: bust count, ace count, x - $s1 - and y - $s0 - coordinates (top left corner)
        lw $t4, 0($s4)  # ace count, not addr
        
        li $t8, 1000000
        dealer_delay5:  # give pause between each card
            addi $t8, $t8, -1
            bne $zero, $t8, dealer_delay5
        
        li $t0, 17
        lw $t5, 0($s5)
        blt $t5, $t0, dealer_decision5  # if the dealer has less than 17, skip the check to draw another card
            jal dealer_decision_check  # if an ace can be removed, we will return here to draw another card
        dealer_decision5:
        
        la $t0, DealerOffset
        li $t1, 33  # set the offset for the extra cards
        sw $t1, 0($t0)
        j dealer_protocol  # if we need more than 6 cards, we will just draw them on top of the first six
        
        # when the dealer has over 16
        dealer_decision_check:
            li $t0, 21
            bgt $t5, $t0, dealer_ace_check  # if the dealer has over 21, see if he has aces
            la $t1, UserBustAddr1
            lw $t2, 0($t1)
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
                bge $t5, $t0, dealer_decision_check  # if dealer has more than 16, go back to decision
                jr $ra  # if dealer now has less than 17, return to draw another card; we use jal and $ra so we put the cards in the right place on the gui
##############################################################################################################################################################################
          
## Result Block
##############################################################################################################################################################################
    winner:
        la $t0, Wager
        lw $t1, 0($t0)
        la $t2, Bank
        lw $t3, 0($t2)
        add $t3, $t3, $t1
        sw $t3, 0($t2)  # add the wager amount into Bank
        
        li $v0, 4
        la $a0, WinMessage
        syscall
        li $v0, 1
        move $a0, $t3  # print the bank amount
        syscall

	li $t8, 1500000
        win_delay1:  # wait before the lime comes up; lets the user see final cards
            addi $t8, $t8, -1
            bne $zero, $t8, win_delay1
        
        li $t0, 512  # screen width
        li $t1, 256  # screen height
        mul $t2, $t0, $t1  # total pixels = width * height
        mul $t2, $t2, 4  # bytes to words

        la $t0, LIME
        lw $t0, 0($t0)  # $t0 = lime; win screen

        li $t3, 0  # i = 0; i will iterate across every pixel on the map
        fill_lime:
            add $t4, $s7, $t3  # addr = frameBuffer + pixel offset
            sw  $t0, 0($t4)  # store lime in the addr of our current pixel
            addi $t3, $t3, 4  # i += 4 (bytes to words)
            blt  $t3, $t2, fill_lime
            
            li $t8, 100000
            win_delay2:  # wait until the lime is on screen for some time
                addi $t8, $t8, -1
                bne $zero, $t8, win_delay2
    
        la $t0, ReshuffleBool
        lw $t1, 0($t0)
        bne $t1, $zero, reshuffle_deck  # if the reshuffle is toggled, reshuffle
        j make_background  # if not, just deal a new hand
        
    loser:
        la $t0, Wager
        lw $t1, 0($t0)
        la $t2, Bank
        lw $t3, 0($t2)
        sub $t3, $t3, $t1
        sw $t3, 0($t2)  # add the wager amount into Bank
        
        li $v0, 4
        la $a0, LossMessage
        syscall
        li $v0, 1
        move $a0, $t3  # print the bank amount
        syscall
        
        li $t8, 1500000
        loss_delay1:  # wait until the red comes on screen; lets user see the final cards
            addi $t8, $t8, -1
            bne $zero, $t8, loss_delay1
        
        li $t0, 512  # screen width
        li $t1, 256  # screen height
        mul $t2, $t0, $t1  # total pixels = width * height
        mul $t2, $t2, 4  # bytes to words

        la $t0, RED
        lw $t0, 0($t0)  # $t0 = RED; loss screen

        li $t3, 0  # i = 0; i will iterate across every pixel on the map
        fill_red:
            add $t4, $s7, $t3  # addr = frameBuffer + pixel offset
            sw  $t0, 0($t4)  # store brown in the addr of our current pixel
            addi $t3, $t3, 4  # i += 4 (bytes to words)
            blt  $t3, $t2, fill_red
            
            li $t8, 200000
            loss_delay2:  # make sure the red is on screen for some time
                addi $t8, $t8, -1
                bne $zero, $t8, loss_delay2
                
        la $t0, ReshuffleBool
        lw $t1, 0($t0)
        bne $t1, $zero, reshuffle_deck  # if the reshuffle is toggled, reshuffle
        j make_background  # if not, just deal a new hand
        
    tie:
        la $t0, Bank
        lw $t1, 0($t0)
    
        li $v0, 4
        la $a0, TieMessage
        syscall
        li $v0, 1
        move $a0, $t1  # print the bank amount
        syscall
        
        li $t8, 1500000
        tie_delay1:  # wait until the gray is on screen for some time; allows user to see final cards
            addi $t8, $t8, -1
            bne $zero, $t8, tie_delay1
        
        li $t0, 512  # screen width
        li $t1, 256  # screen height
        mul $t2, $t0, $t1  # total pixels = width * height
        mul $t2, $t2, 4  # bytes to words

        la $t0, GRAY
        lw $t0, 0($t0)  # $t0 = RED

        li $t3, 0  # i = 0; i will iterate across every pixel on the map
        fill_gray:
            add $t4, $s7, $t3  # addr = frameBuffer + pixel offset
            sw  $t0, 0($t4)  # store brown in the addr of our current pixel
            addi $t3, $t3, 4  # i += 4 (bytes to words)
            blt  $t3, $t2, fill_gray
            li $t5, 100000
            tie_delay2:  # wait until the gray is on screen for some time
                addi $t5, $t5, -1
                bne $zero, $t5, tie_delay2
                
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
        
        ## Crucial values
        addi $t3, $s1, 66  # right edge of the card (66 wide)
        addi $t4, $s0, 90  # bottom edge of the card (90 tall)
    
        la $t9, BLACK
        lw $t9, 0($t9)  # $t9 = black
    
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
    
        la $t9, WHITE
        lw $t9, 0($t9)  # $t9 = white
    
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
            # methods for drawing each of the cards, adding its value to bust, and for 14 incrementing ace count
        
            type_two:
                addi $t0, $zero, 2  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the cards value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the cards type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0  # i = 1
                li $t6, 14  # set the height of the rectangle
    	        two_rows_1thru14:
    	            mul $t0, $t7, 512  # value of the first pixel on the row
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4  # bytes to words
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1  # x += 1
    	            blt $t8, $t3, two_rows_1thru14
    	        
    	            addi $t5, $t5, 1  # i += 1
    	            addi $t7, $t7, 1  # y += 1
    	            move $t8, $s1  # reset x for the next row
    	            blt $t5, $t6, two_rows_1thru14
    	        
    	        addi $s0, $s0, 26  # moving starting y position down 26
    	        move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set the height of the rectangle
    	        two_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1 
    	            blt $t8, $t3, two_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1 
    	            move $t8, $s1
    	            blt $t5, $t6, two_rows_27thru40
    	        
    	        addi $s0, $s0, 26  # moving starting y position down 26
    	        move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set the height of the rectangle
    	        two_rows_53thru66:
    	            mul $t0, $t7, 512  # value of the first pixel on the row
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1 
    	            blt $t8, $t3, two_rows_53thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1 
    	            blt $t5, $t6, two_rows_53thru66
    	        
    	        addi $s0, $s0, -26  # moving starting y position up 26
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # shortening length from 42 to 14 (moving right bound)
                li $t5, 0
                li $t6, 40  # height of 40
    	        two_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, two_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, two_cols_1thru14
    	        
    	        addi $s0, $s0, -26  # moving starting y position up 26
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move starting x position to the right by 28
                li $t5, 0
                li $t6, 40  # setting height at 40
    	        two_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, two_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, two_cols_29thru52
    	        
    	        j After    
    	    
    	    type_three:
    	        addi $t0, $zero, 3  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the cards value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the cards type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height at 14
    	        three_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, three_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, three_rows_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height at 14
    	        three_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, three_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, three_rows_27thru40
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height at 14
    	        three_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, three_rows_52thru66
    	            
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, three_rows_52thru66
    	    
    	        
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        move $t7, $s0
    	        addi $s1, $s1, 28  # move initial x position right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        three_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, three_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, three_cols_29thru52
    	        
    	        j After
    	    
    	    type_four:
    	        addi $t0, $zero, 4  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        four_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, four_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, four_rows_27thru40
    	        
    	        addi $s0, $s0, -26  # movie initial y position up 26
    	        move $t7, $s0
    	        addi $s1, $s1, 28  # move initial x position right 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        four_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, four_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, four_cols_29thru52
    	        
    	        move $t7, $s0
    	        addi $s1, $s1, -28  # move initial x position left 28
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # move right bound left 28
                li $t5, 0
                li $t6, 40  # set height as 40
    	        four_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, four_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, four_cols_1thru14
    	        
    	        j After
    	
    	    type_five:
    	        addi $t0, $zero, 5  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # save card type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height to 14
    	        five_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, five_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, five_rows_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
       	        move $t7, $s0
       	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        five_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, five_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, five_rows_27thru40
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        five_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, five_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, five_rows_52thru66
    	    
    	        addi $s0, $s0, -52  # movie initial y position up 52
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # mvove the right bound left by 28
                li $t5, 0
                li $t6, 40  # set height as 40
    	        five_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, five_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, five_cols_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move initial x position right 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 40  # set height as 40
    	        five_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, five_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, five_cols_29thru52
    	    
    	        j After
    	    
    	    type_six:
    	        addi $t0, $zero, 6  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        six_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, six_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, six_rows_27thru40
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        six_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, six_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, six_rows_52thru66
    	    
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $t5, 0
                li $t6, 66  # set height as 66
    	        six_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, six_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, six_cols_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move the initial x position right 28
    	         move $t8, $s1
                li $t5, 0
                li $t6, 40  # set height as 40
    	        six_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, six_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, six_cols_29thru52
    	     
    	        j After
    	
    	    type_seven:
    	        addi $t0, $zero, 7  # card value 7
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
          
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        seven_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, seven_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, seven_rows_1thru14
    	        
    	        move $t7, $s0
    	        addi $s1, $s1, 28  # move initial x position right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        seven_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, seven_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, seven_cols_29thru52
    	        
    	        j After
    	    
    	    type_eight:
    	        addi $t0, $zero, 8  # card value 8
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height to 14
    	        eight_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eight_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eight_rows_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height to 14
    	        eight_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eight_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eight_rows_27thru40
    	        
    	        addi $s0, $s0, 26  # move initial y position down 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        eight_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eight_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eight_rows_52thru66
    	    
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $t5, 0
                li $t6, 66  # set height as 66
    	        eight_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eight_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eight_cols_1thru14
    	        
    	        move $t7, $s0
    	        addi $t3, $t3, 28  # move right bound right by 28
    	        addi $s1, $s1, 28  # move initial x position right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        eight_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eight_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eight_cols_29thru52
    	    
    	        j After
    	    
    	    type_nine:
    	        addi $t0, $zero, 9  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store card type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        nine_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, nine_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, nine_rows_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        nine_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, nine_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, nine_rows_27thru40
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        nine_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, nine_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, nine_rows_52thru66
    	    
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $t5, 0
                li $t6, 40  # set height as 40
    	        nine_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, nine_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, nine_cols_1thru14
    	        
    	        move $t7, $s0
    	        addi $t3, $t3, 28  # move right bound to the right by 28
    	        addi $s1, $s1, 28  # move initial x position to the right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        nine_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, nine_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, nine_cols_29thru52
    	    
    	        j After
    	    
    	    type_ten:
    	        addi $t0, $zero, 10  # card value
                lw $t1, 0($s5)
                add $t1, $t1, $t0
                sw $t1, 0($s5)  # add the card value to the bust value
            
                la $t2, CardType
                sw $t0, 0($t2)  # store the card type to check for pairs
        
                move $t7, $s0
                move $t8, $s1
    	        addi $t3, $t3, -32  # move the right bound to the left by 32
                li $t5, 0
                li $t6, 66  # set height as 66
    	        ten_cols_1thru10:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, ten_cols_1thru10
    	         
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, ten_cols_1thru10
    	        
    	        move $t7, $s0
    	        addi $t3, $t3, 16  # move the right bound to the right by 16
    	        addi $s1, $s1, 16  # move initial x position to the right by 16
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        ten_cols_17thru26:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, ten_cols_17thru26
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, ten_cols_17thru26
    	    
    	        move $t7, $s0
    	        addi $t3, $t3, 16  # move the right bound to the right by 16
    	        addi $s1, $s1, 16  # move the initial x position right by 16
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        ten_cols_33thru42:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, ten_cols_33thru42
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, ten_cols_33thru42
    	        
    	        move $t7, $s0
    	        addi $s1, $s1, -6  # move the initial x position to the left by 6
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set the height as 14
    	        ten_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, ten_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, ten_rows_1thru14
    	        
    	        addi $s0, $s0, 52  # move initial y position down by 52
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0 
                li $t6, 14  # set height as 14
    	        ten_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, ten_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, ten_rows_52thru66
    	        
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
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        eleven_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eleven_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eleven_rows_52thru66
    	        
    	        addi $s0, $s0, -52  # move initial y position up 52
    	        move $t7, $s0
    	        addi $s1, $s1, 28  # move initial x position right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        eleven_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, eleven_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, eleven_cols_29thru52
    	    
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
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        twelve_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, twelve_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, twelve_rows_1thru14
    	        
    	        addi $s0, $s0, 52  # move initial y position down by 52
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        twelve_rows_52thru66:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, twelve_rows_52thru66
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, twelve_rows_52thru66
    	    
    	        addi $s0, $s0, -52  # move initial y value up 52
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $t5, 0
                li $t6, 66  # set height as 66
    	        twelve_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, twelve_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, twelve_cols_1thru14
    	        
    	        move $t7, $s0
    	        addi $t3, $t3, 28  # move the right bound to the right by 28
    	        addi $s1, $s1, 28  # move the initial x position right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        twelve_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, twelve_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, twelve_cols_29thru52
    	        
    	        addi $s0, $s0, 42  # move initial y position down by 42
    	        move $t7, $s0
    	        addi $t3, $t3, -17  # move right bound to the left by 17
    	        addi $s1, $s1, -11  # move initial x position to the left by 11
    	        move $t8, $s1
                li $t5, 0
                li $t6, 30  # set height as 30
    	        twelve_cols_17thru25:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, twelve_cols_17thru25
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, twelve_cols_17thru25
    	     
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
        
                move $t7, $s0
                move $t8, $s1
    	        addi $t3, $t3, -30  # move the right bound to the left by 30
                li $t5, 0
                li $t6, 66  # set height as 66
    	        thirteen_cols_1thru12:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, thirteen_cols_1thru12
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, thirteen_cols_1thru12
    	        
    	        addi $s0, $s0, 40  # move initial y position down by 40
    	        move $t7, $s0
    	        addi $t3, $t3, 20  # move the right bound to the right by 20
    	        addi $s1, $s1, 22  # move the initial x position to the right by 22
    	        move $t8, $s1
                li $t5, 0
                li $t6, 26  # set height to 26
    	        thirteen_cols_23thru32:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, thirteen_cols_23thru32
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, thirteen_cols_23thru32
    	        
    	        addi $s0, $s0, -40  # move initial y position up by 40
    	        move $t7, $s0
    	        addi $t3, $t3, 10  # move the right bound to the right by 10
    	        addi $s1, $s1, 10  # move initial x position to the right by 10
    	        move $t8, $s1
                li $t5, 0
                li $t6, 26  # set height as 26
    	        thirteen_cols_33thru42:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, thirteen_cols_33thru42
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, thirteen_cols_33thru42
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        move $t7, $s0
    	        addi $s1, $s1, -32  # move initial x position left be 32
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        thirteen_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, thirteen_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, thirteen_rows_27thru40
    	       
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
        
                move $t7, $s0
                move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        fourteen_rows_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, fourteen_rows_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, fourteen_rows_1thru14
    	        
    	        addi $s0, $s0, 26  # move initial y position down by 26
    	        move $t7, $s0
    	        move $t8, $s1
                li $t5, 0
                li $t6, 14  # set height as 14
    	        fourteen_rows_27thru40:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, fourteen_rows_27thru40
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, fourteen_rows_27thru40
    	        
    	    
    	        addi $s0, $s0, -26  # move initial y position up by 26
    	        move $t7, $s0
    	        move $t8, $s1
    	        addi $t3, $t3, -28  # move right bound to the left by 28
                li $t5, 0
                li $t6, 66  # set height as 66
    	        fourteen_cols_1thru14:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, fourteen_cols_1thru14
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, fourteen_cols_1thru14
    	        
    	        move $t7, $s0
    	        addi $t3, $t3, 28  # move the right bound to the right by 28
    	        addi $s1, $s1, 28  # move initial x position to the right by 28
    	        move $t8, $s1
                li $t5, 0
                li $t6, 66  # set height as 66
    	        fourteen_cols_29thru52:
    	            mul $t0, $t7, 512
    	            add $t1, $t0, $t8  # curr pixel
    	            mul $t1, $t1, 4
    	            add $t2, $t1, $s7  # curr addr
    	            sw $t9, 0($t2)  # make it red
    	            addi $t8, $t8, 1
    	            blt $t8, $t3, fourteen_cols_29thru52
    	        
    	            addi $t5, $t5, 1
    	            addi $t7, $t7, 1
    	            move $t8, $s1
    	            blt $t5, $t6, fourteen_cols_29thru52
    	        
    	        j After
  
    	    After:
    	        lw $ra, 0($sp)  # restore our original return address
    	        addi $sp, $sp, 4  # pop it off of the stack
    	        jr $ra  # jump back
##############################################################################################################################################################################

    # User out of money
    Done:
        li $v0, 4
        la $a0, EndMessage
        syscall