.386
.model flat, stdcall
option casemap:none

includelib msvcrt.lib
printf proto c :ptr sbyte, :vararg

.data
szFmt DB        '%d %d %d %d', 0aH, 00H

i = -16
j = -12
k = -8
l = -4

.code
main   PROC
        push    ebp
        mov     ebp, esp
        sub     esp, 16
        mov     DWORD PTR i[ebp], 0
        jmp     SHORT L2
L1:
        mov     eax, DWORD PTR i[ebp]
        add     eax, 1
        mov     DWORD PTR i[ebp], eax
L2:
        cmp     DWORD PTR i[ebp], 4
        jge     SHORT L12
        mov     DWORD PTR j[ebp], 0
        jmp     SHORT L4
L3:
        mov     ecx, DWORD PTR j[ebp]
        add     ecx, 1
        mov     DWORD PTR j[ebp], ecx
L4:
        cmp     DWORD PTR j[ebp], 4
        jge     SHORT L11
        mov     DWORD PTR k[ebp], 0
        jmp     SHORT L6
L5:
        mov     edx, DWORD PTR k[ebp]
        add     edx, 1
        mov     DWORD PTR k[ebp], edx
L6:
        cmp     DWORD PTR k[ebp], 4
        jge     SHORT L10
        mov     DWORD PTR l[ebp], 0
        jmp     SHORT L8
L7:
        mov     eax, DWORD PTR l[ebp]
        add     eax, 1
        mov     DWORD PTR l[ebp], eax
L8:
        cmp     DWORD PTR l[ebp], 4
        jge     SHORT L9
        mov     ecx, DWORD PTR l[ebp]
        push    ecx
        mov     edx, DWORD PTR k[ebp]
        push    edx
        mov     eax, DWORD PTR j[ebp]
        push    eax
        mov     ecx, DWORD PTR i[ebp]
        push    ecx
        push    OFFSET szFmt
        call    printf
        add     esp, 20
        jmp     SHORT L7
L9:
        jmp     SHORT L5
L10:
        jmp     SHORT L3
L11:
        jmp     SHORT L1
L12:
        xor     eax, eax
        mov     esp, ebp
        pop     ebp
        ret     0
main   ENDP
end main