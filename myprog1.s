.intel_syntax noprefix
.text 
_start:
mov rsi, 0x2211
add rcx,rsi
mov rax, rbx
/*mov rax,[0x100] */
mov rax,[rsi]
mov rax,[rbp-8]
mov rax,[rbx*4+0x100]
mov rax,[rdx+rbx*4+8]
/* add [rax],rbx */
mov rbx, 0x1122
mov rcx, 0x11223344
mov rdx, 0x11222344aabbccdd
mov rbx, 0x3322
mov rbx, 0x3322
mov rbx, 0x3322
mov rbx, 0x3322
mov rdx, rsi
mov rcx, 0x55223344
mov rcx, 0x66222344aabbccdd
mov rbx, 0x7722
mov rcx, 0x88223344
mov rax, 0x99222344aabbccdd
mov rax, 0x99222344aabbccdd
jmp _end
