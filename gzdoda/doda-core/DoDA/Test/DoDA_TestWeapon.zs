///////////////////////////
// root/doda/weapon.zsc
//
//////////////////////////
class DoDA_TestWeapon : Weapon
{
    double camYaw;
    double camPitch;
    double deadzoneDegrees;
    double baseYawDeadzone;
    double basePitchDeadzone;
    double yawGap;
    double pitchGap;
    bool initialized;
    bool wasDeadzoneActive;

    double normalFOV;
    double zoomedFOV;
    double crouchZoomBonus;
    double crouchYawBonus;
    double hipfireSpread;
    double deadzoneSpread;
    double offhandSpreadMult;

    double leanAmount;
    double leanDistance;
    double leanAppliedOffset;
    bool wasScrollUp;
    bool wasScrollDown;

    double prevAngle;
    double prevPitch;
    bool sensInitialized;

    int weaponhand;
    int fireLockTics;

    bool wasHoldingFire;
    bool wasLeaningLeftEdge;
    bool wasLeaningRightEdge;
    bool wasDevSwapHand;

    double lastSpriteX;
    double lastSpriteY;
    double lastRotation;

    double debugSpriteX;
    double debugSpriteY;
    double debugSpriteRot;
    double debugSpriteScale;

    bool lastDebugPrintToggleState;
    bool deadzoneActiveHUD;

    double handDipAmount;
    int pendingHand;
    int latchedHand;
    bool hasLatchedSwap;

    bool leanSwapActive;
    int leanLockedHand;

    int lastLoggedHand;
    int lastLoggedPendingHand;
    int lastLoggedLatchedHand;
    bool lastLoggedLatchedSwap;
    bool lastLoggedLeanSwapActive;
    bool lastLoggedDeadzoneActive;

    const Hand_Left = 0;
    const Hand_Right = 1;

    Default
    {
        Weapon.SlotNumber 2;
        Weapon.SelectionOrder 100;
        Weapon.AmmoType "Clip";
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 0;
        Weapon.Kickback 100;
        +WEAPON.NOAUTOAIM
        Tag "DoDA Test Weapon";
        Inventory.PickupMessage "Picked up the DoDA Test Weapon";
    }

    void PrintDebugSpriteOffsets()
    {
        Console.Printf(
            "SPRITE baseX=%.2f baseY=%.2f baseRot=%.2f | dbgX=%.2f dbgY=%.2f dbgRot=%.2f dbgScale=%.3f | finalX=%.2f finalY=%.2f finalRot=%.2f finalScale=%.3f | deadzone=%d hand=%d",
            lastSpriteX,
            lastSpriteY,
            lastRotation,
            debugSpriteX,
            debugSpriteY,
            debugSpriteRot,
            debugSpriteScale,
            lastSpriteX + debugSpriteX,
            lastSpriteY + debugSpriteY,
            lastRotation + debugSpriteRot,
            debugSpriteScale,
            deadzoneActiveHUD ? 1 : 0,
            weaponhand
        );
    }

    void PrintSwapDebug
    (
        bool deadzoneActive,
        bool isLeaning,
        bool leaningLeft,
        bool leaningRight,
        bool leaningLeftPressed,
        bool leaningRightPressed,
        bool devSwapPressed
    )
    {
        Console.Printf(
            "SWAP deadzone=%d lean=%d leanL=%d leanR=%d pressL=%d pressR=%d dev=%d yawGap=%.2f hand=%d pending=%d latched=%d hasLatch=%d leanSwap=%d leanLock=%d fireLock=%d",
            deadzoneActive ? 1 : 0,
            isLeaning ? 1 : 0,
            leaningLeft ? 1 : 0,
            leaningRight ? 1 : 0,
            leaningLeftPressed ? 1 : 0,
            leaningRightPressed ? 1 : 0,
            devSwapPressed ? 1 : 0,
            yawGap,
            weaponhand,
            pendingHand,
            latchedHand,
            hasLatchedSwap ? 1 : 0,
            leanSwapActive ? 1 : 0,
            leanLockedHand,
            fireLockTics
        );
    }

