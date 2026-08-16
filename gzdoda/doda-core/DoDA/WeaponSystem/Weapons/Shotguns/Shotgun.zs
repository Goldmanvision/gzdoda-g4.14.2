// --------------------------------------------------------------------------
//
// Shotgun
//
// --------------------------------------------------------------------------

class DoDAShotgun : DoomWeapon
{
	Default
	{
		Weapon.SelectionOrder 1300;
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 8;
		Weapon.AmmoType "Shell";
		Inventory.PickupMessage "$GOTSHOTGUN";
		Obituary "$OB_MPSHOTGUN";
		Tag "$TAG_SHOTGUN";
	}
    action void A_Shotgun_Fire()
    {
        let agent = FieldAgent(self.owner);
        if (agent && agent.IsDeadzoneAimActive())
        {
            invoker.pendingRack = true;
        }
    }

    action void A_Shotgun_CheckRack()
    {
        if (!invoker.pendingRack)
        {
            self.SetStateLabel("Rack");
        }
    }

    action void A_Shotgun_CheckPendingRack()
    {
        let agent = FieldAgent(self.owner);
        if (agent && !agent.IsDeadzoneAimActive())
        {
            self.SetStateLabel("Rack");
        }
    }

    action void A_Shotgun_ResetRack()
    {
        invoker.pendingRack = false;
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
        TNT1 A 0 A_Shotgun_Fire;
        SHTG A 4;
        TNT1 A 0 A_Shotgun_CheckRack;
        Goto PendingRack;
    PendingRack:
        SHTG A 1 A_Shotgun_CheckPendingRack;
        Loop;
    Rack:
        SHTG A 10;
        TNT1 A 0 A_Shotgun_ResetRack;
        Goto Ready;
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

