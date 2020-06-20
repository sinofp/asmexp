#include<stdio.h>

int main() {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            for (int k = 0; k < 4; k++) {
                for (int l = 0; l < 4; l++) {
                    printf("%d %d %d %d\n", i, j, k, l);
                }
            }
        }
    }
    return 0;
}

/*
int main() {
00331810  push        ebp  
00331811  mov         ebp,esp  
00331813  sub         esp,0F0h  
00331819  push        ebx  
0033181A  push        esi  
0033181B  push        edi  
0033181C  lea         edi,[ebp-0F0h]  
00331822  mov         ecx,3Ch  
00331827  mov         eax,0CCCCCCCCh  
0033182C  rep stos    dword ptr es:[edi]  
0033182E  mov         ecx,offset _2A3D58C5_for4for@c (033C003h)  
00331833  call        @__CheckForDebuggerJustMyCode@4 (0331217h)  
    for (int i = 0; i < 4; i++) {
00331838  mov         dword ptr [ebp-8],0  
0033183F  jmp         main+3Ah (033184Ah)  
00331841  mov         eax,dword ptr [ebp-8]  
00331844  add         eax,1  
00331847  mov         dword ptr [ebp-8],eax  
0033184A  cmp         dword ptr [ebp-8],4  
0033184E  jge         main+0ADh (03318BDh)  
        for (int j = 0; j < 4; j++) {
00331850  mov         dword ptr [ebp-14h],0  
00331857  jmp         main+52h (0331862h)  
00331859  mov         eax,dword ptr [ebp-14h]  
0033185C  add         eax,1  
0033185F  mov         dword ptr [ebp-14h],eax  
00331862  cmp         dword ptr [ebp-14h],4  
00331866  jge         main+0ABh (03318BBh)  
            for (int k = 0; k < 4; k++) {
00331868  mov         dword ptr [ebp-20h],0  
0033186F  jmp         main+6Ah (033187Ah)  
00331871  mov         eax,dword ptr [ebp-20h]  
00331874  add         eax,1  
00331877  mov         dword ptr [ebp-20h],eax  
0033187A  cmp         dword ptr [ebp-20h],4  
0033187E  jge         main+0A9h (03318B9h)  
                for (int l = 0; l < 4; l++) {
00331880  mov         dword ptr [ebp-2Ch],0  
00331887  jmp         main+82h (0331892h)  
00331889  mov         eax,dword ptr [ebp-2Ch]  
0033188C  add         eax,1  
0033188F  mov         dword ptr [ebp-2Ch],eax  
00331892  cmp         dword ptr [ebp-2Ch],4  
00331896  jge         main+0A7h (03318B7h)  
                    printf("%d %d %d %d\n", i, j, k, l);
00331898  mov         eax,dword ptr [ebp-2Ch]  
0033189B  push        eax  
0033189C  mov         ecx,dword ptr [ebp-20h]  
0033189F  push        ecx  
003318A0  mov         edx,dword ptr [ebp-14h]  
003318A3  push        edx  
003318A4  mov         eax,dword ptr [ebp-8]  
003318A7  push        eax  
003318A8  push        offset string "%d %d %d %d\n" (0337B30h)  
003318AD  call        _printf (0331046h)  
003318B2  add         esp,14h  
                }
003318B5  jmp         main+79h (0331889h)  
            }
003318B7  jmp         main+61h (0331871h)  
        }
003318B9  jmp         main+49h (0331859h)  
    }
003318BB  jmp         main+31h (0331841h)  
    return 0;
003318BD  xor         eax,eax  
}
003318BF  pop         edi  
003318C0  pop         esi  
003318C1  pop         ebx  
003318C2  add         esp,0F0h  
}
003318C8  cmp         ebp,esp  
003318CA  call        __RTC_CheckEsp (0331221h)  
003318CF  mov         esp,ebp  
003318D1  pop         ebp  
003318D2  ret  
*/