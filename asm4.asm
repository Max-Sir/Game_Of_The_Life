.model small
.stack 100h

new_score macro
	call update_game_score
	call resolve_score
	call print_score_board
endm

redy_video macro ;macros for prepare to video mode
	push cx
    push di
    push si
    push es

    push video_data ;0B800h
    pop es
    cld
endm



toper macro o1:=<>,o2:=<>;macros allows to make two operations at the same line
&o1
&o2
endm

ddelay macro d:=<>; macro for make delay, which can be inline and get other oper such as ddelay
call delay
call delay
&d
endm

;chk macro v:=<>;generator of call check buffer
;call check_press&v
;endm

case macro operation, result, param1:=<>,param2:=<>;case <cmp|test a,b> jxx <what to do if jxx><what to do when no jxx> 
local true, false, final
&operation 
&result true
jmp false
true:
&param1
jmp final
false:
&param2
jmp final
final:
endm

exit_video macro ;return prev state after working with video
	pop es
    pop si
    pop di
    pop cx
endm

add_ macro b;macros which compare enviroment of the cell and manipulates al register
	LOCAL true,e
	mov ah,'*'
	cmp byte ptr es:[di+&b],ah
	je true
	jmp e
	true:
		add al,1
	e:
endm

add_1 macro b;macros which compare enviroment of the cell and manipulates al register
	LOCAL true,e
	mov ah,'*'
	cmp byte ptr ds:[si+&b],ah
	je true
	jmp e
	true:
		add al,1
	e:
endm
		

.data
    back_copy db 11*22 dup(' ',blue,' ',blue,' ',blue,' ',blue)
	scstpos equ 94
    video_data equ 0B800h
    blinking_blue equ 10011111b
    blue equ 01110011b;01100100b;1Fh ;blue char on white background
    red equ 5Fh
    brown equ 6Fh
	scan_code_q equ 10h
    scan_code_space equ 39h
	scan_code_ESC equ 01h
	scan_code_left  equ 4Bh
	scan_code_right equ 4Dh
	scan_code_up    equ 48h
	scan_code_down  equ 50h
    score_board_size equ 5
    screen_size equ 44*22
    background db 11*22 dup(' ',blue,' ',blue,' ',blue,' ',blue);background
	cell dw 2 dup('*',blue)
	space dw 2 dup (' ',0)
    score_board db score_board_size dup('0', red)
	;game_over_background db 80*25 dup(' ', red)
    decimal_base dw 10
    game_score dw 0
	current_count dw 0
    ; add your data here!
    pkey db "press any key...$"
    ;f db 22 dup (11 dup(2 dup('*',11001110b),2 dup (' ',11110110b)))
    f db 22*44 dup  (1Fh)
    sz equ 44*22       
    start_pos equ 324
    life_msg db "LIFE$"
	flag db 00000000b
	x db 0
	y db 0
    
.code     
start:
    call init_data ;@data
    call init_video_mode;init video mode for chars on colored background 0003h 80*25
	call hide_cursor;hiding cursor
	
	rmpg:
	call fill_background;fill background
	
	call rasstanovka;call manual fullfil of the field
;call coll_checker_rewriter
	
   
	game_loop: ;inf loop waiting for ESC to exit back to the system or Q to restart the game
	mov cx,2
	
	call fill_backgroundcopy;call fill_new
	;call rasstanovka
	;call console_pause
	
	new_score
	;call update_game_score
	;call resolve_score
	;call print_score_board
	
	;call delay * 10 times
	ddelay ddelay ddelay ddelay ddelay
	
	;check for ESC pressed handler
	
	call check_press
	case < cmp dx,scan_code_ESC > je < jmp gp > <>
	case < cmp dx,scan_code_space > je < call game_pause > <> 
	
	;check if Q was in the keyboard buffer
	;ddelay ddelay ddelay
	;;call check_press_q
	;case < cmp dx,scan_code_q > je < toper < call clear_keyboard_buffer > < jmp rmpg > > <> 
	;case < cmp game_score,0000h > je < toper < call print_game_over > <toper < call console_pause > < jmp rmpg > > > <> 
	jmp game_loop
    
	
	
   
    gp:
	
    call exit_null ;terminate 4C00h
    

