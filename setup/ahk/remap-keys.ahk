RoA(WinTitle, Target, WorkingDir = "%A_WorkinDir%", Size = "max") {
    IfWinExist, %WinTitle%
    {
		WinActivate, %WinTitle%
    }
	else
    {
		Run, %Target%, %WorkingDir% ,%Size%
        WinWait, %WinTitle%, , 2
        WinActivate, %WinTitle%
    }
}

;; memo
;; Hotkey
;; + shift
;; ^ Control
;; ! alt
;; # win
;; see http://lukewarm.s101.xrea.com/Hotkeys.html

; Terminal
#Enter::Run wt

; Latin characters xD
#+e:: Send {U+00E9}
+!a:: Send {U+00G2}
+!q:: Send {U+00C3}
#+c:: Send {U+00E7}

; Google Search highlighted text
^+c::
{
 Send, ^c
 Sleep 50
 Run, https://duckduckgo.com/?q=%clipboard%
 Return
}

; Win+T to toggle a window being always on top
#T::WinSet, AlwaysOnTop, Toggle, A

; Empty recycle bin
#Del::FileRecycleEmpty ; win + del

; Suspend AutoHotKey
#ScrollLock::Suspend ; Win + scrollLock
    
; Reboot
#+r::
    Msgbox, 4, Reboot option, Do you want to restart your computer?
    IfMsgBox Yes
    {
        Shutdown, 2
    }
    Return