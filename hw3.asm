##################################
# Part 1 - String Functions
##################################

is_whitespace:
	######################
	move $t0, $a0		# char 'c'
	li $t1, 10		#newline
	li $t2, 0		#null
	li $t3, 32		#space
	
	beq $t0, $t1, iws_true
	beq $t0, $t2, iws_true
	beq $t0, $t3, iws_true
	j iws_false
	
	
	iws_true:
	li $v0, 1
	#syscall
	j iws_end
	
	iws_false:
	li $v0, 0
	#syscall
	
	iws_end:
	######################
	jr $ra

cmp_whitespace:
	######################
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	
	move $s0, $a0		# place arguments in s registers for safekeeping
	move $s1, $a1
	
	jal is_whitespace	# check if first char is whitespace
	
	beqz $v0, cmpws_false
	bne $v0, 1, cmpws_false
	move $a0, $s1		# move second arg to first position to be checked as well
	
	jal is_whitespace
	
	beqz $v0, cmpws_false
	bne $v0, 1, cmpws_false
	
	

	
	cmpws_true:
	li $v0, 1
	#syscall
	j cmpws_end
	
	cmpws_false:
	li $v0, 0
	#syscall
	
	cmpws_end:
	
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	######################
	jr $ra

strcpy:
	######################
	move $t0, $a0
	move $t1, $a1
	
	
	lbu $t2, ($t0)
	sb $t2, ($t1)
	li $t3, 1		# counter 
	
	strcopyLoop:
	beq $t3, $a2, exitstrcopyLoop
	addi $t0, $t0, 1	# next memory address to copy
	addi $t1, $t1, 1	# next memory address of destination
	addi $t3, $t3, 1	# increment counter
	lbu $t2, ($t0)
	sb $t2, ($t1)
	j strcopyLoop
	
	
	
	
	exitstrcopyLoop:
	
	
	
	######################
	jr $ra

strlen:
	######################
	
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	move $s0, $a0			# byte address
	li $s1, 0			# counter
	
	strlenLoop:
	lbu $a0, ($s0)
	jal is_whitespace
	beq $v0, 1, endstrlenLoop
	addi $s0, $s0, 1		# increment address byte
	addi $s1, $s1, 1		# increment counter
	j strlenLoop
	
	
	
	endstrlenLoop:
	
	move $v0, $s1
	#syscall
	
	
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	######################
	jr $ra

##################################
# Part 2 - vt100 MMIO Functions
##################################

set_state_color:
	######################
	
	beq $a2, 1, set_highlightstate
	
	set_defaultstate:
	beq $a3, 2, defcolor_bg
	
	defcolor_fg:
	lbu $t0, ($a0)
	srl $t0, $t0, 4			# get the lower 4 bits to attain foreground only
	sll $t0, $t0, 4
	move $t1, $a1			# byte colour in here = VT100 format
	or $t1, $t0, $t1
	#andi $t1, $t1, 0x0f		# get only foreground of colour as well 
	sb $t1, ($a0)
	
	beq $a3, 1, end_setstatecol
	
	defcolor_bg:
	lbu $t0, ($a0)
	sll $t0, $t0, 4			# get the higher 4 bits to attain background only
	srl $t0, $t0, 4
	move $t1, $a1
	or $t1, $t0, $t1
	#srl $t0, $t0, 4
	sb $t1, ($a0)
		
	
	j end_setstatecol
	
	set_highlightstate:
	addi $a0, $a0, 1		# add 1 to get to highlighted part
	
	beq $a3, 2, hicolor_bg
	
	hicolor_fg:
	lbu $t0, ($a0)
	srl $t0, $t0, 4		# get the lower 4 bits to attain foreground only
	sll $t0, $t0, 4
	move $t1, $a1			# byte colour in here = VT100 format
	or $t1, $t0, $t1
	#andi $t1, $t1, 0x0f		# get only foreground of colour as well 
	sb $t1, ($a0)
	
	beq $a3, 1, end_setstatecol
	
	hicolor_bg:
	lbu $t0, ($a0)
	sll $t0, $t0, 4
	srl $t0, $t0, 4			# get the higher 4 bits to attain background only
	move $t1, $a1
	or $t1, $t0, $t1
	#srl $t0, $t0, 4
	sb $t1, ($a0)
	
	
	end_setstatecol:
	
	
	
	######################
	jr $ra

save_char:
	######################
	lbu $t0, 2($a0)			# int cursor_x		i row
	lbu $t1, 3($a0)			# int cursor_y		j column

	li $t2, 0xffff0000		# base addr
	li $t3, 80			# num columns
	
	mul $t4, $t0, $t3		# i * num columns which is 80
	add $t4, $t4, $t1		# i * num columns + j
	sll $t4, $t4, 1			# 2*(i*num columns +j)
	add $t4, $t2, $t4		# target addr
	
	sb $a1, ($t4)
	
	######################
	jr $ra

