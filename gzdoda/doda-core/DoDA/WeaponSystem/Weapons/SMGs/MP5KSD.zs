class DoDAMP5KSD : DoDAWeapon
{
    const MagazineCapacity = 30;
    const TotalCapacity = 31;

    int magazineRounds;
    bool chamberLoaded;
    bool mp5Initialized;
    int fireMode;
    bool wasFireModePressed;
    int burstShotsRemaining;
    bool burstInProgress;
    bool isReloading;
    bool reloadWasEmpty;
    bool wasMP5AttackHeld;

    const Fire_Semi = 0;
    const Fire_Burst = 1;
    const Fire_Auto = 2;

    Default
    {
        Weapon.SelectionOrder 700;
        Weapon.SlotNumber 4;
        Weapon.AmmoType "Clip";
        Weapon.AmmoUse 0;
        Weapon.AmmoGive 30;
        Inventory.PickupMessage "You got the MP5kSD";
        Obituary "%o was mowed down by %k's MP5kSD.";
        Tag "MP5kSD";
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOALERT;
    }

    override bool ShouldStartFire(bool holdingFire, bool firePressed)
    {
        if (fireMode == Fire_Auto)
        {
            return holdingFire;
        }
        return firePressed;
    }

    override bool UsesManualFireDispatch() { return true; }

    override State GetFireState(bool holdingFire, bool firePressed)
    {
        if (fireMode == Fire_Burst)
        {
            if (burstInProgress) return null;
            Console.Printf("MP5 requesting BurstFire");
            State burstState = ResolveState("BurstFire");
            if (burstState == null)
            {
                Console.Printf("MP5 BurstFire state missing");
                burstInProgress = false;
                burstShotsRemaining = 0;
                return null;
            }
            burstShotsRemaining = 3;
            burstInProgress = true;
            return burstState;
        }
        return ResolveState("Fire");
    }

    override void Tick()
    {
        Super.Tick();
        EnsureFirearmState();

        if (!owner || !owner.player)
        {
            return;
        }

        if (owner.player.ReadyWeapon != self)
        {
            burstShotsRemaining = 0;
            burstInProgress = false;
            isReloading = false;
            wasMP5AttackHeld = false;
            return;
        }

        bool attackDown = (owner.player.cmd.buttons & BT_ATTACK) != 0;
        bool attackPressed = attackDown && !wasMP5AttackHeld;
        wasMP5AttackHeld = attackDown;
    }

    clearscope int GetFireMode()
    {
        return fireMode;
    }

    void CycleFireMode()
    {
        fireMode = (fireMode + 1) % 3;

        A_StartSound("doda/mp5/click", CHAN_WEAPON);
        
        if (fireMode == Fire_Semi) Console.Printf("MP5 mode: SEMI");
        else if (fireMode == Fire_Burst) Console.Printf("MP5 mode: 3-ROUND BURST");
        else Console.Printf("MP5 mode: FULL AUTO");
    }

    void EnsureFirearmState()
    {
        if (mp5Initialized)
        {
            return;
        }

        magazineRounds = MagazineCapacity;
        chamberLoaded = true;
        mp5Initialized = true;
    }

    clearscope int GetMagazineRoundCount()
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

    clearscope int GetLoadedRoundCount()
    {
        return magazineRounds + (chamberLoaded ? 1 : 0);
    }

    clearscope bool IsEmpty()
    {
        return !chamberLoaded && magazineRounds == 0;
    }

    bool CanReload()
    {
        if (!owner) return false;
        let reserveAmmo = Ammo(owner.FindInventory('Clip'));
        return GetLoadedRoundCount() < TotalCapacity && reserveAmmo != null && reserveAmmo.Amount > 0;
    }

    void TryReload()
    {
        if (isReloading) { Console.Printf("MP5 reload refused: already in progress"); return; }
        if (magazineRounds >= MagazineCapacity) { Console.Printf("MP5 reload refused: magazine full"); return; }
        if (!owner) { Console.Printf("MP5 reload refused: no owner"); return; }
        let reserveAmmo = Ammo(owner.FindInventory('Clip'));
        if (!reserveAmmo || reserveAmmo.Amount <= 0) { Console.Printf("MP5 reload refused: no reserve"); return; }
        
        reloadWasEmpty = (magazineRounds == 0 && !chamberLoaded);
        State reloadState;
        if (reloadWasEmpty)
        {
            reloadState = ResolveState('ReloadEmpty');
        }
        else
        {
            reloadState = ResolveState('ReloadTactical');
        }

        if (!reloadState) { Console.Printf("MP5 reload refused: reload state missing"); return; }
        
        isReloading = true;
        Console.Printf("MP5 reload accepted: mag=%d chamber=%d reserve=%d", magazineRounds, chamberLoaded ? 1 : 0, reserveAmmo.Amount);
        owner.player.SetPSprite(PSP_WEAPON, reloadState);
    }

    void PerformReloadTransfer()
    {
        if (!owner) { return; }
        let reserveAmmo = Ammo(owner.FindInventory('Clip'));
        if (!reserveAmmo) { return; }
        
        int amount = Min(MagazineCapacity - magazineRounds, reserveAmmo.Amount);
        magazineRounds += amount;
        reserveAmmo.Amount -= amount;
        
        Console.Printf("MP5 reload finished: mag=%d chamber=%d reserve=%d", magazineRounds, chamberLoaded ? 1 : 0, reserveAmmo.Amount);
    }

    bool ConsumeFiredRound()
    {
        if (!chamberLoaded)
        {
            return false;
        }

        chamberLoaded = false;
        if (magazineRounds > 0)
        {
            magazineRounds--;
            chamberLoaded = true;
        }
        return true;
    }

    override void HandleManualWeaponControl()
    {
        if (!owner || !owner.player) return;

        if (owner.player.cmd.buttons & BT_USER4) // V key
        {
            // Check if we are currently busy
            if (InStateSequence(curstate, ResolveState("Fire")) ||
                InStateSequence(curstate, ResolveState("ReloadTactical")) ||
                InStateSequence(curstate, ResolveState("ReloadEmpty")) ||
                InStateSequence(curstate, ResolveState("Cock")))
            {
                return;
            }

            if (CanCock())
            {
                SetStateLabel("Cock");
            }
        }
    }

    bool CanCock()
    {
        return !chamberLoaded && magazineRounds > 0;
    }

    action void MP5KSD_Fire()
    {
        let mp5 = DoDAMP5KSD(invoker);
        if (mp5 && mp5.ConsumeFiredRound())
        {
            A_FireBullets(0, 0, 1, 10, "BulletPuff", FBF_NORANDOM);
            A_StartSound("doda/mp5/fire", CHAN_WEAPON);
            
            // Spawn cosmetic tracer
            A_SpawnProjectile("DoDATracer", 0, 0, 0, 0, 0);
            
            mp5.fireLockTics = 4;
            
            let reserve = (mp5.owner) ? Ammo(mp5.owner.FindInventory('Clip')) : null;
            Console.Printf("MP5 shot: mag=%d chamber=%d reserve=%d", mp5.magazineRounds, mp5.chamberLoaded ? 1 : 0, reserve ? reserve.Amount : 0);
        }
    }

    States
    {
    Spawn:
        MP5G A -1;
        Stop;

    Ready:
        MP5A A 1 A_WeaponReady(WRF_ALLOWZOOM);
        Loop;

    Select:
        MP5A A 1 A_Raise;
        Loop;

    Deselect:
        MP5A A 1 {
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) mp5.burstShotsRemaining = 0;
            A_Lower();
        }
        Loop;

    Fire:
        MP5A A 1 Bright {
            Console.Printf("MP5 Fire State Entered");
            MP5KSD_Fire();
        }
        MP5A B 1;
        MP5A C 1;
        MP5A D 1;
        Goto Ready;

    BurstFire:
        // Burst round 1
        MP5A A 1 Bright {
            Console.Printf("MP5 entered BurstFire");
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) Console.Printf("MP5 burst shot: remaining=%d mag=%d chamber=%d", mp5.burstShotsRemaining, mp5.magazineRounds, mp5.chamberLoaded ? 1 : 0);
            MP5KSD_Fire();
        }
        MP5A B 1;
        MP5A C 1;
        MP5A D 1;

        // Burst round 2
        MP5A A 1 Bright MP5KSD_Fire();
        MP5A B 1;
        MP5A C 1;
        MP5A D 1;

        // Burst round 3
        MP5A A 1 Bright MP5KSD_Fire();
        MP5A B 1;
        MP5A C 1;
        MP5A D 1;

        TNT1 A 0
        {
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5)
            {
                mp5.burstShotsRemaining = 0;
                mp5.burstInProgress = false;
            }
        }
        Goto Ready;

    DryFire:
        MP5R A 1 A_StartSound("doda/mp5/dryfire", CHAN_WEAPON);
        Goto Ready;


    ReloadTactical:
        MP5R A 2;
        MP5R B 2;
        MP5R C 2;
        MP5R D 2 A_StartSound("doda/mp5/open", CHAN_WEAPON);
        MP5R E 2;
        MP5R F 2;
        MP5R G 2;
        MP5R H 2;
        MP5R I 2;
        MP5R J 2 {
            A_StartSound("doda/mp5/close", CHAN_WEAPON);
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) mp5.PerformReloadTransfer();
        }
        TNT1 A 0 {
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) mp5.isReloading = false;
        }
        Goto Ready;

    ReloadEmpty:
        MP5R A 2;
        MP5R B 2;
        MP5R C 2;
        MP5R D 2 A_StartSound("doda/mp5/open", CHAN_WEAPON);
        MP5R E 2;
        MP5R F 2;
        MP5R G 2;
        MP5R H 2;
        MP5R I 2;
        MP5R J 2 {
            A_StartSound("doda/mp5/close", CHAN_WEAPON);
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) mp5.PerformReloadTransfer();
        }
        MPSL A 2 A_StartSound("doda/mp5/cock", CHAN_WEAPON);
        MPSL B 2;
        MPSL C 2;
        MPSL D 2;
        MPSL E 2 {
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5 && !mp5.chamberLoaded && mp5.magazineRounds > 0)
            {
                mp5.magazineRounds--;
                mp5.chamberLoaded = true;
            }
        }
        MPSL F 2;
        TNT1 A 0 {
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) mp5.isReloading = false;
        }
        Goto Ready;

    Cock:
        MP5R A 5 A_StartSound("doda/mp5/cock", CHAN_WEAPON);
        MP5R A 5 {
            let mp5 = DoDAMP5KSD(invoker);
            if (mp5) mp5.EnsureFirearmState();
            if (mp5 && !mp5.chamberLoaded && mp5.magazineRounds > 0)
            {
                mp5.magazineRounds--;
                mp5.chamberLoaded = true;
                Console.Printf("MP5 cock: mag=%d chamber=%d", mp5.magazineRounds, mp5.chamberLoaded ? 1 : 0);
            }
        }
        Goto Ready;
    }
}
