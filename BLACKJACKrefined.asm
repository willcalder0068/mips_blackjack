.data


    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words (not totally adequate for bitmap)
    BitmapFrameBuffer: .space 0x80000  # allocates space for 512 x 256 bitmap; must be declared at the top of the file or it will be offset


    GREEN: .word 0x00006400  # used for poker table middle
    BROWN: .word 0x006B3410  # used for poker table edges
    WHITE: .word 0x00FFFFFF  # used for card backgrounds
    BLACK: .word 0x00000000  # used for card borders and card numbers / letters
    RED: .word 0x00FF0000  # used for card numbers / letters and losing screen
    GRAY: .word 0x00D3D3D3  # used f0r push (tie) screen
    LIME: .word 0x0000FF00  # used for winning screen
    GOLD: .word 0x00FFD700
    BLUE: .word 0x000000CD  # ^ used to denote split
    
    
    Newline: .asciiz "\n"
    
    InitialMessage1: .asciiz "Welcome.\nCards are pulled from one deck which will be periodically reset.\nStandard rules apply.\n"
    InitialMessage2: .asciiz "You may exit with your chips at any time by entering 'e'.\nIf you run out of chips, you will be kicked out.\n\n  Your chip count: 10,000\n\n"
    
    PromptWager: .asciiz "Enter your wager: "
       
    ReshuffleMessage1: .asciiz "Previous Deck >> "
    ReshuffleMessage2: .asciiz "\n(The deck has been reshuffled)\n"
    ReshuffleMessage3: .asciiz "\n  Your chip count: "
    
    EndMessage: .asciiz "Maybe Blackjack isn't your game.\n\n"
    
    
    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words
    UnshuffledDeck: .space 208  # stores space for an unshuffled deck as a 52 word array; each word is 4 bytes, so we reserve 52 * 4 bytes
    ShuffledDeck: .space 208  # stores space for the shuffled deck
    ShuffleFlags: .space 52  # stores 52 bool toggles (bytes) used when filling the shuffled deck from the unshuffled deck
    
    Bank: .word 10000  # store the users chip amount (starts at 10000)
    Wager1: .word 0  # store the users wager (if they split, stores left hand wager)
    Wager2: .word 0  # store users right hand wager if they split
    
    DeckIndex: .word 0  # tracks what card we are on; when we reach a certain amount, toggle ReshuffleBool
    ReshuffleBool: .byte 0  # 0 when we dont want to reshuffle, 1 when we do
    
