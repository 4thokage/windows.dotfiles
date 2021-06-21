; ========================================================================
; Utility functions for app windows
; ========================================================================


; Returns detailed information about ALL windows
GetWindows(Monitors)
{
  Windows := []

  ; Add the active window FIRST
  ActiveWindow := GetActiveWindow(Monitors)
  Windows.Push(ActiveWindow)

  ; Add all other windows
  WinGet, WinIDs, List, , , Program Manager
  Loop, %WinIDs%
  {
    WindowID := WinIDs%A_Index%

    If (WindowID != ActiveWindow.ID)
    {
      Window := GetWindow(WindowID, Monitors)
      Windows.Push(Window)
    }
  }

  Return Windows
}



; Returns an object containing detailed information about the specified window
GetWindow(ID, Monitors)
{
  WinGetTitle, Title, ahk_id %ID%
  WinGetText, Text, ahk_id %ID%
  WinGetClass, Class, ahk_id %ID%
  WinGet, State, MinMax, ahk_id %ID%
  WinGet, Process, ProcessName, ahk_id %ID%
  WinGet, Transparency, Transparent, ahk_id %ID%
  WinGetPos, Left, Top, Width, Height, ahk_id %ID%

  ; Transparency is 0 (invisible) to 255 (opaque), or blank if not set (i.e. visible)
  Transparency := (Transparency = "" ? 255 : 0)

  Log("Determining the current monitor for window #" . ID . " (" . Title . ")")
  Monitor := GetMonitorByRect(Left, Top, Width, Height, Monitors)

  Window := {}
  Window.ID := ID
  Window.Title := Title
  Window.Text := Text
  Window.Class := Class
  Window.Process := Process
  Window.Monitor := Monitor
  Window.Transparency := Transparency
  Window.Width := Width
  Window.Height := Height

  If (Monitor)
  {
    ; Calculate the window's position on its monitor
    Window.Left := Left - Monitor.Bounds.Left
    Window.Top := Top - Monitor.Bounds.Top
  }
  Else
  {
    ; The window is off of the desktop
    Window.Monitor := { ID: "" }
    Window.Left := Left
    Window.Top := Top
  }

  Window.Right := Window.Left + Width
  Window.Bottom := Window.Top + Height

  ; Convert the window's state from a number to a string, for readability
  If (State = -1)
    Window.State := "MINIMIZED"
  Else If (State = 1)
    Window.State := "MAXIMIZED"
  Else
    Window.State := "NORMAL"

  Log("========== Window #" . Window.ID . " =========="
    . "`r`nTitle: " . Window.Title
    . "`r`nText: " . Window.Text
    . "`r`nClass: " . Window.Class
    . "`r`nProcess: " . Window.Process
    . "`r`nState: " . Window.State
    . "`r`nTransparency: " . Window.Transparency
    . "`r`nSystem Window: " . (IsSystemWindow(Window) ? "yes" : "no")
    . "`r`nMonitor: " . Window.Monitor.ID
    . "`r`nPosition:"
    . "`r`n  Left: " . Window.Left
    . "`r`n  Right: " . Window.Right
    . "`r`n  Top: " . Window.Top
    . "`r`n  Bottom: " . Window.Bottom
    . "`r`n  Width: " . Window.Width
    . "`r`n  Height: " . Window.Height)

  Return Window
}



; Returns the currently-active window
GetActiveWindow(Monitors)
{
  WinGet WindowID, ID, A
  Window := GetWindow(WindowID, Monitors)
  Return Window
}



; Returns all windows in the list that match the specified criteria and DO NOT match the exclusion criteria.
; NOTE: If no matches are found, then the return value is null - NOT an empty array.
FindWindows(Windows, InclusionCriteria, ExclusionCriteria := "")
{
  Matches := []

  For Index, Window in Windows
  {
    If (WindowMatches(Window, InclusionCriteria) and !WindowMatches(Window, ExclusionCriteria))
    {
      Matches.Push(Window)
    }
  }

  Log("Found " . Matches.Length() . " windows that match " . WindowCriteriaToString(InclusionCriteria), False)

  If (Matches.Length() > 0)
    Return Matches
}



