///////////////////////////
// DoDA/WeaponSystem/WeaponBase.zs
///////////////////////////

class DoDAWeapon : Weapon
{
    double yawGap;
    double pitchGap;

    double normalFOV;
    double zoomedFOV;
    double crouchZoomBonus;

    double hipfireSpread;
    double deadzoneSpread;
    double offhandSpreadMult;

    int fireLockTics;
    bool wasDevSwapHand;
    bool initialized;

    DoDALeanInput leanInput;
    DoDALeanController leanController;
    DoDAHandSwapController handSwapController;
    DoDASpriteAnimator spriteAnimator;

    double debugSpriteX;
    double debugSpriteY;
    double debugSpriteRot;
    double debugSpriteScale;
    bool lastDebugPrintToggleState;

    const Hand_Left = 0;
    const Hand_Right = 1;

    Default
    {
        +WEAPON.NOAUTOAIM;
    }

    void PrintDebugSpriteOffsets(int hand)
    {
        Console.Printf(
            "SPRITE x=%.2f y=%.2f rot=%.2f | dbgX=%.2f dbgY=%.2f dbgRot=%.2f scale=%.3f | hand=%d",
            spriteAnimator.GetFinalX(),
            spriteAnimator.GetFinalY(),
            spriteAnimator.GetFinalRotation(),
            debugSpriteX,
            debugSpriteY,
            debugSpriteRot,
            debugSpriteScale,
            hand
        );
    }

    override void Tick()
    {
        Super.Tick();

        if (!owner || !owner.player)
        {
            return;
        }

        let pawn = PlayerPawn(owner);

        if (pawn == null)
        {
            return;
        }

        if (leanInput == null)
        {
            leanInput = new("DoDALeanInput");
        }

        if (leanController == null)
        {
            leanController = new("DoDALeanController");
            leanController.Reset();
        }

        if (handSwapController == null)
        {
            handSwapController = new("DoDAHandSwapController");
        }

        if (spriteAnimator == null)
        {
            spriteAnimator = new("DoDASpriteAnimator");
        }

        normalFOV = 90.0;
        zoomedFOV = 65.0;
        crouchZoomBonus = 8.0;

        hipfireSpread = 6.0;
        deadzoneSpread = 0.0;
        offhandSpreadMult = 3.5;

        double fovSmoothing = 0.15;

        let agent = FieldAgent(owner);

        bool deadzoneActive = agent != null
            && agent.IsDeadzoneAimActive();

        yawGap = agent ? agent.GetDeadzoneYawGap() : 0.0;
        pitchGap = agent ? agent.GetDeadzonePitchGap() : 0.0;

        double yawLimit = agent
            ? agent.GetDeadzoneYawLimit()
            : 12.0;

        leanInput.Update(pawn);

        bool leaningLeft = leanInput.IsLeaningLeft();
        bool leaningRight = leanInput.IsLeaningRight();
        bool isLeaning = leanInput.IsLeaning();

        leanController.Update(
            pawn,
            leaningLeft,
            leaningRight,
            leanInput.IsScrollUp(),
            leanInput.IsScrollDown()
        );

        double crouchAmount = 1.0 - owner.player.crouchFactor;
        double effectiveZoomFOV = zoomedFOV
            - crouchZoomBonus * crouchAmount;

        if (!initialized)
        {
            owner.player.DesiredFOV = normalFOV;
            owner.player.SetFOV(normalFOV);

            initialized = true;
        }

        double targetFOV = deadzoneActive
            ? effectiveZoomFOV
            : normalFOV;

        double newFOV = owner.player.FOV
            + (targetFOV - owner.player.FOV) * fovSmoothing;

        owner.player.DesiredFOV = targetFOV;
        owner.player.SetFOV(newFOV);

        if (fireLockTics > 0)
        {
            fireLockTics--;
        }

        CVar devSwapCVar = CVar.GetCVar(
            'dev_swaphand',
            owner.player
        );

        bool devSwapNow = devSwapCVar
            ? devSwapCVar.GetBool()
            : false;

        bool devSwapPressed = devSwapNow != wasDevSwapHand;
        wasDevSwapHand = devSwapNow;

        let pistol = DoDAPistol(owner.player.ReadyWeapon);

        int actualHand = Hand_Right;

        if (pistol != null)
        {
            actualHand = pistol.GetWeaponHand();
        }

        handSwapController.SetCurrentHand(actualHand);

        int requestedHand = handSwapController.ResolveDesiredHand(
            deadzoneActive,
            yawGap,
            yawLimit,
            leanInput.WasLeaningLeftPressed(),
            leanInput.WasLeaningRightPressed(),
            isLeaning,
            devSwapPressed
        );

        // Request an actual B92Left <-> B92Right inventory weapon change.
        // The current weapon's native Ready state sees PendingWeapon, lowers,
        // then GZDoom selects the pending weapon through its Select state.
        if (
            pistol != null
            && owner.player.ReadyWeapon == self
            && owner.player.PendingWeapon == null
            && requestedHand != actualHand
            && fireLockTics <= 0
        )
        {
            pistol.RequestHandSwap(requestedHand);
        }

        spriteAnimator.Update(
            actualHand,
            yawGap,
            pitchGap,
            leanController.GetLeanAmount(),
            0.0,
            isLeaning,
            leaningLeft
        );

        CVar debugXCVar = CVar.GetCVar(
            'doda_debug_sprite_x',
            owner.player
        );

        CVar debugYCVar = CVar.GetCVar(
            'doda_debug_sprite_y',
            owner.player
        );

        CVar debugRotationCVar = CVar.GetCVar(
            'doda_debug_sprite_rot',
            owner.player
        );

        CVar debugScaleCVar = CVar.GetCVar(
            'doda_debug_sprite_scale',
            owner.player
        );

        CVar debugPrintCVar = CVar.GetCVar(
            'doda_debug_print_now',
            owner.player
        );

        debugSpriteX = debugXCVar ? debugXCVar.GetFloat() : 0.0;
        debugSpriteY = debugYCVar ? debugYCVar.GetFloat() : 0.0;

        debugSpriteRot = debugRotationCVar
            ? debugRotationCVar.GetFloat()
            : 0.0;

        debugSpriteScale = debugScaleCVar
            ? Max(0.05, debugScaleCVar.GetFloat())
            : 1.0;

        bool printNow = debugPrintCVar
            ? debugPrintCVar.GetBool()
            : false;

        if (printNow != lastDebugPrintToggleState)
        {
            lastDebugPrintToggleState = printNow;

            if (printNow)
            {
                PrintDebugSpriteOffsets(actualHand);
            }
        }

        if (owner.player.ReadyWeapon != self)
        {
            return;
        }

        PSprite weaponSprite = owner.player.GetPSprite(PSP_WEAPON);

        if (weaponSprite == null)
        {
            return;
        }

        // Do not overwrite weaponSprite.frame. The active B92 state controls
        // whether G, A, B, C, etc. is shown.
        spriteAnimator.Apply(
            weaponSprite,
            debugSpriteX,
            debugSpriteY,
            debugSpriteRot
        );
    }

