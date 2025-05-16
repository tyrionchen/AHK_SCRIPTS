; AHK 脚本配置指令
#NoEnv  ; 禁用环境变量推荐，提升性能和兼容性
#SingleInstance Force ; 强制单实例运行
SendMode Input  ; 使用更高效的输入模式
SetWorkingDir %A_ScriptDir%  ; 设置工作目录为脚本所在目录

; 初始化变量
MAX_LOOP := 100  ; 循环次数常量
posX := []       ; 存储鼠标X坐标的数组
posY := []       ; 存储鼠标Y坐标的数组
i := 0           ; 循环计数器
Var:=""          ; 备用变量（当前未使用）
recording := true  ; 录制状态标志
FormatTime, TimeString,, HHmmss  ; 获取当前时间格式化为字符串
CoordMode, Mouse, Screen  ; 设置鼠标坐标为屏幕绝对坐标

; 宏文件配置
whatfile :="macro_" MAX_LOOP ".ahk"  ; 生成的宏文件名（使用常量）

; 时间间隔配置
TMI := 70    ; 录制时每次循环的等待时间（毫秒）
TMR := 100   ; 回放时的动作间隔时间（毫秒）
MouseSpeed := 2  ; 鼠标移动速度（1最快-20最慢）

; 录制热键 Ctrl+R
^r:: 
; 创建半透明提示窗口
CustomColor = FFFFFF  ; GUI背景色
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow  ; 创建无边框置顶窗口
Gui, Color, %CustomColor%
Gui, Font, s32       ; 使用32号字体
Gui, Add, Text, vMyText cLime, Recording...Ctrl+d to STOP  ; 提示文本
WinSet, TransColor, %CustomColor% 150  ; 设置150透明度（0-255）
Gui, Show, x100 y400 NoActivate  ; 在屏幕(100,400)位置显示

recording := true  ; 开始录制
while(recording = true)
{    
    ; 首次循环初始化宏文件
    if(i=0)
    {
        FileDelete, %whatfile%  ; 删除旧宏文件
        
        ; 写入AHK脚本头配置
        FileAppend, 
            (
            `n#NoEnv
            `nSetWorkingDir %A_ScriptDir%
            `nCoordMode, Mouse, Screen
            `nSendMode Input
            `n#SingleInstance Force
            `nSetTitleMatchMode 2
            `n#WinActivateForce
            `nSetControlDelay 1
            `nSetWinDelay 0
            `nSetKeyDelay -1
            `nSetMouseDelay -1
            `nSetBatchLines -1
            `nLoop %MAX_LOOP% {  ; 使用常量控制循环次数
            ), %whatfile% 
        
        run, recorde_keys.ahk  ; 启动配套按键记录脚本
    }
    
    ; 记录当前鼠标位置
    MouseGetPos, x, y
    posX[i] := x
    posY[i] := y

    ; 检测左键点击
    if(GetKeyState("LButton", "P"))
    {
        FileAppend, 
            (
            `nMouseMove, %x%, %y%, %MouseSpeed%
            `nsleep %TMR%
            `nsleep 4
            `nClick, down   ; 按下左键
            `nsleep 23
            `nClick, up     ; 松开左键
            `nsleep 15
            ), %whatfile% 
    }
    
    ; 记录鼠标移动
    FileAppend, 
        (
         `nMouseMove, %x%, %y%, %MouseSpeed%
         `nsleep %TMR%
        ), %whatfile% 
    
    sleep %TMI%  ; 录制间隔
    i++          ; 计数器递增
}
return

; 备用回放功能（未启用）Ctrl+E
^e:: 
    recording := false
    i := 0
    l := posX.Length()
    while(i <=l)
    {
        x := posX[i]
        y := posY[i]
        MouseMove, %x%, %y%
        sleep %TMR%
        i := i+1
    }
return

; 停止录制热键 Ctrl+D
^d::  
recording := false

; 关闭配套的按键记录脚本
DetectHiddenWindows, On 
WinClose, %A_ScriptDir%\recorde_keys.ahk ahk_class AutoHotkey

; 为生成的宏文件添加退出功能
FileAppend, 
    (
    `nRun, PowerShell.exe -WindowStyle Hidden -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "%A_ScriptDir%\screenshot.ps1"  ; 调用PowerShell截图脚本
    `n}`n  ; 结束循环
    `nEsc:: ExitApp  ; 按ESC退出
    `nExitApp
    ), %whatfile% 

Gui, cancel  ; 关闭提示窗口
Reload       ; 重新加载本脚本
return