; Determines whether the given window matches the specified criteria
WindowMatches(Window, Criteria)
{
  If (Criteria == "")
    Return False

  If (Criteria.HasTitle and StrLen(Window.Title) == 0)
    Return False

  ; Title can be a string or array of strings
  If (Criteria.Title and not WindowTitleMatches(Window, Criteria.Title))
    Return False

  If (Criteria.Class and Window.Class != Criteria.Class)
    Return False

  If (Criteria.Process and Window.Process != Criteria.Process)
    Return False

  Return True
}



; Determines whether the given window matches one of the specified titles
WindowTitleMatches(Window, Titles, CaseSensitive := True)
{
  ; Normalize Titles as an array
  If (!IsArray(Titles))
    Titles := [Titles]

  For Index, Title in Titles
  {
    If (InStr(Window.Title, Title, CaseSensitive) or InStr(Window.Text, Title, CaseSensitive))
      Return True
  }

  Return False
}



; Sets a window's size and position to the specified layout
SetWindowLayout(Window, Layout, Monitors)
{
  Log("Positioning window #" . Window.ID . ": " . WindowToString(Window))

  ; Calculate the absolute size & position to move the window to
  NewLocation := GetAbsoluteLayout(Window, Layout)

  Log("Current Monitor: " . Window.Monitor.ID
     . "`r`nCurrent Dimensions:"
     . "`r`n  Monitor: " . Window.Monitor.ID
     . "`r`n  Left: " . Window.Left
     . "`r`n  Top: " . Window.Top
     . "`r`n  Width: " . Window.Width
     . "`r`n  Height: " . Window.Height
     . "`r`n  State: " . Window.State
     . "`r`n"
     . "`r`nNew Dimensions:"
     . "`r`n  Monitor: " . NewLocation.Monitor.ID
     . "`r`n  Left: " . NewLocation.Left
     . "`r`n  Top: " . NewLocation.Top
     . "`r`n  Width: " . NewLocation.Width
     . "`r`n  Height: " . NewLocation.Height
     . "`r`n  State: " . NewLocation.State)

  ID := "ahk_id " . Window.ID
  Monitor := NewLocation.Monitor
  State := Layout.State
  Width := NewLocation.Width
  Height := NewLocation.Height
  Left := NewLocation.Left
  Top := NewLocation.Top

  If (State = "MAXIMIZED")
  {
    Width := Floor(Width * .5)
    Height := Floor(Height * .75)
    Left := Floor(Monitor.WorkArea.Width * .25)
    Top := Floor(Monitor.WorkArea.Height * .125)

    Log("The window will be maximized, but when un-maximized, it will be:"
      . "`r`n  Width: " . Width
      . "`r`n  Height: " . Height
      . "`r`n  Left: " . Left
      . "`r`n  Top: " . Top)
  }

  Left := Left + Monitor.Bounds.Left
  Top := Top + Monitor.Bounds.Top


  ; If the window is currently minimized or maximized, then restore it first,
  ; so we can resize and position it
  If (Window.State != "NORMAL")
  {
    WinRestore %ID%
  }

  ; If the window is moving to a new monitor, then we need to resize it TWICE
  ; to account for any change in DPI between the two monitors
  If (Monitor.ID != Window.Monitor.ID)
  {
    Log("Moving the window to a new monitor. Will need to adjust for DPI differences")
    WinMove, %ID%, , Left, Top, Width, Height
    Window.Monitor := Monitor
  }

  PositionWindow(Window, ID, Left, Top, Width, Height)

  ; Set the window's minimized/maximized state, if necessary
  If (State = "MAXIMIZED")
    WinMaximize, %ID%
  Else If (State = "MINIMIZED")
    WinMinimize, %ID%
  Else
    State := "NORMAL"

  Window.State := State

  Log("Final Window Position: "
     . "`r`n  Monitor: " . Window.Monitor.ID
     . "`r`n  Left: " . Window.Left
     . "`r`n  Top: " . Window.Top
     . "`r`n  Width: " . Window.Width
     . "`r`n  Height: " . Window.Height
     . "`r`n  State: " . Window.State)
}


