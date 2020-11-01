#Include, Functions.ahk
#Include, Beeps.ahk
#Include, Sort.ahk

SuspendToggle := false

*>+Backspace::
	ReloadBeep()
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