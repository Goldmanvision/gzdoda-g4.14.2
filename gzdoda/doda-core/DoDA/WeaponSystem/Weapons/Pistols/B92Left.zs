///////////////////////////
// DoDA/WeaponSystem/Weapons/Pistols/B92Left.zs
///////////////////////////

class DoDAB92Left : DoDAPistol
{
    Default
    {
        Weapon.SlotNumber 1;
        Weapon.SelectionOrder 100;
        Weapon.AmmoType "Clip";
        Weapon.AmmoUse 1;
		Weapon.AmmoGive 13;
        +WEAPON.NOAUTOFIRE;
        Tag "DoDA B92 Left";
        Inventory.PickupMessage "Picked up the DoDA B92 Left";
    }

    States
    {
    Spawn:
        B92L G -1;
        Stop;

    Ready:
        B92L G 1 A_WeaponReady(WRF_ALLOWZOOM);
        Loop;

    AltFire:
        B92L G 1 A_WeaponReady(WRF_NOFIRE);
        Loop;

    Deselect:
        B92L G 1 A_Lower;
        Loop;

    Select:
        B92L G 1 A_Raise;
        Loop;

    Fire:
        B92L A 1;
        B92L B 1 Bright A_FireBullets(0.0, 0.0, 1, 10, "BulletPuff");
        B92L C 1;
        B92L D 1;
        B92L E 1;
        B92L F 1;
        Goto Ready;
    }
}