; This function is a wrapper arund `WinMove` that accounts for some weird buggy behavior that I've
; encountered.  For some reason, WinMove adds hundreds of extra pixels to the window height, but
; ONLY on a vertical monitor, and ONLY when the app touches the bottom edge of the monitor. Even
; more odd, the behavior only happens for SOME apps, and it sometimes only happens if they're on
; the RIGHT side of the screen. I've tried everything I can think of, and can't figure out why.
; So the only workaround I've found is reduce the height to compensate.
PositionWindow(Window, ID, Left, Top, Width, Height)
{
  Monitor := Window.Monitor
  IsVerticalMonitor := Monitor.Bounds.Height > Monitor.Bounds.Width
  IsTouchingBottom := IsNear(Top + Height, Monitor.WorkArea.Top + Monitor.WorkArea.Height)
  IsTouchingRight := IsNear(Left + Width, Monitor.WorkArea.Left + Monitor.WorkArea.Width)
  HeightAdjustment := 0

  If (IsVerticalMonitor and IsTouchingBottom and IsTouchingRight)
  {
    ; These apps aren't affected by the bug. So no correction is necessary
    NoCorrectionNecessary := WindowMatches(Window, { Title: ["Google Chrome", "Sourcetree"] })
                  or WindowMatches(Window, { Process: "Spotify.exe", HasTitle: True })
                  or WindowMatches(Window, { Process: "Slack.exe" })

    If (!NoCorrectionNecessary)
    {
      ; These apps need their height reduced by 472 pixels
      Subtract472 := WindowMatches(Window, { Title: "GitKraken" })

      If (Subtract472)
        HeightAdjustment := -472
      Else
        ; All other apps need their height reduced by 612 pixels
        HeightAdjustment := -612
    }
  }

  If (HeightAdjustment != 0)
  {
    Log("The window is being docked to the bottom of a vertical monitor, "
      . "so the height was adjusted by " . HeightAdjustment . "px to compensate for an AutoHotKey bug")
  }

  Window.Left := Left
  Window.Top := Top
  Window.Width := Width
  Window.Height := (Height + HeightAdjustment)
  Window.Right := Window.Left + Window.Width
  Window.Bottom := Window.Top + Window.Height

  WinMove, %ID%, , Window.Left, Window.Top, Window.Width, Window.Height
}



