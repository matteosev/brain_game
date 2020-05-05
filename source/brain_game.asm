; game in which you will train your multiplication table knowledge
; x86_64 asm | linux syscalls

%include "module.asm"

; input
;       bound sup
;       a multiplicator
; output
;       returns in rax an integer between 0 and bound sup

%macro rand_int 2
    mov rbx, %2
    rdtsc
    mul rbx
    mov rbx, 10                 ; divisor
    %%div_loop:
        mov rdx, 0              ; clear rdx
        div rbx                 ; divide rax by rbx
        cmp rax, %1
        jg %%div_loop
%endmacro

; input
;       address to a string
;       length of string
;       a char to replace (ascii code)
%macro replace_char_by_null 3
    mov rax, 0
    mov rcx, %2
    dec rcx
    %%iter:
        mov al, byte [%1 + rcx]
        cmp al, %3
        je %%replace
        dec rcx
        cmp rcx, 0
        je %%end
        jmp %%iter
    %%replace:
        mov byte [%1 + rcx], 0
    %%end: 
        nop
%endmacro

section .data
    line db      " --------------------------------------------", 10, 0
    side db      " |                                          |", 10, 0
    title db     " |                BRAIN GAME                |", 10, 0
    menu_str db "Press 0 to exit", 10, "Press 1 to play a new game", 10, 0
    level_str db "Choose your level :", 10, "1 for noob", 10, "2 for intermediate", 10, "3 for master", 10, 0
    description db "You will have 10 seconds to answer a maximum of calculus.", 10, 0
    x db " x ", 0
    equal db " = ", 0
    end_msg db "Time's up !", 10, "score : ", 0
    on db " / ", 0
    nl db 10
    noob db " (noob)", 0
    inter db " (intermediate)", 0
    master db " (master)", 0
    duration_start db "You will have ", 0
    duration_end db " seconds to answer a maximum of calculations, don't cheat !", 10, "Ready ? (hit enter to start)", 0

section .bss
    inp resq 1
    start_time resq 1
    end_time resq 1
    op1 resq 1
    op2 resq 1
    res resq 1
    nb_attempts resq 1
    temp resq 1
    sup_bound resq 1
    score resq 1
    level_user resb 1
    duration resq 1

section .text
    global _start 

    _start:
        print line, 0
        print side, 0
        print title, 0
        print side, 0
        print line, 0

        menu:
            mov qword [score], 0
            mov qword [nb_attempts], 0
            print nl, 1
            print menu_str, 0
            input inp, 8
            cmp byte [inp], 48  ; "0"
            je end
            cmp byte [inp], 49  ; "1"
            jg menu
            print nl, 1
        level:
            print level_str, 0
            input inp, 8
            print nl, 1
            cmp byte [inp], 48  ; "0"
            je level
            cmp byte [inp], 49  ; "1"
            je l_noob
            cmp byte [inp], 50  ; "2"
            je l_intermediate
            cmp byte [inp], 51  ; "3"
            jg level
            je l_master
        l_noob:
            mov qword [sup_bound], 10
            mov byte [level_user], 1
            mov qword [duration], 10
            jmp setup
        l_intermediate:
            mov qword [sup_bound], 20
            mov byte [level_user], 2
            mov qword [duration], 20
            jmp setup
        l_master:
            mov qword [sup_bound], 50
            mov byte [level_user], 3
            mov qword [duration], 30
            jmp setup
        setup:
            print duration_start, 0
            int_to_str duration, temp
            print duration, 8
            str_to_int duration, 2
            print duration_end, 0
            input inp, 8
            mov qword [inp], 0
            print nl, 1
            mov rax, 201
            mov rdi, start_time
            syscall

            mov rcx, 0
            push rcx
        game_loop:
            pop rcx                     ; get counter
            inc rcx                     ; increment counter
            push rcx                    ; save counter
            rand_int 1000, 4            ; random multiplicator
            rand_int [sup_bound], rax   ; random int
            push rax                    ; push op1 as int
            mov [op1], rax
            int_to_str op1, temp
            print op1, 2

            print x, 0

            rand_int 1000, 7
            rand_int [sup_bound], rax
            push rax                    ; push op2 as int
            mov [op2], rax
            int_to_str op2, temp
            print op2, 2

            print equal, 0  

            pop rax                     ; pop op1
            pop rbx                     ; pop op2
            mul rbx                     ; calculate result
            mov qword [res], rax
            int_to_str res, temp     
            input inp, 8
            replace_char_by_null inp, 8, 10     ; remove new line from input
            mov rsi, res
            mov rdi, inp
            cmpsq                       ; compare input to result
            jne next                    ; if same string, increment score, else go next
            inc qword [score]
            next:
                ; verifie time's not up
                mov rax, 201
                mov rdi, end_time
                syscall
                mov rax, [end_time]
                sub rax, [start_time]
                cmp rax, qword [duration]
                jle game_loop

                ; if time's up display score with some text
                pop rcx
                mov qword [nb_attempts], rcx
                int_to_str nb_attempts, temp
                int_to_str score, temp
                print nl, 1
                print end_msg, 0
                print score, 8
                print on, 0
                print nb_attempts, 8
                cmp byte [level_user], 1
                je p_noob
                cmp byte [level_user], 2
                je p_inter
                cmp byte [level_user], 3
                je p_master
                p_noob:
                    print noob, 0
                    jmp then
                p_inter:
                    print inter, 0
                    jmp then
                p_master:
                    print master, 0
                    jmp then
                then:
                    print nl, 1
                    print nl, 1
                    jmp menu
        end:
            exit

