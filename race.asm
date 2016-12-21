.Model Small
draw_l1 Macro x,y,width,color
    Local l1
    ; draws a line in row x from col 0 to col 319
    MOV AH, 0CH
    MOV AL, color
    MOV CX, x ;beginning column
    MOV DX, y ;beginning row
L1: INT 10h
    inc CX
    CMP CX,width
    JL L1
    EndM

draw_row Macro x
    Local l1
; draws a line in row x from col 10 to col 300
    MOV AH, 0CH
    MOV AL, 1
    MOV CX, 10
    MOV DX, x
L1: INT 10h
    INC CX
    CMP CX, 301
    JL L1
    EndM



draw_car Macro c1,c2,r1,r2,color
    local car,exit
    MOV AH, 0CH
    mov al,color
    mov dx,r1
    car:
    cmp dx,r2
    jg exit
    draw_l1 c1,dx,c2,color
    inc dx
    jmp car


    exit:

EndM

draw_col Macro y
    Local l2
; draws a line col y from row 10 to row 189
    MOV AH, 0CH
    MOV AL, 1
    MOV CX, y
    MOV DX, 10
L2: INT 10h
    INC DX
    CMP DX, 190
    JL L2
    EndM



.Stack 100h
.Data
my_car_pos db 1
first_car_col1 dw 0
first_car_col2 dw 40
second_car_col1 dw 100
second_car_col2 dw 140
third_car_col1 dw 210
third_car_col2 dw 250

game_point dw 0

game_over_text db "Game Over $"
score_text db "Score : $"
game_res_text db " Press R to restart $"

game_start_text db "Pass Da Blocks $"
play_notice db "Press S to Start $"

new_3 dw 0
new_1 dw 0
new_2 dw 0

INPUT DW ?
HNDLR1 DW ?
BUFFER DW ?


.Code











move_car proc

    mov al,my_car_pos
    cmp al,0
    je draw_at_0
    cmp al,1
    je draw_at_1
    cmp al,2
    je draw_at_2
    jmp keyboard

    draw_at_0:
    draw_car 270,310,20,40,1
    jmp keyboard

    draw_at_1:
    draw_car 270,310,80,100,1
    jmp keyboard

    draw_at_2:
    draw_car 270,310,160,180,1
    jmp keyboard

   keyboard:
   mov ah,06h
   mov dl,0ffh
   int 21h


   cmp al,72
   jne check_down
   call move_up
   jmp exit_my_car

   check_down:
   cmp al,80
   jne exit_my_car
   call move_down
   exit_my_car:
   ret

move_car endp


move_up proc
    mov al,my_car_pos

    cmp al,1
    je goto_pos_0_up
    cmp al,2
    je goto_pos_1_up
    jmp exit_up
    ;goto 0th box
    goto_pos_0_up:


    draw_car 270,310,80,100,0

    draw_car 270,310,20,40,1
    mov my_car_pos,0
    jmp exit_up

    ;goto 1st box

    goto_pos_1_up:
    ;draw_car 0,40,20,40,0
    draw_car 270,310,160,180,0
    draw_car 270,310,80,100,1
    mov my_car_pos,1
    jmp exit_up

    exit_up:
    ret

 move_up endp

 file_open proc
    MOV AX,3D00H
    LEA DX,INPUT
    INT 21H
    JC ERROR
    MOV HNDLR1,AX

    ;read
    MOV AH,3FH
    MOV BX,HNDLR1
    MOV CX,512
    LEA DX,BUFFER
    INT 21H
    JC ERROR


    LEA DI,BUFFER

    ERROR:



    MOV DL,0
    MOV AH,2
    INT 21H

 file_open endp

 move_down proc
    mov al,my_car_pos

    cmp al,0
    je goto_pos_1_down
    cmp al,1
    je goto_pos_2_down

    jmp exit_down


    ;goto 1st box
    goto_pos_1_down:
    draw_car 270,310,20,40,0
    draw_car 270,310,160,180,0

    draw_car 270,310,80,100,1
    mov my_car_pos,1
    jmp exit_down

    ;goto 2nd box

    goto_pos_2_down:
    draw_car 270,310,80,100,0

    draw_car 270,310,160,180,1
    mov my_car_pos,2
    jmp exit_down


    exit_down:
    ret

    move_down endp


;


output proc

        MOV AH,6
        XOR AL,AL
        XOR CX,CX
        MOV DX,184FH
        MOV BH,0
        INT 10H
        mov cx,375


    skipping_space:
       mov dl,' '
       int 21h
       loop skipping_space

      mov ah,9
      lea dx,game_over_text
      int 21h
      mov ah,2

      mov cx, 185
skipping_space_res:
       mov dl,' '
       int 21h
       loop skipping_space_res


      mov ah,9
      lea dx,game_res_text
      int 21h
      mov ah,2

      mov cx,225
      skipping_space2:
       mov dl,' '
       int 21h
       loop skipping_space2


      mov ah,9
      lea dx,score_text
      int 21h
      mov ah,2


    xor cx,cx
    mov ax,game_point



    push ax
    push bx
    push cx
    push dx
    or ax,ax
    jge end_if1
    push ax
    mov dl,'-'
    mov ah,2
    int 21h


    pop ax
    neg ax

    end_if1:
    xor cx,cx
    mov bx,10d

    repeat1:
    xor dx,dx
    div bx
    push dx
    inc cx
    or ax,ax
    jne repeat1

    mov ah,2

    print_loop:
    pop dx
    or dl,30h
    int 21h
    loop print_loop

    pop ax
    pop bx
    pop cx
    pop dx

    mov game_point,0

    lll:

      mov ah,0
      int 16h

      cmp al,82
      je mid
      cmp al,114
      je mid

      jmp lll





    MOV AH,0
    INT 16H


   ;text mode on

    MOV AX,3
    int 10h

    mov ah,4ch
    int 21h



    ret
    output endp

