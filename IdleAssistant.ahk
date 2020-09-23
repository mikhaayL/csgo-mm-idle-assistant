SetKeyDelay 0
SetMouseDelay 0

im := new IdleMaster()

*>#Enter::im.Play()
*>^End::im.StopNextMatch()
*>^Home::im.InsertSetup()

*>^PgDn::im.FindDerankGame()

*>^Up::im.ReconnectCycle(true)
*<#Up::im.DerankReconnectCycle()
*>^Down::im.CancelReconnectCycle()

*<#A::im.AcceptGame(im.team1)
*<#T::im.CreateTeam(im.team1)
*<#R::im.DisbandTeam(im.team1)
*<#Left::im.Disconnect(im.team1)
*<#Right::im.Reconnect(im.team1)

*>#A::im.AcceptGame(im.team2)
*>#T::im.CreateTeam(im.team2)
*>#R::im.DisbandTeam(im.team2)
*>#Left::im.Disconnect(im.team2)
*>#Right::im.Reconnect(im.team2)

*>^\::im.InsertLaunchOptions()

*<#Numpad1::im.ActivateGameWindows(im.team1)
*<#Numpad2::im.ActivateGameWindows(im.team2)

*<^Numpad0::im.team1[1].InsertIdentity()
*<^Numpad1::im.team1[2].InsertIdentity()
*<^Numpad2::im.team1[3].InsertIdentity()
*<^Numpad3::im.team1[4].InsertIdentity()
*<^Numpad4::im.team1[5].InsertIdentity()

*<^Numpad5::im.team2[1].InsertIdentity()
*<^Numpad6::im.team2[2].InsertIdentity()
*<^Numpad7::im.team2[3].InsertIdentity()
*<^Numpad8::im.team2[4].InsertIdentity()
*<^Numpad9::im.team2[5].InsertIdentity()

*<!Numpad0::im.team1[1].InsertIdentity(false)
*<!Numpad1::im.team1[2].InsertIdentity(false)
*<!Numpad2::im.team1[3].InsertIdentity(false)
*<!Numpad3::im.team1[4].InsertIdentity(false)
*<!Numpad4::im.team1[5].InsertIdentity(false)

*<!Numpad5::im.team2[1].InsertIdentity(false)
*<!Numpad6::im.team2[2].InsertIdentity(false)
*<!Numpad7::im.team2[3].InsertIdentity(false)
*<!Numpad8::im.team2[4].InsertIdentity(false)
*<!Numpad9::im.team2[5].InsertIdentity(false)

*<!S::im.RunSteamClients()

*>^F12::
	im.QuitAll()
	ExitApp
return

#Include, IdleMaster.ahk