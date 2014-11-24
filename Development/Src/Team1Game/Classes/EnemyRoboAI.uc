class EnemyRoboAI extends UTBot;
//uses a modified "zombie"code
var Pawn target;
var Actor Destination;
var Pawn P;
var int sightDistance;

simulated event PostBeginPlay(){	
  super.PostBeginPlay();
  sightDistance = 400;
}
/**
 * removed bump because it seemed excessive after tick was implemented, now bot fires
 * when in visual range
 */
/*simulated event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal ){
     Super.Bump( Other, OtherComp, HitNormal );
}*/
protected event ExecuteWhatToDoNext(){
	GotoState('Roaming');
}

/**
 * seemed to cause issues when 
 */
/*event EnemyNotVisible (){
	super.EnemyNotVisible();
	target = none;
   GotoState('Roaming');
}*/

event SeePlayer(Pawn SeenPlayer){

     if(target == none && SeenPlayer.IsHumanControlled()){

        target = SeenPlayer;
		GotoState('Follow');
     }
}

state Roaming
{
Begin:
 //go to random destination (patroll pattern)
  if(Destination == none || Pawn.ReachedDestination(Destination)){
    Destination = FindRandomDest();
  }

  MoveToward(FindPathToward(Destination), FindPathToward(Destination));
  LatentWhatToDoNext();
}
state Follow
{
Begin:

	if(target != None) {
		MoveTo(target.Location); 
           GoToState('Looking');
		}

}

state Looking
{
Begin:
  if(target != None) {
		MoveTo(target.Location); 
		 GoToState('Follow');
		}

}

state Dead
{

	ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		   NotifyHeadVolumeChange, NotifyHitWall, NotifyBump, ExecuteWhatToDoNext;

Begin:

	// `Log("Pawn Being Destroyed");
	
	//Pawn.Destroy();
    `Log("Enemy AI Being Destroyed");
	Destroy();

}

state TacticalMove
{
	ignores SeePlayer, HearNoise, Bump;

	function bool EngageDirection(vector StrafeDir,bool bForced){
		
		return Enemy != None && !Enemy.Controller.IsA('AIController') && super.EngageDirection(StrafeDir, bForced);
	
	}

}

function tick(float dt){
	//controls how far the the player must run before bot returns to a normal patroll
	if (pawn != none && enemy != none && vsize(enemy.Location - pawn.Location) > sightDistance) {
		//`log("Stopping chase of enemy "@enemy);
		enemy = none;
		target = none;
		destination = none;
		
		gotostate('Roaming');
	}
	else if(GetALocalPlayerController().Pawn != None){ //experemental code seems to work fine
		enemy = GetALocalPlayerController().Pawn;
		target =GetALocalPlayerController().Pawn;
		destination =GetALocalPlayerController().Pawn;
		gotostate('Follow');
		//`log("Chasing "@enemy);
	}
	super.Tick(dt);
}

defaultproperties
{
	//bSeeFriendly=true;
}

