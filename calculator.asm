.386
.model flat,stdcall
option casemap:none

include windows.inc
include gdi32.inc
includelib gdi32.lib
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
szLogFlt byte 'num is: %f', LF, 0
szLogOp byte 'operator is : %s', LF, 0
szF2s byte '%f', 0
szButton db 'button', 0
szZero byte '0', 0
szStatic byte 'static', 0
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
hInstance dd ?  ;存放应用程序的句柄
hWinMain dd ?   ;存放窗口的句柄
buf byte buf_size dup(?)
num real8 ?
op dword ?

.code
clean_buf proc stdcall
    xor ecx, ecx
    .while ecx < buf_size
        mov buf[ecx], byte ptr 0
        inc ecx
    .endw
    ret
clean_buf endp

_ProcWinMain proc stdcall uses ebx edi esi, hWnd, uMsg, wParam, lParam  ;窗口过程
    local stPs:PAINTSTRUCT
    local stRect:RECT
    local hDc

    mov eax, uMsg  ;uMsg是消息类型，如下面的WM_PAINT,WM_CREATE

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
            ; lea eax, text0
            ; mov edx, [eax][ecx*4]
            invoke CreateWindowEx, NULL, offset szButton, edx, WS_CHILD or WS_VISIBLE, esi, edi, em, em, hWnd, ecx, hInstance, NULL
            popad
            inc ecx
        .endw
        ; 生成数字显示区
		invoke CreateWindowEx, NULL, offset szStatic, offset szZero, WS_CHILD or WS_VISIBLE or ES_RIGHT,0,0,4*em,em,hWnd,20,hInstance,NULL ;DIS 20
    .elseif eax==WM_COMMAND  ;点击时候产生的消息是WM_COMMAND
        mov eax, wParam  ;其中参数wParam里存的是句柄，如果点击了一个按钮，则wParam是那个按钮的句柄
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
        .elseif eax < 18 ; +-*/ sin cos
            mov op, eax
            fld num
            fst num
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
            invoke SetDlgItemText, hWnd, 20, offset szZero
            invoke clean_buf
        .endif
    .else  ;否则按默认处理方法处理消息
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif

    xor eax,eax
    ret
_ProcWinMain endp

_WinMain proc stdcall ;窗口程序
    local stWndClass:WNDCLASSEX  ;定义了一个结构变量，它的类型是WNDCLASSEX，一个窗口类定义了窗口的一些主要属性，图标，光标，背景色等，这些参数不是单个传递，而是封装在WNDCLASSEX中传递的。
    local stMsg:MSG	;还定义了stMsg，类型是MSG，用来作消息传递的	

    invoke GetModuleHandle,NULL  ;得到应用程序的句柄，把该句柄的值放在hInstance中，句柄是什么？简单点理解就是某个事物的标识，有文件句柄，窗口句柄，可以通过句柄找到对应的事物
    mov hInstance,eax
    invoke RtlZeroMemory,addr stWndClass,sizeof stWndClass  ;将stWndClass初始化全0

    invoke LoadCursor,0,IDC_ARROW
    mov stWndClass.hCursor,eax					;---------------------------------------
    push hInstance							;
    pop stWndClass.hInstance					;
    mov stWndClass.cbSize,sizeof WNDCLASSEX			;这部分是初始化stWndClass结构中各字段的值，即窗口的各种属性
    mov stWndClass.style,CS_HREDRAW or CS_VREDRAW			;入门的话，这部分直接copy- -。。。为了赶汇编作业，没时间钻研
    mov stWndClass.lpfnWndProc,offset _ProcWinMain			;
    ;上面这条语句其实就是指定了该窗口程序的窗口过程是_ProcWinMain	;
    mov stWndClass.hbrBackground,COLOR_WINDOW+1			;
    mov stWndClass.lpszClassName,offset szClassName		;---------------------------------------
    invoke RegisterClassEx,addr stWndClass  ;注册窗口类，注册前先填写参数WNDCLASSEX结构

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,\  ;建立窗口
            offset szClassName,offset szCaptionMain,\  ;szClassName和szCaptionMain是在常量段中定义的字符串常量
            WS_OVERLAPPEDWINDOW,600,0,4*em+20,6*em+40,\	;szClassName是建立窗口使用的类名字符串指针，这里是'MyClass'，表示用'MyClass'类来建立这个窗口，这个窗口拥有'MyClass'的所有属性
            NULL,NULL,hInstance,NULL		;如果改成'szButton'那么建立的将是一个按钮，szCaptionMain代表的则是窗口的名称，该名称会显示在标题栏中
    mov hWinMain,eax  ;建立窗口后句柄会放在eax中，现在把句柄放在hWinMain中。
    invoke ShowWindow,hWinMain,SW_SHOWNORMAL  ;显示窗口，注意到这个函数传递的参数是窗口的句柄，正如前面所说的，通过句柄可以找到它所标识的事物
    invoke UpdateWindow,hWinMain  ;刷新窗口客户区

    .while TRUE  ;进入无限的消息获取和处理的循环
        invoke GetMessage,addr stMsg,NULL,0,0  ;从消息队列中取出第一个消息，放在stMsg结构中
        .break .if eax==0  ;如果是退出消息，eax将会置成0，退出循环
        invoke TranslateMessage,addr stMsg  ;这是把基于键盘扫描码的按键信息转换成对应的ASCII码，如果消息不是通过键盘输入的，这步将跳过
        invoke DispatchMessage,addr stMsg  ;这条语句的作用是找到该窗口程序的窗口过程，通过该窗口过程来处理消息
    .endw
    ret
_WinMain endp

main proc
    call _WinMain
    invoke ExitProcess,NULL
    ret
main endp
end main