set_display_mode Proc
; sets display mode and draws boundary
    MOV AH, 0
    MOV AL, 13h; 320x200 4 color
    INT 10h
; select palette
    MOV AH, 0BH
    MOV BH, 1
    MOV BL, 0
    INT 10h
; set bgd color
    MOV BH, 0
    MOV BL, 0;
    INT 10h



    RET
set_display_mode EndP




start proc
        MOV AH,6
        XOR AL,AL
        XOR CX,CX
        MOV DX,184FH
        MOV BH,0
        INT 10H



        mov cx,95
        jmp skipping__space

      mid:

      jmp transition


      skipping__space:
       mov dl,' '
       int 21h
       loop skipping__space

      mov ah,9
      lea dx,game_start_text
      int 21h
      mov ah,2

      mov cx,584
      skipping_space_start:
       mov dl,' '
       int 21h
       loop skipping_space_start


      mov ah,9
      lea dx,play_notice
      int 21h
      mov ah,2


      DRAW_row 30
      draw_row 31
      draw_row 33

      draw_col 60
      draw_col 61
      draw_col 63




      ll:

      mov ah,0
      int 16h

      cmp al,83
      je TRANSITION
      cmp al,115
      je tRANSITION

      jmp ll




ret
    start endp





main Proc
    MOV AX, @data
    MOV DS, AX

; set graphics display mode & draw border
    CALL set_display_mode

    call start


    TRANSITION:





    CALL SET_DISPLAY_MODE
    draw_l1 0,63,319,4
    draw_l1 0,126,319,4


    draw_l1 0,0,319,1
    draw_l1 0,1,319,1

    draw_l1 0,198,319,1
    draw_l1 0,199,319,1

    ;draw_row 0
    ;draw_row 1
    ;draw_row 2

    ;draw_col 0
    ;draw_col 1
    ;draw_col 2





    Infinite_loop:



   ; mov ah,0
   ;int 16h

      ;cmp al,'p'
      ;je pause
      ;cmp al,'P'
      ;je pause

      jmp cnt

      ;pause:
         ;mov ah,0
         ;int 16h

      ;cmp al,'r'
      ;je cnt
      ;cmp al,'R'
      ;je cnt

      ;jmp pause

      cnt:
    cmp first_car_col1,299
    je set_first_car
    jmp end_set_1

    set_first_car:
    draw_car 270,319,20,40,0
    mov first_car_col1,0
    mov first_car_col2,40

    mov al,my_car_pos
    xor ah,ah
    cmp ax,0
    jne exit_one
    call output

    jmp exit_one

    end_set_1:
    ;time delay

    draw_car first_car_col1,first_car_col2,20,40,15
    xor ax,ax
    mov ax,first_car_col1
    add ax,1
    mov new_1,ax
    draw_car first_car_col1,new_1,20,40,0

    inc first_car_col1
    inc first_car_col2
    call move_car

    jmp first_car_running

    exit_one:
    ;draw_car 0,100,20,50,0
    inc game_point
    ;call showPoint


    draw_car 0,100,20,50,0

    first_car_running:


    ; second car goes here

    cmp second_car_col1,280
    je set_second_car
    jmp end_set_2

    set_second_car:
    draw_car 270,319,80,100,0
    mov second_car_col1,0
    mov second_car_col2,40

    mov al,my_car_pos
    xor ah,ah
    cmp ax,1
    jne exit_two
    call output

    jmp exit_two

    end_set_2:
    ;time delay

    draw_car second_car_col1,second_car_col2,80,100,15
    xor ax,ax
    mov ax,second_car_col1
    add ax,1
    mov new_2,ax
    draw_car second_car_col1,new_2,80,110,0

    inc second_car_col1
    inc second_car_col2
    call move_car

    jmp second_car_running

    exit_two:

    draw_car 0,100,80,110,0
    inc game_point
    ;call showPoint


    draw_car 0,100,80,110,0

    second_car_running:

    ;third car goes here

    cmp third_car_col1,280
    je set_third_car
    jmp end_set_3

    set_third_car:
    draw_car 270,319,160,180,0
    mov third_car_col1,0
    mov third_car_col2,40

    mov al,my_car_pos
    xor ah,ah
    cmp ax,2
    jne exit_three
    call output

    jmp exit_three

    end_set_3:
    ;time delay

    draw_car third_car_col1,third_car_col2,160,180,15
     xor ax,ax
     mov ax,third_car_col1
    add ax,1
    mov new_3,ax
    draw_car third_car_col1,new_3,160,180,0

    inc third_car_col1
    inc third_car_col2
    call move_car

    jmp third_car_running

    exit_three:
    draw_car 0,100,160,190,0
    inc game_point
    ;call showPoint


    third_car_running:


    jmp infinite_loop



main EndP
End main
