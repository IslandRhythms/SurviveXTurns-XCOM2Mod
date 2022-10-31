// This is an Unreal Script

class X2MissionSet_DD_Survive_X_Turns extends X2MissionSet config(GameCore);

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionTemplate> Templates;

    Templates.AddItem(AddMissionTemplate('DD_SurviveXTurns'));

    return Templates;
}