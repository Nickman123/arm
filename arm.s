.data

test: .asciz "Testing\n"


start_format:
	.asciz "Input array:\n\n"
end_format:
	.asciz "Min elem: %d\nMax elem: %d\n"

enter_line_format:
	.asciz "Enter line %d\n"
scanf_format:
	.asciz "%d"
enter_M_format:
	.asciz "Enter M\n"
enter_N_format:
	.asciz "Enter N\n"
printf_format:
	.asciz "Enter array elem\n"
init_end_format:
	.asciz "Array is entered\n"
check_init_format:
	.asciz "Bytes count; %d\nBytes per string: %d\nElements count: %d\nElements per string: %d\n\n\n"
print_array_format:
	.asciz "%d "
next_line_format:
	.asciz "\n"
.equ ELEM_SIZE, 4

LINE_SIZE_BYTES:
	.word 0
ARRAY_SIZE_BYTES:
	.word 0
TOTAL_COUNT:
	.word 0
LINES_COUNT:
	.word 0
ELEMS_COUNT:
	.word 0
ARRAY_ELEM:
	.word 0
OFFSET:
	.word 0

prev_elem: .word 0

min_elem: .word 10000
max_elem: .word -10000
.text

init_array:
	push {ip, lr}
	
	ldr r0, =enter_N_format
	bl printf

	ldr r0, =scanf_format
	ldr r1, =LINES_COUNT
	bl scanf

	ldr r0, =enter_M_format
	bl printf

	ldr r0, =scanf_format
	ldr r1, =ELEMS_COUNT
	bl scanf
	
	ldr r0, =ELEM_SIZE
	ldr r1, =ELEMS_COUNT
	ldr r2, [r1]
	mul r3, r0, r2
	ldr r4, =LINE_SIZE_BYTES
	str r3, [r4]
	ldr r1, =LINES_COUNT
	ldr r2, [r1]
	mul r3, r3, r2
	ldr r4, =ARRAY_SIZE_BYTES
	str r3, [r4]
	ldr r0, =ELEMS_COUNT
	ldr r1, [r0]
	mul r3, r1, r2
	ldr r4, =TOTAL_COUNT
	str r3, [r4]

	ldr r0, =check_init_format
	ldr r6, =ARRAY_SIZE_BYTES
	ldr r1, [r6]
	ldr r6, =LINE_SIZE_BYTES
	ldr r2, [r6]
	ldr r6, =TOTAL_COUNT
	ldr r3, [r6]
	ldr r6, =ELEMS_COUNT
	ldr r4, [r6]
	push {r4}
	bl printf
	add sp, sp, #4
	
	ldr r4, =ARRAY_SIZE_BYTES
	ldr r0, [r4]
	bl malloc
	mov r7, r0
	
	push {r7}
	mov r4, #0
	mov r6, #0
enter_line:
	mov r5, #0
	ldr r3, =LINES_COUNT
	ldr r2, [r3]
	cmp r6, r2
	beq end_edit
	ldr r0, =enter_line_format
	add r1, r6, #1
	bl printf
enter_element:
	ldr r0, =printf_format
	bl printf
	
	ldr r0, =scanf_format
	ldr r1, =ARRAY_ELEM
	bl scanf

	ldr r3, =ARRAY_ELEM
	ldr r2, [r3]
	
	add r7, r7, r4
	str r2, [r7]
	
	ldr r4, =ELEM_SIZE	

	ldr r3, =ELEMS_COUNT
	ldr r2, [r3]
	add r5, r5, #1
	cmp r5, r2
	bne enter_element
	add r6, r6, #1
	b enter_line
	
end_edit:
	pop {r7}
	pop {ip, pc}


print_array:
	push {ip, lr}
	push {r7}
	mov r6, #0
	mov r5, #0
	ldr r3, =ELEMS_COUNT
	ldr r4, [r3]
rep:
	add r7, r7, r5
	ldr r5, =ELEM_SIZE
	ldr r1, [r7]
	ldr r0, =print_array_format
	bl printf
	add r6, r6,#1
	cmp r6, r4
	beq next_line
cont:
	ldr r2, =TOTAL_COUNT
	ldr r3, [r2]
	cmp r3,r6
	beq end_print
	bne rep
	b rep
next_line:
	ldr r2, =ELEMS_COUNT
	ldr r3, [r2]
	add r4, r4, r3
	ldr r0, =next_line_format
	bl printf
	b cont