; Calculates the window's absolute layout on the target monitor
GetAbsoluteLayout(Window, Layout)
{
  global MinimumWindowSize
  Monitor := Layout.Monitor
  Width := Layout.Width
  Height := Layout.Height
  Top := Layout.Top
  Left := Layout.Left

  ; Calculate pixel values from percentages
  If (Height <= 1)
    Height := Floor(Monitor.WorkArea.Height * Height)
  If (Width <= 1)
    Width := Floor(Monitor.WorkArea.Width * Width)
  If (Top <= 1 and Top != "")
    Top := (Monitor.WorkArea.Top - Monitor.Bounds.Top) + Floor(Monitor.WorkArea.Height * Top)
  If (Left <= 1 and Left != "")
    Left := (Monitor.WorkArea.Left - Monitor.Bounds.Left) + Floor(Monitor.WorkArea.Width * Left)

  If (Top = "")
  {
    ; Center the window vertically
    Top := (Monitor.WorkArea.Top - Monitor.Bounds.Top) + Floor((Layout.Monitor.WorkArea.Height - Height) / 2)
  }

  If (Left = "")
  {
    ; Center the window horizontally
    Left := (Monitor.WorkArea.Left - Monitor.Bounds.Left) + Floor((Layout.Monitor.WorkArea.Width - Width) / 2)
  }

  Log("Absolute Layout:"
    . "`r`n  Left: " . Left
    . "`r`n  Top: " . Top
    . "`r`n  Width: " . Width
    . "`r`n  Height: " . Height)

  ; Window borders (Windows 10)
  If (WindowHasBorder(Window))
  {
    SysGet, BorderWidth, 32
    SysGet, BorderHeight, 33
    NewLeft := Left - BorderWidth
    NewWidth := Width + (BorderWidth * 1.5)
    NewHeight := Height + BorderHeight

    Log("Adjusting for window borders:"
      . "`r`n  Left: " . Left . " - " . BorderWidth . " = " . NewLeft
      . "`r`n  Width: " . Width . " + " . (BorderWidth * 1.5) . " = " . NewWidth
      . "`r`n  Height: " . Height . " + " . BorderHeight . " = " . NewHeight)

    Left := NewLeft
    Width := NewWidth
    Height := NewHeight
  }

  Absolute := {}
  Absolute.Monitor := Monitor
  Absolute.Left := Floor(Left)
  Absolute.Top := Floor(Top)
  Absolute.Width := Floor(Max(Width, MinimumWindowSize))
  Absolute.Height := Floor(Max(Height, MinimumWindowSize))
  Return Absolute
}



; Returns a user-friendly description of the window
WindowToString(Window)
{
  Title := Window.Title
  If IsEmptyString(Title)
    Title := Window.Text

  If WindowMatches(Window, { Process: "Explorer.EXE", Class: "CabinetWClass" })
    Description := "Windows Explorer"
  Else If WindowMatches(Window, { Process: "Spotify.exe", HasTitle: True })
    Description := "Spotify"
  Else If WindowMatches(Window, { Process: "Slack.exe" })
    Description := "Slack"
  Else If WindowMatches(Window, { Title: "Google Chrome" })
    Description := "Chrome (" . SubStr(Title, 1, 20) . ")"
  Else If IsEmptyString(Title)
    Description := Window.Process . ": " . Window.Class
  Else
    Description := StrReplace(Title, "`r`n", " ")

  ; ; Add the window's size
  ; If (Window.State = "MINIMIZED")
  ;   Description := Description . " (Minimized)"
  ; Else If (Window.State = "MAXIMIZED")
  ;   Description := Description . " (Maximized)"
  ; Else If (Window.Transparency = 0)
  ;   Description := Description . " (Transparent)"
  ; Else If (!Window.Monitor)
  ;   Description := Description . " (" . Window.Width . " x " . Window.Height . ")"
  ; Else
  ; {
  ;   Relative := GetRelativeWindowBounds(Window, Window.Monitor)
  ;   Description := Description . " (" . Relative.Width . " x " . Relative.Height . "`)"
  ; }

  Return Description
}



; Returns a user-friendly description of the specified window criteria
WindowCriteriaToString(Criteria)
{
  If (Criteria.Title)
  {
    If (IsArray(Criteria.Title))
      Return Criteria.Title[1]
    Else
      Return Criteria.Title
  }

  If (Criteria.Process)
    Return Criteria.Process

  If (Criteria.Class)
    Return Criteria.Class
}



; Determines whether the specified window has a Windows 10 border,
; which affects its width and height calculations
WindowHasBorder(Window)
{
  WindowsWithoutBorders := ["Microsoft Visual Studio", "Sourcetree", "Slack"]
  CaseSensitive := true

  For Index, Title in WindowsWithoutBorders
  {
    If (InStr(Window.Title, Title, CaseSensitive))
    {
      Log(Title . " does not have window borders")
      Return False
    }
  }

  Log("The window has borders, which affects its height and width calculations")
  Return True
}



