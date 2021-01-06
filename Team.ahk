class Team {
	__New(accounts) {
		this.accounts := accounts
		this.leader := 1
	}

	OpenFindGame() {
		this.accounts[this.leader].OpenFindGame()
	}

	ClickFindGame(state := true) {
		return this.accounts[this.leader].ClickFindGame(state)
	}

	HasAccept(index := 0) {
		if (index)
			return this.accounts[index].HasAccept()

		Loop, % this.accounts.Length()
			if (!this.accounts[A_Index].HasAccept())
				return false

		Sleep, 1000
		return true
	}

	AcceptGame(index := 0) {
		if (index)
			return this.accounts[index].ClickAccept()

		Loop, % this.accounts.Length()
			this.accounts[A_Index].ClickAccept()
	}

	CreateTeam() {
		this.SendInvites()
		this.OpenFindGame()
		this.AcceptInvites()

		retries := 30
		Loop, % retries {
			if (this.LobbyIsFull())
				break

			Sleep, 500
		}

		if (!this.LobbyIsFull()) {
			this.DisbandTeam()
			this.CreateTeam()
		}
	}

	SendInvites() {
		leader := this.accounts[this.leader]
		Loop, % this.accounts.Length()
			if (A_Index != this.leader)
				leader.SendInvite(this.accounts[A_Index].friendCode)
	}

	AcceptInvites() {
		Loop, % this.accounts.Length()
			if (A_Index != this.leader)
				this.accounts[A_Index].ToLobby()
	}

	LobbyIsFull() {
		return this.accounts[this.leader].LobbyIsFull()
	}

	DisbandTeam() {
		Loop, % this.accounts.Length() - 1
			this.accounts[A_Index].LeaveFromLobby()
	}

	Disconnect() {
		Loop, % this.accounts.Length()
			this.accounts[A_Index].Disconnect()
	}

	Reconnect() {
		Loop, % this.accounts.Length()
			this.accounts[A_Index].Reconnect()

		Sleep, 500

		Loop, % this.accounts.Length()
			this.accounts[A_Index].Reconnect()
	}

	ActivateWindows() {
		Loop, % this.accounts.Length()
			this.accounts[A_Index].Activate()
	}
}