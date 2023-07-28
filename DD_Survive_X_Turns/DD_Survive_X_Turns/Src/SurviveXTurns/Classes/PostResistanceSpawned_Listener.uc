// This is an Unreal Script
class PostResistanceSpawned_Listener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates() {
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTacticalListeners());

	return Templates;
}

static function CHEventListenerTemplate CreateTacticalListeners() {
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'DD_SurviveXTurns');
	Template.AddCHEvent('PostAliensSpawned', OnPostResistanceSpawned, ELD_Immediate);
	Template.RegisterInTactical = true;

	return Template;
}

static protected function EventListenerReturn OnPostResistanceSpawned(Object EventData, Object EventSource, XComGameState StartState, Name EventID, Object CallbackData) {

	local XComGameState_AIGroup GroupState;
	local array<name>EncountersToChange;
	local bool ChangeEnounter;
	local XComGameState_BattleData BattleData;

	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	// First we need to check if the mission is SurviveXTurns
	if (BattleData.MapData.ActiveMission.MissionName != 'DD_SurviveXTurns' ) {
		return ELR_NoInterrupt;
	}

	foreach StartState.IterateByClassType(class'XComGameState_AIGroup', GroupState) {
		if (GroupState.EncounterID == 'Resx6_Std') {
			GroupState = XComGameState_AIGroup(StartState.ModifyStateObject(class'XComGameState_AIGroup', GroupState.ObjectID));
			GroupState.MyEncounterZoneWidth = 30;
			GroupState.MyEncounterZoneDepth = 30;
			GroupState.MyEncounterZoneOffsetFromLOP = 0;
			GroupState.MyEncounterZoneOffsetAlongLOP = -15;
		}
	}

	return ELR_NoInterrupt;
}