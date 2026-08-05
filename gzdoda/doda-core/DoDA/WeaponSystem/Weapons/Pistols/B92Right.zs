class DoDAB92Right : DoDAPistol
{
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
        B92R G 2 A_Lower;
        B92R F 2 A_Lower;
        B92R E 2 A_Lower;
        B92R D 2 A_Lower;
        B92R C 2 A_Lower;
        B92R B 2 A_Lower;
        B92R A 2 A_Lower;
        Loop;

    Select:
        B92R A 2 A_Raise;
        B92R B 2 A_Raise;
        B92R C 2 A_Raise;
        B92R D 2 A_Raise;
        B92R E 2 A_Raise;
        B92R F 2 A_Raise;
        B92R G 2 A_Raise;
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