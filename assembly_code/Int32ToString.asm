;
; 汇编语言程序设计 王爽
; 第十章 习题3
; int32 to string
;
; dx_ax 中存int
; 转换后的字符串存在 ds:si 以0结尾
;---------------------- start -----------------------------
;----------------------  end  -----------------------------

assume cs:code,ss:stack

stack segment
	db 128 dup(0)
stack ends

data segment
	db 128 dup(0)
data ends

code segment

	start:
		mov ax,data
		mov ds,ax
		mov si,0

		mov dx,0ffffh
		mov ax,0ffffh
		call Int32ToString

		mov dh,9
		mov dl,2
		mov cl,2
		call printString

		mov ax,4c00h
		int 21h

;---------------------- start -----------------------------
; dx_ax 中存int
; 转换后的字符串存在 ds:si 以0结尾
Int32ToString:
				push ax
				push bx
				push cx
				push dx
				push si

		xor bx,bx	;记录十进制字符的个数

	division:
		mov cx,10	;除数置 10

		; dx_ax / cx
		;  商 -> dx_ax
		;  余数 -> cx
		call NoOverFlowDiv

		push cx		;余数入栈
		inc bx		;个数加1
		mov cx,ax
		or cx,dx

		jcxz computeEnd
		jmp division

	computeEnd:
		;将栈中内容 逐个弹出 转为ascii 并写入ds:si
		mov cx,bx
	storeString:
		pop bx
		or bl,30h	;数字->ascii字符
		mov ds:[si],bl
		inc si
		loop storeString
		jmp append0

	append0:	;附上'\0'
		mov bh,0
		mov ds:[si],bh

				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				ret
;----------------------  end  -----------------------------



;---------------------- start -----------------------------
;	将 ds:si 处以'\0'结尾的字符串
;	以 cl 中表示的颜色
;	打印在屏幕的 dh行(0~24),dl列(0~79)
printString:
					push ax
					push es
					push di
					push dx
					push cx
					push si

		mov ax,0b800h
		mov es,ax	;指向显示缓冲区的首地址

		;di = 80*2*dh + 2*dl
		mov di,0	;置0
		mov al,160
		mul dh
		add di,ax
		mov al,2
		mul dl
		add di,ax

		mov ah,cl	;取cl中的颜色值 --> ah
		xor cx,cx	;置0
		;逐个移动字符直到'\0'
	movChar:
		mov cl,[si]
		jcxz movCharOK
		mov al,cl
		mov es:[di],ax
		inc di
		inc di
		inc si
		jmp short movChar

	movCharOK:
					pop si
					pop cx
					pop dx
					pop di
					pop es
					pop ax
					ret
;---------------------- end -----------------------------


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