; Determines whether the given window is a system window, such as the Desktop or Start Menu
IsSystemWindow(Window)
{
  ; Start Menu and Action Center
  If ((Window.Process = "ShellExperienceHost.exe")
  and ((Window.Title = "Start") or (Window.Title = "Action center")))
  {
    Return True
  }

  ; System tray
  If ((Window.Process = "Explorer.EXE")
  and ((Window.Class = "Shell_TrayWnd") or (Window.Class = "Shell_SecondaryTrayWnd")))
  {
    Return True
  }

  ; Desktop
  If ((Window.Process = "Explorer.EXE")
  and ((Window.Class = "WorkerW") or (Window.Class = "DesktopWallpaperManager")))
  {
    Return True
  }

  ; Windows input method selector
  If ((Window.Process = "Explorer.EXE") and (Window.Class = "EdgeUiInputTopWndClass"))
  {
    Return True
  }

  ; Cortana
  If ((Window.Process = "SearchUI.exe") and (Window.Title = "Cortana"))
  {
    Return True
  }

  ; These are window decorations, such as borders and drop shadows
  If ((Window.Title = "GlassPanelForm") or (Window.Title = "frmDeviceNotify"))
  {
    Return True
  }

  ; Doesn't seem to be a system window
  Return False
}

; ========================================================================
; Utility functions for monitors
; ========================================================================


; Returns detailed information about ALL monitors
GetMonitors()
{
  Monitors := []

  ; Add the primory monitor FIRST
  PrimaryMonitor := GetPrimaryMonitor()
  Monitors.Push(PrimaryMonitor)

  ; Add all other monitors in numeric order
  SysGet, MonitorCount, MonitorCount
  Loop, %MonitorCount%
  {
    MonitorID := A_Index

    If (MonitorID != PrimaryMonitor.ID)
    {
      Monitor := GetMonitor(MonitorID)
      Monitors.Push(Monitor)
    }
  }

  Return Monitors
}



; Returns the system's primary monitor
GetPrimaryMonitor()
{
  SysGet, PrimaryMonitorID, MonitorPrimary
  Monitor := GetMonitor(PrimaryMonitorID)
  Return Monitor
}



; Returns an object containing detailed information about the specified monitor
GetMonitor(ID)
{
  SysGet, Name, MonitorName, %ID%
  SysGet, Bounds, Monitor, %ID%
  SysGet, WorkArea, MonitorWorkArea, %ID%
  SysGet, PrimaryMonitorID, MonitorPrimary

  Monitor := {}
  Monitor.ID := ID
  Monitor.Name := Name
  Monitor.IsPrimary := (ID = PrimaryMonitorID)

  Monitor.Bounds := {}
  Monitor.Bounds.Left := BoundsLeft
  Monitor.Bounds.Right := BoundsRight
  Monitor.Bounds.Top := BoundsTop
  Monitor.Bounds.Bottom := BoundsBottom
  Monitor.Bounds.Width := BoundsRight - BoundsLeft
  Monitor.Bounds.Height := BoundsBottom - BoundsTop

  Monitor.WorkArea := {}
  Monitor.WorkArea.Left := WorkAreaLeft
  Monitor.WorkArea.Right := WorkAreaRight
  Monitor.WorkArea.Top := WorkAreaTop
  Monitor.WorkArea.Bottom := WorkAreaBottom
  Monitor.WorkArea.Width := WorkAreaRight - WorkAreaLeft
  Monitor.WorkArea.Height := WorkAreaBottom - WorkAreaTop

  Monitor.Type := IsLaptopMonitor(Monitor) ? "LAPTOP" : GetOrientation(Monitor)

  Log("========== Monitor #" . Monitor.ID . " =========="
    . "`r`nName: " . Monitor.Name
    . "`r`nPrimary: " . (Monitor.IsPrimary ? "yes" : "no")
    . "`r`nType: " . Monitor.Type
    . "`r`nBounds:"
    . "`r`n  Left: " . Monitor.Bounds.Left
    . "`r`n  Right: " . Monitor.Bounds.Right
    . "`r`n  Top: " . Monitor.Bounds.Top
    . "`r`n  Bottom: " . Monitor.Bounds.Bottom
    . "`r`n  Width: " . Monitor.Bounds.Width
    . "`r`n  Height: " . Monitor.Bounds.Height
    . "`r`nWorkArea:"
    . "`r`n  Left: " . Monitor.WorkArea.Left
    . "`r`n  Right: " . Monitor.WorkArea.Right
    . "`r`n  Top: " . Monitor.WorkArea.Top
    . "`r`n  Bottom: " . Monitor.WorkArea.Bottom
    . "`r`n  Width: " . Monitor.WorkArea.Width
    . "`r`n  Height: " . Monitor.WorkArea.Height)

  Return Monitor
}



