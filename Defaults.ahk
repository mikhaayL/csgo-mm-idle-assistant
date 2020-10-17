#Include, Sort.ahk

SuspendToggle := false

WaitForRelease() {
	KeyWait, Shift
	KeyWait, LWin
	KeyWait, RWin
	KeyWait, Ctrl
	KeyWait, Alt
}

SplitBGRColor(bgr, ByRef red, ByRef green, ByRef blue) {
	red   := bgr & 0xFF
	green := bgr >> 8 & 0xFF
	blue  := bgr >> 16 & 0xFF
}

GetProcessCreationTime(pid) {
	hPr := DllCall("OpenProcess", UInt, 1040, Int, 0, Int, pid)
	DllCall("GetProcessTimes", UInt, hPr, Int64P, UTC, Int, 0, Int, 0, Int, 0)
	DllCall("CloseHandle", Int, hPr)
	DllCall("FileTimeToLocalFileTime", Int64P, UTC, Int64P, Local), AT := 1601
	AT += % Local//10000000, S
	return AT
}




*>+Backspace::
	SoundBeep, 1000, 50
	SoundBeep, 1500, 50
	SoundBeep, 2000, 50
	Reload
return

*>^Del::
	Suspend, Toggle
	SuspendToggle := !SuspendToggle
	if (SuspendToggle) {
		SoundBeep, 700, 100
		SoundBeep, 400, 150
	} else {
		SoundBeep, 400, 150
		SoundBeep, 700, 100
	}
return