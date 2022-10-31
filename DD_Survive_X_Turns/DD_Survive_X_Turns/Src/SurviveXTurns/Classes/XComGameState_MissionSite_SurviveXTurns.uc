// This is an Unreal Script

class XComGameState_MissionSite_SurviveXTurns extends XComGameState_MissionSite;

// copied from RM's Genji Redux and Iridar's Duke Nukem mod
// Copy ahoy!

function MissionSelected()
{
	local XComHQPresentationLayer Pres;
	local UIMission_SurviveXTurns kScreen;

	Pres = `HQPRES;

	// Show the lost towers mission
	if (!Pres.ScreenStack.GetCurrentScreen().IsA('UIMission_SurviveXTurns'))
	{
		kScreen = Pres.Spawn(class'UIMission_SurviveXTurns');
		kScreen.MissionRef = GetReference();
		Pres.ScreenStack.Push(kScreen);
	}

	if (`GAME.GetGeoscape().IsScanning())
	{
		Pres.StrategyMap2D.ToggleScan();
	}
}


function string GetUIButtonIcon()
{
	//	2d nuke logo at the bottom of the screen in the points-of-interest list
	// return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Advent";
	// return "img:///UILibrary_StrategyImages.X2StrategyMap.MissionIcon_Retaliation"
	return "img:///UILibrary_XPack_Common.MissionIcon_ResOps";
}
