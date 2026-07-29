/*//////////////////////////|
// DoDA/WeaponSystem/WeaponAimController.zs
*///////////////////////////|

enum DoDAWeaponAimMode
{
    WAIM_HipFire,
    WAIM_AimShouldered,
    WAIM_Stabilizing,
    WAIM_SprintLowered,
    WAIM_RecoilRecovery,
    WAIM_Disabled
}

class DoDAWeaponAimProfile : Object
{
    double DeadzoneYaw;
    double DeadzonePitch;
    double MaxOffsetYaw;
    double MaxOffsetPitch;
    double RecenterSpeed;
    double RecenterSpeedInDeadzone;
    double SwayAmplitude;
    double SwayFrequency;
    double RecoilRecoverySpeed;
    double RecoilPitchImpulse;
    double RecoilYawImpulse;
    double MoveSpeedMultiplier;
    double SprintSpeedMultiplier;
    double AimDownSightsMultiplier;

    static DoDAWeaponAimProfile GetProfile(DoDAWeaponAimMode mode)
    {
        let profile = new("DoDAWeaponAimProfile");

        switch (mode)
        {
        case WAIM_HipFire:
            profile.DeadzoneYaw = 6.0;
            profile.DeadzonePitch = 4.0;
            profile.MaxOffsetYaw = 20.0;
            profile.MaxOffsetPitch = 14.0;
            profile.RecenterSpeed = 24.0;
            profile.RecenterSpeedInDeadzone = 8.0;
            profile.SwayAmplitude = 1.8;
            profile.SwayFrequency = 0.9;
            profile.RecoilRecoverySpeed = 48.0;
            profile.RecoilPitchImpulse = 8.0;
            profile.RecoilYawImpulse = 2.5;
            profile.MoveSpeedMultiplier = 1.0;
            profile.SprintSpeedMultiplier = 1.5;
            profile.AimDownSightsMultiplier = 0.6;
            break;

        case WAIM_AimShouldered:
            profile.DeadzoneYaw = 3.5;
            profile.DeadzonePitch = 2.5;
            profile.MaxOffsetYaw = 12.0;
            profile.MaxOffsetPitch = 8.5;
            profile.RecenterSpeed = 48.0;
            profile.RecenterSpeedInDeadzone = 18.0;
            profile.SwayAmplitude = 0.9;
            profile.SwayFrequency = 0.75;
            profile.RecoilRecoverySpeed = 72.0;
            profile.RecoilPitchImpulse = 6.0;
            profile.RecoilYawImpulse = 1.8;
            profile.MoveSpeedMultiplier = 0.8;
            profile.SprintSpeedMultiplier = 1.8;
            profile.AimDownSightsMultiplier = 0.35;
            break;

        case WAIM_Stabilizing:
            profile.DeadzoneYaw = 2.0;
            profile.DeadzonePitch = 1.5;
            profile.MaxOffsetYaw = 8.0;
            profile.MaxOffsetPitch = 5.0;
            profile.RecenterSpeed = 72.0;
            profile.RecenterSpeedInDeadzone = 28.0;
            profile.SwayAmplitude = 0.5;
            profile.SwayFrequency = 0.6;
            profile.RecoilRecoverySpeed = 96.0;
            profile.RecoilPitchImpulse = 5.0;
            profile.RecoilYawImpulse = 1.4;
            profile.MoveSpeedMultiplier = 0.65;
            profile.SprintSpeedMultiplier = 2.0;
            profile.AimDownSightsMultiplier = 0.2;
            break;

        case WAIM_SprintLowered:
            profile.DeadzoneYaw = 14.0;
            profile.DeadzonePitch = 12.0;
            profile.MaxOffsetYaw = 38.0;
            profile.MaxOffsetPitch = 24.0;
            profile.RecenterSpeed = 10.0;
            profile.RecenterSpeedInDeadzone = 4.0;
            profile.SwayAmplitude = 3.5;
            profile.SwayFrequency = 1.4;
            profile.RecoilRecoverySpeed = 24.0;
            profile.RecoilPitchImpulse = 10.0;
            profile.RecoilYawImpulse = 3.6;
            profile.MoveSpeedMultiplier = 1.4;
            profile.SprintSpeedMultiplier = 1.0;
            profile.AimDownSightsMultiplier = 1.0;
            break;

        case WAIM_RecoilRecovery:
            profile.DeadzoneYaw = 4.0;
            profile.DeadzonePitch = 3.0;
            profile.MaxOffsetYaw = 18.0;
            profile.MaxOffsetPitch = 12.0;
            profile.RecenterSpeed = 32.0;
            profile.RecenterSpeedInDeadzone = 12.0;
            profile.SwayAmplitude = 2.2;
            profile.SwayFrequency = 1.2;
            profile.RecoilRecoverySpeed = 120.0;
            profile.RecoilPitchImpulse = 0.0;
            profile.RecoilYawImpulse = 0.0;
            profile.MoveSpeedMultiplier = 1.0;
            profile.SprintSpeedMultiplier = 1.2;
            profile.AimDownSightsMultiplier = 0.8;
            break;

        default:
        case WAIM_Disabled:
            profile.DeadzoneYaw = 0.0;
            profile.DeadzonePitch = 0.0;
            profile.MaxOffsetYaw = 0.0;
            profile.MaxOffsetPitch = 0.0;
            profile.RecenterSpeed = 0.0;
            profile.RecenterSpeedInDeadzone = 0.0;
            profile.SwayAmplitude = 0.0;
            profile.SwayFrequency = 0.0;
            profile.RecoilRecoverySpeed = 0.0;
            profile.RecoilPitchImpulse = 0.0;
            profile.RecoilYawImpulse = 0.0;
            profile.MoveSpeedMultiplier = 1.0;
            profile.SprintSpeedMultiplier = 1.0;
            profile.AimDownSightsMultiplier = 1.0;
            break;
        }

        return profile;
    }
}

