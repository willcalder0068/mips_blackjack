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
    CurrError: .asciiz "ERROR"
    
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
    
    ReshuffleBool: .byte 0  # 0 when we dont want to reshuffle, 1 when we do
    
    DrawCard: .word 0 # indicates if and what card we are drawing when calling to fill a rectangle
    Card1Type: .word 0
    CardType: .word 0  # ^ stores the type of card we have; used for detecting pairs
    CardDrawer: .word 0  # indicates who is drawing the card (0 for dealer, 1 for user (or right on split), 2 for user left on split)
    
    UserBustAddr1: .word 0 # indicate the value of the users hand (over 21 is a bust)
    UserBustAddr2: .word 0  # takes the left hand if we split
    DealerBustAddr: .word 0  # indicates the value of the dealers hand
    UserAceCountAddr1: .word 0
    UserAceCountAddr2: .word 0
    DealerAceCountAddr: .word 0  # ^ used for tracking high / low aces
    
    
.text
.globl main
main:

    j initializer
    
    delay:
        li $t8, 1000000
        delay_loop:  # give pause
            addi $t8, $t8, -1
            bne $zero, $t8, delay_loop
        jr $ra

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
    
        li $s6, 0  # keeps track of where we are in the deck, used to toggle a reshuffle; DECKINDEX STAYS IN $s6 FOR THE WHOLE PROGRAM
        
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
            li $v0, 42  # generate a random integer (syscall 42)
            li $a0, 0
            li $a1, 52  # ^ between 0 and 51
            syscall  # stored in $a0
            
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
        la $t0, Wager1
        sw $zero, 0($t0)
        la $t0, Wager2
        sw $zero, 0($t0)
        la $t0, Card1Type
        sw $zero, 0($t0)
        la $t0, CardType
        sw $zero, 0($t0)
        la $t0, CardType
        sw $zero, 0($t0)
        la $t0, UserBustAddr1
        sw $zero, 0($t0)
        la $t0, UserBustAddr2
        sw $zero, 0($t0)
        la $t0, DealerBustAddr
        sw $zero, 0($t0)
        la $t0, UserAceCount1
        sw $zero, 0($t0)
        la $t0, UserAceCount2
        sw $zero, 0($t0)
        la $t0, DealerAceCount
        sw $zero, 0($t0)
        
        
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

            #### 'e' for exit, nothing else
            
        give_first_cards:
            la $t6, CardDrawer
            li $t7, 1  # indicate that the user is drawing cards (used for bust value and ace count)
            sw $t7, 0($t6)
            
            li $s0, 189
            li $s1, 146
            li $s2, 66
            li $s3, 90
            la $t4, BLACK
            lw $s4, 0($t4)
            lw $s5, 0($t4)
            jal draw_card  # first user card
            # args - starting x in $s0, starting y in $s1, x width in $s2, y height in $s3, left color in $s4, right color in $s5
            
            la $t0, CardType
            la $t1, Card1Type
            lw $t2, 0($t0)
            sw $t2, 0($t1)  # store the CardType of the users first card in Card1Type (used for detecting splits)
            
            li $s0, 257
            li $s1, 146
            li $s2, 66
            li $s3, 90
            la $t4, BLACK
            lw $s4, 0($t4)
            lw $s5, 0($t4)
            jal draw_card  # second user card
            # args - starting x in $s0, starting y in $s1, x width in $s2, y height in $s3, left color in $s4, right color in $s5
            
            la $t6, CardDrawer
            sw $zero, 0($t6)  # indicate that the dealer is now drawing
            
            li $s0, 257
            li $s1, 20
            li $s2, 66
            li $s3, 90
            la $t4, BLACK
            lw $s4, 0($t4)
            lw $s5, 0($t4)
            jal draw_card  # first dealer card
            # args - starting x in $s0, starting y in $s1, x width in $s2, y height in $s3, left color in $s4, right color in $s5
            
            la $t0, ReshuffleBool
            lw $t1, 0($t0)
            bne $zero, $t1, print_previous_deck
                j deal_hand
        
        
        
        
    
    draw_card:  # always falls through to fill rectangle
        addi $sp, $sp, -4  # make room on the stack
        sw $ra, 0($sp)  # store current return address on the top of the stack; we will be jumping a lot so it may be overridden in $ra
        
        jal delay  # give pause between each card being drawn
        
        la $t0, DrawCard
    	li $t1, 1  # flip DrawCard to one, allows later fall through action
    	sw $t1, 0($t0)
    	
    	li $a0, 34
        blt $s6, $a0, fill_rectangle_bitmap
            la $t8, ReshuffleBool
            li $t9, 1  # if we have gone past 34 cards, trigger a reshuffle for the next hand
            sw $t9, 0($t8)  # then fall through
        
    
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
    	  
    	      
    	la $t0, DrawCard
    	lw $t1, 0($t0)
    	bne $t1, $zero, draw_card_fall_through  # if DrawCard does not contain a zero, then we must draw a card
            jr $ra  # jr $ra means we will go to the line after the jal which sent us here
            # this register can be used by the caller of fill_rectangle_bitmap, or it can be hijacked by draw_card and used to draw the card numbers / letters
        
        # if we are drawing a card, we will first pick it from the deck, then continuously draw rectangles on the bitmap until the card is done
        draw_card_fall_through:
            sw $zero, 0($t0)  # stop from drawing successive cards; this will have to be toggled on in draw_card
            
            addi $s0, $s0, 4
            addi $s1, $s1, 4
            addi $s2, $s2, -8
            addi $s3, $s3, -8
            la $t4, WHITE
            lw $s4, 0($t4)
            lw $s5, 0($t4)  # ^ move 4 pixels in to create the black borders (by filling in the white background of the card)
            jal fill_rectangle_bitmap  # now the jr $ra will return us here as we have hijacked $ra and untoggled DrawCard
            
            addi $s0, $s0, 8
            addi $s1, $s1, 8
            addi $s2, $s2, -16
            addi $s3, $s3, -16  # & move card number / letter away from the corner
            
            
            la $t1, ShuffledDeck
            mul $t2, $s6, 4
            add $t3, $t1, $t2  # current index of our shuffled deck
            lw $t9, 0($t3)  # current card value of our shuffled deck index
            addi $t6, $t9, 0  # store a copy of $t9 in $t6
            
            addi $s6, $s6, 1  # increment our deck index, as we will be moving to the next card
            
            
            li $t2, 20
            la $t5, BLACK  # default the color to black
            blt $t9, $t2, pull_suit_correction_latch
                la $t5, RED
                addi $t6, $t9, -20  # ^ if our card is red, overwrite the black addr and correct for the value in separate register $t6
            pull_suit_correction_latch:
            lw $s4, 0($t5)
            lw $s5, 0($t5)  # save our color to both halves (RED / BLACK)
            
            la $t0, CardType
            sw $t6, ($t0)  # save card type in memory addr
            
            
            la $t7, CardDrawer  # 0 when the dealer is drawing, 1 when the user is drawing, 2 when the users left split hand is drawing
            lw $t8, 0($t7)
            li $t0, 0
            bne $t8, $t0, dealer_draw_latch
                la $t7, DealerBustAddr
                lw $t1, 0($t7)
                add $t2, $t1, $t6  # add the curr bust value and the CardType (we will correct from type to value later)
                sw $t2, 0($t7)  # save it in the memory addr
                j user_draw_latch2
            dealer_draw_latch:
            li $t0, 1
            bne $t8, $t0, user_draw_latch1
                la $t7, UserBustAddr1
                lw $t1, 0($t7)
                add $t2, $t1, $t6
                sw $t2, 0($t7)
                j user_draw_latch2
            user_draw_latch1:
            li $t0, 2
            beq $t8, $t0, user_draw_latch2
                la $t7, UserBustAddr2
                lw $t1, 0($t7)
                add $t2, $t1, $t6
                sw $t2, 0($t7)
            user_draw_latch2:
            
            li $t4, 2
            beq $t6, $t4, draw_type_two
            li $t4, 3
            beq $t6, $t4, draw_type_three
            li $t4, 4
            beq $t6, $t4, draw_type_four
            li $t4, 5
            beq $t6, $t4, draw_type_five
            li $t4, 6
            beq $t6, $t4, draw_type_six
            li $t4, 7
            beq $t6, $t4, draw_type_seven
            li $t4, 8
            beq $t6, $t4, draw_type_eight
            li $t4, 9
            beq $t6, $t4, draw_type_nine
            li $t4, 10
            beq $t6, $t4, draw_type_ten
            li $t4, 11
            beq $t6, $t4, draw_type_eleven
            li $t4, 12
            beq $t6, $t4, draw_type_twelve
            li $t4, 13
            beq $t6, $t4, draw_type_thirteen
            li $t4, 14
            beq $t6, $t4, draw_type_fourteen
            li $v0, 10
            syscall 
            
            draw_type_two:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                li $s2, 14
                li $s3, 40
                addi $s1, $s1, -26
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                addi $s1, $s1, -26
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_three:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                addi $s1, $s1, -52
                li $s2, 14
                li $s3, 66
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_four:
                addi $s1, $s1, 26
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, -26
                li $s2, 14
                li $s3, 40
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                li $s3, 66
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_five:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                li $s2, 14
                li $s3, 40
                addi $s1, $s1, -52
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_six:
                addi $s1, $s1, 26
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, -52
                li $s2, 14
                li $s3, 66
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                addi $s1, $s1, 26
                li $s3, 40
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_seven:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                li $s2, 14
                li $s3, 66
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_eight:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, -52
                li $s2, 14
                li $s3, 66
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_nine:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, -26
                li $s2, 14
                li $s3, 40
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                li $s3, 66
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_ten:
                li $s2, 10
                li $s3, 68
                jal fill_rectangle_bitmap
                addi $s0, $s0, 16
                jal fill_rectangle_bitmap
                addi $s0, $s0, 16
                jal fill_rectangle_bitmap
                addi $s0, $s0, -6
                li $s2, 6
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 54
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j card_drawn  # full return from draw_card
                
            draw_type_eleven:
                addi $s1, $s1, 52
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                addi $s1, $s1, -52
                li $s2, 14
                li $s3, 66
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j face_card_bust_adjustment  # corrects from CardType to card value in the bust addr; falls through to card_drawn
                
            draw_type_twelve:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 54
                jal fill_rectangle_bitmap
                addi $s1, $s1, -54
                li $s2, 14
                li $s3, 68
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                jal fill_rectangle_bitmap
                add $s0, $s0, -11
                addi $s1, $s1, 48
                li $s2, 8
                li $s3, 24
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j face_card_bust_adjustment  # corrects from CardType to card value in the bust addr; falls through to card_drawn
                
            draw_type_thirteen:
                li $s2, 12
                li $s3, 66
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s0, $s0, 22
                li $s2, 10
                li $s3, 40
                jal fill_rectangle_bitmap
                addi $s0, $s0, 10
                addi $s1, $s1, -26
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j face_card_bust_adjustment  # corrects from CardType to card value in the bust addr; falls through to card_drawn
                
            draw_type_fourteen:
                li $s2, 42
                li $s3, 14
                jal fill_rectangle_bitmap
                addi $s1, $s1, 26
                jal fill_rectangle_bitmap
                addi $s1, $s1, -26
                li $s2, 14
                li $s3, 66
                jal fill_rectangle_bitmap
                addi $s0, $s0, 28
                jal fill_rectangle_bitmap
                # args - starting x in $s0, starting y in $s1, x width in $s2, y width in $s3, left color in $s4, right color in $s5
                j face_card_bust_adjustment  # corrects from CardType to card value in the bust addr; falls through to card_drawn
                
            face_card_bust_adjustment:
                la $t0, CardDrawer
                lw $t1, 0($t0)
                # save ace count if 14 change the bust values to reflect true card values
                
            card_drawn:
                lw $ra, 0($sp)  # restore original $ra stored at the top of draw_card
                addi $sp, $sp, 4  # pop it from the stack
                jr $ra  # return