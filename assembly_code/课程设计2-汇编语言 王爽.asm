;
; 王爽 汇编语言 (第二版)  课程设计2 "参考"答案 (只是个参考)
; 
; 这是我在看完书后做的。
; 自己明白像此源码，别人是基本看不懂的。
; 一来是由于汇编的晦涩，二来是我水平很一般。
; 如若，有人能写出“优美”“易读”的汇编代码，那也可谓之大师了。
; 但，毕竟是自己辛苦调出来的，可供后来者参考、借鉴、评判。
; 当然，说“供后来者 评判”也是假谦虚 :)  这本来注定就是要进“代码坟墓”的代码 :(  ...
;
;
;
;
;需说明下：四个功能中前三个按要求实现。
;第四个功能，只提供了输入界面，在输入字符串后按回车就直接返回了。
;并没有去尝试修改BIOS时间。（因为我不会）
;
;

assume cs:code
data segment
	db '----',0	;存放从 boot到bootEnd的程序大小的字符串	即要写入软盘引导扇区的程序大小
data ends
code segment
	start:
		mov ax,data
		mov ds,ax

	; 将 从 boot 开始的512字节 写入软盘引导扇区(1扇区)
		mov ax,code
		mov es,ax
		mov bx,offset boot

		mov ah,3	;2:读 3:write
		mov al,1	;读/写 扇区个数
		mov ch,0	;磁道号
		mov cl,1	;扇区号 1~X
		mov dh,0	;磁头号 0~1
		mov dl,0	;驱动器号

		int 13h		;写入软盘

	;将secStart 到 secEnd 写入 2-x 扇区
		mov bx,offset secStart
		mov ah,3	;2:读 3:write
		mov al,2	;读/写 扇区个数
		mov ch,0	;磁道号
		mov cl,2	;扇区号 1~X
		mov dh,0	;磁头号 0~1
		mov dl,0	;驱动器号

		int 13h		;写入软盘




	;打印 从 secStart 到 secEnd 的大小
		mov ax,3	;si=3
		mov si,ax
		mov ax,offset secEnd - offset secStart	;计算大小
		mov bl,10
		;将大小 转换成字符串
	divide:
		div bl
		or ah,30h
		mov ds:[si],ah
		dec si
		xor ah,ah
		cmp ax,0
		jne divide

		mov ax,0	;si=0
		mov si,ax
		mov dh,10 	;行
		mov dl,3	;列
		mov cl,2	;颜色
		call printString


		mov ax,4c00h
		int 21h


; boot--bootEnd  写入引导扇区 (1扇区)
; 功能是将 软盘的其他扇区读到 0:7e00h
boot:
	;将 2,3号扇区读入内存 0:7e00h
	mov ax,0
	mov es,ax
	mov bx,7e00h

	mov ah,2	;2:读 3:write
	mov al,2	;读/写 扇区个数  暂定为2个扇区
	mov ch,0	;磁道号
	mov cl,2	;扇区号 1~X
	mov dh,0	;磁头号 0~1
	mov dl,0h	;驱动器号

	int 13h		;读到 es:bx

	;跳到0:7e00h处执行
	jmp bx
bootEnd: nop



;将被读到0:7e00h处
secStart:
		;在 0:7bffh 处建立堆栈
		; mov ax,7bffh
		; mov sp,ax
		jmp s0
	string1:
		db '1) restart PC.',0
	string2:
		db '2) start system.',0
	string3:
		db '3) show clock.',0
	string4:
		db '4) set clock.',0
	string5:
		db 'Please select the function Num.',0

	s0:	mov dh,10 	;行
		mov dl,3	;列
		mov cl,2	;颜色
		; mov ax,0
		; mov ds,ax	;数据段 段地址 :0
		mov ah,7eh	;由于第一扇区被加载到 7eh 处 So..

		mov al,offset string1 - offset secStart
		mov si,ax	;起始字符索引
		call printString

		mov dh,11 	;行
		mov al,offset string2 - offset secStart
		mov si,ax	;起始字符索引
		call printString

		mov dh,12 	;行
		mov al,offset string3 - offset secStart
		mov si,ax	;起始字符索引
		call printString

		mov dh,13 	;行
		mov al,offset string4 - offset secStart
		mov si,ax	;起始字符索引
		call printString

		mov dh,15 	;行
		mov al,offset string5 - offset secStart
		mov si,ax	;起始字符索引
		call printString


	int16:
		mov ah,0
		int 16h		; 读键盘的按键值

		cmp al,'1'
		jne testF2
			jmp function1
	testF2:
		cmp al,'2'
		jne testF3
			jmp function2
	testF3:
		cmp al,'3'
		jne testF4
			jmp function3
	testF4:
		cmp al,'4'
		jne int16
			jmp function4

function1:
	;ok
		;restart system  跳到ffff:0000
		mov ax,0ffffh
		mov bx,0
		mov ds:[0fffeh],ax
		mov ds:[0fffch],bx
		jmp dword ptr ds:[0fffch]	;跳到ffff:0000
function2:
	;ok
		;将下面的 从 bootC 到 bootCEnd 的这段程序复制到
		;内存 0:6000h 处（腾出0:7c00h处的空间）
		;然后跳过去执行

		mov ax,offset bootC - offset secStart
		add ax,7e00h
		mov si,ax	;ds:si 源地址

		mov ax,0
		mov es,ax 	;es:di 目的地址
		mov ax,6000h
		mov di,ax

		mov cx,offset bootCEnd - offset bootC ;字节数
		cld		;正向传送
		rep movsb

		jmp ax	;跳到 0:6000h 处执行 即，bootC处
;-------------------------------------------------------
				;将 C盘0道0面1扇（引导扇区） 读入内存 0:7c00h处 然后跳过去执行
				bootC:
					mov ax,0
					mov es,ax
					mov bx,7c00h

					mov ah,2	;2:读 3:write
					mov al,1	;读/写 扇区个数
					mov ch,0	;磁道号
					mov cl,1	;扇区号 1~X
					mov dh,0	;磁头号 0~1
					mov dl,80h	;驱动器号 C盘:80h

					int 13h		;读入到内存0:7c00h处

					jmp bx		;跳到0:7c00h处执行
				bootCEnd: nop
;-------------------------------------------------------

function3:
	;ok
		;;
		;;显示CMOS时间
		;;按F1键改变 时间 的显示颜色
		;;按Esc键 返回初始菜单
		;;


	; 注册新的int 9驱动 处理键盘按键中断
		mov ax,0
		mov ds,ax
		;将 old int 9  的地址保存在 0:7be9h 处
		mov ax,ds:[9*4]		;ip=4n  cs=4n+2
		mov ds:[7be9h],ax

		mov bx,ds:[9*4+2]
		mov ds:[7bebh],bx

		;;计算 新int9中断的地址
		mov ax,offset newInt9Start - offset secStart
		add ax,7e00h

		cli		;关中断
		mov ds:[9*4],ax		;设置新的中断向量 指向newInt9Start
		mov word ptr ds:[9*4+2],0
		sti		;开中断

		jmp f3goon
;;------------------------------
; 新的Int9中断处理程序
newInt9Start:
	push ax
	push bx
	push cx
	push es

	in al,60h
	pushf
	call dword ptr ds:[7be9h]	;old int 9
	cmp al,3bh	;F1的扫描码为3bh
	jne	testEsc
		;改变背景颜色
		mov al,ds:[7bffh]
		inc al
		mov byte ptr ds:[7bffh],al
		jmp newInt9End
testEsc:
	cmp al,1		;esc?
	jne	newInt9End
		call ClearScreen
		;恢复int9 中断
		cli		;关中断
			mov ax,ds:[7be9h]
			mov word ptr ds:[9*4],ax
			mov ax,ds:[7bebh]
			mov word ptr ds:[9*4+2],ax
		sti		;开中断

		mov ax,7e00h
		mov bx,sp
		mov ss:[bx+4*2],ax
newInt9End:
	pop es
	pop cx
	pop bx
	pop ax
	iret
;;------------------------------

	f3goon:
	;颜色 存到0:7bffh处
		mov al,2
		mov ds:[7bffh],al

	;将时间字符串写到 0:7bedh处 以'\0'结尾 再将其显示出来
		mov si,7bedh
		call ClearScreen

		mov dh,6	;行号
		mov dl,6	;列号
	reFreshTime:
		call IncomeTime
		mov cl,ds:[7bffh]	;读取颜色

		call printString
		jmp reFreshTime

;;-------------------------------------------------
function4:
		call ClearScreen
		xor ax,ax
		mov ds:[7a00h],ax  ;存放堆栈中的字符个数

		mov ax,7700h
		mov si,ax ;;ds:si指向字符栈空间		在0:7700h处建立字符堆栈

		mov dh,2	;在 3行 3列处显示输入的字符
		mov dl,2

			getstrs:
				mov ah,0
				int 16h		;读入一个字符
				cmp al,20h
				jb notChar	;比 20h小 则不是个字符

				mov ah,0
				call charstack	; push Char 字符入栈

				mov ah,2
				call charstack	;showChar 显示字符串

				jmp getstrs		;读取下一个字符
			notChar:
				cmp al,08h
				je keyBackspace	;如果是 退格键 则
				cmp al,0dh		;如果是 回车键 则
				je enterx
				jmp getstrs		; 既不是 退格键 也不是 回车键 则继续读入下一个字符

			; 按退格键 后的 动作
			keyBackspace:
				mov ah,1
				call charstack	;popChar 弹出一个字符
				mov ah,2
				call charstack	;showChar 显示字符串
				jmp getstrs		;继续读入下一个字符

			;;按回车键后的动作
			enterx:
				; mov ah,0		;push char 将'enter'压入栈中
				; call charstack
				; mov ah,2
				; call charstack	;showChar 显示字符串
				call ClearScreen
				mov ax,7e00h
				jmp ax

			;;-------------------
			;
			;
			;
			;;  ds:si指向字符栈空间
			charstack:
				; jmp short charstart
				; table dw charpush,charpop,charshow

				; top	 dw 0	;此值放在 7a00h~7a01h 处
			; charstart:
				push bx
				push di
				push es

				cmp ah,2
				ja sret		;功能号比2大直接返回
				cmp ah,0
					je charpush
				cmp ah,1
					je charpop
				cmp ah,2
					je charshow
			charpush:
				mov bx,ds:[7a00h]	;栈中字符个数
				mov [si][bx],al		;将字符写入栈中
				inc word ptr ds:[7a00h]
				jmp sret
			charpop:
				cmp word ptr ds:[7a00h],0
				je sret
				dec word ptr ds:[7a00h]
				mov bx,[7a00h]
				mov al,[si][bx]
				jmp sret

			charshow:
			; dh dl 分别为 行号 列号
					mov bx,0b800h
					mov es,bx

					mov al,160	;每行 160 个字符
					mov ah,0
					mul dh		;行号
					mov di,ax
					add di,dl	;di中 存放第一个字符的地址
					;;?????
					;;inc di

					mov bx,0
				charshows:
					cmp bx,ds:[7a00h]
					jne noempty
					mov byte ptr es:[di],' '
					jmp sret
				noempty:
					mov al,[si][bx]
					mov es:[di],al
					; mov byte ptr es:[di+2],' '
					inc bx
					add di,2
					jmp charshows


			sret:
				pop es
				pop di
				pop bx
				ret
			;;--------------------------

;---------------------- printString start -----------------------------
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
ClearScreen:
		push bx
		push es
		push cx
	;清空整个屏幕
		mov bx,0b800h
		mov es,bx
		mov bx,0
		mov cx,2000
	clearNext:
		mov byte ptr es:[bx],' '
		add bx,2
		loop clearNext
		pop cx
		pop es
		pop	bx
		ret
;---------------------- end -----------------------------
;---------------------- start -----------------------------

;;
;;从 CMOS读入时间 并将处理好的时间字符串存到 ds:si 处 以'\0'结尾
;;
IncomeTime:

			push ax
			push cx
			push si
; Year
		mov al,9
		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,0fh
		add ah,30h
		add al,30h

		mov [si],ah
		inc si
		mov [si],al
		inc si
		mov byte ptr [si],'/'
		inc si
		; OK Year

		; Month
		mov al,8

		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,0fh
		add ah,30h
		add al,30h

		mov [si],ah
		inc si
		mov [si],al
		inc si
		mov byte ptr [si],'/'
		inc si
		; OK Month

		; Day
		mov al,7

		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,0fh
		add ah,30h
		add al,30h

		mov [si],ah
		inc si
		mov [si],al
		inc si
		mov byte ptr [si],' '
		inc si
		; OK Day

		; Hour
		mov al,4

		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,0fh
		add ah,30h
		add al,30h

		mov [si],ah
		inc si
		mov [si],al
		inc si
		mov byte ptr [si],':'
		inc si
		; OK Hour


		; Minuets
		mov al,2

		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,0fh
		add ah,30h
		add al,30h

		mov [si],ah
		inc si
		mov [si],al
		inc si
		mov byte ptr [si],':'
		inc si
		; OK Minuets

		; Second
		mov al,0

		out 70h,al
		in al,71h
		mov ah,al
		mov cl,4
		shr ah,cl
		and al,0fh
		add ah,30h
		add al,30h

		mov [si],ah
		inc si
		mov [si],al
		inc si
		mov byte ptr [si],0
		;inc si
		; OK second
		pop si
		pop cx
		pop ax

		ret
;---------------------- end -----------------------------

secEnd:	nop

code ends
end start