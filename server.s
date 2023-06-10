.intel_syntax noprefix
.globl _start

.section .text

_start:
    # create socket(AF_INET, SOCK_STREAM, IPROTO_IP)
    mov rdi, 0x2 # AF_INET
    mov rsi, 0x1 # SOCK_STREAM
    mov rdx, 0x0 # IPROTO_IP
    mov rax, 0x29
    syscall

    mov r8, rax

    # create bind(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("0.0.0.0")}, 16)
    mov rdi, r8 # socket fd
    lea rsi, [rip+sockaddr] # struct sockaddr = {AF_INET, htons(80), inet_addr(0.0.0.0)}
    mov rdx, 16 # socketlen
    mov rax, 0x31
    syscall

    # create listen(3, 0)
    mov rdi, r8 # socket fd
    mov rsi, 0x0 # backlog
    mov rax, 0x32
    syscall

loopaccept:
    # cretate accept()
    mov rdi, r8 # sockfd
    mov rsi, 0x0 # sockaddr
    mov rdx, 0x0 # socklen
    mov rax, 0x2b
    syscall

    mov r9, rax

    mov rax, 0x39
    syscall
    cmp rax, 0
    je child
    jmp close
child:
    mov rdi, r8
    mov rax, 0x3
    syscall

    # create read(4, rsp, 512)
    mov rdi, r9
    mov rsi, rsp
    mov rdx, 512
    mov rax, 0
    syscall
    mov r13, rax

    mov r10, rsp
    mov rcx, 0
loop:
    # parse method name
    mov r12b, [r10]
    cmp r12b, ' '
    je done
    inc r10
    shl r12, 8
    jmp loop
done:
    inc r10
    mov r11, r10

loop2:
    # parse destination
    mov al, [r11]
    cmp al, ' '
    je done2
    inc r11
    jmp loop2

done2:
    # check method
    mov byte ptr [r11], 0
    mov rax, 0x47455420 # rax = "GET " 
    cmp r12, rax
    je get
    mov rax, 0x504f535420 # rax = "POST " 
    cmp r12, rax
    jne method_not_allowed
    
    # open(file_name(r10), O_WRONLY|O_CREAT, 0777) 
    mov rdi, r10
    mov rsi, 65
    mov rdx, 0777
    mov rax, 2
    syscall

    mov r15, rax
    mov r14, 0
postloop:
    # parse from body content
    mov ax, [r10]
    cmp ax, 0x0d0a
    je postdone
    inc r10
    inc r14
    jmp postloop

postdone:
    add r10, 3
    add r14, 8
    sub r13, r14

    # write(fd, content_from_body(r10), size)
    mov rdi, r15
    mov rsi, r10
    mov rdx, r13
    mov rax, 1
    syscall
    mov r10, rax

    # close file
    mov rdi, r15
    mov rax, 0x3
    syscall

    # create write(4, "HTTP/1.0 200 OK\r\n\r\n", 5)
    mov rdi, r9
    lea rsi, [rip+response]
    mov rdx, 19
    mov rax, 0x1
    syscall
    jmp exit

get:
    # open file
    mov rdi, r10
    mov rsi, 0
    mov rdx, 0
    mov rax, 2
    syscall
    cmp rax, 0
    jl not_found
    mov r15, rax

    # read from file
    mov rdi, rax
    mov rsi, rsp
    mov rdx, 0x100
    mov rax, 0
    syscall
    mov r10, rax
    
    # close file
    mov rdi, r15
    mov rax, 0x3
    syscall

    # create write(4, "HTTP/1.0 200 OK\r\n\r\n", 5)
    mov rdi, r9
    lea rsi, [rip+response]
    mov rdx, 19
    mov rax, 0x1
    syscall
    
    # create write(r9, file_content, size)
    mov rdi, r9
    mov rsi, rsp
    mov rdx, r10
    mov rax, 0x1
    syscall
    jmp exit
close:
    # close
    mov rdi, r9
    mov rax, 0x3
    syscall

    jmp loopaccept

method_not_allowed:
    mov rdi, r9
    lea rsi, [rip+response_405]
    mov rdx, 35
    mov rax, 0x1
    syscall
    jmp exit

not_found:
    mov rdi, r9
    lea rsi, [rip+response_404]
    mov rdx, 26
    mov rax, 0x1
    syscall
exit:
    # exit
    mov rdi, 0
    mov rax, 60
    syscall

.section .data
sockaddr:
    .2byte 2
    .byte 0
    .byte 80
    .4byte 0
    .8byte 0

response:
    .string "HTTP/1.0 200 OK\r\n\r\n"

response_405:
    .string "HTTP/1.0 405 Method Not Allowed\r\n\r\n"

response_404:
    .string "HTTP/1.0 404 Not Found\r\n\r\n"



