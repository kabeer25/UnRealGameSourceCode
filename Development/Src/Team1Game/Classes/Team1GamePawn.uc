/*
 * Camera mechanics implemented by Danny borrowed from
 * http://udn.epicgames.com/Three/CameraTechnicalGuide.html#Example Third Person Camera
 */

class Team1GamePawn extends UTPawn;

var(NPC) class NPCController;
var float currentStamina;
const MAX_STAMINA=100; // full stamina value
const SLOW_WALK_SPEED=100;
const NORMAL_WALK_SPEED=400;
const STAMINA_DECREASE_SWORD=15; // how much to decrease stamina by each attack
const STAMINA_DECREASE_RUN = 0.5;
const STAMINA_DECREASE_JUMP=12;
const STAMINA_DECREASE_DAMAGE_DIVISOR=3;
const STAMINA_DRY_REFILL=40; // When the user depletes their stamina, they must wait until they have this much to use it again
var bool bStaminaRanDry; // true: the user fully depleted their stamina
var float TotalTimeRefresh;
const STAMINA_REPLENISH_FREQ=0.125; // How often the stamina is replenished by 1

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DT, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float DamagetoStamina;
	
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DT, HitInfo, DamageCauser);
	DamagetoStamina=DamageAmount/STAMINA_DECREASE_DAMAGE_DIVISOR;
	self.TakeStamina(DamagetoStamina);
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	TotalTimeRefresh+=DeltaTime;
	if(TotalTimeRefresh>=STAMINA_REPLENISH_FREQ)
	{
		TotalTimeRefresh=0.0;
		if(!bStaminaRanDry && !IsZero(Velocity))
		{
			TakeStamina(STAMINA_DECREASE_RUN);
		}
		
		if(currentStamina <= 0) // help eliminate bugs
		{
			currentStamina=0;
			bStaminaRanDry=true; // They fully depleted their stamina, OH NO!
		}
	}
	if(bStaminaRanDry)
	{
		GroundSpeed=SLOW_WALK_SPEED;
	} 
	else
	{
		GroundSpeed=NORMAL_WALK_SPEED;
	}
}

function Timer()
{
	if(!bStaminaRanDry && !IsZero(Velocity))
	{
		return;
	}

	currentStamina+=1.0; // increase stamina
	if(currentStamina >= MAX_STAMINA) // check bounds
	{     
		currentStamina=MAX_STAMINA;
	}
	// the player didn't deplete stamina and is ready to attack
	if(bStaminaRanDry && currentStamina >= STAMINA_DRY_REFILL)
	{
		bStaminaRanDry=false;
	}
}

function bool DoJump(bool bUpdating)
{
	local bool retValue;

	retValue=super.DoJump(bUpdating);
	TakeStamina(STAMINA_DECREASE_JUMP);
	return retValue;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay(); // REQUIRED! Or not all actors/object spawn = BAD!
	SetTimer(STAMINA_REPLENISH_FREQ, true); // Stamina is replinished automatically
}

defaultproperties
{
	currentStamina=MAX_STAMINA;
	bStaminaRanDry=false;
	TotalTimeRefresh=0.0;
	
	WalkingPct=+0.4
	CrouchedPct=+0.4
	BaseEyeHeight=38.0
	EyeHeight=38.0
	GroundSpeed=NORMAL_WALK_SPEED;
	AirSpeed=440.0
	WaterSpeed=220.0
	DodgeSpeed=200.0
	DodgeSpeedZ=295.0
	AccelRate=2048.0
	JumpZ=322.0
	CrouchHeight=29.0
	CrouchRadius=21.0
	WalkableFloorZ=.75
	CamOffset=(X=15.0,Y=40.0,Z=-20.0)
	AlwaysRelevantDistanceSquared=+1960000.0
	//InventoryManagerClass=class'UTGame.UTInventoryManager'
	//ControllerClass=class'Ninja.NinjaPlayerController'
	NPCController=class'Team1Game.Team1GamePlayerController'
	MeleeRange=+20.0
	bMuffledHearing=true
	Buoyancy=+000.99000000
	UnderWaterTime=+00020.000000
	bCanStrafe=True
	bCanSwim=true
	RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
	MaxLeanRoll=2048
	AirControl=+0.35
	DefaultAirControl=+0.35
	bCanCrouch=true
	bCanClimbLadders=True
	bCanPickupInventory=True
	bCanDoubleJump=true
	SightRadius=+3000.0
	FireRateMultiplier=5.0
	MaxMultiJump=3
	MultiJumpRemaining=10
	MultiJumpBoost=-95.0
	SoundGroupClass=class'UTGame.UTPawnSoundGroup'
	TransInEffects(0)=class'UTEmit_TransLocateOutRed'
	TransInEffects(1)=class'UTEmit_TransLocateOut'
	MaxStepHeight=35.0
	MaxJumpHeight=69.0
	MaxDoubleJumpHeight=87.0
	DoubleJumpEyeHeight=43.0
	SuperHealthMax=9000

	Begin Object Name=WPawnSkeletalMeshComponent
		bOwnerNoSee=false
		Scale=1.3975 
		Translation=(Z=20.0)
	End Object
	Name="Default__NinjaPawn"
}

function TakeStamina(float amount)
{
	if(currentStamina >= 0 && !bStaminaRanDry && currentStamina >= amount)
	{     
		currentStamina-=amount;
	}
	if(currentStamina <= 0) // help eliminate bugs
	{
		currentStamina=0;
		bStaminaRanDry=true; // They fully depleted their stamina, OH NO!
	}
}

//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView);
      }
   }
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   local vector CamStart, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset;
   local float DesiredCameraZOffset;

   CamStart = Location;
   CurrentCamOffset = CamOffset;

   DesiredCameraZOffset = (Health > 0) ? 1.2 * GetCollisionHeight() + Mesh.Translation.Z : 0.f;
   CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;
   
   if ( Health <= 0 )
   {
      CurrentCamOffset = vect(0,0,0);
      CurrentCamOffset.X = GetCollisionRadius();
   }

   CamStart.Z += CameraZOffset;
   GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
   CamDirX *= CurrentCameraScale;

   if ( (Health <= 0) || bFeigningDeath )
   {
      // adjust camera position to make sure it's not clipping into world
      // @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
      FindSpot(GetCollisionExtent(),CamStart);
   }
   if (CurrentCameraScale < CameraScale)
   {
      CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
   }
   else if (CurrentCameraScale > CameraScale)
   {
      CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
   }

   if (CamDirX.Z > GetCollisionHeight())
   {
      CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
   }

   out_CamLoc = CamStart - CamDirX*CurrentCamOffset.X + CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;

   if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
   {
      out_CamLoc = HitLocation;
   }

   return true;
}   