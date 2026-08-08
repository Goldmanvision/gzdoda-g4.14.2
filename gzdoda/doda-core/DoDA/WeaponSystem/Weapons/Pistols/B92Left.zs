///////////////////////////
// DoDA/WeaponSystem/Weapons/Pistols/B92Left.zs
///////////////////////////

class DoDAB92Left : DoDAPistol
{
    override int GetWeaponHand()
    {
        return DoDAHandSwapController.Hand_Left;
    }

    States
    {
    Spawn:
        B92L G -1;
        Stop;

    // BT_ALTATTACK is owned by FieldAgent as the deadzone modifier.
    Ready:
        B92L G 1 A_WeaponReady(
            WRF_ALLOWZOOM | WRF_NOSECONDARY
        );
        Loop;

    AltFire:
        Goto Ready;

    // Three native lower steps per tic. The G pose slides down quickly until
    // A_Lower completes the actual pending-weapon transition.
    Deselect:
        B92L G 0 A_Lower;
        B92L G 0 A_Lower;
        B92L G 1 A_Lower;
        Loop;

    // Three native raise steps per tic. A_Raise returns to Ready once the
    // weapon reaches its normal ready height.
    Select:
        B92L G 0 A_Raise;
        B92L G 0 A_Raise;
        B92L G 1 A_Raise;
        Loop;

    Fire:
        B92L G 1;
        B92L A 1 Bright;
        B92L B 1 Bright DoDA_FireTrace;
        B92L C 1;
        B92L D 1;
        B92L E 1;
        B92L F 1;
        Goto Ready;
    }
}