;rasstanovka proc
;;prepare es and ds
;redy_video
;
;mov di,164
;push ax
;mov ah,' '
;mov al,'*'
;
;;check for ' ' in the keyb buffer
;toper < call check_press_space > < case< cmp dx,0FFFFh > je < case < cmp byte ptr es:[di],al > je < toper <mov byte ptr es:[di],ah > < mov byte ptr es:[di+2],ah > > < toper< mov byte ptr es:[di],al > < mov byte ptr es:[di+2],al > > >
;;call delay
;;call delay
;call clear_keyboard_buffer
;mov ah,y;y
;mov al,x;x
;cmp dx,0FFFFh
;je r123
;jmp pax
;
;r123:
;call cnt_x
;toper < call check_press_left > < case < cmp dx,0FFFFh > je < case < cmp al,0 > je <> < toper < mov di,bx > < sub al,1 > > > <> >
;call clear_keyboard_buffer
;pop bx
;mov x,al
;cmp dx,0FFFFh
;je r124
;jmp pax
;
;r124:
;call cnt_y
;toper < call check_press_down > < case < cmp dx,0FFFFh > je < case < cmp ah,21 > je <> < toper < add ah,1 > < mov di,bx > > > <> >
;call clear_keyboard_buffer
;pop bx
;mov y,ah
;cmp dx,0FFFFh
;jne pax
;
;
;
;call cnt_y
;toper < call check_press_up > < case < cmp dx,0FFFFh > je < case < cmp ah,0 > je <> < toper < sub ah,1 > < mov di,bx > > > <> >
;call clear_keyboard_buffer
;pop bx
;mov y,ah
;cmp dx,0FFFFh
;jne pax
;
;
;call cnt_x
;toper < call check_press_right > < case < cmp dx,0FFFFh > je < case < cmp al,21 > je <> < toper < mov di,bx > < sub al,1 > > > <> >
;call clear_keyboard_buffer
;pop bx
;mov x,al
;cmp dx,0FFFFh
;jne pax
;
;
;pax:
;pop ax
;exit_video
;ret
;rasstanovka endp 

;;;;;;;;;;;;;rasstanovka proc
;;;;;;;;;;;;;;prepare es and ds
;;;;;;;;;;;;;redy_video
;;;;;;;;;;;;;push ax
;;;;;;;;;;;;;mov di,164
;;;;;;;;;;;;;jollup:
;;;;;;;;;;;;;new_score;;;
;;;;;;;;;;;;;mov ah,' '
;;;;;;;;;;;;;mov al,'*'
;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay ;07h 21h
;;;;;;;;;;;;;;check for ' ' in the keyb buffer
;;;;;;;;;;;;;toper < call check_press_space > < case< cmp dx,0FFFFh > je < case < cmp byte ptr es:[di],al > je < toper <mov byte ptr es:[di],ah > < mov byte ptr es:[di+2],ah > > < toper< mov byte ptr es:[di],al > < mov byte ptr es:[di+2],al > > <> >
;;;;;;;;;;;;;
;;;;;;;;;;;;;call clear_keyboard_buffer
;;;;;;;;;;;;;
;;;;;;;;;;;;;xor ax,ax
;;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;mov ah,y;y
;;;;;;;;;;;;;mov al,x;x
;;;;;;;;;;;;;
;;;;;;;;;;;;;leftt:
;;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;toper < call check_press_left > < case < cmp dx,0FFFFh > je < case < cmp al,0 > je <> < toper < sub al,1 > < sub di, 4> > < jmp jollup > > > <> >
;;;;;;;;;;;;;call clear_keyboard_buffer
;;;;;;;;;;;;;mov x,al
;;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;downn:
;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;toper < call check_press_down > < case < cmp dx,0FFFFh > je < case < cmp ah,21 > je <> < toper < toper < add ah,1 > < add di, 160> > < jmp jollup > > > <> >
;;;;;;;;;;;;;call clear_keyboard_buffer
;;;;;;;;;;;;;mov y,ah
;;;;;;;;;;;;;
;;;;;;;;;;;;;
;;;;;;;;;;;;;upp:
;;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;toper < call check_press_up > < case < cmp dx,0FFFFh > je < case < cmp ah,0 > je <> < toper < toper < sub ah,1 > < sub di, 160> > < jmp jollup > > > <> >
;;;;;;;;;;;;;call clear_keyboard_buffer
;;;;;;;;;;;;;mov y,ah
;;;;;;;;;;;;;
;;;;;;;;;;;;;rightt:
;;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;toper < call check_press_right > < case < cmp dx,0FFFFh > je < case < cmp al,21 > jge <> < toper < toper < add al,1 > < add di, 4> > < jmp jollup > > > <> >
;;;;;;;;;;;;;call clear_keyboard_buffer
;;;;;;;;;;;;;mov x,al
;;;;;;;;;;;;;
;;;;;;;;;;;;;ESCC:
;;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;ddelay ddelay ddelay ddelay ddelay
;;;;;;;;;;;;;toper < call check_press_ESC > < case < cmp dx,0FFFFh > je < toper < call clear_keyboard_buffer > < jmp exxit > > <> >
;;;;;;;;;;;;;
;;;;;;;;;;;;;jmp jollup
;;;;;;;;;;;;;
;;;;;;;;;;;;;exxit:
;;;;;;;;;;;;;pop ax
;;;;;;;;;;;;;exit_video
;;;;;;;;;;;;;ret
;;;;;;;;;;;;;rasstanovka endp 

