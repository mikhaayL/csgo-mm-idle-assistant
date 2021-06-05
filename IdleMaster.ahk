#Include, Defaults.ahk
#Include, Account.ahk
#Include, Team.ahk

class SteamGuard {
	__New(tfaGenerateCodeUrl) {
		this.tfaGenerateCodeUrl := tfaGenerateCodeUrl
	}

	GetTfaCode(secret, timeIndent) {
		data := Format("{ ""secret"": ""{:s}"", ""time_indent"": {:d} }", secret, timeIndent)

		request := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		request.Open("POST", this.tfaGenerateCodeUrl)
		request.Send(data)
		request.WaitForResponse()

		return request.ResponseText
	}
}

class ActionWrapper {
	Before(block := false) {
		this.BeforeActionBeep()

		if (block)
			BlockInput, On

		WinGet, uid, ID, A
		MouseGetPos, x, y

		this.window := uid
		this.mouseX := x
		this.mouseY := y
	}

	After(block := false) {
		uid := this.window
		x   := this.mouseX
		y   := this.mouseY

		WinActivate, ahk_id %uid%
		MouseMove, x, y, 0

		if (block) {
			BlockInput, Off
			this.ReleasePressedKeys()
		}

		this.AfterActionBeep()
	}

	ReleasePressedKeys() {
		Loop, 0xFF
			if GetKeyState(key := Format("VK{:X}", A_Index))
				SendInput, {%key% up}
	}

	BeforeActionBeep() {
		SoundBeep, 1000, 100
	}

	AfterActionBeep() {
		SoundBeep, 500, 100
	}
}

class IdleMaster {
	__New(path) {
		this.actionWrapper := new ActionWrapper()
		this.cycleToggle := false
		this.LoadLaunchOptions()
		this.LoadGameSettings()
		this.LoadLayout()
		this.InitAccounts(path)
		SuccessBeep()
	}

	LoadLaunchOptions() {
		launchOptions := []
		Loop, Read, LaunchOptions.txt
			launchOptions[A_Index] := A_LoopReadLine

		this.steamLaunchOptions := launchOptions[1]
		this.gamelaunchOptions := launchOptions[2]
		this.steamGuard := new SteamGuard(launchOptions[3])
		this.steamPath := launchOptions[4]
		this.warmup := launchOptions[5]
		this.teamLoadDelay := launchOptions[6]
		this.beforeRoundDelay := launchOptions[7]
		this.afterRoundDelay := launchOptions[8]
		this.halfMatchDelay  := launchOptions[9]
		this.additionalDelay := launchOptions[10]

		this.disconnectDelay := this.afterRoundDelay
		this.disconnectDelay += this.beforeRoundDelay
		this.disconnectDelay += this.additionalDelay
		this.disconnectDelay -= this.teamLoadDelay

		this.reconnectDelay := this.afterRoundDelay
		this.reconnectDelay += this.beforeRoundDelay
		this.reconnectDelay += this.additionalDelay
		this.reconnectDelay += this.teamLoadDelay
	}

	LoadGameSettings() {
		this.gameSettings := []
		Loop, Read, GameSettings.txt
			this.gameSettings[A_Index] := A_LoopReadLine
	}

	LoadLayout() {
		this.layout := []
		Loop, Read, Layout.txt
			this.layout[A_Index] := A_LoopReadLine
	}

	LoadAccounts(path) {
		this.accounts    := []
		this.accounts[1] := []

		paramRows  := 5
		paramIndex := 1
		Loop, Read, %path%
		{
			accountIndex := Floor(A_Index / paramRows) + 1

			this.accounts[accountIndex][paramIndex] := A_LoopReadLine
			paramIndex++

			If (paramIndex == paramRows)
				continue

			If (paramIndex > paramRows) {
				this.accounts[accountIndex] := []
				paramIndex := 1
			}
		}
	}

	InitAccounts(path) {
		this.LoadAccounts(path)
		Loop % this.accounts.Length()
		{
			login  := this.accounts[A_Index][1]
			pass   := this.accounts[A_Index][2]
			code   := this.accounts[A_Index][3]
			secret := this.accounts[A_Index][4]

			account := new Account(login, pass, code, secret, this.steamLaunchOptions, this.gamelaunchOption, this.layout[A_Index], this.steamGuard, this.steamPath)
			this.accounts[A_Index] := account
		}

		this.SetupProcesses()
		this.SetupTeams()
	}

	SetupProcesses() {
		gameProcesses := GetProcessUids("csgo.exe")
		steamProcesses := GetProcessUids("steam.exe")
		this.launched := gameProcesses.Length() > 0

		Loop, % this.accounts.Length()
			this.accounts[A_Index].uid := gameProcesses[A_Index].uid

		Loop, % this.accounts.Length()
			this.accounts[A_Index].steamPid := steamProcesses[A_Index].pid
	}

	SetupTeams() {
		this.team1 := []
		this.team2 := []

		size   := 5
		index  := 1
		length := size * 2
		While, index <= length {
			if (index > size)
				this.team2[index - size] := this.accounts[index]
			else
				this.team1[index] := this.accounts[index]

			index++
		}

		this.team1 := new Team(this.team1)
		this.team2 := new Team(this.team2)
	}

	Sleep(duration) {
		passed := 0
		delay  := 500

		While, (passed + delay) < duration {
			if (!this.cycleToggle)
				return

			Sleep, delay
			passed += delay
		}

		Sleep, duration - passed
	}

