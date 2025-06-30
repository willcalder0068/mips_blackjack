.data

    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words
    FrameBuffer: .space 0x80000  # allocate space for bitmap
   
    RED: .word 0x00FF0000
    GREEN: .word 0x00006400
    BLACK: .word 0x00000000
    WHITE: .word 0x00FFFFFF
    BROWN: .word 0x006B3410
   
    NewLine: .asciiz "\n"
    InitialMessage1: .asciiz "YOUR STARTING CHIP COUNT: 1000 \n"
    InitialMessage2: .asciiz "Enter your wager: "
   
    .align 2
    BaseDeck: .space 208
    .align 2
    UserDeck: .space 208
    DeckFlags: .space 52
   
.text
.globl main
main:
    la $s7, FrameBuffer  # $s7 = base addr of frame buffer
    addi $s6, $zero, 0  # USER BUST VALUE 1
    addi $s5, $zero, 0  # USER BUST VALUE 2 (Used if the hand is split)
    addi $s4, $zero, 0  # DEALER BUST VALUE
    ## $s4-7 CANNOT UNDER ANY CIRCUMSTANCES BE OVERRIDDEN / OVERWRITTEN

    initialize:
        # Print Initial Messages
    	li $v0, 4
    	la $a0, InitialMessage1
    	syscall
    	la $a0, InitialMessage2
    	syscall

    shuffle_deck:
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
        sw $t1, 204($t0) # initialize an unshuffled deck. 11 = J, 12 = Q, 13 = K, 14 = A
        
        la $t0, DeckFlags # load base addr of deck flags
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
            li $v0, 42 # generate random integer
            li $a0, 0
            li $a1, 52 # between 0 and 51
            syscall
            move $t9, $a0 # store it in $t9
            
            la $t0, DeckFlags
            add $t1, $t0, $t9 # random index from deck flags stored in $t1
            lb $t2, 0($t1) # load random bit from deck flags
            bne $t2, $zero, shuffle_loop # try again if we have already used it
            li $t2, 1
            sb $t2, 0($t1) # mark index as used
            
            la $t0, BaseDeck
            mul $t2, $t9, 4
            add $t3, $t0, $t2 # store the random index of our base deck in $t3
            lw $t4, 0($t3) # store the random value from our base deck in $t4
            
            la $t0, UserDeck
            add $t3, $t0, $t7 # start at the beginning of the user deck and ascend
            sw $t4, 0($t3) # store the random value from the base deck in the user deck
            addi $t7, $t7, 4
            ble $t7, $t8, shuffle_loop


        # Print user deck
        la $a0, NewLine
        li $v0, 4
        syscall
        la $t0, UserDeck
        li $t1, 0
        li $t4, 52
        print_loop:
            mul $t2, $t1, 4
            add $t3, $t0, $t2
            lw  $a0, 0($t3)
            li  $v0, 1
            syscall
            li  $a0, 32  # ascii for space
            li  $v0, 11
            syscall
            addi $t1, $t1, 1
            blt  $t1, $t4, print_loop
               
    # Make the poker table on the bitmap             
    poker_table:
        li $t0, 512  # screen width
        li $t1, 256  # screen height
        mul $t2, $t0, $t1  # total pixels = width * height

        la $t0, BROWN
        lw $t0, 0($t0)  # $t3 = brown
        la $t1, GREEN
        lw $t1, 0($t1)  # $t4 = green

        li $t3, 0  # i = 0; i will iterate across every pixel on the map
        
        fill_brown:
            mul $t4, $t3, 4  # each pixel uses 4 bytes; offset = i * 4
            add $t5, $s7, $t4  # addr = frameBuffer + offset
            sw  $t0, 0($t5)  # store brown in $t8; holds the addr of our current pixel
            addi $t3, $t3, 1  # i += 1
            blt  $t3, $t2, fill_brown

    	# We leave a 12 pixel border as brown and color over the rest with green
    	li $t6, 500  # max x = 512 - 12
    	li $t7, 244  # max y = 256 - 12
    
    	li $s0, 12  # y = 12; y will be incremented as we move to the next row
    	increment_row_1:
            li $s1, 12  # x = 12; x needs to be incremented across each row
            mul $t8, $s0, 512  # first pixel of row = y * width

            fill_row_1:
                add $t3, $t8, $s1  # curr pixel index = (y * width) + x
                mul $t3, $t3, 4  # offset = index * 4
            	add $t4, $s7, $t3  # addr = frameBuffer + offset
            	sw  $t1, 0($t4)  # store green in $t7; holds the addr of our current pixel
            	addi $s1, $s1, 1  # x += 1
            	blt  $s1, $t6, fill_row_1

            addi $s0, $s0, 1  # y += 1
            blt  $s0, $t7, increment_row_1
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
addi $s1, $zero, 100
addi $s0, $zero, 100
# Top left corner of card: x value stored in $s1, y value stored in $s0
draw_card:

    li $t0, 66  # card width
    li $t1, 90  # card height
    add $t3, $s1, $t0  # right edge of the card
    add $t4, $s0, $t1  # bottom edge of the card
    
    la $t9, BLACK
    lw $t9, 0($t9)  # $t9 = black
    
    move $t0, $s0  # preserve original pixel value
    increment_row_2:
    	mul $t2, $t0, 512  # store first pixel of row in $t5
    	move $t1, $s1  # reset $t7 as the original x value for each row
    	fill_row_2:
    	    add $t8, $t2, $t1
    	    mul $t8, $t8, 4
    	    add $t8, $s7, $t8  # acess the addr of our pixel
    	    sw $t9, 0($t8)  # make it black
    	    addi $t1, $t1, 1  # x += 1
    	    blt $t1, $t3, fill_row_2
    	
    	addi $t0, $t0, 1  # y += 1
    	blt $t0, $t4, increment_row_2
    	
    addi $t3, $t3, -4  # set border thickness
    addi $t4, $t4, -4
    addi $s0, $s0, 4
    addi $s1, $s1, 4
    
    la $t9, WHITE
    lw $t9, 0($t9)  # $t9 = white
    
    move $t0, $s0  # preserve original pixel value
    increment_row_3:
    	mul $t2, $t0, 512  # store first pixel of row in $t5
    	move $t1, $s1  # reset $t7 as the original x value for each row
    	fill_row_3:
    	    add $t8, $t2, $t1
    	    mul $t8, $t8, 4
    	    add $t8, $s7, $t8  # acess the addr of our pixel
    	    sw $t9, 0($t8)  # make it black
    	    addi $t1, $t1, 1  # x += 1
    	    blt $t1, $t3, fill_row_3
    	
    	addi $t0, $t0, 1  # y += 1
    	blt $t0, $t4, increment_row_3
    	
    # Pick a card form the deck, remove it, draw it, increment the user / dealer bust value
    draw_card_value:
        
    	    