coll_checker_rewriter proc
push ax
push bx
push cx
push dx
push ds
push es
push di

redy_video
mov di,0
mov ah,' '
mov cx,80
kk:
mov es:[di],ah
add di,2
loop kk
mov di,160*23
mov cx,80
kk1:
mov es:[di],ah
add di,2
loop kk1
mov di,160*24
mov cx,80
kk4:
mov es:[di],ah
add di,2
loop kk4
mov di,0
mov cx,23
kk2:
mov es:[di],ah
add di,160
loop kk2

mov di,92
mov cx,24
outer1:;?????
push cx
mov cx,72
inner1:
add di,2
mov es:[di],ah
loop inner1
sub di,68
add di,160
pop cx
loop outer1

exit_video
pop di
pop es
pop ds
pop dx
pop cx
pop bx
pop ax
ret
coll_checker_rewriter endp


rasstanovka proc
;prepare es and ds
redy_video
push ax
mov di,164
jollup:
new_score;;;
mov ah,' '
mov al,'*'
;07h 21h
;check for ' ' in the keyb buffer
call check_press
case< cmp dx,scan_code_space > je < case < cmp byte ptr es:[di],al > je < toper <mov byte ptr es:[di],ah > < mov byte ptr es:[di+2],ah > > < toper< mov byte ptr es:[di],al > < mov byte ptr es:[di+2],al > > <>

call clear_keyboard_buffer

xor ax,ax


mov ah,y;y
mov al,x;x

leftt:

case < cmp dx,scan_code_left > je < case < cmp al,1 > je <> < toper < sub al,1 > < sub di, 4> > < jmp jollup > > > <>
call clear_keyboard_buffer
mov x,al



downn:

case < cmp dx,scan_code_down > je < case < cmp ah,21 > je <> < toper < toper < add ah,1 > < add di, 160> > < jmp jollup > > > <> 
call clear_keyboard_buffer
mov y,ah


upp:

case < cmp dx,scan_code_up > je < case < cmp ah,1 > je <> < toper < toper < sub ah,1 > < sub di, 160> > < jmp jollup > > > <> 
call clear_keyboard_buffer
mov y,ah

rightt:

case < cmp dx,scan_code_right > je < case < cmp al,21 > jge <> < toper < toper < add al,1 > < add di, 4> > < jmp jollup > > > <> 
call clear_keyboard_buffer
mov x,al

ESCC:

case < cmp dx,scan_code_ESC > je < jmp exxit > <> 

jmp jollup

exxit:
pop ax
exit_video
ret
rasstanovka endp 

cnt_x proc ;bx= 164+4*x
push ax
push bx
mov al,x
mov ah,4
mul ah
mov bx,ax
add bx,164
pop ax
ret
cnt_x endp 

cnt_y proc ;bx=160*y+164
push ax
push bx
mov al,y
mov ah,160
mul ah
mov bx,ax
add bx,164 
pop ax
ret
cnt_y endp

fill_new proc
    redy_video
	
    mov cx, 22
    mov di, 164
    
    fpr:  ; lines
	;call delay
	;call delay
	;call delay
	;call delay
    push cx
	mov cx, 44
	new:;line
    
	push ax
	xor ax,ax
	mov al,0;
	add_ <-160> ;up
	add_ <160> ;down
	add_ <164> ;down right
	add_ <-164> ;up left
	add_ <156>;down left
	add_ <-156>;up right
	add_ <-4>;left
	add_ <4>;right
	cmp al,2;if 2 then life
	je go ;ost
	cmp al,3;if 3 then life
	je ost;life or new life
	jmp kill;else if not in 2..3 then kill
	ost:
	mov ah,'*'
	mov byte ptr es:[di],ah
	jmp go
	kill:
	mov ah,' '
	mov byte ptr es:[di],ah
	
	go:
	add di,2;next cell in row
	pop ax
    dec cx ;manual loop
	cmp cx,0
	je cntt
	jmp new
	cntt:
	
	;1 more manual loop 
    add di, 72
    pop cx
    dec cx
	cmp cx,0
	je continue
	jmp fpr
	continue:
    exit_video
    ret
