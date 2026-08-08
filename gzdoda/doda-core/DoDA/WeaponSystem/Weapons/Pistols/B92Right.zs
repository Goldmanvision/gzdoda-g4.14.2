///////////////////////////
// DoDA/WeaponSystem/Weapons/Pistols/B92Right.zs
///////////////////////////

class DoDAB92Right : DoDAPistol
{
    override int GetWeaponHand()
    {
        return DoDAHandSwapController.Hand_Right;
    }

    States
    {
    Spawn:
        B92R G -1;
        Stop;

    // BT_ALTATTACK is owned by FieldAgent as the deadzone modifier.
    Ready:
        B92R G 1 A_WeaponReady(
            WRF_ALLOWZOOM | WRF_NOSECONDARY
        );
        Loop;

    AltFire:
        Goto Ready;

    // Three native lower steps per tic. The G pose slides down quickly until
    // A_Lower completes the actual pending-weapon transition.
    Deselect:
        B92R G 0 A_Lower;
        B92R G 0 A_Lower;
        B92R G 1 A_Lower;
        Loop;

    // Three native raise steps per tic. A_Raise returns to Ready once the
    // weapon reaches its normal ready height.
    Select:
        B92R G 0 A_Raise;
        B92R G 0 A_Raise;
        B92R G 1 A_Raise;
        Loop;

    Fire:
        B92R G 1;
        B92R A 1 Bright;
        B92R B 1 Bright DoDA_FireTrace;
        B92R C 1;
        B92R D 1;
        B92R E 1;
        B92R F 1;
        Goto Ready;
    }
}