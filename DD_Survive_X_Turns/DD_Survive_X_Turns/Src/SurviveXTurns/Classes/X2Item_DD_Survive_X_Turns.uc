// This is an Unreal Script
class X2Item_DD_Survive_X_Turns extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreateQuestItemDD_SurviveXTurns());

	return Items;
}

static function X2DataTemplate CreateQuestItemDD_SurviveXTurns()
{
	local X2QuestItemTemplate Item;

	`CREATE_X2TEMPLATE(class 'X2QuestItemTemplate', Item, 'DD_SurviveXTurns_ImportantDocuments');
	
	Item.ItemCat = 'quest';

	Item.MissionType.AddItem("DD_SurviveXTurns");

	Item.RewardType.AddItem('Reward_Intel');
	Item.RewardType.AddItem('Reward_Supplies');
	Item.RewardType.AddItem('Reward_Soldier');
	Item.RewardType.AddItem('Reward_Scientist');
	Item.RewardType.AddItem('Reward_Engineer');

	return Item;
}