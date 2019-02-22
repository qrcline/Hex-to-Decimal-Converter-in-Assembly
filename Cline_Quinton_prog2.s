# 3760
# Program 2 Test Harness

#-------------------------------------------------------------------------
# PLACE YOUR FUNCTION HERE
#-------------------------------------------------------------------------

.text
#stored value registers
	#$t2 temp register used for subtraction and comparisons
	#$t3 temp register used for destination of subtraction
#output registers
	#$v1 set to 1 if there is an Overflow
	#ra the final number

convert_hex_str:
#load the string from $a0 to temp register
#shift left tell tell you get a non-zero


lb		$t1 , 0($a0)  #loads in the byte to t1
beq		$t1,$0,convert_hex_str #branch to beginning if leading zero


#0-9 integer
li		$t2,48
sub		$t3,$t1,$t2  #subtract 48
li		$t2,9  #loads 9
bgt		$t0,$t2,uppercase	
j		addto	

uppercase:
#uppercase
li		 $t2,7
sub		  $t3,$t1,$t2  #subtract 7
li		$t2,15  #loads 15
bgt		$t0,$t2,lowercase	
j		addto	


lowercase:
#lowercase
li		 $t2,32
sub		  $t3,$t1,$t2  #subtract 32
j		addto	

addto:
##



error:
	addi $v0,$0,1



#-------------------------------------------------------------------------
# DO NOT MODIFY BELOW THIS COMMENT
#-------------------------------------------------------------------------

# Test harness
# Ask user to enter the hex string.
# Print the resulting integer, or report overflow.
# An empty string will terminate the program.

.data

# User prompt strings
prompt_str:     .asciiz "Enter your hexadecimal string.  Just hit enter to quit: "
your_str:       .asciiz "Your string: "
linefeed:       .asciiz "\n"
dbl_linefeed:   .asciiz "\n\n"
value_str:      .asciiz "Value : "
overflow_str:   .asciiz "Overflow detected!\n\n"
all_done_str:   .asciiz "\nGood luck with your program!.  Goodbye.\n"
hex_str_buf:  # Space for input string from user.
.space 256

.text
.globl main
.globl convert_hex_str

main: 

get_input_string:

# display prompt
    li $v0,4            # code for print_string
    la $a0,prompt_str   # point $a0 to prompt string
    syscall             # print the string


# get the input string from the user
    li $v0,8            # code for read_string
    la $a0,hex_str_buf  # $a0 - input buffer address
    li $a1,256          # $a1 - Input buffer length
    
    syscall                # Get the string
                        # The string is NUL terminated.
    la $s0,hex_str_buf  # Save string in $s0
    
    # SPIM puts a closing NEW LINE (ASCII 0xa) on the end of the string.
    #  We need to strip that off, since that is not a legal character in our hex format.
    #  We just overwrite it with NUL (ASCII 0)

    move $s1, $s0     # $s1 char pointer
    
strip_nl:
    lbu $s2, ($s1)    # $s2 Get the current character
    beqz $s2, remove_nl
    addi $s1, $s1, 1  # Next character
    j strip_nl
    
remove_nl:
    li $s2, 10       # Expected NL = ASCII 10 (0xa)
    lbu $s3, -1($s1) # Character just before the NUL terminator
    bne $s3, $s2, check_for_exit

    li $s2, 0        # NUL Char (0)
    sb $s2, -1($s1)  # Wipe out NL

check_for_exit:
    # Check if the input string is empty.
    lbu $s2, ($s0)         # Load first byte of the string.
    beq $s2, $0, all_done  # Exit if first byte is NUL terminator
    
# print result string
# - Prompt string
    li    $v0,4            # code for print_string
    la $a0, your_str
    syscall                # print the string

# - The string
    li    $v0,4            # code for print_string
    move $a0, $s0
    syscall                # print the string

# - LF    
    li    $v0,4            # code for print_string
    la    $a0,linefeed     # point $a0 to string
    syscall                # print the string
    
# Call Hex Converter
    move $a0, $s0
    jal convert_hex_str

    move $s1, $v0         # Save value result in $s0
    move $s2, $v1         # Save error result in $s1
    
    beq $v1, $0, no_overflow

# - Overflow detected

    # Print overflow message
    li    $v0,4
    la $a0, overflow_str
    syscall                # print the string

    j get_input_string     # Repeat
    
# - Value
no_overflow:
    # Print value message.
    li    $v0,4            # code for print_string
    la $a0, value_str
    syscall                # print value prompt

    li    $v0,1            # code for print_int
    move $a0, $s1
    syscall                # print the value itself.

    li    $v0,4            
    la    $a0,dbl_linefeed
    syscall                # print the linefeed

    j get_input_string     # Repeat
    
# - Prompt string
    li    $v0,4            # code for print_string
    la $a0, error_str
    syscall                # print the string
    
# All done, thank you!
all_done:    
    li    $v0,4            # code for print_string
    la $a0, all_done_str
    syscall                # print the string
    
    li    $v0,10           # code for exit
    syscall                # exit program
