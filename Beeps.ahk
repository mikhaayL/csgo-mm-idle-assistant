SuccessBeep() {
	SoundBeep, 1000, 100
	SoundBeep, 2000, 100
	SoundBeep, 2000, 100
}

FailureBeep() {
	SoundBeep, 500, 200
	SoundBeep, 500, 100
}

ReadyBeep() {
	SoundBeep, 600, 100
	Sleep, 100
	SoundBeep, 500, 100
	SoundBeep, 500, 100
	Sleep, 30
	SoundBeep, 500, 100
	Sleep, 100
	SoundBeep, 500, 100
	Sleep, 300
	SoundBeep, 600, 100
	Sleep, 150
	SoundBeep, 700, 100
}

ReloadBeep() {
	SoundBeep, 500, 50
	SoundBeep, 750, 50
	SoundBeep, 999, 50
}

ExitBeep() {
	SoundBeep, 1500, 100
	SoundBeep, 1250, 125
	SoundBeep, 1000, 150
}