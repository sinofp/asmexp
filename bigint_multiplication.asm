.386
.model flat, stdcall
option casemap:none

includelib msvcrt.lib
printf proto c :ptr sbyte, :vararg
scanf proto c :ptr sbyte, :vararg

.const
LF equ 0AH

.data
input_prompt byte 'Please input bit int %d', LF, 0
output_prompt byte 'The answear is', LF, 0
str_in byte '%c', 0
neg_sign byte '-', 0
szOutc byte '%c', 0

.data? ; _bss 段，初始值全0
buf1 dword 200 dup(?)
buf2 dword 200 dup(?)
ans dword 400 dup(?)
size1 dword ?
size2 dword ?
size3 dword ?
is_neg byte ?

.code
read_int proc stdcall num: dword, buf: ptr dword,  siz: ptr dword
    local temp: dword
    pushad
    invoke printf, offset input_prompt, num

    mov ebx, buf
    mov esi, siz

    mov dword ptr [esi], 0
    invoke scanf, offset str_in, addr temp
    .if temp == '-'
        xor is_neg, 1
        invoke scanf, offset str_in, addr temp
    .endif
    .while temp != LF
        sub temp, '0'
        mov edx, temp
        mov edi, dword ptr [esi]
        mov [ebx][edi*4], edx
        inc dword ptr [esi]
        invoke scanf, offset str_in, addr temp
    .endw

    popad
    ret
read_int endp

main proc
    ; read big ints
    invoke read_int, 1, offset buf1, offset size1
    invoke read_int, 2, offset buf2, offset size2

    ; 乘
    mov esi, 0
    .while esi < size1 ; for i in range(size1)
        mov edi, 0
        .while edi < size2 ; for j in range(size2)
            mov eax, buf1[esi*4]
            mul buf2[edi*4] ; eax = buf1[i]*buf2[j]
            mov ebx, 1
            add ebx, esi
            add ebx, edi ; ebx = esi+edi+1
            add ans[ebx*4], eax
            inc edi
        .endw
        inc esi
    .endw

    ; 进位
    mov ecx, size1
    add ecx, size2
    dec ecx
    mov size3, ecx
    .while sdword ptr ecx >= 0
        mov eax, ans[ecx*4]
        mov ebx, 10
        cdq
        div ebx ; eax 商，edx 余
        mov ans[ecx*4], edx
        dec ecx
        add ans[ecx*4], eax
    .endw

    ; 输出
    invoke printf, offset output_prompt
    .if is_neg != 0
        invoke printf, offset neg_sign
    .endif
    mov esi, 0
    .if ans[0] == 0
        inc esi
    .endif
    .while esi <= size3
        mov ebx, ans[esi*4]
        add ebx, '0'
        invoke printf, offset szOutc, ebx
        inc esi
    .endw

    mov eax, 0 ; return 0，看到返回代码不是0就难受
    ret
main endp
end main
