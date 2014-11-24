class SwordWeapon extends UTWeapon;
/*--------New Code----*/

/*--------New Code End----*/

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'GDC_Materials.Meshes.SK_ExportSword2'
		AnimSets(0)=AnimSet'GDC_Materials.Meshes.SwordAnimset'
		Animations=MeshSequenceA
		Translation=(x=0,y=4,z=-8)
	End Object 

	AttachmentClass=class'WeaponAttachment'

	//PickupMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'GDC_Materials.Meshes.SK_ExportSword2'
	End Object

//	AnimSets(0)=AnimSet'GDC_Materials.Meshes.SwordAnimset'
	WeaponFireSnd(0) = SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'


	bInstantHit=true
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit

	InstantHitMomentum(0)=+30000.0

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	ShotCost(0)=0
	ShotCost(1)=0

	Spread(0)=00.0

	DefaultAnimSpeed=3.0

	AmmoCount=100
	LockerAmmoCount=100
	MaxAmmoCount=100

	WeaponRange=1000

	InstantHitDamage(0)=100
	InstantHitDamage(1)=100
	FireInterval(0)=0.25
	InstantHitDamageTypes(0)=class'UTDmgType_ShockPrimary'

	WeaponFireAnim(0)=Slice_01
}


