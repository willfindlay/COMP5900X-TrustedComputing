	.file	"indirect.c"
	.text
	.globl	my_fn
	.type	my_fn, @function
my_fn:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	imull	%eax, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	my_fn, .-my_fn
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	leaq	my_fn(%rip), %rax
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	$42, %edi
	call	__x86_indirect_thunk_rax
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.section	.text.__x86_indirect_thunk_rax,"axG",@progbits,__x86_indirect_thunk_rax,comdat
	.globl	__x86_indirect_thunk_rax
	.hidden	__x86_indirect_thunk_rax
	.type	__x86_indirect_thunk_rax, @function
__x86_indirect_thunk_rax:
.LFB2:
	.cfi_startproc
	call	.LIND1
.LIND0:
	pause
	lfence
	jmp	.LIND0
.LIND1:
	.cfi_def_cfa_offset 16
	mov	%rax, (%rsp)
	ret
	.cfi_endproc
.LFE2:
	.ident	"GCC: (GNU) 10.2.0"
	.section	.note.GNU-stack,"",@progbits
