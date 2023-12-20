// This is an Unreal Script

//---------------------------------------------------------------------------------------
//  FILE:    SeqAct_CaptureBleedingOutUnits.uc
//  AUTHOR:  Beat
//  PURPOSE: Causes all XCom units that are bleeding out to be captured by the aliens

class SeqAct_CaptureBleedingOutUnits extends SequenceAction
	implements(X2KismetSeqOpVisualizer);

function BuildVisualization(XComGameState GameState);

function ModifyKismetGameState(out XComGameState GameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		if(UnitState.GetTeam() == eTeam_XCom
			&& !UnitState.IsDead()
			&& !UnitState.bRemovedFromPlay)
		{
			UnitState = XComGameState_Unit(GameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.bCaptured = true;
			UnitState.bBleedingOut = false; // Just in case they don't lose the bleeding out status and so when recovering them there is now a mistaken timer.
		}
	}
}

defaultproperties
{
	ObjName="Capture Bleeding Out Units"
	ObjCategory="Gameplay"

	bConvertedForReplaySystem=true
	bCanBeUsedForGameplaySequence=true
	bAutoActivateOutputLinks=true

	VariableLinks.Empty
}
