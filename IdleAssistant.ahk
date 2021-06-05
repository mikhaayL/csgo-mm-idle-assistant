SetKeyDelay, 0
SetMouseDelay, 0
SetDefaultMouseSpeed, 0
SetWinDelay, 0

accountsPath := A_Args[1]
im := new IdleMaster(accountsPath)

*<!Enter::im.RunClients(true)
*>!Enter::im.Run()					; Steam clients launch and game loop launch

*>#Enter::im.Play()					; Game loop launch (withot increased delay for first game)
*>#>^Enter::im.Play(false, true)	; Game loop launch (with increased delay for first game)
*>#>+Enter::im.Play(true)			; Game loop launch in the game

*>^Down::im.CancelReconnectCycle()	; Canceling game loop
*>#End::im.StopNextMatch()			; Will complete the game loop after the current match

*>^Home::im.InsertSetups()

*>#Up::im.ActivateAll()
*>#Left::im.team1.ActivateWindows()
*>#Right::im.team2.ActivateWindows()

*<#A::im.team1.AcceptGame()
*>#A::im.team2.AcceptGame()

*<#R::im.team1.CreateTeam()
*>#R::im.team2.CreateTeam()

*<#D::im.team1.DisbandTeam()
*>#D::im.team2.DisbandTeam()

*<#.::im.team1.Reconnect()
*>#.::im.team2.Reconnect()

*<#,::im.team1.Disconnect()
*>#,::im.team2.Disconnect()

*>!,::
	im.team1.Disconnect()
	Sleep, 100
	im.team1.Reconnect()
Return

*Pause::
Process, Close, csgo.exe
Sleep, 500
Process, Close, steam.exe
Sleep, 100
return

*>!.::
	im.team2.Disconnect()
	Sleep, 100
	im.team2.Reconnect()
Return

*>^F12::im.Quit()

*<^Numpad0::im.RunClient(1, true)
*<^Numpad1::im.RunClient(2, true)
*<^Numpad2::im.RunClient(3, true)
*<^Numpad3::im.RunClient(4, true)
*<^Numpad4::im.RunClient(5, true)
*<^Numpad5::im.RunClient(6, true)
*<^Numpad6::im.RunClient(7, true)
*<^Numpad7::im.RunClient(8, true)
*<^Numpad8::im.RunClient(9, true)
*<^Numpad9::im.RunClient(10, true)

*>^Numpad0::im.RunClient(1, false)
*>^Numpad1::im.RunClient(2, false)
*>^Numpad2::im.RunClient(3, false)
*>^Numpad3::im.RunClient(4, false)
*>^Numpad4::im.RunClient(5, false)
*>^Numpad5::im.RunClient(6, false)
*>^Numpad6::im.RunClient(7, false)
*>^Numpad7::im.RunClient(8, false)
*>^Numpad8::im.RunClient(9, false)
*>^Numpad9::im.RunClient(10, false)

#Include, IdleMaster.ahk