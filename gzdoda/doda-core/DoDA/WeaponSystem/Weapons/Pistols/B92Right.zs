///////////////////////////
// DoDA/WeaponSystem/Weapons/Pistols/B92Right.zs
///////////////////////////

class DoDAB92Right : DoDAPistol
{
    Default
    {
        Weapon.SlotNumber 2;
        Weapon.SelectionOrder 100;
        Weapon.AmmoType "Clip";
        Weapon.AmmoUse 1;
        +WEAPON.NOAUTOFIRE;
        Tag "DoDA B92 Right";
        Inventory.PickupMessage "Picked up the DoDA B92 Right";
    }

    States
    {
    Spawn:
        B92R G -1;
        Stop;

    Ready:
        B92R G 1 A_WeaponReady(WRF_ALLOWZOOM);
        Loop;

    AltFire:
        B92R G 1 A_WeaponReady(WRF_NOFIRE);
        Loop;

    Deselect:
        B92R G 1 A_Lower;
        Loop;

    Select:
        B92R G 1 A_Raise;
        Loop;

    Fire:
        B92R A 1;
        B92R B 1 Bright A_FireBullets(0.0, 0.0, 1, 10, "BulletPuff");
        B92R C 1;
        B92R D 1;
        B92R E 1;
        B92R F 1;
        Goto Ready;
    }
}