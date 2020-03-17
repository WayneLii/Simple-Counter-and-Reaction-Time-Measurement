##################################################
## Name:    Lab3_Template.s  					##
## Purpose:	Reaction Time Measurement	 		##
## Author:	Mahmoud A. Elmohr 					##
##################################################

# Start of the data section
.data			
.align 4						# To make sure we start with 4 bytes aligned address (Not important for this one)
SEED:
	.word 0x1234				# Put any non zero seed
	
# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl	main
main:
	# Put your initializations here
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)
    li s9, 0x01                 #turn on the first LED to do the relfex memter
    li s5, 20000                #to delay 2 seconds
    li t2, 100000               #to delay 5 seconds
    li s6, 1250                 #to delay 0.1 ms
	
	
	
	# Write your code here
	START:
	#	LED_OFF
    sw zero, 0(s1)      #turn off all LED first
	
	#addi sp,sp,-4
	#sw ra, 0(sp)
	jal RANDOM_NUM          # then call the random number generator
	
	loop:
	BLT a0,s5,INCREMENT         # if the random number is less than 20000, increment
	jal DELAY           # otherwise, it start delay
	
	BEQ zero,zero, ON       #after delay, it the LED will be on
	
	INCREMENT:              # increment loop
	add a0, a0 ,a0	#a0*2
	BLT a0,s5,INCREMENT
	j loop
	
	ON:
	sw s9, 0(s1)
	
	REACTION:         #Reaction time, it records the time between the time is on and you push botton
	li a5, 0
	
	while_push:
		lw s3, 0(s2)
		addi a4,zero,0xF
		#addi a0, zero, 1
		BNE a4,s3,DISPLAY_NUM
		
		li s7,0
		while_R2: 
			addi s7, s7, 1
			BNE s7, s6, while_R2
			addi a5, a5, 1
		j while_push
		
	
	
	
	
	
	
# End of main function		
		







# Subroutines			
DELAY:
	# Insert your code here to make a delay of a0 * 0.1 ms
	while_D1:
		addi a0, a0, -1
		li s7, 0
		while_D2: 
			addi s7, s7, 1
			BNE s7, s6, while_D2
		
	BNE a0,zero, while_D1
	
	jr ra



DISPLAY_NUM:
	# Insert your code here to display the 32 bits in a0 on the LEDs byte by byte (Least isgnificant byte first) with 2 seconds delay for each byte and 5 seconds for the last
	#li s11, 0xFF11220F
	#sw s11, 0(s1)
	
	display:
	add s8, zero,a5
	#1           #the first 8 bits
	sw s8,0(s1)
	srli s8, s8, 8
	jal DELAY_2S
	jal CHECK
	
	# 2           #the second 8 bits
	sw s8, 0(s1)
	srli s8, s8, 8
	jal CHECK
	jal DELAY_2S
	jal CHECK

	# 3           #the third 8 bits
	sw s8, 0(s1)
	jal CHECK
	srli s8, s8, 8
	jal DELAY_2S
	jal CHECK

	# 4           #the forth 8 bits
	sw s8, 0(s1)
	jal CHECK
	jal DELAY_5S
	jal CHECK
	
	j display
	
	jr ra
	
	
DELAY_2S:           #subroutine, delay 2 seconds
	li a6, 25000000
	
	#loop2S_a:
	li s7, 0
	loop2S_b: 
		addi s7, s7, 1
		BNE s7, a6, loop2S_b
		
	jr ra
	
DELAY_5S:           #subroutine, delay 5 seconds
	li a7, 62500000
	
	#loop5S_a:
	li s7, 0
	loop5S_b: 
		addi s7, s7, 1
		BNE s7, a7, loop5S_b
		
	jr ra
	
CHECK:           #check if you push the button while it display your reaction time
		lw s3, 0(s2)
		addi a4,zero,0xF
		BNE a4, s3, START
		
		jr ra



RANDOM_NUM:
	# This is a provided pseudorandom number generator no need to modify it, just call it using JAL (the random number is saved at a0)
	addi sp, sp, -4				# push ra to the stack
	sw ra, 0(sp)
	la gp, SEED				# load address of the random number in memory
	
	lw t0, 0(gp)				# load the seed or the last previously generated number from the data memory to t0
	li t1, 0x8000
	and t2, t0, t1				# mask bit 16 from the seed
	li t1, 0x2000
	and t3, t0, t1				# mask bit 14 from the seed
	slli t3, t3, 2				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 14 with bit 16
	li t1, 0x1000		
	and t3, t0, t1				# mask bit 13 from the seed
	slli t3, t3, 3				# allign bit 13 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 13 with bit 14 and bit 16
	andi t3, t0, 0x400				# mask bit 11 from the seed
	slli t3, t3, 5				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 11 with bit 13, bit 14 and bit 16
	srli t2, t2, 15				# shift the xoe result to the right to be the LSB
	slli t0, t0, 1				# shift the seed to the left by 1
	or t0, t0, t2				# add the XOR result to the shifted seed 
	li t1, 0xFFFF				
	and t0, t0, t1				# clean the upper 16 bits to stay 0
	sw t0, 0(gp)				# store the generated number to the data memory to be the new seed
	mv a0, t0					# copy t0 to a0 as a0 is always the return value of any function
	
	lw ra, 0(sp)				# pop ra from the stack
	addi sp, sp, 4
	jr ra


#Lab Report questions:
#1. maximum amount of time which can be stored in 8 bits is 2^8*0.1ms
#   maximum amount of time which can be stored in 16 bits is 2^16*0.1ms
#   maximum amount of time which can be stored in 24 bits is 2^24*0.1ms
#   maximum amount of time which can be stored in 32 bits is 2^32*0.1ms
#
#2. considering typical human reactime time, in terms of my experience in the lab, 16 bits size
#   would be the best for this task.
#
#
#
##
#
