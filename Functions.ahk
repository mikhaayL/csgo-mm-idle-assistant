MouseClick(uid, x, y, before := 0, after := 10) {
	lParam := x & 0xFFFF | (y & 0xFFFF) << 16

	Sleep, before
	PostMessage, 0x200, 0x00000000, %lParam%, , ahk_id %uid%
	Sleep, 10
	PostMessage, 0x201, 0x00000001, %lParam%, , ahk_id %uid%
	Sleep, 30
	PostMessage, 0x202, 0x00000000, %lParam%, , ahk_id %uid%
	Sleep, after
}

SendText(uid, value, before := 0, after := 10) {
	Sleep, before
	ControlSend, ahk_parent, {Text}%value%, ahk_id %uid%
	Sleep, after
}

SendKey(uid, value, before := 0, after := 10) {
	Sleep, before
	ControlSend, ahk_parent, %value%, ahk_id %uid%
	Sleep, after
}

GetProcessUids(processName) {
	_processes := []
	WinGet, processList, List, ahk_exe %processName%
	Loop, %processList%
	{
		uid := processList%A_Index%
		WinGet, pid, PID, ahk_id %uid%
		creationTime := GetProcessCreationTime(pid)
		WinGet, lastUid, IDLast, ahk_pid %pid%

		_processes[pid] := { "pid": pid, "uid": lastUid, "time": creationTime }
	}

	index := 1
	processes := []
	Loop, % _processes.Length()
	{
		process := _processes[A_Index]
		if (!process)
			continue

		processes[index] := process
		index++
	}

	return SortObjectArrayBy(processes, "time")
}

GetProcessCreationTime(pid) {
	handleProcess := DllCall("OpenProcess", UInt, 0x400, Int, 0, UInt, pid)
	DllCall("GetProcessTimes", UInt, handleProcess, Int64P, creationTime, Int64P, 0, Int64P, 0, Int64P, 0)
	DllCall("CloseHandle", UInt, handleProcess)

	DllCall("FileTimeToLocalFileTime", Int64P, creationTime, Int64P, LocalCreationTime)

	processCreationTime := 1601 ; year of starting range
	processCreationTime += % LocalCreationTime // 10000000, Seconds

	return processCreationTime
}

GetPixelColor(pc_wID, pc_x, pc_y)
{
	if pc_wID
	{
		pc_hDC := DllCall("GetDC", "UInt", pc_wID)
		pc_fmtI := A_FormatInteger
		SetFormat, IntegerFast, Hex

		pc_c := DllCall("GetPixel", "UInt", pc_hDC, "Int", pc_x, "Int", pc_y, "UInt")
		pc_c := pc_c >> 16 & 0xff | pc_c & 0xff00 | (pc_c & 0xff) << 16
		pc_c .= ""

		SetFormat, IntegerFast, %pc_fmtI%
		DllCall("ReleaseDC", "UInt", pc_wID, "UInt", pc_hDC)
		
		return pc_c
	}
}

SplitBGRColor(bgr, ByRef red, ByRef green, ByRef blue) {
	red   := bgr & 0xFF
	green := bgr >> 8 & 0xFF
	blue  := bgr >> 16 & 0xFF
}

SplitRGBColor(bgr, ByRef red, ByRef green, ByRef blue) {
	blue  := bgr & 0xFF
	green := bgr >> 8 & 0xFF
	red   := bgr >> 16 & 0xFF
}