fill_new endp  

new_algorithm proc
push ax
push bx
push cx
push dx
push ds
push es
push di

redy_video

	
push video_data
pop ds ;ds:si==0B800h

mov ax,@data
mov es,ax


mov si, 164
lea di,back_copy
cld

mov cx, 22
inn1:
push cx
mov cx,44
newl:
push ax
xor ax,ax
mov al, 0
	add_1 <-160> ;up
	add_1 <160> ;down
	add_1 <164> ;down right
	add_1 <-164> ;up left
	add_1 <156>;down left
	add_1 <-156>;up right
	add_1 <-4>;left
	add_1 <4>;right
	cmp al,2;if 2 then life
	je gol ;ost
	cmp al,3;if 3 then life
	je ostl;life or new life
	jmp killl;else if not in 2..3 then kill
	ostl:
	mov ah,'*'
	mov byte ptr es:[di],ah
	jmp gol
	killl:
	mov ah,' '
	mov byte ptr es:[di],ah
	
	gol:
	case < cmp ds:[si],ah > je < mov es:[di],ah > <>;;;;;;;;;
	add di,2;next cell in row
	add si,2
	pop ax
    dec cx ;manual loop
	cmp cx,0
	je contt
	jmp newl
contt:
    add si, 72
	;add di, 2
    pop cx
    dec cx
	cmp cx,0
	je continuee
	jmp inn1
	continuee:
exit_video

pop di
pop es
pop ds
pop dx
pop cx
pop bx
pop ax
new_algorithm endp

fill_background proc
    redy_video
    mov cx, 22
    mov di, 164; (0,0) of our field
    lea si, background;what to write to video merory directly
    fp:
    push cx
    mov cx, 44
    rep movsw;char and attribute
    add di, 72;go to next row to begin x=0
    pop cx
    loop fp
    exit_video
    ret
fill_background endp    

fill_backgroundcopy proc
	call new_algorithm
    redy_video
    mov cx, 22
    mov di, 164; (0,0) of our field
    lea si, back_copy;what to write to video merory directly
	mov si,0
    fpi:
    push cx
    mov cx, 44
    rep movsw;char and attribute
    add di, 72;go to next row to begin x=0
    pop cx
    loop fpi
    exit_video
    ret
fill_backgroundcopy endp  
    
init_data proc
    push ax
    mov ax, @data;prepare ds and es to working with Data
    mov ds, ax
    mov es, ax
    pop ax
    ret
init_data endp

init_video_mode proc
    push ax
    mov ah, 00h;set vm func
    mov al, 03h;colored text 80*25 with cls
    int 10h;call inter
    pop ax
    ret
init_video_mode endp

;console_pause proc
;    push ax
;    mov ah, 01h;func number
;    int 21h;call int
;    pop ax
;    ret
;console_pause endp

game_pause proc
	g:
	call check_press
	case < cmp dx,scan_code_space > je < jmp ex1 > < >
	case < cmp dx,scan_code_ESC > je < jmp gp > < jmp g >
	ex1:
	ret
game_pause endp

exit_null proc
    mov ah, 4Ch ;terminate
    int 21h;call intr
exit_null endp  

delay proc
    push cx
    push dx
    push ax
    
    mov cx, 0;
    mov dx, 30000;long of the delay in microsec
    mov ah, 86h;make a delay of timer
    int 15h;BIOS 15h call int
    
    pop ax
    pop dx
    pop cx
    ret
delay endp

check_press_down proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h ;check char in buffer func BIOS
    int 16h
    jz jump_not_pressed1
    xor ah,ah;read char with waiting
    int 16h
    cmp ah, scan_code_down
    jne jump_not_pressed1
    not dx
    jump_not_pressed1:
    
    pop ax
    ret
check_press_down endp


check_press proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h ;check char in buffer func BIOS
    int 16h
    jz jump_not_pressed152
    xor ah,ah;read char with waiting
    int 16h
    case < cmp ah, scan_code_down > je < mov dx,0050h > <>
	case < cmp ah, scan_code_left > je < mov dx,004Bh > <>
	case < cmp ah, scan_code_right > je < mov dx,004Dh > <>
	case < cmp ah, scan_code_up > je < mov dx,0048h > <>
	case < cmp ah, scan_code_ESC > je < mov dx,0001h > <>
	case < cmp ah, scan_code_space > je < mov dx,0039h > <>
	;case < cmp ah, scan_code_q > je < mov dx,0010h > <>
	
	cmp dx,0
    jne jump_not_pressed152
    not dx
    jump_not_pressed152:
    
    pop ax
	call clear_keyboard_buffer
    ret
