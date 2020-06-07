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

.data?
buf1 dword 200 dup(0)
buf2 dword 200 dup(0)
ans dword 400 dup(0)
size1 dword 0
size2 dword 0
size3 dword ?
temp dword ?
is_neg byte 0

.code
main proc
    invoke printf, offset input_prompt, 1

    ; read first big int
    mov size1, 0
    invoke scanf, offset str_in, offset temp
    .if temp == '-'
        xor is_neg, 1
        invoke scanf, offset str_in, offset temp
    .endif
    .while temp != LF
        sub temp, '0'
        mov edx, temp
        mov edi, size1
        mov buf1[edi*4], edx
        inc size1
        invoke scanf, offset str_in, offset temp
    .endw

    invoke printf, offset input_prompt, 2

    ; read second big int
    mov size2, 0
    invoke scanf, offset str_in, offset temp
    .if temp == '-'
        xor is_neg, 1
        invoke scanf, offset str_in, offset temp
    .endif
    .while temp != LF
        sub temp, '0'
        mov edx, temp
        mov edi, size2
        mov buf2[edi*4], edx
        inc size2
        invoke scanf, offset str_in, offset temp
    .endw

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
    .while ecx <= size3; ecx >= (unsigned long)0
        mov eax, ans[ecx*4]
        mov ebx, 10
        cdq
        div ebx ; eax 商，edx 余
        mov ans[ecx*4], edx
        dec ecx
        add ans[ecx*4], eax
    .endw

    invoke printf, offset output_prompt
    .if is_neg != 0
        invoke printf, offset neg_sign
    .endif
    mov ecx, 0
    .if ans[0] == 0
        inc ecx
    .endif
    .while ecx <= size3
        pushad
        mov ebx, ans[ecx*4]
        add ebx, '0'
        invoke printf, offset szOutc, ebx
        popad
        inc ecx
    .endw

    ret
main endp
end main
