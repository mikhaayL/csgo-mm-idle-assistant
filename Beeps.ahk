SuccessBeep() {
	SoundBeep, 2000, 100
	SoundBeep, 3000, 100
}

FailureBeep() {
	SoundBeep, 500, 500
}

ReadyBeep() {
	SoundBeep, 500, 100
	Sleep, 100
	SoundBeep, 500, 100
	SoundBeep, 500, 100
	Sleep, 30
	SoundBeep, 500, 100
	Sleep, 100
	SoundBeep, 500, 100
	Sleep, 300
	SoundBeep, 500, 100
	Sleep, 150
	SoundBeep, 500, 100
}

ReloadBeep() {
	SoundBeep, 1000, 50
	SoundBeep, 1500, 50
	SoundBeep, 2000, 50
}

ExitBeep() {
	SoundBeep, 1500, 100
	SoundBeep, 1500, 100
	SoundBeep, 1500, 100
}