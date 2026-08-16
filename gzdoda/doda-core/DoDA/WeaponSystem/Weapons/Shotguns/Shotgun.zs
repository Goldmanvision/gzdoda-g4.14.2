// --------------------------------------------------------------------------
//
// Shotgun
//
// --------------------------------------------------------------------------

class DoDAShotgun : DoDAWeapon
{
    Default {
        Weapon.SelectionOrder 1300;
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 8;
        Weapon.AmmoType "Shell";
        Inventory.PickupMessage "$GOTSHOTGUN";
        Obituary "$OB_MPSHOTGUN";
        Tag "$TAG_SHOTGUN";
    }

    action State A_Shotgun_Fire()
    {
        if (!invoker || !owner) return ResolveState("Ready");
        invoker.pendingRack = true;
        let agent = FieldAgent(owner);
        if (agent && agent.DeadzoneAimActive)
        {
            return ResolveState("PendingRack");
        }
        return ResolveState("Rack");
    }

    action State A_Shotgun_CheckPendingRack()
    {
        if (!invoker || !owner) return ResolveState("Ready");
        let agent = FieldAgent(owner);
        if (agent && !agent.DeadzoneAimActive)
        {
            return ResolveState("Rack");
        }
        return null;
    }

    action State A_Shotgun_ResetRack()
    {
        if (!invoker) return ResolveState("Ready");
        invoker.pendingRack = false;
        return ResolveState("Ready");
    }

    States
    {
    Ready:
        SHTG A 1 A_WeaponReady;
        Loop;
    Deselect:
        SHTG A 1 A_Lower;
        Loop;
    Select:
        SHTG A 1 A_Raise;
        Loop;
    Fire:
        SHTG A 4 A_FireBullets(5.6, 0, 7, 5, "BulletPuff");
        TNT1 A 0 A_Shotgun_Fire;
        Stop;
    PendingRack:
        SHTG A 1;
        TNT1 A 1 A_Shotgun_CheckPendingRack;
        Loop;
    Rack:
        SHTG A 10;
        TNT1 A 0 A_Shotgun_ResetRack;
        Stop;
    Flash:
        SHTF A 4 Bright A_Light1;
        SHTF B 3 Bright A_Light2;
        Goto LightDone;
    Spawn:
        SHOT A -1;
        Stop;
    }
    bool pendingRack;
}