; Returns the NEXT monitor in the list, or the first monitor
GetNextMonitor(CurrentMonitor, Monitors)
{
  For Index, Monitor In Monitors
  {
    If (Monitor.ID = CurrentMonitor.ID)
    {
      NextMonitor := Monitors[Index + 1]
      If (NextMonitor)
        Return NextMonitor
      Else
        Return Monitors[1]
    }
  }

  Log("!!!!! Unable to determine the next monitor")
  Return Monitors[1]
}



; Returns the monitor that contains the majority of the specified rectangle
GetMonitorByRect(Left, Top, Width, Height, Monitors)
{
  ; Calculate the center point of the rect
  CenterX := Floor(Left + (Width / 2))
  CenterY := Floor(Top + (Height / 2))

  ; Calculate the bottom and right of the rect
  Bottom := Top + Height
  Right := Left + Width

  ; Try to find the monitor that contains the center point.
  ; If that fails, then find the first monitor that contains a corner of the rect
  Points := []
  Points.Push({ X: CenterX, Y: CenterY })
  Points.Push({ X: Left, Y: Top })
  Points.Push({ X: Right, Y: Top })
  Points.Push({ X: Left, Y: Bottom })
  Points.Push({ X: Right, Y: Bottom })

  For Index, Point in Points
  {
    Monitor := GetMonitorForPoint(Point.X, Point.Y, Monitors)
    If (Monitor)
      Return Monitor
  }

  Log("!!!!! Unable to find the window's monitor")
  Return Monitors[1]
}



; Returns the monitor that contains the specified X, Y point
GetMonitorForPoint(X, Y, Monitors)
{
  For Index, Monitor in Monitors
  {
    If ((X >= Monitor.Bounds.Left) and (Y >= Monitor.Bounds.Top)
    and (X <= Monitor.Bounds.Right) and (Y <= Monitor.Bounds.Bottom))
    {
      Log("Point " . X . ", " . Y . " is on monitor #" . Monitor.ID
        . " (" . Monitor.Bounds.Left . ", " . Monitor.Bounds.Top
        . " to " . Monitor.Bounds.Right . ", " . Monitor.Bounds.Bottom . ")")
      Return Monitor
    }
  }

  Log("No monitor contains the point " . X . ", " . Y)
}



; Returns the given monitor's orientation
GetOrientation(Monitor)
{
  If (Monitor.Bounds.Height > Monitor.Bounds.Width)
    Return "VERTICAL"
  Else
    Return "HORIZONTAL"
}



; Determines whether the given monitor is the built-in laptop screen
IsLaptopMonitor(Monitor)
{
  Return (Monitor.Bounds.Width = 2400 and Monitor.Bounds.Height = 1350) ; 200% scaling
      or (Monitor.Bounds.Width = 2743 and Monitor.Bounds.Height = 1543) ; 175% scaling
}



