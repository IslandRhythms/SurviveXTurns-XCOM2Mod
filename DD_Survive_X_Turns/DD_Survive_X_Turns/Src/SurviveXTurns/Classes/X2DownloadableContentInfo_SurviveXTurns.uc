//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_SurviveXTurns.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_SurviveXTurns extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

exec function SpawnCovertAction(name TemplateName, optional bool bForce = true, optional name FactionTemplateName = '')
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_ResistanceFaction FactionState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionTemplate ActionTemplate;
	local array<name> ActionExclusionList;

	History = `XCOMHISTORY;
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate(TemplateName));

	if (ActionTemplate == none)
	{
		`REDSCREEN("Cannot execute SpawnCovertAction cheat - invalid template name");
		return;
	}

	// Find first faction
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionTemplateName == '' || FactionState.GetMyTemplateName() == FactionTemplateName)
		{
			break;
		}
	}

	if (FactionState == none)
	{
		class'Helpers'.static.OutputMsg("Cannot execute SpawnCovertAction cheat - invalid faction template name");		
		return;
	}

	// Test if we can even use this covert action
	if (!bForce && !ActionTemplate.AreActionRewardsAvailable(FactionState, NewGameState))
	{
		class'Helpers'.static.OutputMsg("Covert Action: " $ TemplateName $ " does not meet requirements!");		
		return;
	}


	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: CreateCovertAction" @ TemplateName);

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(FactionState.Class, FactionState.ObjectID));

	FactionState.AddCovertAction(NewGameState, ActionTemplate, ActionExclusionList);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

exec function ForceRefreshCovertActions()
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_ResistanceFaction FactionState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2CovertActionTemplate ActionTemplate;
	local array<name> ActionExclusionList;

	History = `XCOMHISTORY;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: ForceRefreshCovertActions");

	// Iterate through each faction and refresh their Covert Action list
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(FactionState.Class, FactionState.ObjectID));
		FactionState.CleanUpFactionCovertActions(NewGameState);
		FactionState.CreateGoldenPathActions(NewGameState);
		FactionState.GenerateCovertActions(NewGameState, ActionExclusionList);
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	class'Helpers'.static.OutputMsg("Covert Actions successfully regenerated!");		
}

