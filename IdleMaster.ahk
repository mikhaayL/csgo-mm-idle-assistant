#Include, Defaults.ahk
#Include, Account.ahk
#Include, Beeps.ahk

SetKeyDelay 0

class IdleMaster {
	__New() {
		this.cycleToggle := false
		this.LoadLaunchOptions()
		this.LoadGameSettings()
		this.InitAccounts()
		this.SetupTeams()
		SuccessBeep()
	}

	LoadLaunchOptions() {
		FileReadLine, launchOptions, LaunchOptions.txt, 1
		this.launchOptions := launchOptions

		FileReadLine, startDelay, LaunchOptions.txt, 2
		this.startDelay := startDelay

		FileReadLine, teamLoadDelay, LaunchOptions.txt, 3
		this.teamLoadDelay := teamLoadDelay
	}

	LoadGameSettings() {
		this.gameSettings := []
		Loop, Read, GameSettings.txt
			this.gameSettings[A_Index] := A_LoopReadLine
	}

	LoadAccounts() {
		this.accounts    := []
		this.accounts[1] := []

		paramRows := 4
		paramIndex := 1
		accountIndex := 0
		Loop, Read, Accounts.txt
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

	InitAccounts() {
		this.LoadAccounts()
		Loop % this.accounts.Length()
		{
			login := this.accounts[A_Index][1]
			pass  := this.accounts[A_Index][2]
			code  := this.accounts[A_Index][3]
			setups := this.gameSettings

			account := new Account(login, pass, code, setups)
			this.accounts[A_Index] := account
		}

		this.SetupProcesses()
	}

	GetProcesses(processName) {
		_processes := []
		WinGet, processList, List, ahk_exe %processName%
		Loop, %processList%
		{
			uid := processList%A_Index%
			WinGet, pid, PID, ahk_id %uid%
			creationTime := GetProcessCreationTime(pid)
			WinGet, lastUid, IDLast, ahk_pid %pid%

			_processes[pid] := { "uid": lastUid, "time": creationTime }
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

	SetupProcesses() {
		gameProcesses := this.GetProcesses("csgo.exe")
		if (gameProcesses.Length() == 0)
			steamProcesses := this.GetProcesses("steam.exe")

		Loop, % this.accounts.Length()
		{
			this.accounts[A_Index].gameUid := gameProcesses[A_Index].uid
			this.accounts[A_Index].steamUid := steamProcesses[A_Index].uid
		}
	}

	SetupTeams() {
		this.team1 := []
		this.team2 := []

		size := 5
		index := 1
		length := size * 2
		While, index <= length {
			if (index > size)
				this.team2[index - size] := this.accounts[index]
			else
				this.team1[index] := this.accounts[index]

			index++
		}

		if (this.accounts[1].steamUid) {
			this.FormSteamLayout(this.team1)
			this.FormSteamLayout(this.team2)
		}
	}

	Play() {
		this.cycleToggle := true
		this.toNextMatch := true

		While, this.cycleToggle && this.toNextMatch {
			if (this.cycleToggle)
				this.FindGame()

			Sleep, this.startDelay

			if (this.cycleToggle)
				this.ReconnectCycle()
		}

		this.cycleToggle := false
		this.toNextMatch := false
	}

	ReconnectCycle(test := false) {
		if (test) {
			if (this.cycleToggle)
				return

			this.cycleToggle := true
		}

		round := 1
		rounds := 30
		While, round <= rounds && this.cycleToggle {
			this.PerformReconnectCycle(this.team2, round)
			this.PerformReconnectCycle(this.team1, round)
		}

		if (!this.cycleToggle)
			return

		Sleep, 5000
		this.Disconnect(this.team1)
		this.Disconnect(this.team2)
		Sleep, 5000

		if (test)
			this.cycleToggle := false
	}

	FirstReconnectCycle(team, ByRef round) {
		this.Disconnect(team)
		Sleep, 1000
		this.Reconnect(team)
		Sleep, 25000
		round++
	}

	PerformReconnectCycle(team, ByRef round) {
		if (round <= 2) {
			this.FirstReconnectCycle(team, round)
			return
		}

		this.Disconnect(team)
		Sleep, 25000 - this.teamLoadDelay
		round++

		if (!this.cycleToggle)
			return

		if (round == 16)
			Sleep, 7000

		this.Reconnect(team)
		Sleep, this.teamLoadDelay + 25000
		round++

		if (!this.cycleToggle)
			return
	}

	StopNextMatch() {
		this.toNextMatch := false
		SuccessBeep()
	}

	CancelReconnectCycle() {
		this.cycleToggle := false
		SuccessBeep()
	}

	InsertLaunchOptions() {
		SendInput -windowed -noborder -w 640 -h 480 -console
		Sleep, 100

		launchOptions := this.launchOptions
		SendInput {Text} %launchOptions%
		Sleep, 100

		SendInput {Enter}
	}

	InsertSetup() {
		this.FormGameLayout(this.team1)
		this.FormGameLayout(this.team2)

		Loop, % this.accounts.Length()
			this.accounts[A_Index].InsertSetup()

		this.team1[1].OpenFindGame()
		this.team2[1].OpenFindGame()

		SuccessBeep()
	}

	FindDerankGame() {
		this.CreateTeam(this.team1)
		this.team1[1].ClickFindGame()

		While, !this.HaveAccept(this.team1)
			Sleep, 100

		this.AcceptGame(this.team1)
		FindGameSuccessBeep()
	}

	DerankReconnectCycle() {
		this.cycleToggle := true

		round := 1
		rounds := 16
		While, round <= rounds && this.cycleToggle {
			this.Disconnect(this.team1)
			Sleep, 25000 - this.teamLoadDelay
			round++

			if (!this.cycleToggle)
				return

			if (round == 16)
				Sleep, 7000

			this.Reconnect(this.team1)
			Sleep, this.teamLoadDelay + 25000
			round++

			if (!this.cycleToggle)
				return
		}

		if (!this.cycleToggle)
			return

		Sleep, 5000
		this.Disconnect(this.team1)
		Sleep, 5000

		this.cycleToggle := false
	}

	FindGame() {
		if (this.cycleToggle)
			this.CreateTeam(this.team1)

		if (this.cycleToggle)
			this.CreateTeam(this.team2)

		this.team1[1].ClickFindGame()
		this.team2[1].ClickFindGame()

		readyTeam1 := false
		readyTeam2 := false
		While, !readyTeam1 && !readyTeam2 && this.cycleToggle {
			if (!readyTeam1 && this.HaveAccept(this.team1))
				readyTeam1 := true

			if (!readyTeam2 && this.HaveAccept(this.team2)) {
				if (!readyTeam1 && this.HaveAccept(this.team1))
					readyTeam1 := true

				readyTeam2 := true
			}
		}

		if (!this.cycleToggle)
			return

		if (readyTeam1 && readyTeam2) {
			FindGameSuccessBeep()

			this.AcceptGame(this.team1)
			this.AcceptGame(this.team2)

			return
		}

		if (readyTeam1 && !readyTeam2)
			this.team2[1].ClickFindGame()

		if (readyTeam2 && !readyTeam1)
			this.team1[1].ClickFindGame()

		this.RegroupTeams()
	}

	RegroupTeams() {
		FindGameFailureBeep()

		Sleep 25000

		if (!this.cycleToggle)
			return

		this.DisbandTeam(this.team1)
		this.DisbandTeam(this.team2)

		Sleep 25000

		if (!this.cycleToggle)
			return

		this.FindGame()
	}

	HaveAccept(team) {
		Loop, % team.Length()
			if (!team[A_Index].HaveAccept())
				return false

		return true
	}

	AcceptGame(team) {
		Loop, % team.Length()
			team[A_Index].ClickAccept()
	}

	FormGameLayout(team) {
		firstTeam := this.accounts[1].login == team[1].login

		team[2].MoveGame(0, 30)
		team[3].MoveGame(0, 540)

		team[1].MoveGame(640, firstTeam ? 30 : 540)

		team[4].MoveGame(1280, 30)
		team[5].MoveGame(1280, 540)
	}

	FormSteamLayout(team) {
		firstTeam := this.accounts[1].login == team[1].login
		y := firstTeam ? 30 : 540
		padding := 20
		Loop, % team.Length()
		{
			width := 300
			height := 300
			x := (A_Index * padding - padding) + (A_Index * width - width)
			team[A_Index].MoveSteam(x, y, width, height)
		}
	}

	ActivateGameWindows(team) {
		Loop, % team.Length()
			team[A_Index].ActivateGame()
	}

	CreateTeam(team) {
		this.SendInvites(team)
		team[1].OpenFindGame()
		this.AcceptInvites(team)
	}

	SendInvites(team) {
		Loop, % team.Length()
			if (A_Index > 1)
				team[1].SendInvite(team[A_Index].friendCode)
	}

	AcceptInvites(team) {
		Loop, % team.Length()
			if (A_Index > 1)
				team[A_Index].ToLobby()
	}

	DisbandTeam(team) {
		Loop, % team.Length() - 1
			team[A_Index].LeaveFromLobby()
	}

	Disconnect(team, mod := 0) {
		Loop, % team.Length() - mod
			team[A_Index].Disconnect()
	}

	Reconnect(team, mod := 0) {
		Loop, % team.Length() - mod
			team[A_Index].Reconnect()
	}

	RunSteamClients() {
		Loop, % this.accounts.Length()
		{
			Run, A:\Programs\Steam\Steam.exe
			Sleep, 1000
		}

		SuccessBeep()
	}

	QuitAll() {
		Loop, % this.accounts.Length()
			this.accounts[A_Index].CloseGame()

		Sleep, 2000

		Loop, % this.accounts.Length()
		{
			Process, Close, steam.exe
			Sleep, 300
		}
	}
}