.text
.globl main
main:


    initializer:
    	li $v0, 4  # print a string (syscall 4)
    	la $a0, InitialMessage1
    	syscall
    	la $a0, InitialMessage2
    	syscall
    	
        la $s7, BitmapFrameBuffer  # store the base addr of the Bitmap's frame (upper left pixel); BITMAPFRAMEBUFFER STAYS IN $s6 FOR THE WHOLE PROGRAM
    	
        # initializing an unshuffled deck with four of each card; red suit cards will be entered with an offset of 20 (black 2 is 2, red 2 is 22,..., black ten is 10, red ten is 30)
        # 11 (31) - J, 12 (32) - K, 13 (33) - Q, 14 (34) - A
        la $t0, UnshuffledDeck
        li $t1, 2  # black deck inputs
        li $t2, 22  # red deck input
        li $t3, 15  # we stop after aces (14 + 1)
        unshuffled_deck_loop:
            sw $t1, 0($t0)  # load red input into the deck
            sw $t1, 4($t0)  # ^ twice
            sw $t2, 8($t0)  # load black input into the deck
            sw $t2, 12($t0)  # ^ twice, now we have four
            addi $t0, $t0, 16  # move to the next indices; we add 16 because each word takes 4 bytes (a nmber occupies one word, we have 4 numbers)
            addi $t1, $t1, 1  # increment the black deck input
            addi $t2, $t2, 1  # increment the red input
            bne $t1, $t3, unshuffled_deck_loop  # once we have put in all of our aces (14s) we are done
         
        j shuffle_deck  # we have no previous deck to reveal; jump straight to shuffling
    
    
    print_previous_deck:  # always falls through to shuffle_deck
        li $v0, 4
        la $a0, ReshuffleMessage1
        syscall
        
        la $t0, ShuffledDeck
        li $t1, 0  # i = 0
        li $t5, 20  # check for red suits
        li $t6, 52
        deck_print_loop:
            li $v0, 1  # ready to print an int (syscall 1)
            
            mul $t2, $t1, 4
            add $t3, $t0, $t2  # addr of card i index in the ShuffledDeck
            lw $a0, 0($t3)  # card type from index i
            blt $a0, $t5, print_suit_correction_latch
                addi $a0, $a0, -20  # if the card "type" is above 20, we subtract to match the actual card value (correct for red suit offset)
            print_suit_correction_latch:
            
            face_card_number_to_letter:
                li $t4, 11
                blt $a0, $t4, not_a_face_card
                bne $a0, $t4, card_type_jack_latch
                    li $a0, 'J'
                    j card_type_ace_latch
                card_type_jack_latch:
                
                li $t4, 12
                bne $a0, $t4, card_type_queen_latch
                    li $a0, 'Q'
                    j card_type_ace_latch
                card_type_queen_latch:
            
                li $t4, 13
                bne $a0, $t4, card_type_king_latch
                    li $a0, 'K'
                    j card_type_ace_latch
                card_type_king_latch:
                
                li $t4, 14
                bne $a0, $t4, card_type_ace_latch
                    li $a0, 'A'
                card_type_ace_latch:
                
                li $v0, 11  # print a character instead of a number (syscall 11)
            
            not_a_face_card:  # face cards fall through; here to maintain $v0 = 1 by jumping the line above
            
            syscall  # print card type; $v0 contains 1 (int) unless we are printing a letter and have changed it to 11 (char)
            
            li  $a0, 32  # space in ascii
            li  $v0, 11
            syscall
            
            addi $t1, $t1, 1  # go to next card
            blt  $t1, $t6, deck_print_loop
            
        li $v0, 4
        la $a0, ReshuffleMessage2
        syscall
        la $a0, ReshuffleMessage3
        syscall
        
        li $v0, 1
        la $t7, Bank
        lw $a0, 0($t7)
        syscall  # ^ print value in bank after ReshuffleMessages
        li $v0, 4
        la $a0, Newline
        syscall
            
        la $t8, ReshuffleBool
        sw $zero, 0($t8)  # ^ reset ReshuffleBool to 0
        
        
    shuffle_deck:  # always falls through to deal_hand
        la $s6, DeckIndex  # keeps track of where we are in the deck, used to toggle a reshuffle; DECKINDEX STAYS IN $s6 FOR THE WHOLE PROGRAM
        sw $zero, DeckIndex  # set the index to 0; new deck so we are on the first card
        
        la $t1, ShuffleFlags  # keeps track of which cards have already been used to fill the shuffled deck
        li $t2, 0  # i = 0
        li $t3, 52
        flag_loop:
            sb $zero, 0($t1)  # initialize all deck flags to 0, indicating their cards havent been moved to the shuffled deck
            addi $t1, $t1, 1  # move to next byte in the flag (next byte reserved in ShuffleFlags)
            addi $t2, $t2, 1  # i += 1
            bne $t2, $t3, flag_loop
        
        li $t0, 0  # i = 1
        li $t1, 1  # we will set flag bytes to 1
        la $t2, ShuffleFlags
        la $t3, UnshuffledDeck
        la $t4, ShuffledDeck
        li $t9, 208  # 52 * 4 (words to bytes, memory reserved for a deck)
        shuffle_loop:
            li $v0, 42  # syscall to generate a random integer
            li $a0, 0
            li $a1, 52  # ^ between 0 and 51
            syscall  # stoed in $a0
            
            add $t5, $t2, $a0  # addr of a random deck flag stored in $t5
            lb $t6, 0($t5)  # load the byte
            beq $t6, $t1, shuffle_loop  # if the byte is 1, it has been used and we need to get a different random number
            sb $t1, 0($t5)  # change the deck flag to 1, as its index is currently being accessed
            
            mul $t7, $a0, 4  # bytes to words (ShuffleFlags stores butes, UnshuffledDeck stores words)
            add $t8, $t7, $t3  # access the random index in UnshuffledDeck
            lw $t5, 0($t8)  # random card from UnshuffledDeck now in $t5
            
            add $t6, $t4, $t0  # ascend through ShuffledDeck
            sw $t5, 0($t6)  # store the random value in the UnshuffledDeck within ShuffledDeck
            
            addi $t0, $t0, 4  # i += 4
            bne $t0, $t9, shuffle_loop  # if we haven't yet done 52 cards, reloop
            
            
    deal_hand: 
        li $s0, 0
        li $s1, 0
        li $s2, 512
        li $s3, 256  # entire bitmap
        la $t4, BROWN
        lw $s4, 0($t4)
        lw $s5, ($t4)
        jal fill_rectangle_bitmap  # poker table border
        # args - starting x in $s0, starting y in $s1, x width in $s2, y height in $s3, left color in $s4, right color in $s5
        
        li $s0, 12
        li $s1, 12
        li $s2, 488
        li $s3, 232  # leave a brown border of 12 on all sides
        la $t4, GREEN
        lw $s4, 0($t4)
        lw $s5, ($t4)
        jal fill_rectangle_bitmap  # poker table middle
        # args - starting x in $s0, starting y in $s1, x width in $s2, y height in $s3, left color in $s4, right color in $s5
        
        check_game_over:
            la $t0, Bank
            lw $t1, 0($t0)
            bgt $t1, $zero, prompt_wager  # if the user is not out of money, they continue
            li $v0, 4
            la $a0, EndMessage
            syscall
            li $v0, 10  # end program (syscall 10)
            syscall 
            #### expanded end screen
        
        prompt_wager:
            li $v0, 4
            la $a0, PromptWager
    	    syscall
            li $v0, 5
            syscall
            ##### make it so the program doen't terminate if they enter a non int (unless its 'e')
        
        
    
    
    
    
    
    
    
    
     
    # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
    fill_rectangle_bitmap:
        mul $t0, $s0, 4  # move original x into $t0; change it from words to bytes outside of the loop
    	mul $t1, $s1, 4  # move original y into $t1; change it from words to bytes outside of the loop
        mul $t9, $s2, 2  # cut the bytes total of x width in half (* 4 / 2; used for the split colors)
        
        li $t7, 0  # j = 0
        row_increment:
            li $t8, 0  # i = 0
            row_fill:
                mul $t2, $t1, 512  # first pixel of column = curr y * width
    	        add $t3, $t2, $t0  # starting x pixel = first pisel of column + original x
    	        add $t4, $t3, $t8  # curr pixel = starting x pixel + curr x
    	        add $t5, $t4, $s7  # current byte addr = curr pixel + BitmapFrameBuffer (pixels have already been turned into bytes; one pixel is one word)
    	        sw $s4, 0($t5)  # save our left color
    	        
    	        add $t6, $t5, $t9  # add half of the width to get to the right half of the rectangle
    	        sw $s5, 0($t6)  # save our right color
    	        
    	        addi $t8, $t8, 4  # i += 4
    	        blt $t8, $t9, row_fill  # when we reach halfway, the second color has finished
    	        
    	    addi $t1, $t1, 4  # y += 4
    	    addi $t7, $t7, 1  # j += 1  # converting $t7, $s3 to bytes would be less efficient, so we leave them as words
    	    blt $t7, $s3, row_increment  # we increase y and color the next row until we reach the y height
        
        jr $ra  # jr $ra means we will go to the line after the jal which sent us here
