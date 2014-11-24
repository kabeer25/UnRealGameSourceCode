class Team1GameInfo extends UTTeamGame;

var Team1GamePlayerController currentPlayer;
var Class<Pawn> DefaultRoboPawnClass; //added this for AI


//
// Restart a player. Modified to prevent AI restarts
//
/**
 * modified to prevent bots from respawning
 */
function RestartPlayer(Controller NewPlayer)
{
	local NavigationPoint startSpot;
	local int TeamNum, Idx;
	local array<SequenceObject> Events;
	local SeqEvent_PlayerSpawned SpawnedEvent;
	local LocalPlayer LP; 
	local PlayerController PC; 

	if( bRestartLevel && WorldInfo.NetMode!=NM_DedicatedServer && WorldInfo.NetMode!=NM_ListenServer )
	{
		`warn("bRestartLevel && !server, abort from RestartPlayer"@WorldInfo.NetMode);
		return;
	}
	// figure out the team number and find the start spot
	TeamNum = ((NewPlayer.PlayerReplicationInfo == None) || (NewPlayer.PlayerReplicationInfo.Team == None)) ? 255 : NewPlayer.PlayerReplicationInfo.Team.TeamIndex;

	StartSpot = FindPlayerStart(NewPlayer, TeamNum);
	`Log("~~~~~~~~~~~~~~~~~Team Number: "@TeamNum);

	// if a start spot wasn't found,
	if (startSpot == None)
	{
		// check for a previously assigned spot
		if (NewPlayer.StartSpot != None)
		{
			StartSpot = NewPlayer.StartSpot;
			`warn("Player start not found, using last start spot");
		}
		else
		{
			// otherwise abort
			`warn("Player start not found, failed to restart player");
			return;
		}
	}
	// try to create a pawn to use of the default class for this player
	if (NewPlayer.Pawn == None && UTBot(NewPlayer) == none)//this is where I changed it
	{
		NewPlayer.Pawn = SpawnDefaultPawnFor(NewPlayer, StartSpot);
	}
	if (NewPlayer.Pawn == None)
	{
		`log("failed to spawn player at "$StartSpot);
		NewPlayer.GotoState('Dead');
		if ( PlayerController(NewPlayer) != None )
		{
			PlayerController(NewPlayer).ClientGotoState('Dead','Begin');
		}
	}
	else
	{
		// initialize and start it up
		NewPlayer.Pawn.SetAnchor(startSpot);
		if ( PlayerController(NewPlayer) != None )
		{
			PlayerController(NewPlayer).TimeMargin = -0.1;
			startSpot.AnchoredPawn = None; // SetAnchor() will set this since IsHumanControlled() won't return true for the Pawn yet
		}
		NewPlayer.Pawn.LastStartSpot = PlayerStart(startSpot);
		NewPlayer.Pawn.LastStartTime = WorldInfo.TimeSeconds;
		NewPlayer.Possess(NewPlayer.Pawn, false);
		NewPlayer.Pawn.PlayTeleportEffect(true, true);
		NewPlayer.ClientSetRotation(NewPlayer.Pawn.Rotation, TRUE);

		if (!WorldInfo.bNoDefaultInventoryForPlayer)
		{
			AddDefaultInventory(NewPlayer.Pawn);
		}
		SetPlayerDefaults(NewPlayer.Pawn);

		// activate spawned events
		if (WorldInfo.GetGameSequence() != None)
		{
			WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_PlayerSpawned',TRUE,Events);
			for (Idx = 0; Idx < Events.Length; Idx++)
			{
				SpawnedEvent = SeqEvent_PlayerSpawned(Events[Idx]);
				if (SpawnedEvent != None &&
					SpawnedEvent.CheckActivate(NewPlayer,NewPlayer))
				{
					SpawnedEvent.SpawnPoint = startSpot;
					SpawnedEvent.PopulateLinkedVariableValues();
				}
			}
		}
	}
	// To fix custom post processing chain when not running in editor or PIE.
	PC = PlayerController(NewPlayer);
	if (PC != none)
	{
		LP = LocalPlayer(PC.Player); 
		if(LP != None) 
		{ 
			LP.RemoveAllPostProcessingChains(); 
			LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(),INDEX_NONE,true); 
			if(PC.myHUD != None)
			{
				PC.myHUD.NotifyBindPostProcessEffects();
			}
		} 
	}


	`Log("Player restarted");
	currentPlayer = Team1GamePlayerController(NewPlayer);//aPlayer to NewPlayer
	//currentPlayer.resetMesh();
	//currentPlayer.rSetBehindView(true);
	//currentPlayer.rSetCameraMode('ThirdPerson');
}





/*function RestartPlayer(Controller aPlayer)
{
	super.RestartPlayer(aPlayer);
	`Log("Player restarted");
	currentPlayer = Team1GamePlayerController(aPlayer);
	//currentPlayer.resetMesh();
	//currentPlayer.rSetBehindView(true);
	//currentPlayer.rSetCameraMode('ThirdPerson');
}*/

/**
 * Allows many bots that would otherwise not be permitted
 * with the default function
 */
function bool TooManyBots(Controller botToRemove){
   return false;
}
/**
 * Helps assign player to one team and bots to other teams
 */
function UTTeamInfo GetBotTeam(optional int TeamBots,optional bool bUseTeamIndex, optional int TeamIndex)
{
	local int first, second;
	local PlayerController PC;

	if( bUseTeamIndex )
	{
		return Teams[TeamIndex];
	}

	if ( bForceAllRed )
	{
		return Teams[0];
	}

	if ( bPlayersVsBots && (WorldInfo.NetMode != NM_Standalone) )
	{
		return Teams[1];
	}

	if ( WorldInfo.NetMode == NM_Standalone )
	{
		if ( Teams[0].AllBotsSpawned() )
	    {
		    if ( !Teams[1].AllBotsSpawned() )
			{
			    return Teams[1];
			}
	    }
	    else if ( Teams[1].AllBotsSpawned() )
	    {
		    return Teams[0];
		}
	}

	second = 1;
	// always imbalance teams in favor of bot team in single player
	if (  WorldInfo.NetMode == NM_Standalone )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( (PC.PlayerReplicationInfo.Team != None) && (PC.PlayerReplicationInfo.Team.TeamIndex == 1) )
			{
				first = 1;
				second = 0;
			}
			break;
		} 
	}
	//if ( Teams[first].Size < Teams[second].Size )
	if( PC.Pawn.IsHumanControlled())//this is where teams are decided
	{
		`Log("TeamFirst "@Teams[first].Size);
		return Teams[first];
	}
	else
	{
		`Log("TeamSecond "@Teams[second].Size);
		return Teams[second];
	}
 
}


simulated function PostBeginPlay() {
	local UTTeamGame Game;
	Super.PostBeginPlay();
	Game = UTTeamGame(WorldInfo.Game);
	if (Game != None)
	{
		Game.PlayerControllerClass=Class'Team1Game.Team1GamePlayerController';
	}
}

//added this for AI
function class<Pawn> GetDefaultPlayerClass(Controller C)
{
	local class<Pawn> rv;

	rv = DefaultPawnClass;
	if (c.IsA(BotClass.Name)) {
		rv = DefaultRoboPawnClass;
	}

	return rv;
}

defaultproperties
{
	MapPrefixes(0)="NM"
	PlayerControllerClass=Class'Team1Game.Team1GamePlayerController';
	bUseClassicHUD=true
	HUDType=class'Team1Game.Team1GameHUD'
	DefaultPawnClass=Class'Team1Game.Team1GamePawn'
	DefaultRoboPawnClass=class'EnemyPawn'//added this for AI
	BotClass=class'EnemyRoboAI'//added this for AI
	//bDelayedStart=false
}