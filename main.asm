###########################################################################
#  Name: Isabella
#  Assignment: MIPS #1
#  Description: Calculate the area of each trapezoid. Read from arrays of
#				size word. Store results into word-sized array. 
#				Become familiar with MIPS and RISC architecture.

#  CS 218, MIPS Assignment #1
###########################################################################
#  data segment

.data

aSides:	.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
	.word	  15,   25,   33,   44,   58,   69,   72,   86,   99,  101
	.word	 107,  121,  137,  141,  157,  167,  177,  181,  191,  199
	.word	 202,  209,  215,  219,  223,  225,  231,  242,  244,  249
	.word	 251,  253,  266,  269,  271,  272,  280,  288,  291,  299
	.word	 369,  374,  377,  379,  382,  384,  386,  388,  392,  393
	.word	1469, 2474, 3477, 4479, 5482, 5484, 6486, 7788, 8492, 1493

cSides:	.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
	.word	  32,   51,   76,   87,   90,  100,  111,  123,  132,  145
	.word	 206,  212,  222,  231,  246,  250,  254,  278,  288,  292
	.word	 332,  351,  376,  387,  390,  400,  411,  423,  432,  445
	.word	 457,  487,  499,  501,  523,  524,  525,  526,  575,  594
	.word	 634,  652,  674,  686,  697,  704,  716,  720,  736,  753
	.word	1782, 2795, 3807, 3812, 4827, 5847, 6867, 7879, 7888, 1894

heights:
	.word	   1,    2,    3,    4,    5,    6,    7,    8,    9,   10
	.word	 102,  113,  122,  139,  144,  151,  161,  178,  186,  197
	.word	 203,  215,  221,  239,  248,  259,  262,  274,  280,  291
	.word	 400,  404,  406,  407,  424,  425,  426,  429,  448,  492
	.word	 501,  513,  524,  536,  540,  556,  575,  587,  590,  596
	.word	 782,  795,  807,  812,  827,  847,  867,  879,  888,  894
	.word	1912, 2925, 3927, 4932, 5447, 5957, 6967, 7979, 7988, 1994

tAreas:	.space	280

len:	.word	70
 
taMin:	.word	0
taMid:	.word	0
taMax:	.word	0
taSum:	.word	0
taAve:	.word	0

LN_CNTR	= 8

# -----

hdr:	.ascii	"MIPS Assignment #1 \n"
	.ascii	"Program to calculate area of each trapezoid in a series "
	.ascii	"of trapezoids. \n"
	.ascii	"Also finds min, mid, max, sum, and average for the "
	.asciiz	"trapezoid areas. \n\n"

new_ln:	.asciiz	"\n"
blnks:	.asciiz	"  "

a1_st:	.asciiz	"\nTrapezoid min = "
a2_st:	.asciiz	"\nTrapezoid med = "
a3_st:	.asciiz	"\nTrapezoid max = "
a4_st:	.asciiz	"\nTrapezoid sum = "
a5_st:	.asciiz	"\nTrapezoid ave = "


###########################################################
#  text/code segment

.text
.globl main
.ent main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall				# print header

# --------------------------------------------------------
#   Initialize
la $s0, aSides			# set $s0 addr of aSides
la $s1, cSides			# set $s1 addr of cSides
la $s2, heights			# set $s2 addr of heights
lw $t0, len				# set $t1 to length
li $t7, 0
li $t5, 2				# set t5 to 2

calcLoop:
	lw $t3, ($s0)			# get aSides[n]
	lw $t4, ($s1)			# get cSides[n]
	lw $t6, ($s2)			# get heights[n]

	# tAreas[n] = (heights[n] * ((aSides[n] + cSides[n])/2)
	addu $t3, $t3, $t4		# aSides[n] + cSides[n]
	divu $t3, $t3, $t5		# .../2
	mul $t3, $t3, $t6		# ...* heights[n]

	sw $t3, tAreas($t7)			# = tAreas[n] 

	addu $s0, $s0, 4				# increment addr by word-size
	addu $s1, $s1, 4				# ...
	addu $s2, $s2, 4				# ...
	addu $t7, $t7, 4				# increment accessor to array
	subu $t0, $t0, 1				# decrement counter
