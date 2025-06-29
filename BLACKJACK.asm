.data

    .align 2  # makes sure the space is aligned on a 2^n bit; allows proper memory alignment for words
    FrameBuffer: .space 0x80000  # allocate space for bitmap
   
    RED: .word 0x00FF0000
    GREEN: .word 0x00006400
    BLACK: .word 0x00000000
    WHITE: .word 0x00FFFFFF
    BROWN: .word 0x006B3410
   
    InitialMessage1: .asciiz "Before each hand, enter your wager. \n"
    InitialMessage2: .asciiz "Press 'h' to hit, 's' to stand, 'p' to split, and 'd' to double. \n"
    InitialMessage3: .asciiz "\n"
    InitialMessage4: .asciiz "YOUR STARTING CHIP COUNT: 1000 \n"
   
    .align 2
    BaseDeck: .space 208
    .align 2
    UserDeck: .space 208
    DeckFlags: .space 52
   
.text
.globl main
main:

initialize:
    # Print Initial Messages
    li $v0, 4
    la $a0, InitialMessage1
    syscall
    la $a0, InitialMessage2
    syscall
    la $a0, InitialMessage3
    syscall
    la $a0, InitialMessage4
    syscall
    la $a0, InitialMessage3
    syscall

    shuffle_decks:
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
        
        
        addi $s7, $zero, 0
        addi $s6, $zero, 204
        shuffle_loop:
            li $v0, 42 # generate random integer
            li $a0, 0
            li $a1, 52 # between 0 and 51
            syscall
            move $t9, $a0 # store in $t9
            
            la $t0, DeckFlags
            add $t1, $t0, $t9 # random index from deck flags stored in $t1
            lb $t2, 0($t1) # load random bit from deck flags
            bne $t2, $zero, shuffle_loop # try again if we have already used it
            li $t3, 1
            sb $t3, 0($t1) # mark index as used
            
            la $t0, BaseDeck
            mul $t3, $t9, 4
            add $t4, $t0, $t3 # store the random index of our base deck in $t4
            lw $s0, 0($t4) # store the random value from our base deck in $s0
            
            la $t0, UserDeck
            add $t4, $t0, $s7 # start at the beginning of the user deck and ascend
            sw $s0, 0($t4) # store the random value from the base deck in the user deck
            addi $s7, $s7, 4
            ble $s7, $s6, shuffle_loop


            # Print user deck
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
                


    li $t0, 512  # screen width
    li $t1, 256  # screen height
    mul $t6, $t0, $t1  # total pixels = width * height
    li $t2, 12  # border thickness
    la $s7, FrameBuffer  # $s7 = base addr of frame buffer

    la $t3, BROWN
    lw $t3, 0($t3)  # $t3 = brown
    la $t4, GREEN
    lw $t4, 0($t4)  # $t4 = green

    li $t5, 0  # i = 0; i will iterate across every pixel on the map
    fill_brown:
        mul $t7, $t5, 4  # each pixel uses 4 bytes; offset = i * 4
        add $t8, $s7, $t7  # addr = frameBuffer + offset
        sw  $t3, 0($t8)  # store brown in $t8; holds the addr of our current pixel
        addi $t5, $t5, 1  # i += 1
        blt  $t5, $t6, fill_brown

    # We leave a 12 pixel border as brown and color over the rest with green
    li $s2, 500  # max x = 512 - 12
    li $s3, 244  # max y = 256 - 12
    
    li $s0, 12  # y = 12; y will be incremented as we move to the next row
    increment_row:
        li $s1, 12  # x = 12; x needs to be incremented across each row
        mul $t9, $s0, 512  # first pixel of row = y * width

        fill_row:
            add $t6, $t9, $s1  # curr pixel index = (y * width) + x
            mul $t6, $t6, 4  # offset = index * 4
            add $t7, $s7, $t6  # addr = frameBuffer + offset
            sw  $t4, 0($t7)  # store green in $t7; holds the addr of our current pixel
            addi $s1, $s1, 1  # x += 1
            blt  $s1, $s2, fill_row

        addi $s0, $s0, 1  # y += 1
        blt  $s0, $s3, increment_row
            
            
        
        