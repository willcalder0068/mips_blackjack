.data

    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words
    FrameBuffer: .space 0x80000  # allocate space for bitmap
   
    RED: .word 0x00FF0000
    GREEN: .word 0x00006400
    BLACK: .word 0x00000000
    WHITE: .word 0x00FFFFFF
    BROWN: .word 0x006B3410
    LIME: .word 0x0000FF00
    BLUE: .word 0x000000CD
    GRAY: .word 0x00D3D3D3
   
    NewLine: .asciiz "\n"
    InitialMessage1: .asciiz "YOUR STARTING CHIP COUNT: 1000 \n"
    InitialMessage2: .asciiz "Enter your wager: "
    FaultyWager: .asciiz "Insufficient funds, try again. \n"
    HSDP: .asciiz "Press 'h' to hit, 's' to stand, 'p' to split, or 'd' to double: "
    HSD: .asciiz "Press 'h' to hit, 's' to stand, or 'd' to double: "
   
    .align 2
    BaseDeck: .space 208
    UserDeck: .space 208
    DeckFlags: .space 52
    UserBust1: .word 0
    UserBust2: .word 0
    DealerBust: .word 0
    UserAceCount1: .word 0
    UserAceCount2: .word 0
    DealerAceCount: .word 0
    CardType: .word 0
    Card1: .word 0
    Bank: .word 1000
    Wager: .word 0
    ReshuffleBool: .word 0
   
