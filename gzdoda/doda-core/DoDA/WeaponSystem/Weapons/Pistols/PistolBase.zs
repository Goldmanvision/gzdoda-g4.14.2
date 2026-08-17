///////////////////////////
// DoDA/WeaponSystem/Weapons/Pistols/PistolBase.zs
///////////////////////////

class DoDAPistol : DoDAWeapon
{
    const MagazineCapacity = 15;

    bool adsActive;

    // Each concrete pistol inventory instance has independent firearm state.
    int magazineRounds;
    bool chamberLoaded;
    bool firearmStateInitialized;

    // Set by WeaponBase when this pistol is the chosen reload target.
    bool reloadQueued;
    bool reloadInProgress;

    Default
    {
        Weapon.Kickback 100;
        Weapon.SlotNumber 2;
        +WEAPON.NOAUTOFIRE;

        Tag "DoDA Pistol Base";
        Inventory.PickupMessage "Picked up the DoDA Pistol";
    }

    void EnsureFirearmState()
    {
        if (firearmStateInitialized)
        {
            return;
        }

        magazineRounds = MagazineCapacity;
        chamberLoaded = true;
        firearmStateInitialized = true;
    }

    Ammo GetReserveAmmo()
    {
        if (owner == null)
        {
            return null;
        }

        return Ammo(owner.FindInventory('Clip'));
    }

    bool IsADSActive()
    {
        return adsActive;
    }

    void SetADSActive(bool active)
    {
        adsActive = active;
    }

    clearscope bool UsesWeaponHUD()
    {
        return true;
    }

    clearscope String GetHUDWeaponLabel()
    {
        return "B92";
    }

    clearscope int GetMagazineRounds()
    {
        return magazineRounds;
    }

    clearscope int GetMagazineCapacity()
    {
        return MagazineCapacity;
    }

    clearscope bool IsChamberLoaded()
    {
        return chamberLoaded;
    }


    bool IsEmpty()
    {
        EnsureFirearmState();
        return magazineRounds == 0 && !chamberLoaded;
    }

    bool CanReload()
    {
        EnsureFirearmState();
        
        // Allow reloading even if magazine is empty, as long as reserve ammo exists
        let reserveAmmo = GetReserveAmmo();
        
        return reserveAmmo != null && reserveAmmo.Amount > 0 && magazineRounds < MagazineCapacity;
    }

    bool TryReload()
    {
        return CommitReload();
    }

    clearscope int GetReserveRounds()
    {
        if (owner == null)
        {
            return 0;
        }

        let reserveAmmo = Ammo(owner.FindInventory('Clip'));

        return reserveAmmo != null
            ? reserveAmmo.Amount
            : 0;
    }

    int GetLoadedRoundCount()
    {
        EnsureFirearmState();

        return magazineRounds + (chamberLoaded ? 1 : 0);
    }

    bool IsFullyLoaded()
    {
        EnsureFirearmState();

        return magazineRounds >= MagazineCapacity
            && chamberLoaded;
    }

    bool NeedsReload()
    {
        return !IsFullyLoaded();
    }

    bool CanFireRound()
    {
        EnsureFirearmState();
        return chamberLoaded;
    }

    bool ConsumeFiredRound()
    {
        EnsureFirearmState();

        if (!chamberLoaded)
        {
            return false;
        }

        if (magazineRounds > 0)
        {
            magazineRounds--;
            chamberLoaded = true;
        }
        else
        {
            chamberLoaded = false;
        }

        return true;
    }


    void QueueReload()
    {
        if (CanReload())
        {
            reloadQueued = true;
        }
    }

    bool IsReloadQueued()
    {
        return reloadQueued;
    }

    void ClearReloadQueue()
    {
        reloadQueued = false;
        reloadInProgress = false;
    }