    override void Tick()
    {
        Super.Tick();

        if (!owner || !owner.player) return;

        baseYawDeadzone = 10.0;
        basePitchDeadzone = 5.0;
        normalFOV = 90.0;
        zoomedFOV = 65.0;
        crouchZoomBonus = 8.0;
        crouchYawBonus = 6.0;
        hipfireSpread = 6.0;
        deadzoneSpread = 0.15;
        offhandSpreadMult = 3.5;

        double smoothing = 0.35;
        double fovSmoothing = 0.15;
        double leanSmoothing = 0.25;
        double spriteXScale = 3.0;
        double spriteYScale = 0.6;
        double scrollStep = 2.0;
        double minLeanDistance = 8.0;
        double maxLeanDistance = 40.0;

        double baseSensitivity = 0.75;
        double leanSensitivityMult = 0.75;
        double crouchSensitivityMult = 0.85;
        double bothSensitivityMult = 0.9;
        double minSensitivity = 0.25;

        double baseMoveMult = 0.8;
        double crouchMoveMult = 0.7;
        double leanMoveMult = 0.6;

        double tiltStartThreshold = 3.0;
        double tiltScale = 1.4;
        double maxTilt = 18.0;
        double leanTiltAmount = 10.0;

        double handSwapThresholdPct = 0.30;
        double handSwapReleasePct = 0.60;

        double dipSpeed = 0.6;
        double dipDistance = 40.0;

        double baseSpriteXOffset = 8.0;
        double restXOffset = -38.0;
        double offhandFineTune = 15.0;
        double restYOffset = 0.0;

        if (leanDistance <= 0.0) leanDistance = 20.0;

        bool realAltFire = (owner.player.cmd.buttons & BT_ALTATTACK) != 0;
        CVar dbgDeadzone = CVar.GetCVar('doda_debug_force_deadzone', owner.player);
        bool forceDeadzone = dbgDeadzone ? dbgDeadzone.GetBool() : false;
        bool deadzoneActive = realAltFire || forceDeadzone;

        deadzoneActiveHUD = deadzoneActive;

        bool holdingFire = (owner.player.cmd.buttons & BT_ATTACK) != 0;
        bool firePressed = holdingFire && !wasHoldingFire;
        wasHoldingFire = holdingFire;

        bool leaningLeft = (owner.player.cmd.buttons & BT_USER1) != 0;
        bool leaningRight = (owner.player.cmd.buttons & BT_USER2) != 0;
        bool scrollUp = (owner.player.cmd.buttons & BT_USER3) != 0;
        bool scrollDown = (owner.player.cmd.buttons & BT_USER4) != 0;
        bool isLeaning = leaningLeft || leaningRight;

        bool leaningLeftPressed = leaningLeft && !wasLeaningLeftEdge;
        bool leaningRightPressed = leaningRight && !wasLeaningRightEdge;
        wasLeaningLeftEdge = leaningLeft;
        wasLeaningRightEdge = leaningRight;

        if (isLeaning)
        {
            if (scrollUp && !wasScrollUp) leanDistance = Clamp(leanDistance + scrollStep, minLeanDistance, maxLeanDistance);
            if (scrollDown && !wasScrollDown) leanDistance = Clamp(leanDistance - scrollStep, minLeanDistance, maxLeanDistance);
        }
        wasScrollUp = scrollUp;
        wasScrollDown = scrollDown;

        double crouchAmount = 1.0 - owner.player.crouchFactor;
        bool isCrouching = crouchAmount > 0.05;

        double sensMultiplier = baseSensitivity;
        if (isLeaning) sensMultiplier *= leanSensitivityMult;
        if (isCrouching) sensMultiplier *= crouchSensitivityMult;
        if (isLeaning && isCrouching) sensMultiplier *= bothSensitivityMult;
        sensMultiplier = Clamp(sensMultiplier, minSensitivity, 1.0);

        if (!sensInitialized)
        {
            prevAngle = owner.angle;
            prevPitch = owner.pitch;
            sensInitialized = true;
        }

        double rawYawDelta = DeltaAngle(prevAngle, owner.angle);
        double rawPitchDelta = DeltaAngle(prevPitch, owner.pitch);

        owner.angle = prevAngle + (rawYawDelta * sensMultiplier);
        owner.pitch = prevPitch + (rawPitchDelta * sensMultiplier);

        prevAngle = owner.angle;
        prevPitch = owner.pitch;

        double moveMultiplier = baseMoveMult;
        if (isCrouching) moveMultiplier *= crouchMoveMult;
        if (isLeaning) moveMultiplier *= leanMoveMult;
        owner.Speed = moveMultiplier;

        double effectiveYawDeadzone = baseYawDeadzone + (crouchYawBonus * crouchAmount);
        double effectivePitchDeadzone = basePitchDeadzone;
        double effectiveZoomFOV = zoomedFOV - (crouchZoomBonus * crouchAmount);

        double targetLean = 0.0;
        if (leaningLeft && !leaningRight) targetLean = -1.0;
        if (leaningRight && !leaningLeft) targetLean = 1.0;

        leanAmount = leanAmount + ((targetLean - leanAmount) * leanSmoothing);

        double currentOffset = leanAmount * leanDistance;

        double rightX = cos(owner.angle - 90.0);
        double rightY = sin(owner.angle - 90.0);

        owner.SetViewPos((rightX * currentOffset, rightY * currentOffset, 0.0), VPSF_ABSOLUTEOFFSET);
        leanAppliedOffset = currentOffset;

        if (!initialized)
        {
            camYaw = owner.angle;
            camPitch = owner.pitch;
            owner.player.DesiredFOV = normalFOV;
            owner.player.SetFOV(normalFOV);

            weaponhand = Hand_Right;
            pendingHand = Hand_Right;
            latchedHand = Hand_Right;

            leanSwapActive = false;
            leanLockedHand = Hand_Right;

            lastLoggedHand = -1;
            lastLoggedPendingHand = -1;
            lastLoggedLatchedHand = -1;
            lastLoggedLatchedSwap = false;
            lastLoggedLeanSwapActive = false;
            lastLoggedDeadzoneActive = deadzoneActive;

            initialized = true;
        }

        double targetFOV = deadzoneActive ? effectiveZoomFOV : normalFOV;
        double newFOV = owner.player.FOV + ((targetFOV - owner.player.FOV) * fovSmoothing);
        owner.player.DesiredFOV = targetFOV;
        owner.player.SetFOV(newFOV);

        bool releasedThisTic = wasDeadzoneActive && !deadzoneActive;

        if (releasedThisTic)
        {
            owner.angle = camYaw;
            owner.pitch = camPitch;
            owner.A_SetViewAngle(0.0, SPF_INTERPOLATE);
            owner.A_SetViewPitch(0.0, SPF_INTERPOLATE);

            yawGap = 0.0;
            pitchGap = 0.0;
            deadzoneDegrees = 0.0;

            hasLatchedSwap = false;
            pendingHand = Hand_Right;
            latchedHand = Hand_Right;
            leanSwapActive = false;
            leanLockedHand = Hand_Right;
        }
        else if (!deadzoneActive)
        {
            camYaw = owner.angle;
            camPitch = owner.pitch;
            deadzoneDegrees = 0.0;
            yawGap = 0.0;
            pitchGap = 0.0;

            owner.A_SetViewAngle(0.0, SPF_INTERPOLATE);
            owner.A_SetViewPitch(0.0, SPF_INTERPOLATE);

            hasLatchedSwap = false;
            pendingHand = Hand_Right;
            latchedHand = Hand_Right;
            leanSwapActive = false;
            leanLockedHand = Hand_Right;
        }
        else
        {
            deadzoneDegrees = effectiveYawDeadzone;

            double rawYawGap = DeltaAngle(camYaw, owner.angle);
            double rawPitchGap = DeltaAngle(camPitch, owner.pitch);

            double targetYaw = owner.angle - Clamp(rawYawGap, -effectiveYawDeadzone, effectiveYawDeadzone);
            double targetPitch = owner.pitch - Clamp(rawPitchGap, -effectivePitchDeadzone, effectivePitchDeadzone);

            camYaw = camYaw + (DeltaAngle(camYaw, targetYaw) * smoothing);
            camPitch = camPitch + (DeltaAngle(camPitch, targetPitch) * smoothing);

            yawGap = DeltaAngle(camYaw, owner.angle);
            pitchGap = DeltaAngle(camPitch, owner.pitch);

            owner.A_SetViewAngle(-yawGap, SPF_INTERPOLATE);
            owner.A_SetViewPitch(-pitchGap, SPF_INTERPOLATE);
        }

        wasDeadzoneActive = deadzoneActive;

        if (fireLockTics > 0) fireLockTics--;

        CVar devSwapCvar = CVar.GetCVar('dev_swaphand', owner.player);
        bool devSwapNow = devSwapCvar ? devSwapCvar.GetBool() : false;
        bool devSwapPressed = devSwapNow != wasDevSwapHand;
        wasDevSwapHand = devSwapNow;

        if (fireLockTics <= 0)
        {
            if (leaningLeftPressed)
            {
                leanSwapActive = true;
                leanLockedHand = Hand_Left;
                latchedHand = Hand_Left;
                hasLatchedSwap = true;
            }
            else if (leaningRightPressed)
            {
                leanSwapActive = true;
                leanLockedHand = Hand_Right;
                latchedHand = Hand_Right;
                hasLatchedSwap = true;
            }
            else if (!isLeaning && leanSwapActive)
            {
                leanSwapActive = false;
                hasLatchedSwap = false;
            }
            else if (devSwapPressed)
            {
                leanSwapActive = false;
                latchedHand = (weaponhand == Hand_Left) ? Hand_Right : Hand_Left;
                hasLatchedSwap = true;
            }
            else if (leanSwapActive)
            {
                latchedHand = leanLockedHand;
                hasLatchedSwap = true;
            }
            else if (!deadzoneActive)
            {
                hasLatchedSwap = false;
                latchedHand = Hand_Right;
            }
            else
            {
                double swapLeftDeg = effectiveYawDeadzone * handSwapThresholdPct;
                double swapRightDeg = effectiveYawDeadzone * handSwapReleasePct;

                if (yawGap < -swapLeftDeg)
                {/* Lines 406-408 omitted */}
                else if (yawGap > swapRightDeg)
                {/* Lines 411-413 omitted */}
                else
                {/* Lines 416-417 omitted */}
            }
        }

        pendingHand = hasLatchedSwap ? latchedHand : Hand_Right;

        if (deadzoneActive != lastLoggedDeadzoneActive
            || weaponhand != lastLoggedHand
            || pendingHand != lastLoggedPendingHand
            || latchedHand != lastLoggedLatchedHand
            || hasLatchedSwap != lastLoggedLatchedSwap
            || leanSwapActive != lastLoggedLeanSwapActive
            || leaningLeftPressed
            || leaningRightPressed
            || devSwapPressed)
        {
            PrintSwapDebug(
                deadzoneActive,
                isLeaning,
                leaningLeft,
                leaningRight,
                leaningLeftPressed,
                leaningRightPressed,
                devSwapPressed
            );

            lastLoggedDeadzoneActive = deadzoneActive;
            lastLoggedHand = weaponhand;
            lastLoggedPendingHand = pendingHand;
            lastLoggedLatchedHand = latchedHand;
            lastLoggedLatchedSwap = hasLatchedSwap;
            lastLoggedLeanSwapActive = leanSwapActive;
        }

        if (fireLockTics <= 0)
        {
            if (pendingHand != weaponhand)
            {
                handDipAmount = Clamp(handDipAmount + dipSpeed, 0.0, 1.0);
                /* Lines 456-469 omitted */
            }
            else
            {/* Lines 472-473 omitted */}
        }

        double dipOffset = handDipAmount * dipDistance;

        bool flipNow = (weaponhand == Hand_Right);

        double rawTiltMag = Max(0.0, Abs(yawGap) - tiltStartThreshold) * tiltScale;
        rawTiltMag = Clamp(rawTiltMag, 0.0, maxTilt);

        double tiltMagnitude = isLeaning ? Max(leanTiltAmount, rawTiltMag) : rawTiltMag;
        double tiltSign;
        if (isLeaning)
        {
            tiltSign = leaningLeft ? 1.0 : -1.0;
        }
        else
        {
            tiltSign = (yawGap < 0.0) ? -1.0 : 1.0;
        }

        double tilt = tiltMagnitude * tiltSign;
        tilt = -tilt;
        if (flipNow) tilt = -tilt;

        double handXOffset = flipNow ? -baseSpriteXOffset : baseSpriteXOffset;
        double appliedRestOffset = flipNow ? (-restXOffset + offhandFineTune) : restXOffset;

        lastSpriteX = (-yawGap * spriteXScale) + (leanAmount * 8.0) + handXOffset + appliedRestOffset;
        lastSpriteY = 32 + (pitchGap * spriteYScale) + dipOffset + restYOffset;
        lastRotation = tilt;

        CVar dbgX = CVar.GetCVar('doda_debug_sprite_x', owner.player);
        CVar dbgY = CVar.GetCVar('doda_debug_sprite_y', owner.player);
        CVar dbgRot = CVar.GetCVar('doda_debug_sprite_rot', owner.player);
        CVar dbgScale = CVar.GetCVar('doda_debug_sprite_scale', owner.player);
        CVar dbgPrint = CVar.GetCVar('doda_debug_print_now', owner.player);

        debugSpriteX = dbgX ? dbgX.GetFloat() : 0.0;
        debugSpriteY = dbgY ? dbgY.GetFloat() : 0.0;
        debugSpriteRot = dbgRot ? dbgRot.GetFloat() : 0.0;
        debugSpriteScale = dbgScale ? dbgScale.GetFloat() : 1.0;

        if (debugSpriteScale < 0.05) debugSpriteScale = 0.05;

        bool printNow = dbgPrint ? dbgPrint.GetBool() : false;
        if (printNow != lastDebugPrintToggleState)
        {
            lastDebugPrintToggleState = printNow;
            if (printNow)
            {/* Lines 524-525 omitted */}
        }

        if (firePressed && fireLockTics <= 0)
        {
            owner.player.SetPSprite(PSP_WEAPON, ResolveState("Fire"));
        }

        PSprite finalWeaponLayer = owner.player.GetPSprite(PSP_WEAPON);
        if (finalWeaponLayer)
        {
            State readyState = ResolveState("Ready");
            if (finalWeaponLayer.CurState == readyState)
            {/* Lines 539-547 omitted */}

            double finalX = lastSpriteX + debugSpriteX;
            double finalY = lastSpriteY + debugSpriteY;
            double finalRot = lastRotation + debugSpriteRot;

            finalWeaponLayer.x = finalX;
            finalWeaponLayer.y = finalY;
            finalWeaponLayer.bFlip = flipNow;
            finalWeaponLayer.rotation = finalRot;
            finalWeaponLayer.HAlign = PSPA_CENTER;
            finalWeaponLayer.VAlign = PSPA_CENTER;
            finalWeaponLayer.bPivotPercent = true;
            finalWeaponLayer.pivot = (0.5, 0.5);
        }
    }