    action void DoDA_FireTrace()
    {
        invoker.fireLockTics = 9;

        let agent = FieldAgent(invoker.owner);

        bool deadzoneActive = agent != null
            && agent.IsDeadzoneAimActive();

        let pistol = DoDAPistol(
            invoker.owner.player.ReadyWeapon
        );

        bool isLeftHand = pistol != null
            && pistol.GetWeaponHand() == Hand_Left;

        double spread = invoker.hipfireSpread;

        if (deadzoneActive)
        {
            spread = 0.0;
        }
        else if (isLeftHand)
        {
            spread *= invoker.offhandSpreadMult;
        }

        double randomAngle = Random(0.0, 360.0);
        double randomRadius = Random(0.0, spread);

        double yawOffset = deadzoneActive
            ? agent.GetDeadzoneYawGap()
            : 0.0;

        double pitchOffset = deadzoneActive
            ? agent.GetDeadzonePitchGap()
            : 0.0;

        double fireYaw = invoker.owner.angle
            + yawOffset
            + Cos(randomAngle) * randomRadius;

        double firePitch = invoker.owner.pitch
            + pitchOffset
            + Sin(randomAngle) * randomRadius;

        A_StartSound("weapons/pistol", CHAN_WEAPON);

        FLineTraceData trace;

        double attackZ =
            invoker.owner.height * 0.5
            - invoker.owner.floorclip
            + invoker.owner.player.mo.AttackZOffset
                * invoker.owner.player.crouchFactor;

        bool hit = invoker.owner.LineTrace(
            fireYaw,
            2048.0,
            firePitch,
            0,
            attackZ,
            0.0,
            invoker.leanController.GetAppliedOffset(),
            trace
        );

        if (!hit)
        {
            return;
        }

        if (
            trace.HitType == TRACE_HitWall
            || trace.HitType == TRACE_HitFloor
            || trace.HitType == TRACE_HitCeiling
        )
        {
            Spawn("BulletPuff", trace.HitLocation);
            return;
        }

        if (trace.HitType != TRACE_HitActor || !trace.HitActor)
        {
            return;
        }

        let target = trace.HitActor;

        double targetTop = target.Pos.Z + target.Height;
        double headBandStart = targetTop - target.Height * 0.22;

        int damage = trace.HitLocation.Z >= headBandStart
            ? 35
            : 10;

        target.DamageMobj(
            invoker.owner,
            invoker.owner,
            damage,
            'Hitscan'
        );

        Spawn("BulletPuff", trace.HitLocation);
    }
}