.text
.globl main
main:
    la $s7, FrameBuffer  # $s7 = base addr of frame buffer
    ## $s7 CANT BE OVERRIDDEN / OVERWRITTEN

    initial_messages:
    	li $v0, 4
    	la $a0, InitialMessage1
    	syscall
    	la $a0, InitialMessage2
    	syscall

    shuffle_deck:
        li $s6, -4  # deck index stored in $s6; we iterate through this when pulling from our shuffled deck
        ## $s6 CANT BE OVERRIDDEN / OVERWRITTEN
        
        la $t0, BaseDeck  # load base addr of the space reserved for the base deck
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
        sw $t1, 204($t0)  # initialize an unshuffled deck. 11 = J, 12 = Q, 13 = K, 14 = A
        
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
        sb $zero, 51($t0) # initialize all deck flags to 0
        
        addi $t7, $zero, 0
        addi $t8, $zero, 204
        shuffle_loop:
            li $v0, 42  # generate random integer
            li $a0, 0
            li $a1, 52  # between 0 and 51
            syscall
            move $t9, $a0  # store it in $t9
            
            la $t0, DeckFlags
            add $t1, $t0, $t9  # random index from deck flags stored in $t1
            lb $t2, 0($t1)  # load random bit from deck flags
            bne $t2, $zero, shuffle_loop  # try again if we have already used it
            li $t2, 1
            sb $t2, 0($t1)  # mark index as used
            
            la $t0, BaseDeck
            mul $t2, $t9, 4  # btye to word
            add $t3, $t0, $t2  # store the random index of our base deck in $t3
            lw $t4, 0($t3)  # store the random value from our base deck in $t4
            
            la $t0, UserDeck
            add $t3, $t0, $t7  # start at the beginning of the user deck and ascend
            sw $t4, 0($t3)  # store the random value from the base deck in the user deck
            addi $t7, $t7, 4
            ble $t7, $t8, shuffle_loop

        # Print user deck
        #la $a0, NewLine
        #li $v0, 4
        #syscall
        #la $t0, UserDeck
        #li $t1, 0
        #li $t4, 52
        #print_loop:
            #mul $t2, $t1, 4
            #add $t3, $t0, $t2
            #lw  $a0, 0($t3)
            #li  $v0, 1
            #syscall
            #li  $a0, 32  # ascii for space
            #li  $v0, 11
            #syscall
            #addi $t1, $t1, 1
            #blt  $t1, $t4, print_loop
            
    # always back the background after shuffling              
    make_background:
        li $t0, 512  # screen width
        li $t1, 256  # screen height
        mul $t2, $t0, $t1  # total pixels = width * height
        mul $t2, $t2, 4  # bytes to words

        la $t0, BROWN
        lw $t0, 0($t0)  # $t3 = brown
        la $t1, GREEN
        lw $t1, 0($t1)  # $t4 = green

        li $t3, 0  # i = 0; i will iterate across every pixel on the map
        fill_brown:
            add $t4, $s7, $t3  # addr = frameBuffer + pixel offset
            sw  $t0, 0($t4)  # store brown in the addr of our current pixel
            addi $t3, $t3, 4  # i += 4 (bytes to words)
            blt  $t3, $t2, fill_brown

    	li $t6, 2000  # max x = 512 - 12; leave a brown border of 12 pixels (bytes to bits)
    	li $t7, 244  # max y = 256 - 12; leave a brown border of 12 pixels
    	li $s0, 12  # y = 12; y will be incremented as we move to the next row
    	increment_green_row:
            li $s1, 48  # x = 48 (bytes to words) ; x needs to be incremented across each row
            mul $t8, $s0, 512  # first pixel of row = y * width
            mul $t8, $t8, 4  # bytes to words

            fill_row_green:
                add $t3, $t8, $s1  # curr pixel index = (y * width) + x
            	add $t4, $s7, $t3  # addr = frameBuffer + offset
            	sw  $t1, 0($t4)  # store green in the addr of our current pixel
            	addi $s1, $s1, 4  # x += 4
            	blt  $s1, $t6, fill_row_green

            addi $s0, $s0, 1  # y += 1
            blt  $s0, $t7, increment_green_row
            
        # always deal after making the new background
        initial_deal:
            li $v0, 5  # read a string
            syscall
            la $t0, Bank
            lw $t0, 0($t0)
            ble $v0, $t0, wager_ifelse  # if the wager is less than the bank, it cant happen
                li $v0, 4
                la $a0, FaultyWager
                syscall
                la $a0, InitialMessage2
                syscall
                j initial_deal  # try again
            wager_ifelse:
                la $t0, Wager
                lw $v0, 0($t0)  # store the wager amount
            
            la $s5, DealerBust
            la $s4, DealerAceCount
            li $s1, 256
            li $s0, 22
            jal draw_card  # first dealer card
            # arguments: bust count, ace count, x - $s1 - and y - $s2 - coordinates (top left corner)
        
            la $s5, UserBust1
            la $s4, UserAceCount1
            li $s1, 183
            li $s0, 144
            jal draw_card  
            # arguments: bust count, ace count, x - $s1 - and y - $s2 - coordinates (top left corner)
            
            la $t0, Card1
            la $t1, CardType
            lw $t1, 0($t1)
            sw $t1, 0($t0)  # store the first card type in Card1
            
            li $s1, 263
            li $s0, 144
            jal draw_card  # second user-card
            # arguments: bust count and ace count (same), x - $s1 - and y - $s2 - coordinates (top left corner)
            
            la $t0, Card1
            lw $t0, 0($t0)
            la $t1, CardType  # get the second CardType
            lw $t1, 0($t1)
            bne $t0, $t1, pair_ifelse1  # if the user has a pair, they can split
                li $v0, 4
    		la $a0, HSDP  # hit, stand, double, split
    		syscall
    		j pair_ifelse2
            pair_ifelse1:
                li $v0, 4
                la $a0, HSD  # hit, stand, double
                syscall
            pair_ifelse2:
            
            
            j Done
    
    
    
    
    
    
    
    
    
    
    # x value stored in $s1 and y value stored in $s0 (top left corner), card index count in $s6, bust addr stored in $s5, ace count addr in $s4
    draw_card:
        addi $sp, $sp, -4
        sw $ra, 0($sp)  # store return address on the top of the stack
        addi $s6, $s6, 4  # increment the card index count as a card is going to be taken out
        li $t0, 140
        blt $s6, $t0, reshuffle_bool  # if we have used more than 34 cards, flip reshuffle bool to true
            la $t0, ReshuffleBool
            li $t1, 1
            sw $t1, 0($t0)
        reshuffle_bool:

        li $t0, 66  # card width
        li $t1, 90  # card height
        
        ## Crucial values
        add $t3, $s1, $t0  # right edge of the card
        add $t4, $s0, $t1  # bottom edge of the card
    
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
    	
        # Pick a card form the deck, remove it, draw it, increment the user / dealer bust value
        draw_card_number:
            addi $t3, $t3, -8
            addi $t4, $t4, -8
            addi $s0, $s0, 8
            addi $s1, $s1, 8  # set pixel offsets; the numbers are 8 pixels from the white edge
        
            la $t9, RED
            lw $t9, 0($t9)  # $t9 = red
        
            la $t0, UserDeck
            add $t0, $t0, $s6  # move to the current index
            lw $t0, 0($t0)  # get its type
        
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
            beq $t0, $t1, type_fourteen  # go to the correct card type
        
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
                addi $t0, $t0, 3  # adjust from value to type (10 to 13
                sw $t0, 0($t2)
                addi $t0, $t0, -3
        
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
    	        lw $ra, 0($sp)
    	        addi $sp, $sp, 4
    	        jr $ra  # restore return address and jump back
           
        Done: