/*//////////////////////////|
// DoDA/WeaponSystem/WeaponBase.zs
*///////////////////////////|*/

class DoDAWeaponBase : DoomWeapon
{
	action void A_DoDAPistolFire()
	{
		A_FireBullets(0.0, 0.0, 1, 5, "BulletPuff");
		A_StartSound("weapons/pistol", CHAN_WEAPON);
	}
}

class DoDAPistol : DoDAWeaponBase
{
	Default
	{
		Weapon.SelectionOrder 1900;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 20;
		Weapon.SlotNumber 0;
		Weapon.AmmoType "Clip";
		Inventory.MaxAmount 1;
		Inventory.Amount 1;
		+WEAPON.WIMPY_WEAPON;
		Inventory.PickupMessage "$PICKUP_PISTOL_DROPPED";
		Obituary "$OB_MPPISTOL";
		Tag "$TAG_PISTOL";
	}

	States
	{
	Ready:
		B92L G 1 A_WeaponReady;
		Loop;

	Deselect:
		B92L G 1 A_Lower;
		Loop;

	Select:
		B92L G 1 A_Raise;
		Loop;

	Fire:
		B92L A 1 A_DoDAPistolFire;
		B92L B 1;
		B92L C 1;
		B92L D 1;
		B92L E 1;
		B92L F 1;
		Goto Ready;
	}
}