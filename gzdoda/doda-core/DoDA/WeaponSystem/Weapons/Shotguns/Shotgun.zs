///////////////////////////
// DoDA/WeaponSystem/Weapons/Shotguns/Shotgun.zs
///////////////////////////

class DoDAShotgun : DoDAWeapon
{
    const TubeCapacity = 7;

    int tubeShells;
    bool chamberLoaded;
    bool pendingRack;

    bool wasShotgunAttackHeld;
    bool wasShotgunReloadHeld;
    bool shotgunInitialized;

    Default
    {
        Weapon.SelectionOrder 1300;
        Weapon.AmmoType "Shell";
        Weapon.AmmoUse 0;
        Weapon.AmmoGive 8;
        Inventory.PickupMessage "$GOTSHOTGUN";
        Obituary "$OB_MPSHOTGUN";
        Tag "$TAG_SHOTGUN";
        +WEAPON.NOAUTOFIRE;
    }

    override void Tick()
    {
        Super.Tick();

        if (
            owner == null
            || owner.player == null
        )
        {
            return;
        }

        if (!shotgunInitialized)
        {
            tubeShells = TubeCapacity;
            chamberLoaded = true;
            pendingRack = false;
            shotgunInitialized = true;
        }

        bool attackDown =
            (owner.player.cmd.buttons & BT_ATTACK) != 0;

        bool attackPressed =
            attackDown && !wasShotgunAttackHeld;

        wasShotgunAttackHeld = attackDown;

        bool reloadDown =
            (owner.player.cmd.buttons & BT_RELOAD) != 0;

        bool reloadPressed =
            reloadDown && !wasShotgunReloadHeld;

        wasShotgunReloadHeld = reloadDown;

        if (owner.player.ReadyWeapon != self)
        {
            return;
        }

        PSprite weaponSprite = owner.player.GetPSprite(
            PSP_WEAPON
        );

        if (
            weaponSprite == null
            || weaponSprite.CurState == null
        )
        {
            return;
        }

        bool isReady =
            weaponSprite.CurState == ResolveState("Ready");

        if (attackPressed && isReady)
        {
            owner.player.SetPSprite(
                PSP_WEAPON,
                chamberLoaded
                    ? ResolveState("Fire")
                    : ResolveState("DryFire")
            );

            return;
        }

        if (
            reloadPressed
            && isReady
            && !pendingRack
            && tubeShells < TubeCapacity
        )
        {
            owner.player.SetPSprite(
                PSP_WEAPON,
                ResolveState("Reload")
            );
        }
    }

    override void HandleManualWeaponControl()
    {
        if (
            owner == null
            || owner.player == null
        )
        {
            return;
        }

        if (
            !pendingRack
            && !chamberLoaded
            && tubeShells <= 0
        )
        {
            return;
        }

        PSprite weaponSprite = owner.player.GetPSprite(
            PSP_WEAPON
        );

        if (
            weaponSprite != null
            && weaponSprite.CurState == ResolveState("Ready")
        )
        {
            owner.player.SetPSprite(
                PSP_WEAPON,
                ResolveState("HipRack")
            );
        }
    }

    clearscope int GetTubeShellCount()
    {
        return tubeShells;
    }

    clearscope int GetTubeCapacity()
    {
        return TubeCapacity;
    }

    clearscope bool IsChamberLoaded()
    {
        return chamberLoaded;
    }

    clearscope bool IsRackPending()
    {
        return pendingRack;
    }

    clearscope int GetReserveShellCount()
    {
        if (owner == null)
        {
            return 0;
        }

        let reserveShells = Ammo(
            owner.FindInventory('Shell')
        );

        return reserveShells != null
            ? reserveShells.Amount
            : 0;
    }

    clearscope String GetChamberStatusText()
    {
        if (chamberLoaded)
        {
            return "LIVE";
        }

        if (pendingRack)
        {
            return "SPENT / UNRACKED";
        }

        return "EMPTY";
    }

    action void A_Shotgun_DryFireSound()
    {
        if (
            invoker == null
            || invoker.owner == null
        )
        {
            return;
        }

        A_StartSound(
            "doda/shotgun/dryfire",
            CHAN_WEAPON
        );
    }

    action void A_Shotgun_RackSound()
    {
        if (
            invoker == null
            || invoker.owner == null
        )
        {
            return;
        }

        A_StartSound(
            "doda/shotgun/rack",
            CHAN_WEAPON
        );
    }

    action State A_Shotgun_BeginFire()
    {
        if (
            invoker == null
            || invoker.owner == null
            || invoker.owner.player == null
        )
        {
            return ResolveState("Ready");
        }

        if (
            invoker.pendingRack
            || !invoker.chamberLoaded
        )
        {
            return ResolveState("DryFire");
        }

        return ResolveState("HipFire");
    }

