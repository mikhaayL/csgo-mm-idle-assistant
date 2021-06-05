#Include, Functions.ahk
#Include, Beeps.ahk
#Include, Sort.ahk

SuspendToggle := false

*>+Backspace::
	ReloadBeep()
	try
	{
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart %1%
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %1%
	}

	ExitApp
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