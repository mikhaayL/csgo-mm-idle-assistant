class Account {
	__New(login, pass, code, secret, steamLaunchOptions, gamelaunchOptions, layout, steamGuard, steamPath) {
		this.login := login
		this.password := pass
		this.friendCode := code
		this.secret := secret
		this.steamLaunchOptions := steamLaunchOptions
		this.gamelaunchOptions := gamelaunchOptions
		this.layout := layout
		this.steamGuard := steamGuard
		this.steamPath := steamPath
	}

	GetSteamArguments(pure := false) {
		credential := this.login . " " . this.password
		launchOptions := " -login " . credential

		if (!pure)
			launchOptions .= " " . this.steamLaunchOptions

		return launchOptions
	}

	GetSteamAppArguments() {
		launchOptions := " -applaunch 730"
		launchOptions .= " -windowed -noborder -w 640 -h 480 -console"
		launchOptions .= " " . this.gamelaunchOptions

		coordinates   := this.layout
		launchOptions .= " " . coordinates

		return launchOptions
	}

	GetTfaCode(timeIndent) {
		if (!this.secret)
			return

		return this.steamGuard.GetTfaCode(this.secret, timeIndent)
	}

	RunClient(pure := false, after := 5) {
		launchOptions := this.GetSteamArguments(pure)
		if (!pure)
			launchOptions .= this.GetSteamAppArguments()

		runArgs := this.steamPath
		runArgs .= " " . launchOptions
		Run, %runArgs%, , , pid

		timeIndent := 5
		While, timeIndent >= 0
		{
			tfaCode := this.GetTfaCode(timeIndent--)

			passed := true
			if (tfaCode && this.EnterTfaCodeToClient(pid, tfaCode)) {
				errorWindow := "Steam - Error"
				WinWait, %errorWindow%, , after
				if ErrorLevel
					break

				RunWait, taskkill /F /PID %pid%
				Sleep, 2000
				Run, %runArgs%, , , pid
			}
		}
	}

	EnterTfaCodeToClient(pid, tfaCode) {
		tfaWindow := "Steam Guard - Computer Authorization Required"

		WinWait, %tfaWindow%
		Sleep, 100

		WinGet, uid, IDLast, ahk_pid %pid%
		WinActivate, ahk_id %uid%
		SendText(uid, tfaCode, 10, 10)
		SendKey(uid, "{Enter}", , 1000)

		return !WinExist(tfaWindow)
	}

	ManualSignIn() {
		login := this.login
		pass := this.password
		tfaCode := this.GetTfaCode(0)

		SendInput, {Text}%login%
		Sleep, 50
		SendInput, {Tab Down}
		Sleep, 10
		SendInput, {Tab Up}
		Sleep, 50
		SendInput, {Text}%pass%
		Sleep, 50
		SendInput, {Enter Down}
		Sleep, 10
		SendInput, {Enter Up}
		Sleep, 500

		SendInput, {Text}%tfaCode%
		Sleep, 50
		SendInput, {Enter Down}
		Sleep, 10
		SendInput, {Enter Up}
		Sleep, 1000
	}

	OpenPanel() {
		MouseClick(this.uid,  20,  20, , 50)
		MouseClick(this.uid, 630, 470, , 50)
	}

	OpenFindGame() {
		this.OpenPanel()
		MouseClick(this.uid, 22, 65, 300, 500) ; play button
		MouseClick(this.uid, 80, 80, , 50)  ; competitive button
	}

	ClickFindGame(state := true) {
		SoundBeep, 500, 100
		findGameButtonColor := GetPixelColor(this.uid, 455, 458)
		SplitRGBColor(findGameButtonColor, red, green, blue)

		if (state && red < 40 || !state && red > 40)
		{
			MouseClick(this.uid, 455, 458, , 50) ; start play button
			return true
		}

		return false
	}

	SendInvite(code) {
		this.OpenPanel()

		MouseClick(this.uid, 620, 121, 300, 150) ; mail button
		MouseClick(this.uid, 493, 150, , 150) ; add button

		MouseClick(this.uid, 250, 230, , 50)  ; click to input
		SendText(this.uid, code, , 100)
		MouseClick(this.uid, 355, 231, , 300) ; submit

		inviteTitleColor := GetPixelColor(this.uid, 210, 176)
		SplitRGBColor(inviteTitleColor, red, green, blue)

		if (red > 50) {
			MouseClick(this.uid, 233, 250, , 300) ; open profile
			MouseClick(this.uid, 445, 250, , 300) ; invite
		}

		MouseClick(this.uid, 400, 295, , 100) ; close popup

		if (red < 50)
			this.SendInvite(code)
	}

	LobbyIsFull() {
		if (!this.uid)
			return false

		lobbyColor := GetPixelColor(this.uid, 638, 180)
		SplitRGBColor(lobbyColor, red, green, blue)

		if (blue < 50)
			return false

		Sleep, 100
		lobbyColor := GetPixelColor(this.uid, 638, 180)
		SplitRGBColor(lobbyColor, red, green, blue)

		return blue > 50
	}

	ToLobby() {
		this.OpenPanel()
		MouseClick(this.uid, 615, 135, 300)
	}

	LeaveFromLobby() {
		this.OpenPanel()
		MouseClick(this.uid, 620, 13, 300, 50)
		MouseClick(this.uid, 620, 43, , 50)
	}

	HasAccept() {
		if (!this.uid)
			return false

		acceptColor := GetPixelColor(this.uid, 278, 263)
		SplitRGBColor(acceptColor, red, green, blue)

		return red < 100 && blue < 100 && green > 150
	}

	ClickAccept() {
		MouseClick(this.uid, 278, 263)
	}

	InsertSetup(setups) {
		Loop, % setups.Length()
		{
			row := setups[A_Index]
			SendText(this.uid, row)
			SendKey(this.uid, "{Enter}", , 50)
		}

		SendText(this.uid, "bind ""F4"" ""disconnect""")
		SendKey(this.uid, "{Enter}", , 50)

		SendText(this.uid, "bind ""F7"" ""toggleconsole""")
		SendKey(this.uid, "{Enter}", , 50)

		SendText(this.uid, "bind ""F8"" ""quit""")
		SendKey(this.uid, "{Enter}", , 50)

		SendKey(this.uid, "{Esc}")
		SendKey(this.uid, "{Esc}", 100, 50)
	}

	Reconnect() {
		MouseClick(this.uid, 435, 270)
		MouseClick(this.uid, 450, 37)
	}

	Disconnect() {
		SendKey(this.uid, "{F4}")
	}

	CloseGame() {
		SendKey(this.uid, "{F7}")
		SendKey(this.uid, "{F8}", 200, 200)
	}

	Activate(beep := true) {
		if (!this.uid) {
			if (beep)
				FailureBeep()

			return false
		}

		uid := this.uid
		WinActivate, ahk_id %uid%

		return true
	}
}