bnez $t0, calcLoop

#	************* PRINT AREA LIST ***************
	lw $t0, len		# set $t0 to length
	li $t1, 0
	printLoop:
		beq $t0, $zero, endPrint		# check index

		lw $t9, tAreas($t1)				# grab area[n]

		addu $t1, $t1, 4				# increment for next accessor
		subu $t0, $t0, 1				# decrement counter

		# Prints current number
		li $v0, 1
		move $a0, $t9
		syscall	

		# Prints spaces
		li $v0, 4
		la $a0, blnks
		syscall	

		j printLoop

	endPrint:
#	**********************************************

#   Initialize
lw $t0, len		# set $t0 to length
la $s3, tAreas	# set $s3 addr of tAreas
lw $t1, ($s3)	# set min to first word in array
lw $t2, ($s3)	# set max to first word in array
li $t4, 2

dataLoop:	lw $t7, ($s3)	# get array[n]

#	** Running Sum **
	add $s4, $s4, $t7		# sum = current sum + [n]
#	***********************
#	** Median **            # length is even, therefore...
	beq $t0, 35, asetMed	# add index 1
	beq $t0, 36, asetMed    # and add index 2 together
	medDone:
#	***********************
#	**Minimum and Maximum**		
	blt $t7,  $t1, aifMin		# check if new min
	bgt $t7,  $t2, aifMax		# check if new max
	endMinMax:
#	***********************
	subu $t0, $t0, 1				# decrement counter
	addu $s3, $s3, 4				# increment address by word-size
bnez $t0, dataLoop					# loop only if index is not exceeded

# Storing values
sw $s4, taSum			# store sum
sw $t1, taMin			# store min
sw $t2, taMax			# store max

# calculate and store average
lw $t0, len				# set $t0 to length
divu $s4, $s4, $t0		# divide average by length	
sw $s4, taAve			# store average

# calculate median
div $s7, $s7, $t4		# divide added median indexes by 2
sw $s7, taMid			# store median

b next
# *********JUMPS*****************
asetMed:
	addu $s7, $s7, $t7			# keep track of sum for median
	b medDone
aifMin:
	move $t1, $t7				# set new min	
	b endMinMax
aifMax:
	move $t2, $t7				# set new max
	b endMinMax
# ********************************
next:
# --------------------------------------------------------
#  Display results.

	la	$a0, new_ln		# print a newline
	li	$v0, 4
	syscall
	la	$a0, new_ln		# print a newline
	li	$v0, 4
	syscall

#  Print min message followed by result.

	la	$a0, a1_st
	li	$v0, 4
	syscall				# print "min = "

	lw	$a0, taMin
	li	$v0, 1
	syscall				# print min

# -----
#  Print middle message followed by result.

	la	$a0, a2_st
	li	$v0, 4
	syscall				# print "med = "

	lw	$a0, taMid
	li	$v0, 1
	syscall				# print mid

# -----
#  Print max message followed by result.

	la	$a0, a3_st
	li	$v0, 4
	syscall				# print "max = "

	lw	$a0, taMax
	li	$v0, 1
	syscall				# print max

# -----
#  Print sum message followed by result.

	la	$a0, a4_st
	li	$v0, 4
	syscall				# print "sum = "

	lw	$a0, taSum
	li	$v0, 1
	syscall				# print sum

# -----
#  Print average message followed by result.

	la	$a0, a5_st
	li	$v0, 4
	syscall				# print "ave = "

	lw	$a0, taAve
	li	$v0, 1
	syscall				# print average

# -----
#  Done, terminate program.

endit:
	la	$a0, new_ln		# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall				# all done!

.end main