reset:
	######################
	
	#beq $a1, 1, color_only_one
	#beqz $a1, color_only_zero
	
	
	color_only_one:
	li $t0, 0xffff0001		# counter
	move $t1, $a0
	lbu $t2, ($a0)			# keep colour
	li $t5,  0xffff0fa0
	
	color_one_loop:			# resets the colour value
	bgt $t0, $t5, colorone_fin 
	sb $t2, ($t0)
	addi $t0, $t0, 2		# increment address counter
	j color_one_loop
	
	colorone_fin:
	beqz $a1, color_only_zero
	j end_reset
	
	color_only_zero:		# resets the ascii char to null
	li $t0, 0xffff0000		# counter
	move $t1, $a0
	li $t2, 0			# keep zero
	
	color_zero_loop:
	bgt $t0, $t5, end_reset
	sb $t2, ($t0)
	addi $t0, $t0, 2		# increment address counter
	j color_zero_loop
	
	
	
	
	end_reset:
	
	######################
	jr $ra

clear_line:
	######################
	#a0 = cursor_x or i, #a1 = cursor_y or j
	li $t0, 0xffff0000		# base addr
	li $t1, 80			# num columns
	
	mul $t2, $a0, $t1		# i * num columns which is 80
	add $t2, $t2, $a1		# i * num columns + j
	sll $t2, $t2, 1			# 2*(i*num columns +j)
	add $t2, $t0, $t2		# base addr + offset = target addr
	
	li $t3, 79			# column we want to be at
	mul $t4, $a0, $t1		# i * num columns 
	add $t4, $t4, $t3		# i * num columns + 79
	sll $t4, $t4, 1			# 2*(i*num columns + 79)
	add $t4, $t2, $t4		# x,y address + offset = x,79
	
	move $t5, $a2			# color
	
	clearline_loop:
	bgt $t2, $t4, fin_clearline
	sb $zero, ($t2)
	sb $t5, 1($t2)
	addi $t2, $t2, 2
	j clearline_loop
	
	
	fin_clearline:
	
	
	######################
	jr $ra

set_cursor:
	######################
	
	# a0 = struct state addr, a1 = new byte x or i , a2 = new byte y or j, a3 = int inital
	
	li $t0, 10001000		# number to xor with to invert bold bits
	li $t1, 0xffff0000		# base addr
	li $t4, 80			# num columns
	bne $a3, 1, clear_first
	beq $a3, 1, update_cursor_spot
	
	clear_first:
	lbu $t2, 2($a0)			# current x or i
	lbu $t3, 3($a0)			# current y or j
	
	mul $t5, $t2, $t4		# i * num columns which is 80
	add $t5, $t5, $t3		# i * num columns + j
	sll $t5, $t5, 1			# 2*(i*num columns +j)
	add $t5, $t1, $t5		# base addr + offset = target addr
	
	lbu $t6, 1($t5)			# load in colour from current address
	xor $t6, $t6, $t0		# xor the colour to invert bolt bits
	
	sb $t6, 1($t5)
	
	update_cursor_spot:
	sb $a1, 2($a0)			# set new x in struct
	sb $a2, 3($a0)			# set new y in struct
	
	set_new_spot_color:
	lbu $t2, 2($a0)			# new x or i
	lbu $t3, 3($a0)			# new y or j
	li $t5, 0
	
	mul $t5, $t2, $t4		# i * num columns which is 80
	add $t5, $t5, $t3		# i * num columns + j
	sll $t5, $t5, 1			# 2*(i*num columns +j)
	add $t5, $t1, $t5		# base addr + offset = target addr
	
	li $t6, 0
	lbu $t6, 1($t5)
	xor $t6, $t6, $t0
	
	sb $t6, 1($t5)
	
	
	######################
	jr $ra

move_cursor:
	######################
	
	# h left 104
	# j down 106
	# k up 107
	# l right 108
	
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	
	move $s0, $a0		# address of struct state
	move $s1, $a1		# char direction
	
	lbu $s2, 2($s0)		# current x
	lbu $s3, 3($s0)		# current y
	
	beq $s1, 107, cursor_up
	beq $s1, 106, cursor_down
	beq $s1, 104, cursor_left
	beq $s1, 108, cursor_right
	j fin_movecursor
	
	cursor_up:
	beqz $s2, fin_movecursor
	li $t1, 1
	sub $s2, $s2, $t1
	j execute_movement
	
	
	
	cursor_down:
	beq $s2, 24, fin_movecursor
	li $t1, 1
	add $s2, $s2, $t1
	j execute_movement
	
	
	
	cursor_left:
	beqz $s3, fin_movecursor
	li $t1, 1
	sub $s3, $s3, $t1
	j execute_movement
	
	
	cursor_right:
	beq $s3, 79, fin_movecursor
	li $t1, 1
	add $s3, $s3, $t1
	j execute_movement
	
	
	
	execute_movement:
	move $a1, $s2		# updated x cord
	move $a2, $s3		# updated y cord
	li $a3, 0		# initial to 0
	
	jal set_cursor
	
	
	fin_movecursor:
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	
	######################
	jr $ra