    States
    {
    Ready:
        PISG A 1 A_WeaponReady(WRF_NOFIRE);
        Loop;

    Deselect:
        PISG A 1 A_Lower;
        Loop;

    Select:
        PISG A 1 A_Raise;
        Loop;

    Fire:
        PISG A 4;
        PISG B 6 Bright
        {
            A_AlertMonsters();
            DoDA_FireTrace();
        }
        PISG C 4;
        PISG B 5 A_ReFire;
        Goto Ready;
    }

    action void DoDA_FireTrace()
    {
        invoker.fireLockTics = 9;

        bool realAltFire = (invoker.owner.player.cmd.buttons & BT_ALTATTACK) != 0;
        CVar dbgDeadzone = CVar.GetCVar('doda_debug_force_deadzone', invoker.owner.player);
        bool forceDeadzone = dbgDeadzone ? dbgDeadzone.GetBool() : false;
        bool deadzoneActive = realAltFire || forceDeadzone;

        double spread = deadzoneActive ? invoker.deadzoneSpread : invoker.hipfireSpread;
        bool isOffhand = (invoker.weaponhand == invoker.Hand_Left);
        if (isOffhand) spread *= invoker.offhandSpreadMult;

        double randAngle = FRandom[DoDASpread](0.0, 360.0);
        double randRadius = FRandom[DoDASpread](0.0, spread);

        double fireYaw = invoker.owner.angle + (cos(randAngle) * randRadius);
        double firePitch = invoker.owner.pitch + (sin(randAngle) * randRadius);

        A_StartSound("weapons/pistol", CHAN_WEAPON);

        FLineTraceData trace;
        double attackZ =
            invoker.owner.height * 0.5
            - invoker.owner.floorclip
            + invoker.owner.player.mo.AttackZOffset * invoker.owner.player.crouchFactor;

        bool hit = invoker.owner.LineTrace(
            fireYaw,
            2048,
            firePitch,
            0,
            attackZ,
            0,
            invoker.leanAppliedOffset,
            trace
        );

        Console.Printf(
            "TRACE hit=%d yaw=%.2f pitch=%.2f attackZ=%.2f side=%.2f hitType=%d hand=%d",
            hit ? 1 : 0,
            fireYaw,
            firePitch,
            attackZ,
            invoker.leanAppliedOffset,
            trace.HitType,
            invoker.weaponhand
        );

        if (!hit)
        {
            return;
        }

        if (trace.HitType == TRACE_HitWall || trace.HitType == TRACE_HitFloor || trace.HitType == TRACE_HitCeiling)
        {
            Spawn("BulletPuff", trace.HitLocation);
            return;
        }

        if (trace.HitType == TRACE_HitActor && trace.HitActor)
        {
            let target = trace.HitActor;

            double targetTop = target.Pos.Z + target.Height;
            double headBandStart = targetTop - (target.Height * 0.22);
            bool headshot = trace.HitLocation.Z >= headBandStart;

            int damage = headshot ? 35 : 10;

            target.DamageMobj(invoker.owner, invoker.owner, damage, 'Hitscan');
            Spawn("BulletPuff", trace.HitLocation);

            Console.Printf(
                /* Lines 664-671 omitted */
            );
        }
    }
}
