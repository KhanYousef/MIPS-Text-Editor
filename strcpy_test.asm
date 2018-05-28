.include "hw3.asm"
.macro printf(%str)
.data
.text
li $v0, 4
la $a0, %str
syscall
.end_macro
.text
.data

dest: .asciiz "test"
src: .asciiz "here"



.globl main
.text
main:

la $a0, src
la $a1, dest
li $a2, 4
jal strcpy

printf(dest)