mmio_streq:
	######################
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	
	
	move $s0, $a0			# preserve first string here
	move $s1, $a1			# preserve second string here
	
	streq_loop:
	lbu $s2, ($s0)
	lbu $s3, ($s1)
	
	beq $s2, $s3, str_match		# if chars match
	j str_diff			# if chars are different
	
	str_match:
	move $a0, $s2
	move $a1, $s3
	jal cmp_whitespace
	beq $v0, 0, mmiostr_cont	# chars are same and not whitespace
	beq $v0, 1, match_whitespace	# chars are both whitespace
	
	
	str_diff:
	move $a0, $s2
	move $a1, $s3
	jal cmp_whitespace
	beq $v0, 0, unmatch		# chars are different and not whitespace
	beq $v0, 1, match_whitespace	# chars are different but both whitespace
	
	
	mmiostr_cont:
	addi $s0, $s0, 2
	addi, $s1, $s1, 1
	j streq_loop
	
	
	
	
	
	match_whitespace:
	li $v0, 1
	j fin_streq
	
	unmatch:
	li $v0, 0
	
	fin_streq:
	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	######################
	jr $ra

##################################
# Part 3 - UI/UX Functions
##################################

handle_nl:
	######################
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	#save newline
	move $s0, $a0			# struct state addr
	li $s1, 10			# new line char
	
	move $a1, $s1
	jal save_char			# now newline has been placed
	
	#clear rest of line
	lbu $t1, 2($s0)			# x of current
	lbu $t2, 3($s0)			# y of current
	li $t0, 1
	add $t2, $t2, $t0		# increment column by 1
	
	move $a0, $t1
	move $a1, $t2
	lbu $a2, ($s0)
	jal clear_line
	
	#change cursor pos
	lbu $t0, 2($s0)			# x
	lbu $t1, 3($s0)			# y
	beq $t0, 24, already_at_last
	
	li $t2, 1
	add $t0, $t0, $t2		# increment row by 1, new x
	
	move $a0, $s0
	move $a1, $t0
	move $a2, $zero
	move $a3, $zero
	jal set_cursor
	j fin_handle_nl

	
	already_at_last:
	move $a0, $s0
	move $a1, $t0
	move $a2, $zero
	move $a3, $zero
	jal set_cursor
	

	fin_handle_nl:
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	
	######################
	jr $ra

handle_backspace:
	######################
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	lbu $s0, 2($a0)			# x
	lbu $s1, 3($a0)			# y
	move $s2, $a0			# struct state here
	
	
	addi $t0, $s1, 1		# n+1 in t0, n in s1
	li $t1, 79
	sub $t2, $t1, $t0		# 79 - n+1 = length to copy
	
	# get (x,y) address
	
	li $t5, 0xffff0000		# base addr
	li $t6, 80
	
	mul $t3, $s0, $t6		# i * num columns which is 80
	add $t3, $t3, $s1		# i * num columns + j which is 79 here
	sll $t3, $t3, 1			# 2*(i*num columns +j)
	add $t3, $t5, $t3		# base addr + offset = target addr THIS IS N
	
	addi $t7, $t3, 2		#N+1
	
	# copy the  characters
	move $a0, $t7
	move $a1, $t3
	move $a2, $t2
	jal strcpy
	
	# reset (x, 79)
	li $t0, 0xffff0000		# base addr
	li $t1, 80
	li $t2, 79
	
	mul $t3, $s0, $t1		# i * num columns which is 80
	add $t3, $t3, $t2		# i * num columns + j which is 79 here
	sll $t3, $t3, 1			# 2*(i*num columns +j)
	add $t3, $t0, $t3		# base addr + offset = target addr
	
	# we are now at (x,79), so reset it to def colour and ascii to null
	sb $zero, ($t3)
	lbu $t4, ($s2)
	sb $t4, 1($t3)
	
	
	
	
	
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	
	
	######################
	jr $ra

highlight:
	######################
	# Insert your code here
	######################
	jr $ra

highlight_all:
	######################
	# Insert your code here
	######################
	jr $ra
