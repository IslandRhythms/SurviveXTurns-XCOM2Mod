// This is an Unreal Script

class X2StrategyElement_Rewards_SurviveXTurns extends X2StrategyElement_DefaultRewards dependson(X2RewardTemplate) config(GameData);

var config int MinPrisonBreakDuration;
var config int MaxPrisonBreakDuration;
var config int RequiredForceLevel;

var config int CapturedUnitThreshold;
var config int ChanceForChosenCapturedSoldier;
var config int ChanceForADVENTCapturedSoldier;
var config int ChanceForRandomHighRankSoldier;
var config int ChanceForRandomRookie;
var config int ChanceForRandomFactionSoldier;
var config int ChanceForRandomScientist;
var config int ChanceForRandomEngineer;
var config int ChanceForReward;
var config bool bEnableRewardChanceForStandardMission;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	//Missions
	Rewards.AddItem(CreateSurviveXTurnsMissionRewardTemplate());

	return Rewards;
}

static function X2DataTemplate CreateSurviveXTurnsMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2RewardTemplate', Template, 'Reward_Mission_SurviveXTurns');

	Template.GiveRewardFn = GiveRescueSoldierReward;
	Template.GetRewardStringFn = GetMissionRewardString;
	Template.RewardPopupFn = MissionRewardPopup;
	Template.IsRewardAvailableFn = IsSurviveXTurnsMissionAvailable;

	return Template;
}

//
// Prison Break - Reward - Rescue Soldier Mission
// --------------------------------------------------
static function bool IsSurviveXTurnsMissionAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameStateHistory						History;
	local XComGameState_CovertAction				ActionState;
	local XComGameState_HeadquartersAlien			AlienHQ;
	local XComGameState_CampaignSettings			CampaignSettings;
	local XComGameState_MissionSite					MissionState;

	History = `XCOMHISTORY;
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	//Disable this reward until Mox is rescued to prevent duplication bugs.
	CampaignSettings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	
	if ( CampaignSettings.bXPackNarrativeEnabled && !class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('XP0_M4_RescueMoxComplete') )
	{
		`log("["$ default.class $ "::" $ GetFuncName() $ "] XPACK Narrative is enabled and the player hasn't rescued Mox, not spawning", true, 'WotC_Mission_PrisonBreak');
		return false;
	}


	if(AlienHQ.GetForceLevel() < default.RequiredForceLevel)
	{
		`log("["$ default.class $ "::" $ GetFuncName() $ "] Force Level " $ AlienHQ.GetForceLevel() $ " does not meet minimum: " $ default.RequiredForceLevel, true, 'WotC_Mission_PrisonBreak');
		return false;
	}

	//Disable spawning this reward if an existing mission of this type already exists
	foreach History.IterateByClassType(class'XComGameState_MissionSite', MissionState)
	{
		if (MissionState.Source == 'MissionSource_SurviveXTurns')
		{
			`log("["$ default.class $ "::" $ GetFuncName() $ "] Mission State " $ MissionState.ObjectID $ " exists: " $ MissionState.Source, true, 'WotC_Mission_PrisonBreak');
			return false;
		}

	}

	// Only one can exist at one time
	foreach History.IterateByClassType(class'XComGameState_CovertAction', ActionState)
	{
		if(ActionState.GetMyTemplateName() == 'CovertAction_SurviveXTurnsMission' && (ActionState.bStarted)) //this is dumb but we have to account for this
		{
			`log("["$ default.class $ "::" $ GetFuncName() $ "] Covert Action: " $ ActionState.GetMyTemplateName() $ " already exists. bStarted: " $ ActionState.bStarted, true, 'WotC_Mission_PrisonBreak');
			return false;
		}

	}

	`log("["$ default.class $ "::" $ GetFuncName() $ "] Successfully cleared all conditions!", true, 'WotC_Mission_PrisonBreak');

	return true;
}

static function GiveRescueSoldierReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_MissionSite					MissionState;
	local XComGameState_WorldRegion					RegionState;
	local XComGameState_Reward						MissionRewardState;
	local XComGameState_CovertAction				ActionState;
	local X2RewardTemplate							RewardTemplate;
	local X2StrategyElementTemplateManager			StratMgr;
	local X2MissionSourceTemplate					MissionSource;
	local array<XComGameState_Reward>				MissionRewards;
	local array<XComGameState_WorldRegion>			ContactRegions;
	local XComGameState_AdventChosen				ChosenState;
	local XComGameState_HeadquartersAlien			AlienHQ;
	local XComGameStateHistory						History;
	local XComGameState_HeadquartersResistance		ResHQ;

	local int										IteratorCapturedUnitsChosen;
	local int										MaxNumberOfPrisoners;

	local float										MissionDuration;
	local int										i, index;
	local string									PrisonerTag;


	History = `XCOMHISTORY;
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ActionState = XComGameState_CovertAction(`XCOMHISTORY.GetGameStateForObjectID(AuxRef.ObjectID));
	RegionState = ActionState.GetWorldRegion();

	if(RegionState == none)
	{
		foreach `XCOMHistory.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
		{
			ContactRegions.AddItem(RegionState);
		}
		RegionState = ContactRegions[`SYNC_RAND_STATIC(ContactRegions.Length)];
	}

	//Firstly, get the max number of captured soldiers by one particular Chosen Faction or ADVENT
	ChosenState = ActionState.GetFaction().GetRivalChosen();
	AlienHQ = XComGameState_HeadquartersAlien(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));

	//Reset Mission Rewards
	MissionRewards.Length = 0;

	//Set the first reward as the intel reward, because it's Objective 0
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Intel'));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference()); // Give Intel
	MissionRewards.AddItem(MissionRewardState);
		while (MissionRewards.Length < 7)
		{
			if (`SYNC_RAND_STATIC(100) < default.ChanceForRandomHighRankSoldier)
			{
				RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Soldier'));
				MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference()); // Give High Ranking Soldier
				MissionRewards.AddItem(MissionRewardState);
			}
			else if (`SYNC_RAND_STATIC(100) < default.ChanceForRandomFactionSoldier)
			{
				RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_ExtraFactionSoldier'));
				MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference()); // Give Faction Soldier
				MissionRewards.AddItem(MissionRewardState);
			}
			else if (`SYNC_RAND_STATIC(100) < default.ChanceForRandomScientist)
			{
				RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Scientist'));
				MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference()); // Give Scientist
				MissionRewards.AddItem(MissionRewardState);
			}
			else if (`SYNC_RAND_STATIC(100) < default.ChanceForRandomEngineer)
			{
				RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Engineer'));
				MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference()); // Give Engineer
				MissionRewards.AddItem(MissionRewardState);
			} else {
				RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Soldier'));
				MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				MissionRewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState), RegionState.GetReference()); // Give High Ranking Soldier
				MissionRewards.AddItem(MissionRewardState);
			}
		}
	//
	//END STANDARD MISSION
	//

	//Calculate Duration
	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);


	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_SurviveXTurns'));

	MissionState = XComGameState_MissionSite_SurviveXTurns(NewGameState.CreateNewStateObject(class'XComGameState_MissionSite_SurviveXTurns'));
	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	// Set this mission as associated with the Faction whose Covert Action spawned it
	MissionState.ResistanceFaction = ActionState.Faction;

	// Then overwrite the reward reference so the mission is properly awarded when the Action completes
	RewardState.RewardObjectReference = MissionState.GetReference();

	`XEVENTMGR.TriggerEvent('SurviveMissionSpawned', , , NewGameState);
}