    bool CommitReload()
    {
        EnsureFirearmState();

        if (!CanReload())
        {
            return false;
        }

        let reserveAmmo = GetReserveAmmo();

        if (reserveAmmo == null)
        {
            return false;
        }

        // Return unused rounds in the removed magazine to shared reserve.
        reserveAmmo.Amount += magazineRounds;
        magazineRounds = 0;

        int roundsToLoad = Min(
            MagazineCapacity,
            reserveAmmo.Amount
        );

        magazineRounds = roundsToLoad;
        reserveAmmo.Amount -= roundsToLoad;

        // A reload from an empty chamber chambers one round from the new mag.
        if (!chamberLoaded && magazineRounds > 0)
        {
            magazineRounds--;
            chamberLoaded = true;
        }

        Console.Printf(
            "[DODA/WEAPON] reload hand=%d mag=%d chamber=%d reserve=%d",
            GetWeaponHand(),
            magazineRounds,
            chamberLoaded ? 1 : 0,
            reserveAmmo.Amount
        );

        return true;
    }

    action void DoDA_PlayFireSound()
    {
        if (invoker == null || invoker.owner == null)
        {
            return;
        }

        int soundVariant = Random(1, 3);

        if (soundVariant == 1)
        {
            A_StartSound(
                "doda/pistol/fire1",
                CHAN_WEAPON
            );
        }
        else if (soundVariant == 2)
        {
            A_StartSound(
                "doda/pistol/fire2",
                CHAN_WEAPON
            );
        }
        else
        {
            A_StartSound(
                "doda/pistol/fire3",
                CHAN_WEAPON
            );
        }
    }

    action void DoDA_PlayDryFireSound()
    {
        if (invoker == null || invoker.owner == null)
        {
            return;
        }

        A_StartSound(
            "doda/pistol/dryfire",
            CHAN_BODY
        );
    }

    action void DoDA_PlayMagazineEjectSound()
    {
        if (invoker == null || invoker.owner == null)
        {
            return;
        }

        A_StartSound(
            "doda/pistol/mag_eject",
            CHAN_BODY
        );
    }

    action void DoDA_PlayMagazineLoadSound()
    {
        if (invoker == null || invoker.owner == null)
        {
            return;
        }

        A_StartSound(
            "doda/pistol/mag_load",
            CHAN_BODY
        );
    }

    action void DoDA_PlaySlideSound()
    {
        if (invoker == null || invoker.owner == null)
        {
            return;
        }

        A_StartSound(
            "doda/pistol/slide",
            CHAN_BODY
        );
    }

    // Called on the first R92L/R92R animation frame. It protects against
    // a stale queued request after reserve ammo changes.
    action void DoDA_BeginReload()
    {
        let pistol = DoDAPistol(invoker);

        if (pistol == null || !pistol.reloadQueued || !pistol.CanReload())
        {
            if (invoker != null)
            {
                invoker.SetStateLabel("Ready");
            }

            return;
        }

        pistol.reloadQueued = false;
        pistol.reloadInProgress = true;
    }

    action State A_DoDA_Ready()
    {
        let pistol = DoDAPistol(invoker);

        if (pistol && !pistol.chamberLoaded)
        {
            return ResolveState("ReadyEmpty");
        }

        A_WeaponReady(WRF_ALLOWZOOM | WRF_NOSECONDARY);
        return null;
    }

    action State A_DoDA_Fire()
    {
        let pistol = DoDAPistol(invoker);

        if (pistol && !pistol.chamberLoaded)
        {
            return ResolveState("DryFire");
        }

        return null;
    }

    // Called on B92LE0/B92RE0: the supplied magazine-seat/chamber frame.
    action void DoDA_CommitReload()
    {
        let pistol = DoDAPistol(invoker);

        if (pistol == null || !pistol.reloadInProgress)
        {
            return;
        }

        pistol.CommitReload();
        pistol.reloadInProgress = false;
    }

    override int GetWeaponHand()
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

    bool RequestHandSwap(int requestedHand, bool isManualRequest = false)
    {
        if (owner == null || owner.player == null)
        {
            return false;
        }

        if (!isManualRequest && handSwapController && handSwapController.IsPistolSwapLocked())
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
        EnsureFirearmState();
    }
}
