;Vxp:------
; xp:------
; 汇编语言程序设计 王爽
; 第十章 课程设计1
;
;
;---------------------- start -----------------------------
;----------------------  end  -----------------------------

assume cs:code,ss:stack

set0 segment
	db 1760 dup(20h)	; 80x22 个空格符
	db 0				;'\0'
set0 ends

stack segment
	db 128 dup(0)
stack ends

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983','1984','1985','1986','1987','1988','1989'
	db '1990','1991','1992','1993','1994','1995'

	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000

	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
	dw 11542,14430,15257,17800
data ends

outputBuffer segment
	db 32 dup(0)
outputBuffer ends

code segment

	start:
		;clear the terminal
		mov ax,set0
		mov ds,ax
		xor si,si

		mov dh,0	;行号
		mov cl,2	;颜色
		mov dl,0	;列号

		call printString


		;输出年份
		mov ax,data
		mov ds,ax
		mov ax,outputBuffer
		mov es,ax

		xor si,si
		xor di,di

		mov al,20h
		mov es:[0],al	;output 2 spaces
		mov es:[1],al

	outputYear:
		mov cx,4
	moveYearString:
		mov bx,cx
		add bx,0ffffh	;bl=cl-1
		mov al,ds:[di+bx]
		mov es:[bx+2],al
		loop moveYearString

		xor ax,ax		;append '\0'
		mov es:[6],al

		push ds
			mov ax,es
			mov ds,ax

			mov ax,di
			mov bl,4
			div bl
			inc al
			inc al		;show data from the terminal's 2th line

			mov dh,al	;行号
			mov cl,2	;颜色
			mov dl,0	;列号

			call printString
		pop ds

		add di,4
		mov cx,84
		xor cx,di
		jcxz outputYearOK
		jmp outputYear	;next year
	outputYearOK:
		;输出年份结束


		;输出收入
		mov al,20h
		mov es:[0],al	;output 6 spaces
		mov es:[1],al
		mov es:[2],al
		mov es:[3],al
		mov es:[4],al
		mov es:[5],al
	outputIncome:
		mov ax,[di]		; 低16位
		mov dx,[di+2]	; 高16位

		push ds
			mov bx,es
			mov ds,bx
			mov si,6
			call Int32ToString

			mov ax,di	;计算行号
			add ax,0ffach	;ax=ax-84
			mov bl,4
			div bl
			inc al		;
			inc al		;show data from the terminal's 2th line

			mov dh,al	;行号
			mov cl,2	;颜色
			mov dl,6	;列号

			xor si,si
			call printString
		pop ds

		add di,4
		mov cx,168
		xor cx,di
		jcxz outputIncomeOK
		jmp outputIncome	;next income
	outputIncomeOK:
		;输出收入结束


		;输出员工数
		mov al,20h
		mov es:[0],al	;output 10 spaces
		mov es:[1],al
		mov es:[2],al
		mov es:[3],al
		mov es:[4],al
		mov es:[5],al
		mov es:[6],al
	outputWorkerNum:
		mov ax,[di]		; 低16位
		xor dx,dx		; 高16位=0

		push ds
			mov bx,es
			mov ds,bx
			mov si,7
			call Int32ToString

			mov ax,di	;计算行号
			add ax,0ff58h	;ax=ax-168
			mov bl,2
			div bl
			inc al		;
			inc al		;show data from the terminal's 2th line

			mov dh,al	;行号
			mov cl,2	;颜色
			mov dl,22	;列号

			xor si,si
			call printString
		pop ds

		add di,2
		mov cx,210
		xor cx,di
		jcxz outputWorkerNumOK
		jmp outputWorkerNum	;next income
	outputWorkerNumOK:
		;输出收入结束

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