    action void A_Shotgun_FireTrace()
    {
        if (
            invoker == null
            || invoker.owner == null
            || invoker.owner.player == null
            || invoker.owner.player.mo == null
            || invoker.owner.health <= 0
        )
        {
            return;
        }

        let agent = FieldAgent(invoker.owner);

        bool deadzoneActive = agent != null
            && agent.IsDeadzoneAimActive();

        double yawOffset = deadzoneActive
            ? agent.GetDeadzoneYawGap()
            : 0.0;

        double pitchOffset = deadzoneActive
            ? agent.GetDeadzonePitchGap()
            : 0.0;

        double leanOffset = invoker.leanController != null
            ? invoker.leanController.GetAppliedOffset()
            : 0.0;

        double attackZ =
            invoker.owner.height * 0.5
            - invoker.owner.floorclip
            + invoker.owner.player.mo.AttackZOffset
                * invoker.owner.player.crouchFactor;

        A_StartSound(
            "doda/shotgun/fire",
            CHAN_WEAPON
        );

        for (int pellet = 0; pellet < 7; pellet++)
        {
            double randomAngle = Random(0.0, 360.0);
            double randomRadius = Random(0.0, 5.0);

            double fireYaw = invoker.owner.angle
                + yawOffset
                + Cos(randomAngle) * randomRadius;

            double firePitch = invoker.owner.pitch
                + pitchOffset
                + Sin(randomAngle) * randomRadius;

            FLineTraceData trace;

            bool hit = invoker.owner.LineTrace(
                fireYaw,
                2048.0,
                firePitch,
                0,
                attackZ,
                0.0,
                leanOffset,
                trace
            );

            if (!hit)
            {
                continue;
            }

            if (
                trace.HitType == TRACE_HitWall
                || trace.HitType == TRACE_HitFloor
                || trace.HitType == TRACE_HitCeiling
            )
            {
                Spawn("BulletPuff", trace.HitLocation);
                continue;
            }

            if (
                trace.HitType != TRACE_HitActor
                || !trace.HitActor
            )
            {
                continue;
            }

            trace.HitActor.DamageMobj(
                invoker.owner,
                invoker.owner,
                5,
                'Hitscan'
            );

            Spawn("BulletPuff", trace.HitLocation);
        }
    }

    action State A_Shotgun_AfterShot()
    {
        if (
            invoker == null
            || invoker.owner == null
            || invoker.owner.player == null
        )
        {
            return ResolveState("Ready");
        }

        invoker.chamberLoaded = false;
        invoker.pendingRack = true;

        return ResolveState("Ready");
    }

    action State A_Shotgun_LoadSingleShell()
    {
        if (
            invoker == null
            || invoker.owner == null
            || invoker.owner.player == null
        )
        {
            return ResolveState("Ready");
        }

        let reserveShells = Ammo(
            invoker.owner.FindInventory('Shell')
        );

        int reserveCount = reserveShells != null
            ? reserveShells.Amount
            : 0;

        if (invoker.tubeShells >= invoker.TubeCapacity)
        {
            Console.Printf(
                "[DODA/SHOTGUN] reload blocked: tube=%d/%d reserve=%d",
                invoker.tubeShells,
                invoker.TubeCapacity,
                reserveCount
            );

            return ResolveState("Ready");
        }

        if (
            reserveShells == null
            || reserveShells.Amount <= 0
        )
        {
            Console.Printf(
                "[DODA/SHOTGUN] reload blocked: no reserve Shell"
            );

            return ResolveState("Ready");
        }

        if (!invoker.owner.TakeInventory('Shell', 1))
        {
            Console.Printf(
                "[DODA/SHOTGUN] reload failed: TakeInventory Shell"
            );

            return ResolveState("Ready");
        }

        invoker.tubeShells++;

        A_StartSound(
            "doda/shotgun/shell_load",
            CHAN_WEAPON
        );

        Console.Printf(
            "[DODA/SHOTGUN] reload success: tube=%d/%d reserve=%d",
            invoker.tubeShells,
            invoker.TubeCapacity,
            reserveShells.Amount
        );

        return ResolveState("Ready");
    }

    action State A_Shotgun_FinishRack()
    {
        if (
            invoker == null
            || invoker.owner == null
            || invoker.owner.player == null
        )
        {
            return ResolveState("Ready");
        }

        bool ejectedLiveShell = invoker.chamberLoaded;

        invoker.chamberLoaded = false;

        if (ejectedLiveShell)
        {
            A_StartSound(
                "doda/shotgun/shell_eject",
                CHAN_WEAPON
            );
        }

        if (invoker.tubeShells > 0)
        {
            invoker.tubeShells--;
            invoker.chamberLoaded = true;
        }

        invoker.pendingRack = false;

        return ResolveState("Ready");
    }

    States
    {
    Spawn:
        SHTC A -1;
        Stop;

    Ready:
        SHTN A 1 A_WeaponReady(WRF_NOFIRE);
        Loop;

    Deselect:
        SHTN A 1 A_Lower;
        Loop;

    Select:
        SHTN A 1 A_Raise;
        Loop;

    Fire:
        TNT1 A 0 A_Shotgun_BeginFire;
        Stop;

    DryFire:
        TNT1 A 0 A_Shotgun_DryFireSound;
        SHTN A 4;
        Goto Ready;

    HipFire:
        SHTA A 1 Bright A_Shotgun_FireTrace;
        SHTA B 1;
        SHTA C 1;
        SHTA D 1;
        SHTA E 1 A_Shotgun_AfterShot;
        Stop;

    Reload:
        SHTN V 1;
        SHTN W 1;
        SHTN X 1;
        SHTN Y 1;
        SHTN Z 1;
        SHTN [ 1;
        SHTN ] 1 A_Shotgun_LoadSingleShell;
        Stop;

    HipRack:
        TNT1 A 0 A_Shotgun_RackSound;
        SHTN A 1;
        SHTN B 1;
        SHTN C 1;
        SHTN D 1;
        SHTN E 1;
        SHTN G 1;
        SHTN H 1;
        SHTN I 1;
        SHTN J 1;
        SHTN K 1;
        SHTN L 1;
        SHTN M 1;
        SHTN N 1;
        SHTN O 1;
        SHTN P 1;
        SHTN Q 1;
        SHTN R 1;
        SHTN F 1;
        SHTN E 1;
        SHTN D 1;
        SHTN C 1;
        SHTN B 1;
        SHTN A 1 A_Shotgun_FinishRack;
        Stop;
    }
}