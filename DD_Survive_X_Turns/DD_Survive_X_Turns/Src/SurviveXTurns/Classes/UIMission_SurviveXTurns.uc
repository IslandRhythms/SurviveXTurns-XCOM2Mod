class UIMission_SurviveXTurns extends UIMission_RescueSoldier;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	FindMission('MissionSource_SurviveXTurns');

	BuildScreen();
}

simulated function Name GetLibraryID()
{
	return 'XPACK_Alert_MissionBlades';
}

simulated function BuildMissionPanel()
{
	local XComGameState_ResistanceFaction FactionState;

	FactionState = GetMission().GetResistanceFaction();

	LibraryPanel.MC.BeginFunctionOp("UpdateMissionInfoBlade");
	LibraryPanel.MC.QueueString(m_strImageGreeble);
	LibraryPanel.MC.QueueString("");
	LibraryPanel.MC.QueueString(FactionState.GetFactionTitle());
	LibraryPanel.MC.QueueString(FactionState.GetFactionName());
	LibraryPanel.MC.QueueString(GetMissionImage());
	LibraryPanel.MC.QueueString(GetOpName());
	LibraryPanel.MC.QueueString(m_strMissionObjective);
	LibraryPanel.MC.QueueString(GetObjectiveString());
	LibraryPanel.MC.QueueString(m_strReward);
	LibraryPanel.MC.EndOp();
	
	LibraryPanel.MC.BeginFunctionOp("UpdateMissionReward");
	LibraryPanel.MC.QueueNumber(0);
	LibraryPanel.MC.QueueString(GetRewardString());
	LibraryPanel.MC.QueueString(""); // Rank Icon
	LibraryPanel.MC.QueueString(""); // Class Icon
	LibraryPanel.MC.EndOp();

	SetFactionIcon(FactionState.GetFactionIcon());
	
	Button1.OnClickedDelegate = OnLaunchClicked;
	Button2.OnClickedDelegate = OnCancelClicked;
	Button3.Hide();
	ConfirmButton.Hide();
}

//-------------- EVENT HANDLING --------------------------------------------------------

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function bool CanTakeMission()
{
	return true;
}
simulated function EUIState GetLabelColor()
{
	return eUIState_Normal;
}

//==============================================================================

defaultproperties
{
	InputState = eInputState_Consume;
	Package = "/ package/gfxXPACK_Alerts/XPACK_Alerts";
}
