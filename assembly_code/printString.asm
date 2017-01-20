;
; 汇编语言程序设计 王爽
; 第十章 习题1
;
; 写了个子函数 printString 将一个以0结尾的字符串输出到屏幕的指定位置
；具体参数见下面的注释。
;
;---------------------- start -----------------------------
;----------------------  end  -----------------------------


assume cs:code
data segment
	db '+++++123456789012345678901234567901234567890123456789012345678901234567890+++++',0
data ends

stack segment
	db 128 dup(0)
stack ends

code segment

	start:
		mov ax,stack
		mov ss,ax
		mov dh,10 	;行
		mov dl,3	;列
		mov cl,2	;颜色
		mov ax,data
		mov ds,ax	;数据段 段地址
		mov si,0	;起始字符索引

		call printString

		mov ax,4c00h
		int 21h


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

code ends
end start