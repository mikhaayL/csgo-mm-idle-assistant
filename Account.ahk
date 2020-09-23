#Include, Defaults.ahk
#Include, Beeps.ahk

SetKeyDelay 0
SetMouseDelay 0

class Account {
	__New(login, pass, code, setups) {
		this.login := login
		this.password := pass
		this.friendCode := code
		this.setups := setups
	}

	OpenFindGame() {
		if (!this.ActivateGame())
			return

		MouseClick, left, 22, 65 ; play button
		Sleep, 300

		MouseClick, left, 80, 80 ; competitive button
		Sleep, 100
	}

	ClickFindGame() {
		if (!this.ActivateGame())
			return

		MouseClick, left, 450, 460 ; competitive button
		Sleep, 50
	}

	SendInvite(code) {
		if (!this.ActivateGame())
			return

		this.OpenPanel()

		MouseClick, left, 620, 111 ; mail button
		Sleep 400

		MouseClick, left, 493, 139 ; add button
		Sleep 300

		MouseClick, left, 310, 231 ; click to input
		Sleep 200

		SendInput %code%

		Sleep 200
		MouseClick, left, 339, 231 ; submit
		Sleep 300

		MouseClick, left, 218, 251 ; open profile
		Sleep 300

		MouseClick, left, 430, 253 ; invite
		Sleep 300

		; MouseClick, left, 310, 231 ; close profile
		; Sleep 300

		MouseClick, left, 417, 295 ; close popup
		Sleep 300
	}

	ToLobby() {
		if (!this.ActivateGame())
			return

		this.OpenPanel()
		MouseClick, left, 618, 123
		Sleep 200
		MouseClick, left, 618, 123
		Sleep 200
	}

	LeaveFromLobby() {
		if (!this.ActivateGame())
			return

		this.OpenPanel()
		MouseClick, left, 621, 13
		Sleep 100
		MouseClick, left, 621, 43
		Sleep 100
	}

	OpenPanel() {
		this.ClickWatchTab()
		MouseClick, left, 630, 470
		Sleep 500
	}

	ClickWatchTab() {
		MouseClick, left, 21, 195
		Sleep, 300
		MouseClick, left, 124, 56
		Sleep, 100
	}

	Reconnect() {
		if (!this.ActivateGame())
			return

		MouseClick, left, 454, 26, 3
		Sleep, 100
	}

	Disconnect() {
		if (!this.ActivateGame())
			return

		Send {F4}
		Sleep, 50
		Send {F4}
		Sleep, 50
		Send {F4}
		Sleep, 50
	}

	HaveAccept() {
		if (!this.ActivateGame())
			return false

		PixelGetColor, acceptColor, 365, 258
		SplitBGRColor(acceptColor, red, green, blue) 

		return red < 100 && blue < 100 && green > 150
	}

	ClickAccept() {
		if (!this.ActivateGame())
			return

		MouseClick, left, 365, 258, 3
		Sleep, 100
	}

	InsertIdentity(useSteamProcess := true) {
		if (useSteamProcess) {
			if (!this.ActivateSteam())
				return

			MouseClick, left, 130, 100
			Sleep, 100
		}

		login := this.login
		SendInput {Text}%login%

		Sleep 100
		SendInput {Tab Down}
		Sleep 50
		SendInput {Tab Up}

		password := this.password
		SendInput {Text}%password%

		Sleep 50
		SendInput {Enter Down}
		Sleep 50
		SendInput {Enter Up}
	}

	InsertSetup() {
		if (!this.ActivateGame())
			return

		Loop, % this.setups.Length()
		{
			setups := this.setups[A_Index]
			SendInput {Text}%setups%
			SendInput {Enter}
			Sleep 50
		}

		SendInput bind "F4" "disconnect" {Enter}
		Sleep 50

		SendInput {Esc}
		Sleep, 50
	}

	ActivateGame() {
		if (!this.gameUid) {
			FailureBeep()
			return false
		}

		return this.Activate(this.gameUid)
	}

	ActivateSteam() {
		if (!this.steamUid) {
			FailureBeep()
			return false
		}

		return this.Activate(this.steamUid)
	}

	Activate(uid) {
		WinActivate ahk_id %uid%

		WaitForRelease()
		Sleep 100

		return true
	}

	MoveGame(x, y) {
		if (!this.gameUid)
			return

		gameUid := this.gameUid
		WinMove, ahk_id %gameUid%, , x, y
	}

	MoveSteam(x, y, width, height) {
		if (!this.steamUid)
			return

		steamUid := this.steamUid
		WinMove, ahk_id %steamUid%, , x, y, width, height
	}

	CloseGame() {
		if (!this.ActivateGame())
			return

		Send {``}
		Sleep, 100
		Send quit {Enter}
	}
}