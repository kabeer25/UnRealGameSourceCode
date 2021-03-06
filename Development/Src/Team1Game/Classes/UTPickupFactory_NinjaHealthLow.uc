/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
/**
 * Changed for this game
 */
class UTPickupFactory_NinjaHealthLow extends UTHealthPickupFactory placeable ClassGroup(Team1Game);

/** list of adjacent vials; used to adjust AI ratings for vial groups */
var array<UTPickupFactory_NinjaHealthLow> AdjacentVials;

/*simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		if (AdjacentVials.length == 0)
		{
			FindAdjacentVials(AdjacentVials, self);
			MaxDesireability += 0.5 * MaxDesireability * AdjacentVials.length;
		}
	}
}
*/
/** adds all adjacent vials to the given array
 * recursive, so it detects strung out vial groups and such
 */
function FindAdjacentVials(out array<UTPickupFactory_NinjaHealthLow> InAdjacentVials, UTPickupFactory_NinjaHealthLow InitialCaller)
{
	local int i;
	local UTPickupFactory_NinjaHealthLow OtherVial;

	for (i = 0; i < PathList.length; i++)
	{
		if (PathList[i] != None && PathList[i].Distance < 150 && AdvancedReachSpec(PathList[i]) == None)
		{
			OtherVial =UTPickupFactory_NinjaHealthLow(PathList[i].GetEnd());
			if (OtherVial != None && OtherVial != InitialCaller && InAdjacentVials.Find(OtherVial) == INDEX_NONE)
			{
				InAdjacentVials.AddItem(OtherVial);
				OtherVial.FindAdjacentVials(InAdjacentVials, InitialCaller);
			}
		}
	}
}

/**
 * Give the benefit of this pickup to the recipient
 */
function SpawnCopyFor( Pawn Recipient )
{
	// Give health to recipient
    if((Recipient.Health + HealAmount(Recipient))<Recipient.HealthMax)
	   Recipient.Health += HealAmount(Recipient);
     else{
		Recipient.Health +=(Recipient.HealthMax - Recipient.Health);
     }

	Recipient.MakeNoise(0.1);
	PlaySound( PickupSound );

	if ( PlayerController(Recipient.Controller) != None )
	{
		PlayerController(Recipient.Controller).ReceiveLocalizedMessage(MessageClass,,,,class);
	}
}

function float BotDesireability(Pawn P, Controller C)
{
	local int OldHealingAmount, i;
	local float Desire;

	OldHealingAmount = HealingAmount;

	// add rating for adjacent vials that bot can also use
	for (i = 0; i < AdjacentVials.length; i++)
	{
		if (AdjacentVials[i].ReadyToPickup(0.0))
		{
			HealingAmount += AdjacentVials[i].HealingAmount;
		}
	}

	Desire = Super.BotDesireability(P, C);
	HealingAmount = OldHealingAmount;

	return Desire;
}

auto state Pickup
{
	/* DetourWeight()
	value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
	*/
	function float DetourWeight(Pawn Other,float PathWeight)
	{
		if ( PathWeight > 500 )
			return 0;

		return Super.DetourWeight(Other, PathWeight);
	}

	/**
	 * Checks if health should be given to the pawn 
	 */
	function bool ValidTouch ( Pawn Other ){
	`Log("Insert Log Message Here");
		 if(Other != None){

			if(Other.bCanPickupInventory && Other.IsHumanControlled()){
				if(Other.Health < Other.HealthMax){
	                `Log("Pickup is Valid");
				    return true;
				}else{
				  return false;
				}
			
			}else{
			  return false;
			}

		 }else{
        
			return false;
     
		 }
	   return false;
	}


}

defaultproperties
{
	bSuperHeal=true
	bIsSuperItem=false
	RespawnTime=30.000000
	MaxDesireability=0.0
	HealingAmount=5//change this to set value
	PickupSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Small_Cue_Modulated'

	bRotatingPickup=true
	YawRotationRate=32000

	bFloatingPickup=true
	bRandomStart=true
	BobSpeed=4.0
	BobOffset=5.0

	Begin Object Name=HealthPickUpMesh
		StaticMesh=StaticMesh'NinjaHealthPackage.HealthPackSmall'
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
	End Object


	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00030.000000
		CollisionHeight=+00020.000000
		CollideActors=true
	End Object
}
