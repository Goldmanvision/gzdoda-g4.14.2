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

    bool CanReload()
    {
        EnsureFirearmState();

        if (IsFullyLoaded())
        {
            return false;
        }

        let reserveAmmo = GetReserveAmmo();

        if (reserveAmmo == null)
        {
            return false;
        }

        return reserveAmmo.Amount + magazineRounds > 0;
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