class DoDACameraController : Inventory
{
    double CameraYaw;
    double CameraPitch;

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNCLEARABLE;
    }

    override void Tick()
    {
        Super.Tick();

        if (Owner == null)
        {
            return;
        }

        CameraYaw = Owner.Angles.Yaw;
        CameraPitch = Owner.Angles.Pitch;
    }

    void UpdateRawViewAngles(double yawDegrees, double pitchDegrees)
    {
        CameraYaw = yawDegrees;
        CameraPitch = pitchDegrees;
    }

    void ApplyRawInput(double yawDelta, double pitchDelta)
    {
        CameraYaw += yawDelta;
        CameraPitch += pitchDelta;
    }

    void GetViewAngles(out double outYaw, out double outPitch)
    {
        outYaw = CameraYaw;
        outPitch = CameraPitch;
    }
}

class DoDAWeaponAimController : Inventory
{
    double CurrentYawOffset;
    double CurrentPitchOffset;
    double RecoilYaw;
    double RecoilPitch;
    double SwayPhase;
    double LastCameraYaw;
    double LastCameraPitch;
    DoDAWeaponAimMode AimMode;
    bool bWeaponPoseFrozen;
    bool bWeaponHandSideLeft;

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.UNCLEARABLE;
    }

    override void Tick()
    {
        Super.Tick();

        if (Owner == null)
        {
            return;
        }

        if (bWeaponPoseFrozen)
        {
            return;
        }

        double cameraYaw;
        double cameraPitch;
        if (GetOwnerViewAngles(cameraYaw, cameraPitch))
        {
            double yawDelta = NormalizeAngle(cameraYaw - LastCameraYaw);
            double pitchDelta = cameraPitch - LastCameraPitch;

            AddCameraDelta(yawDelta, pitchDelta);

            LastCameraYaw = cameraYaw;
            LastCameraPitch = cameraPitch;
        }

        DoDAWeaponAimProfile profile = DoDAWeaponAimProfile::GetProfile(AimMode);
        double deltaTime = 1.0 / 35.0;

        UpdateSway(profile, deltaTime);
        UpdateRecoil(profile, deltaTime);
        UpdateRecenter(profile, deltaTime);
        UpdateWeaponHandSide(profile);

        LogDebugState();
    }

    void SetAimMode(DoDAWeaponAimMode mode)
    {
        if (AimMode == mode)
        {
            return;
        }

        AimMode = mode;
        DoDAWeaponAimProfile profile = DoDAWeaponAimProfile::GetProfile(mode);

        CurrentYawOffset = Clamp(CurrentYawOffset, -profile.MaxOffsetYaw, profile.MaxOffsetYaw);
        CurrentPitchOffset = Clamp(CurrentPitchOffset, -profile.MaxOffsetPitch, profile.MaxOffsetPitch);
    }

    void SetMovementState(bool isAiming, bool isSprinting, bool isStabilizing, bool isDisabled)
    {
        if (isDisabled)
        {
            SetAimMode(WAIM_Disabled);
        }
        else if (isSprinting)
        {
            SetAimMode(WAIM_SprintLowered);
        }
        else if (isStabilizing)
        {
            SetAimMode(WAIM_Stabilizing);
        }
        else if (isAiming)
        {
            SetAimMode(WAIM_AimShouldered);
        }
        else
        {
            SetAimMode(WAIM_HipFire);
        }
    }

    void AddCameraDelta(double yawDelta, double pitchDelta)
    {
        DoDAWeaponAimProfile profile = DoDAWeaponAimProfile::GetProfile(AimMode);

        CurrentYawOffset = Clamp(CurrentYawOffset + yawDelta, -profile.MaxOffsetYaw, profile.MaxOffsetYaw);
        CurrentPitchOffset = Clamp(CurrentPitchOffset + pitchDelta, -profile.MaxOffsetPitch, profile.MaxOffsetPitch);
    }

    void ApplyRecoil(double pitchImpulse, double yawImpulse)
    {
        DoDAWeaponAimProfile profile = DoDAWeaponAimProfile::GetProfile(AimMode);

        RecoilPitch += pitchImpulse != 0.0 ? pitchImpulse : profile.RecoilPitchImpulse;
        RecoilYaw += yawImpulse != 0.0 ? yawImpulse : profile.RecoilYawImpulse;
    }

    void GetWeaponPose(out double outYaw, out double outPitch)
    {
        DoDAWeaponAimProfile profile = DoDAWeaponAimProfile::GetProfile(AimMode);
        double swayYaw = Sin(SwayPhase) * profile.SwayAmplitude;
        double swayPitch = Cos(SwayPhase * 1.15) * profile.SwayAmplitude * 0.75;

        outYaw = CurrentYawOffset + RecoilYaw + swayYaw;
        outPitch = CurrentPitchOffset + RecoilPitch + swayPitch;
    }

    void GetWorldMuzzleAlignment(double cameraYaw, double cameraPitch, out double outYaw, out double outPitch)
    {
        double offsetYaw;
        double offsetPitch;
        GetWeaponPose(offsetYaw, offsetPitch);

        outYaw = cameraYaw + offsetYaw;
        outPitch = cameraPitch + offsetPitch;
    }

    void GetMuzzleAlignment(out double outYaw, out double outPitch)
    {
        double cameraYaw;
        double cameraPitch;
        if (!GetOwnerViewAngles(cameraYaw, cameraPitch))
        {
            outYaw = CurrentYawOffset + RecoilYaw;
            outPitch = CurrentPitchOffset + RecoilPitch;
            return;
        }

        GetWorldMuzzleAlignment(cameraYaw, cameraPitch, outYaw, outPitch);
    }

    DoDACameraController GetCameraController()
    {
        if (Owner == null)
        {
            return null;
        }

        return DoDACameraController(Owner.FindInventory("DoDACameraController"));
    }

    bool GetOwnerViewAngles(out double outYaw, out double outPitch)
    {
        DoDACameraController camera = GetCameraController();
        if (camera != null)
        {
            camera.GetViewAngles(outYaw, outPitch);
            return true;
        }

        if (Owner == null)
        {
            return false;
        }

        outYaw = Owner.Angles.Yaw;
        outPitch = Owner.Angles.Pitch;
        return true;
    }

    void UpdateSway(DoDAWeaponAimProfile profile, double deltaTime)
    {
        SwayPhase += profile.SwayFrequency * deltaTime;
    }

    void UpdateRecoil(DoDAWeaponAimProfile profile, double deltaTime)
    {
        RecoilPitch = Approach(RecoilPitch, 0.0, profile.RecoilRecoverySpeed * deltaTime);
        RecoilYaw = Approach(RecoilYaw, 0.0, profile.RecoilRecoverySpeed * deltaTime);
    }

    void UpdateRecenter(DoDAWeaponAimProfile profile, double deltaTime)
    {
        double yawSpeed = Abs(CurrentYawOffset) <= profile.DeadzoneYaw
            ? profile.RecenterSpeedInDeadzone
            : profile.RecenterSpeed;
        double pitchSpeed = Abs(CurrentPitchOffset) <= profile.DeadzonePitch
            ? profile.RecenterSpeedInDeadzone
            : profile.RecenterSpeed;

        CurrentYawOffset = Approach(CurrentYawOffset, 0.0, yawSpeed * deltaTime);
        CurrentPitchOffset = Approach(CurrentPitchOffset, 0.0, pitchSpeed * deltaTime);

        CurrentYawOffset = Clamp(CurrentYawOffset, -profile.MaxOffsetYaw, profile.MaxOffsetYaw);
        CurrentPitchOffset = Clamp(CurrentPitchOffset, -profile.MaxOffsetPitch, profile.MaxOffsetPitch);
    }

    double Approach(double current, double target, double amount)
    {
        if (current < target)
        {
            current += amount;
            if (current > target)
            {
                current = target;
            }
        }
        else if (current > target)
        {
            current -= amount;
            if (current < target)
            {
                current = target;
            }
        }

        return current;
    }

    double NormalizeAngle(double angle)
    {
        double result = angle;

        while (result >= 180.0)
        {
            result -= 360.0;
        }
        while (result < -180.0)
        {
            result += 360.0;
        }

        return result;
    }

    void UpdateWeaponHandSide(DoDAWeaponAimProfile profile)
    {
        if (CurrentYawOffset < -profile.DeadzoneYaw)
        {
            bWeaponHandSideLeft = true;
        }
        else if (CurrentYawOffset > profile.DeadzoneYaw)
        {
            bWeaponHandSideLeft = false;
        }
    }

    bool IsWeaponHandSideLeft()
    {
        return bWeaponHandSideLeft;
    }

    void LogDebugState()
    {
        if (Owner == null)
        {
            return;
        }

        Console.Printf(
            "DoDA WeaponAim [%d] YawOffset=%.2f PitchOffset=%.2f RecoilYaw=%.2f RecoilPitch=%.2f SwayPhase=%.2f",
            AimMode,
            CurrentYawOffset,
            CurrentPitchOffset,
            RecoilYaw,
            RecoilPitch,
            SwayPhase
        );
    }
}

class DoDAWeaponAimInitializer : EventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        Super.WorldLoaded(e);

        if (e.IsSaveGame || e.IsReopen)
        {
            return;
        }

        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (players[i].mo == null)
            {
                continue;
            }

            EnsurePlayerControllers(players[i].mo);
        }
    }

    void EnsurePlayerControllers(PlayerPawn pawn)
    {
        if (pawn == null)
        {
            return;
        }

        if (pawn.FindInventory("DoDACameraController") == null)
        {
            pawn.GiveInventory("DoDACameraController", 1);
        }

        if (pawn.FindInventory("DoDAWeaponAimController") == null)
        {
            pawn.GiveInventory("DoDAWeaponAimController", 1);
        }

        DoDAWeaponAimController aimController = DoDAWeaponAimController(pawn.FindInventory("DoDAWeaponAimController"));
        if (aimController != null)
        {
            aimController.LastCameraYaw = pawn.Angles.Yaw;
            aimController.LastCameraPitch = pawn.Angles.Pitch;
            aimController.SetAimMode(WAIM_HipFire);
        }
    }
}
