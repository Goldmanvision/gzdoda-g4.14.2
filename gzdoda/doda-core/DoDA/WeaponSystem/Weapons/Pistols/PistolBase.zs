///////////////////////////
// DoDA/WeaponSystem/Weapons/Pistols/PistolBase.zs
///////////////////////////

class DoDAPistol : DoDAWeapon
{
    bool adsActive;

    Default
    {
        Weapon.AmmoType "Clip";
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 20;
        Weapon.Kickback 100;

        +WEAPON.NOAUTOFIRE;

        Tag "DoDA Pistol Base";
        Inventory.PickupMessage "Picked up the DoDA Pistol";
    }

    bool IsADSActive()
    {
        return adsActive;
    }

    void SetADSActive(bool active)
    {
        adsActive = active;
    }

    // B92Right is the inherited/default hand. DoDAB92Left overrides this.
    virtual int GetWeaponHand()
    {
        return DoDAHandSwapController.Hand_Right;
    }

    Weapon GetOppositeHandWeapon()
    {
        if (owner == null)
        {
            return null;
        }

        if (GetWeaponHand() == DoDAHandSwapController.Hand_Left)
        {
            return Weapon(owner.FindInventory('DoDAB92Right'));
        }

        return Weapon(owner.FindInventory('DoDAB92Left'));
    }

    bool RequestHandSwap(int requestedHand)
    {
        if (owner == null || owner.player == null)
        {
            return false;
        }

        if (requestedHand == GetWeaponHand())
        {
            return false;
        }

        if (owner.player.ReadyWeapon != self)
        {
            return false;
        }

        // GZDoom uses WP_NOCHANGE to mean that no switch is pending.
        if (owner.player.PendingWeapon != WP_NOCHANGE)
        {
            return false;
        }

        Weapon targetWeapon = GetOppositeHandWeapon();

        if (targetWeapon == null)
        {
            Console.Printf(
                "HANDSWAP: opposite weapon is absent from inventory"
            );

            return false;
        }

        // A_WeaponReady on the current weapon detects this request and starts
        // the native Deselect -> Select transition.
        owner.player.PendingWeapon = targetWeapon;

        Console.Printf(
            "HANDSWAP queued: current=%d requested=%d target=%s",
            GetWeaponHand(),
            requestedHand,
            targetWeapon.GetClassName()
        );

        return true;
    }

    override void Tick()
    {
        Super.Tick();
    }
}