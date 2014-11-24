class EnemyBossPawn extends UTPawn placeable ClassGroup(Team1Game);
var(NPC) SkeletalMeshComponent NPCMesh;
var(NPC) class<AIController> NPCController;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	   `Log("Enemy Pawn created");
  if(NPCController != none)
  {
    //set the existing ControllerClass to our new NPCController class
    ControllerClass = NPCController;
  }

  AddDefaultInventory();//calls custom weapon due to AI

}

//override to do nothing
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}

/**
 * Adds custom weapon
 */
function AddDefaultInventory()
{
    InvManager.CreateInventory(class'EnemyBossGun');
	//InvManager.CreateInventory(class'SwordWeapon');//uncomment to add sword
}


/**
 * this is so they do not throw the weapon when they die
 */
function ThrowWeaponOnDeath()
{
}

/**
 * death Animation
 */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc){
	SetCollisionType(COLLIDE_NoCollision);
	FullBodyAnimSlot.SetActorAnimEndNotification(true);
	FullBodyAnimSlot.PlayCustomAnim('Death_Stinger', 1.0, , -1.0, false, false);
	LifeSpan=1.0;
	 //GoToState('Dead');
	  `Log("Enemy Being Destroyed");
}

state Dead
{
Begin:
   `Log("Enemy Pawn Destroyed");
	Destroy();
    
}


defaultproperties 
{
  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=NPCMesh0
    SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
    PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
    AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
    AnimtreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
  End Object
  NPCMesh=NPCMesh0
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)
  GroundSpeed=200
  SightRadius=1500
  //PeripheralVision=-0.76
  Alertness=1;
  Health=1500
  //Points to custom AIController class - as the default value
  NPCController=class'EnemyRoboAI'
}