end_print:
	pop {r7}	
	pop {ip, pc}

ordered_by_asc:
	push {ip, lr}
	push {r7}
	mov r0, #0
	mov r1, #0
	mov r2, #0
check_order_asc:
	add r7, r7, r2
	ldr r2, =LINE_SIZE_BYTES
	ldr r2, [r2]
	push {r0}
	mov r0, #0
	
	ldr r3, =ELEM_SIZE
	mul r3, r3, r0
	ldr r3, [r7, r3]
	ldr r4, =prev_elem
	str r3, [r4]
check_line_asc:
	add r0, r0, #1
	ldr r3, =ELEM_SIZE
	mul r3, r3, r0
	ldr r3, [r7, r3]
	ldr r4, =prev_elem
	ldr r4, [r4]
	cmp r3, r4
	bgt mark_asc
end_check_asc:
	pop {r0}
	add r0, r0, #1
	ldr r5, =LINES_COUNT
	ldr r5, [r5]
	cmp r0, r5
	bne check_order_asc
	pop {r7}
	pop {ip, pc}

mark_asc:
	ldr r4, =prev_elem
	str r3, [r4]
	mov r4, r0
	add r4, r4, #1
	ldr r5, =ELEMS_COUNT
	ldr r5, [r5]
	cmp r4, r5
	bne check_line_asc
	ldr r4, =ELEMS_COUNT
	ldr r4, [r4]
	sub r4, r4, #1
	ldr r5, =ELEM_SIZE
	mul r4, r4, r5
	ldr r5, [r7, r4]
	ldr r4, =max_elem
	ldr r4, [r4]
	cmp r5, r4
	bgt update_max_asc
ret_asc_1:
	ldr r5, [r7]
	ldr r4, =min_elem
	ldr r4, [r4]
	cmp r5, r4
	blt update_min_asc
ret_asc_2:
	b end_check_asc

update_max_asc:
	ldr r4, =max_elem
	str r5, [r4]
	b ret_asc_1

update_min_asc:
	ldr r4, =min_elem
	str r5, [r4]
	b ret_asc_2

ordered_by_desc:
	push {ip, lr}
	push {r7}
	mov r0, #0
	mov r1, #0
	mov r2, #0
check_order_desc:
	add r7, r7, r2
	ldr r2, =LINE_SIZE_BYTES
	ldr r2, [r2]
	push {r0}
	mov r0, #0
	
	ldr r3, =ELEM_SIZE
	mul r3, r3, r0
	ldr r3, [r7, r3]
	ldr r4, =prev_elem
	str r3, [r4]
check_line_desc:
	add r0, r0, #1
	ldr r3, =ELEM_SIZE
	mul r3, r3, r0
	ldr r3, [r7, r3]
	ldr r4, =prev_elem
	ldr r4, [r4]
	cmp r3, r4
	blt mark_desc
end_check_desc:
	pop {r0}
	add r0, r0, #1
	ldr r5, =LINES_COUNT
	ldr r5, [r5]
	cmp r0, r5
	bne check_order_desc
	pop {r7}
	pop {ip, pc}

mark_desc:
	ldr r4, =prev_elem
	str r3, [r4]
	mov r4, r0
	add r4, r4, #1
	ldr r5, =ELEMS_COUNT
	ldr r5, [r5]
	cmp r4, r5
	bne check_line_desc
	ldr r4, =ELEMS_COUNT
	ldr r4, [r4]
	sub r4, r4, #1
	ldr r5, =ELEM_SIZE
	mul r4, r4, r5
	ldr r5, [r7, r4]
	ldr r4, =min_elem
	ldr r4, [r4]
	cmp r5, r4
	blt update_min_desc
ret_desc_1:
	ldr r5, [r7]
	ldr r4, =max_elem
	ldr r4, [r4]
	cmp r5, r4
	bgt update_max_desc
ret_desc_2:	
	b end_check_desc

update_max_desc:
	ldr r4, =max_elem
	str r5, [r4]
	b ret_desc_2

update_min_desc:
	ldr r4, =min_elem
	str r5, [r4]
	b ret_desc_1

.global main
main:
	push {ip, lr}
	bl init_array

	ldr r0, =start_format
	bl printf
	bl print_array

	bl ordered_by_asc
	bl ordered_by_desc

	ldr r0, =end_format
	ldr r1, =min_elem
	ldr r1, [r1]
	ldr r2, =max_elem
	ldr r2, [r2]
	bl printf	
	pop {ip, pc}