; Returns the Monitor for the built-in laptop screen
FindLaptopMonitor(Monitors)
{
  For Index, Monitor in Monitors
  {
    If (IsLaptopMonitor(Monitor))
    {
      Log("The laptop screen is monitor #" . Monitor.ID
        . " (" . Monitor.Bounds.Width . " x " . Monitor.Bounds.Height . ")")
      Return Monitor
    }
  }

  Log("The laptop screen is closed")
}



; Returns the first horizontal Monitor in the list
FindHorizontalMonitor(Monitors, Exclude := "")
{
  Exclude := Exclude ? Exclude : { ID: "" }

  For Index, Monitor in Monitors
  {
    If (Monitor.ID = Exclude.ID)
      Continue

    If (GetOrientation(Monitor) = "HORIZONTAL")
    {
      Log("The horizontal screen is monitor #" . Monitor.ID
        . " (" . Monitor.Bounds.Width . " x " . Monitor.Bounds.Height . ")")
      Return Monitor
    }
  }

  Log("There is no horizontal monitor connected")
}



; Returns the first vertical monitor in the list
FindVerticalMonitor(Monitors)
{
  For Index, Monitor in Monitors
  {
    If (GetOrientation(Monitor) = "VERTICAL")
    {
      Log("The vertical screen is monitor #" . Monitor.ID
        . " (" . Monitor.Bounds.Width . " x " . Monitor.Bounds.Height . ")")
      Return Monitor
    }
  }

  Log("There is no vertical monitor connected")
}

; ========================================================================
; Miscellaneous utility functions
; ========================================================================


; Determines whether the given string is empty or entirely whitespace
IsEmptyString(String)
{
  Return RegExMatch(String, "^ *$")
}


; Determines whether the given value is an Array
IsArray(Value)
{
  Return IsObject(Value) and Value.MaxIndex() != ""
}



; Returns the array item with the specified ID
FindByID(Array, ID)
{
  For Index, Item in Array
  {
    If (Item.ID = ID)
      Return Item
  }
}



; Returns the items from Subset that are also in Superset
SubsetOf(Superset, Subset)
{
  ; Special case: If there is no superset, then the entire subset is returned
  If (Superset.Length() = 0)
    Return Subset

  Intersection := []

  For Index, SubItem in Subset
  {
    For Index2, SuperItem in Superset
    {
      If (SuperItem.ID = SubItem.ID)
      {
        Intersection.Push(SubItem)
        Break
      }
    }
  }

  Return Intersection
}



; Determines whether two position values are near each other, within a few pixels
IsNear(a, b)
{
  Tolerance := 50

  If ((a >= b) and (a - b < Tolerance))
  {
    Return True
  }
  Else If ((b > a) and (b - a < Tolerance))
  {
    Return True
  }
  Else
  {
    Return False
  }
}



; Displays an informational message modal
Info(Message)
{
  MsgBox, 64, AutoHotKey, %Message%
}



; Writes the given text to a log file, if logging is enabled
Log(Text, PrependBlankLine := True)
{
  Try
  {
    global LoggingEnabled

    If (LoggingEnabled)
    {
      Text := Text . "`r`n"

      If (PrependBlankLine)
        Text := "`r`n" . Text

      FileCreateDir, logs
      FileAppend, %Text%, logs\log.txt
    }
  }
  Catch Exception
  {
    Message := "Error while writing to the log file: " . Exception.Message
    MsgBox, 16, AutoHotKey, %Message%
  }
}



; Creates a new log file
NewLog()
{
  Try
  {
    FileMove, logs\log.txt, logs\log_%A_Hour%%A_Min%.txt, 1
  }
  Catch Exception
  {
    Message := "Error while creating a new log file: " . Exception.Message
    MsgBox, 16, AutoHotKey, %Message%
  }
}



; Displays errors in a message box
ErrorHandler(Exception)
{
  Message := Exception.Message
  Log("========== ERROR ==========`r`n" . Message)
  ; MsgBox, 16, AutoHotKey, %Message%
}