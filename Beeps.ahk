#Include, Defaults.ahk

FindGameSuccessBeep() {
	SoundBeep, 1500, 100
	SoundBeep, 1500, 100
	SoundBeep, 1500, 100
}

FindGameFailureBeep() {
	SoundBeep, 500, 500
	SoundBeep, 500, 200
}

SuccessBeep() {
	SoundBeep, 2000, 100
	SoundBeep, 3000, 100
}

FailureBeep() {
	SoundBeep, 500, 500
}