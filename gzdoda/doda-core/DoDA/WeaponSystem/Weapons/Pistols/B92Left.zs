class DoDAB92Left : DoDAPistol
{
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
        B92L G 2 A_Lower;
        B92L F 2 A_Lower;
        B92L E 2 A_Lower;
        B92L D 2 A_Lower;
        B92L C 2 A_Lower;
        B92L B 2 A_Lower;
        B92L A 2 A_Lower;
        Loop;

    Select:
        B92L A 2 A_Raise;
        B92L B 2 A_Raise;
        B92L C 2 A_Raise;
        B92L D 2 A_Raise;
        B92L E 2 A_Raise;
        B92L F 2 A_Raise;
        B92L G 2 A_Raise;
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