check_press endp


check_press_q proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h
    int 16h
    jz jump_not_pressed10h
    xor ah,ah
    int 16h
    cmp ah, scan_code_q
    jne jump_not_pressed10h
    not dx
    jump_not_pressed10h:
    
    pop ax
    ret
check_press_q endp

check_press_ESC proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h
    int 16h
    jz jump_not_pressed10
    xor ah,ah
    int 16h
    cmp ah, scan_code_ESC
    jne jump_not_pressed10
    not dx
    jump_not_pressed10:
    
    pop ax
    ret
check_press_ESC endp

check_press_right proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h
    int 16h
    jz jump_not_pressed2
    xor ah,ah
    int 16h
    cmp ah, scan_code_right
    jne jump_not_pressed2
    not dx
    jump_not_pressed2:
    
    pop ax
    ret
check_press_right endp

update_game_score proc
push ax
push bx
push cx
push dx
push ds
push es
redy_video
mov di,164
mov cx,22
mov ax,@data
mov ds,ax
xor ax,ax
mov game_score,0

losc:
push cx
mov cx,22
	loscin:
	mov al,'*'
	cmp es:[di],al
	je fog
	jmp nog
	fog:
	xor ax,ax
	mov ax,game_score
	add ax,1
	add di,4;2
	mov game_score,ax
	jmp eee
	nog:
	add di,4;2
	eee:
	loop loscin
	add di,72
	pop cx
loop losc

exit_video
pop es
pop ds
pop dx
pop cx
pop bx
pop ax

ret
update_game_score endp

check_press_left proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h
    int 16h
    jz jump_not_pressed3
    xor ah,ah
    int 16h
    cmp ah, scan_code_left
    jne jump_not_pressed3
    not dx
    jump_not_pressed3:
    
    pop ax
    ret
check_press_left endp

check_press_up proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h
    int 16h
    jz jump_not_pressed4
    xor ah,ah
    int 16h
    cmp ah, scan_code_up
    jne jump_not_pressed4
    not dx
    jump_not_pressed4:
    
    pop ax
    ret
check_press_up endp

check_press_space proc
    push ax

    mov dx, 0               ;not pressed by default
    mov ah, 01h
    int 16h
    jz jump_not_pressed
    xor ah,ah
    int 16h
    cmp ah, scan_code_space
    jne jump_not_pressed
    not dx
    jump_not_pressed:
    
    pop ax
    ret
check_press_space endp

print_score_board proc
    push es
    push cx
    push si
    push di
    push ax

    call resolve_score
    ;mov ax, @data
	push video_data
	pop es
    ;mov es, ax
    lea si, score_board
    mov di, 98;background
    mov cx, score_board_size
    cld
    rep movsw

    pop ax
    pop di
    pop si
    pop cx
    pop es
    ret
print_score_board endp

resolve_score proc
    push cx
    push ax
    push bx
    push dx

    jump_get_score:
    xor dx, dx
    mov cx, 8
    mov ax, [game_score]
    cmp ax, 0FFFFh
    jne jump_resolve_score_loop
    mov [game_score], 5
    jmp jump_get_score
    jump_resolve_score_loop:    
    div [decimal_base]
    add dx, 48
    lea bx, score_board
    add bx, cx
    mov [bx],dl 
    cmp cx, 0
    je jump_exit_resolve_score_loop
    sub cx, 2             
    xor dx, dx
    jmp jump_resolve_score_loop
    jump_exit_resolve_score_loop:
    
    pop dx
    pop bx
    pop ax
    pop cx
    ret
resolve_score endp

hide_cursor proc
    push ax
    push bx
    push dx
    
    mov ah, 02h
    mov bh, 0
    mov dh, 25
    mov dl, 0
    int 10h
    
    pop dx
    pop bx
    pop ax
    ret
hide_cursor endp

clear_keyboard_buffer proc
	push ax
	push es
	push cx
	push di

	mov ax, 0000h
	mov es, ax
	mov cx, 16
	cld
	mov di, 41Ah
	jump_clear_buff_word:
	mov ax, 0
	stosw
	loop jump_clear_buff_word
	
	pop di
	pop cx
	pop es
	pop ax
	ret
clear_keyboard_buffer endp

;print_game_over proc
;	push cx
;	push di
;	push si
;	push es
;
;	push video_data
;	pop es
;	cld
;	mov cx, screen_size
;	mov di, 0
;	lea si, game_over_background
;	rep movsw
;
;	pop es
;	pop si
;	pop di
;	pop cx
;	ret
;print_game_over endp




end start
