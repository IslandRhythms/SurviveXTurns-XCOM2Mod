// This is an Unreal Script
class X2StrategyElement_MissionSource_SurviveXTurns extends X2StrategyElement_DefaultMissionSources config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;

	MissionSources.AddItem(CreateSurviveXTurnsTemplate());

	return MissionSources;
}

// Survive X Turns
//---------------------------------------------------------------------------------------
static function X2DataTemplate CreateSurviveXTurnsTemplate()
{
	local X2MissionSourceTemplate Template;

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_SurviveXTurns');
	Template.bIncreasesForceLevel = true;
	Template.bDisconnectRegionOnFail = false;

	Template.OnSuccessFn = SurviveOnSuccess;
	Template.OnFailureFn = SurviveOnFailure;

	Template.GetMissionDifficultyFn = GetMissionDifficultyFromTemplate;
	Template.OverworldMeshPath = "StaticMesh'UI_3D.Overwold_Final.RescueOps'";
	// Template.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Reduce_Avatar_Project_Progress";
	Template.MissionImage = "img:///UILibrary_XPACK_StrategyImages.CovertOp_Facility_Lead";
	Template.MissionPopupFn = SurvivePopup;
	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;
	Template.GetMissionRegionFn = GetCalendarMissionRegion;
	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;

	return Template;
}

static function SurviveOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local array<int> ExcludeIndices;
	ExcludeIndices = GetSurviveXTurnsExcludeRewards(MissionState);
	GiveRewards(NewGameState, MissionState, ExcludeIndices);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_Mission_Survive_Success');
	
	`XEVENTMGR.TriggerEvent('SurviveComplete', , , NewGameState);
}

static function SurviveOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{


	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_Mission_Survive_Failed');

	`XEVENTMGR.TriggerEvent('SurviveFailed', , , NewGameState);
}

static function SurviveOnExpire(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_Mission_Survive_Failed');
}

static function SurvivePopup(optional XComGameState_MissionSite MissionState)
{
	class'X2Helpers_Mission_SurviveXTurns'.static.ShowMissionSurvivePopup(MissionState);
}

static function array<int> GetSurviveXTurnsExcludeRewards(XComGameState_MissionSite MissionState)
{
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local array<int> ExcludeIndices;
	local int idx;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));

	for (idx = 0; idx < BattleData.MapData.ActiveMission.MissionObjectives.Length; idx++)
	{
		if(BattleData.MapData.ActiveMission.MissionObjectives[idx].ObjectiveName == 'Grand' &&
			!BattleData.MapData.ActiveMission.MissionObjectives[idx].bCompleted)
		{
			ExcludeIndices.AddItem(idx - 1);
			ExcludeIndices.AddItem(idx);
			ExcludeIndices.AddItem(idx+1);
			ExcludeIndices.AddItem(idx+2);
		}
	}

	return ExcludeIndices;
}

