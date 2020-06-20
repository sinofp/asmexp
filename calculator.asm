.386
.model flat, stdcall
option casemap:none

include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
includelib msvcrt.lib
printf proto c :ptr sbyte, :vararg
sprintf proto c :ptr sbyte, :ptr sbyte, :vararg
atof proto c :ptr sbyte

.const
LF equ 0AH
szClassName db 'MyClass', 0
szCaptionMain db 'T-800 Calculator', 0
szButton db 'button', 0
szStatic byte 'static', 0
szLogFlt byte 'num is: %f', LF, 0
szLogOp byte 'operator is : %s', LF, 0
szF2s byte '%f', 0
szZero byte '0', 0
em equ 100
buf_size equ 200
; button position and text
;                                                                        10    11    12    13    14    15  16  17    18    19
;            0     1     2     3     4     5     6     7     8     9     .     +     -     *     /     sin cos tan   =     clear
x_list dword em,   0,    em,   2*em, 0,    em,   2*em, 0,    em,   2*em, 2*em, 3*em, 3*em, 3*em, 3*em, 0,  em, 2*em, 3*em, 0
y_list dword 5*em, 4*em, 4*em, 4*em, 3*em, 3*em, 3*em, 2*em, 2*em, 2*em, 5*em, 5*em, 4*em, 3*em, 2*em, em, em, em  , em,   5*em
text0   byte '0', 0, 0, 0
text1   byte '1', 0, 0, 0
text2   byte '2', 0, 0, 0
text3   byte '3', 0, 0, 0
text4   byte '4', 0, 0, 0
text5   byte '5', 0, 0, 0
text6   byte '6', 0, 0, 0
text7   byte '7', 0, 0, 0
text8   byte '8', 0, 0, 0
text9   byte '9', 0, 0, 0
textdot byte '.', 0, 0, 0
textadd byte '+', 0, 0, 0
textsub byte '-', 0, 0, 0
textmul byte '*', 0, 0, 0
textdiv byte '/', 0, 0, 0
textsin byte 'sin', 0
textcos byte 'cos', 0
texttan byte 'tan', 0
texteq  byte '=', 0, 0, 0
textac  byte 'AC', 0, 0
text_list dword text0, text1, text2, text3, text4, text5, text6, text7, text8, text9, textdot, textadd, textsub, textmul, textdiv, textsin, textcos, texttan, texteq, textac

.data?
hInstance dd ? ; 应用程序的句柄
hWinMain dd ?  ; 窗口的句柄
buf byte buf_size dup(?)
num real8 ?
op dword ?

.code
clean_buf proc stdcall
    ; 用RtlZeroMemory也行，但我想写
    xor ecx, ecx
    .while ecx < buf_size
        mov buf[ecx], byte ptr 0
        inc ecx
    .endw
    ret
clean_buf endp

_ProcWinMain proc stdcall uses ebx edi esi, hWnd, uMsg, wParam, lParam
    local stPs:PAINTSTRUCT
    local stRect:RECT
    local hDc

    mov eax, uMsg ; 把消息放给eax

    .if eax==WM_CLOSE  ;窗口关闭消息
        invoke DestroyWindow,hWinMain
        invoke PostQuitMessage,NULL

    .elseif eax==WM_CREATE
        mov ecx, 0
        ; 生成按钮
        .while sdword ptr ecx < 20
            pushad
            mov esi, x_list[ecx*4]
            mov edi, y_list[ecx*4]
            mov edx, text_list[ecx*4]
            invoke CreateWindowEx, NULL, offset szButton, edx, WS_CHILD or WS_VISIBLE, esi, edi, em, em, hWnd, ecx, hInstance, NULL
            popad
            inc ecx
        .endw
        ; 生成数字显示区，不想换行
		invoke CreateWindowEx, NULL, offset szStatic, offset szZero, WS_CHILD or WS_VISIBLE or ES_RIGHT, 0, 0, 4*em, em, hWnd, 20, hInstance, NULL
    .elseif eax==WM_COMMAND ; 点击按钮
        mov eax, wParam ; wParam是按钮的句柄
        .if eax < 11 ; 输入的是数字或小数点
            xor ecx, ecx
            .while buf[ecx] != 0
                inc ecx ; 找到buf里第一个为\0的下标
            .endw
            .if eax == 10
                mov buf[ecx], '.'
            .else
                add al, '0'
                mov buf[ecx], al
            .endif
            invoke atof, offset buf
            fstp num
            invoke SetDlgItemText, hWnd, 20, offset buf
            invoke printf, offset szLogFlt, num
        .elseif eax < 18 ; + - * / sin cos tan
            mov op, eax
            fld num
            invoke printf, offset szLogOp, text_list[eax*4]
            invoke clean_buf
            invoke SetDlgItemText, hWnd, 20, offset szZero
        .elseif eax == 18 ; =
            invoke printf, offset szLogOp, text_list[eax*4]
            .if op == 11 ; +
                fld num
                faddp st(1), st(0)
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .elseif op == 12 ; -
                fld num
                fsubp st(1), st(0)
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .elseif op == 13 ; *
                fld num
                fmulp st(1), st(0)
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .elseif op == 14 ; /
                fld num
                fdivp st(1), st(0)
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .elseif op == 15 ; sin
                fsin
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .elseif op == 16 ; cos
                fcos
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .elseif op == 17 ; tan
                fptan
                fstp num
                invoke printf, offset szLogFlt, num
                invoke sprintf, offset buf, offset szF2s, num
                invoke SetDlgItemText, hWnd, 20, offset buf
            .endif
            invoke clean_buf
        .else ; AC
            invoke printf, offset szLogOp, text_list[eax*4]
            invoke SetDlgItemText, hWnd, 20, offset szZero
            invoke clean_buf
        .endif
    .else ; 都不是，按默认处理方法处理消息
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif

    xor eax,eax
    ret
_ProcWinMain endp

_WinMain proc stdcall
    local stWndClass: WNDCLASSEX ; 窗口属性
    local stMsg: MSG             ; 用来传消息	

    ; 初始化窗口属性
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke RtlZeroMemory, addr stWndClass, sizeof stWndClass
    invoke LoadCursor, 0, IDC_ARROW
    mov stWndClass.hCursor, eax
    push hInstance
    pop stWndClass.hInstance
    mov stWndClass.cbSize, sizeof WNDCLASSEX
    mov stWndClass.style, CS_HREDRAW or CS_VREDRAW
    mov stWndClass.lpfnWndProc, offset _ProcWinMain
    mov stWndClass.hbrBackground, COLOR_WINDOW+1
    mov stWndClass.lpszClassName, offset szClassName

    ; 注册窗口
    invoke RegisterClassEx, addr stWndClass
    ; 创建窗口
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset szClassName, offset szCaptionMain, WS_OVERLAPPEDWINDOW, 600, 0, 4*em+20, 6*em+40, NULL,NULL,hInstance,NULL
    mov hWinMain, eax
    ; 显示窗口
    invoke ShowWindow, hWinMain, SW_SHOWNORMAL
    invoke UpdateWindow, hWinMain

    .while TRUE ; 消息循环
        invoke GetMessage, addr stMsg, NULL, 0, 0
        .break .if eax==0 ; 0是退出
        invoke DispatchMessage, addr stMsg
    .endw
    ret
_WinMain endp

main proc
    call _WinMain
    invoke ExitProcess, NULL
    ret
main endp
end main