	Play(inGame := false, firstGame := false) {
		this.cycleToggle := true
		this.toNextMatch := true

		delay := this.warmup
		delay += this.afterRoundDelay
		delay += this.beforeRoundDelay
		delay += this.additionalDelay

		delay += this.teamLoadDelay * 2

		if (!inGame) {
			this.FindGame()
			additionalDelay := 0
			if (firstGame)
				additionalDelay := this.teamLoadDelay * 2

			this.Sleep(delay + additionalDelay)
		}

		While, this.cycleToggle && this.toNextMatch {
			this.ReconnectCycle()
			this.FindGame()
			this.Sleep(delay)
		}

		if (this.cycleToggle && !this.toNextMatch)
			this.Quit()

		this.cycleToggle := false
		this.toNextMatch := false
	}

	ReconnectCycle() {
		round  := 1
		rounds := 30
		While, round <= rounds && this.cycleToggle {
			if (round > 15) {
				this.PerformReconnectCycle(this.team1, round)
			} else {
				this.PerformReconnectCycle(this.team2, round)
			}
		}

		if (!this.cycleToggle)
			return

		this.team1.Disconnect()
		this.team2.Disconnect()
	}

	PerformReconnectCycle(team, ByRef round) {
		team.Disconnect()
		round++
		Sleep, 500
		team.Reconnect()

		this.Sleep(this.teamLoadDelay)
		if (round < 7 || round > 15 && round < 20)
			return

		round++
		this.Sleep(this.afterRoundDelay)

		if (round == 16)
			this.Sleep(this.halfMatchDelay)
	}

	StopNextMatch() {
		this.toNextMatch := false
		SuccessBeep()
	}

	CancelReconnectCycle() {
		this.cycleToggle := false
		SuccessBeep()
	}

	InsertSetups() {
		this.SetupProcesses()

		Loop, % this.accounts.Length()
		{
			this.accounts[A_Index].InsertSetup(this.gameSettings)
			Sleep, 1000
		}

		Sleep, 100
		SuccessBeep()
		this.ActivateAll()
	}

	FindGame() {
		found := false
		While, !found {
			found := this.FindGameCycle()
		}
	}

	CreateTeams() {
		this.team1.CreateTeam()
		this.team2.CreateTeam()

		Sleep, 500
	}

	FindGameCycle() {
		this.CreateTeams()

		While, !this.team1.ClickFindGame(true) || !this.team2.ClickFindGame(true)
			this.Sleep(1000)

		readyTeam1 := false
		readyTeam2 := false
		While, !readyTeam1 && !readyTeam2 && this.cycleToggle {
			if (!readyTeam1 && this.team1.HasAccept())
				readyTeam1 := true

			if (!readyTeam2 && this.team2.HasAccept()) {
				if (!readyTeam1 && this.team1.HasAccept())
					readyTeam1 := true

				readyTeam2 := true
			}
		}

		if (!this.cycleToggle)
			return true

		if (readyTeam1 && readyTeam2) {
			this.team1.AcceptGame()
			this.team2.AcceptGame()

			return true
		}

		this.RegroupTeams(readyTeam1, readyTeam2)

		return false
	}

	RegroupTeams(readyTeam1, readyTeam2) {
		if (readyTeam1 && !readyTeam2) {
			this.team2.ClickFindGame(false)
			this.AwaitToRegroup(this.team1)
		}

		if (readyTeam2 && !readyTeam1) {
			this.team1.ClickFindGame(false)
			this.AwaitToRegroup(this.team2)
		}

		this.DisbandTeams()
	}

	AwaitToRegroup(team) {
		team.AcceptGame(5)

		While, % team.HasAccept(1)
			Sleep, 1000

		team.ClickFindGame(false)
	}

	DisbandTeams() {
		this.team1.DisbandTeam()
		this.team2.DisbandTeam()

		this.Sleep(30000)
		if (!this.cycleToggle)
			return
	}

	Run() {
		; if (this.launched)
		; 	return

		SoundBeep, 900, 100
		this.RunClients()
		this.InsertSetups()
		ReadyBeep()
		this.Play(false, true)
	}

	RunClients(pure := false) {
		this.actionWrapper.Before()

		Loop, % this.accounts.Length()
			this.accounts[A_Index].RunClient(pure, 10)

		if (!pure) {
			SoundBeep, 500, 200
			Sleep, 20000
			SoundBeep, 1000, 100
			SoundBeep, 1000, 100
		}

		this.actionWrapper.After()
	}

	RunClient(index, pure := false, after := 0) {
		this.accounts[index].RunClient(pure, 10)
	}

	ActivateAll() {
		this.actionWrapper.Before()
		Sleep, 500

		Loop, % this.accounts.Length()
			this.accounts[A_Index].Activate()

		Sleep, 3000
		this.actionWrapper.After()
	}

	Quit() {
		SoundBeep, 1000, 100

		Loop, % this.accounts.Length()
			this.accounts[A_Index].CloseGame()

		if (this.launched)
			Sleep, 2000

		Loop, % this.accounts.Length() * 2
		{
			Process, Close, csgo.exe
			Sleep, 200
			Process, Close, steam.exe
			Sleep, 100
		}

		ExitBeep()
		ExitApp
	}
}