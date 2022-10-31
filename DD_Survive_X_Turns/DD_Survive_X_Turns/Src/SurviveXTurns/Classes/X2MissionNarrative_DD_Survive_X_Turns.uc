// This is an Unreal

class X2MissionNarrative_DD_Survive_X_Turns extends X2MissionNarrative;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2MissionNarrativeTemplate> Templates;

    Templates.AddItem(AddDefaultDDSurviveXTurnsNarrativeTemplate());

    return Templates;
}

static function X2MissionNarrativeTemplate AddDefaultDDSurviveXTurnsNarrativeTemplate()
{
    local X2MissionNarrativeTemplate Template;

    `CREATE_X2MISSIONNARRATIVE_TEMPLATE(Template, 'DD_SurviveXTurns');

    Template.MissionType = "DD_SurviveXTurns";
    Template.NarrativeMoments[0]="XPACK_NarrativeMoments.X2_XP_Fire_T_In_Position_Extraction"; //Extraction Ready
	Template.NarrativeMoments[1]="XPACK_NarrativeMoments.X2_XP_CEN_T_Neutralize_Comm_General_Killed"; //General Killed
	Template.NarrativeMoments[2]="X2NarrativeMoments.TACTICAL.General.CEN_ExtrGEN_HeavyLosses"; //Heavy Losses

    return Template;
}