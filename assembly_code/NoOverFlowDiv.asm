;
; 汇编语言程序设计 王爽
; 第十章 习题2
; 做除法时不会发生溢出的函数
; dx_ax / cx
;  商 -> dx_ax
;  余数 -> cx
;
;---------------------- start -----------------------------
;----------------------  end  -----------------------------


assume cs:code,ss:stack

stack segment
	db 128 dup(0)
stack ends

code segment
	start:
		mov dx,0ffffh
		mov ax,0ffffh
		mov cx,7

		call NoOverFlowDiv

		mov ax,4c00h
		int 21h

;---------------------- start -----------------------------
; dx_ax / cx
;  商 -> dx_ax
;  余数 -> cx
NoOverFlowDiv:
					push bx

	push ax
		mov ax,dx
		xor dx,dx
		div cx
		mov bx,ax	;存商的高16位
	pop ax
		div cx
		mov cx,dx	;余数 to cx
		mov dx,bx	;高16位 to dx

					pop bx
					ret
;----------------------  end  -----------------------------

code ends
end start