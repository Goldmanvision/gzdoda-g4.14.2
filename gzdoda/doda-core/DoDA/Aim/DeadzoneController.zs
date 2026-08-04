/*//////////////////////////
// DoDA/Aim/DeadzoneController.zs
*///////////////////////////*/

class DoDADeadzoneController : Inventory
{
    bool DeadzoneActive;
    bool CameraPriorityMode;

    double YawGap;
    double PitchGap;
    double DeadzoneYawLimit;
    double DeadzonePitchLimit;

    double CameraYaw;
    double CameraPitch;

    double CameraEase;
    double GapEase;

    double PendingMouseX;
    double PendingMouseY;

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

        if (Owner == null || Owner.player == null)
        {
            return;
        }

        if (DeadzoneYawLimit <= 0.0)
        {
            DeadzoneYawLimit = 12.0;
        }

        if (DeadzonePitchLimit <= 0.0)
        {
            DeadzonePitchLimit = 8.0;
        }

        if (CameraEase <= 0.0)
        {
            CameraEase = 0.20;
        }

        if (GapEase <= 0.0)
        {
            GapEase = 0.35;
        }

        ApplyPendingMouse();
        UpdateCamera();
    }

    void EnableDeadzone(bool enabled)
    {
        DeadzoneActive = enabled;

        if (!enabled)
        {
            PendingMouseX = 0.0;
            PendingMouseY = 0.0;
        }
    }

    void SetPriorityMode(bool cameraPriority)
    {
        CameraPriorityMode = cameraPriority;
    }

    void QueueMouseDelta(int mouseX, int mouseY)
    {
        PendingMouseX += mouseX;
        PendingMouseY += mouseY;
    }

    void ApplyPendingMouse()
    {
        if (PendingMouseX == 0.0 && PendingMouseY == 0.0)
        {
            return;
        }

        double nextYaw = YawGap + (PendingMouseX * 1.5);
        double nextPitch = PitchGap + (PendingMouseY * 1.5);

        double clampedYaw = Clamp(nextYaw, -DeadzoneYawLimit, DeadzoneYawLimit);
        double clampedPitch = Clamp(nextPitch, -DeadzonePitchLimit, DeadzonePitchLimit);

        double overflowYaw = nextYaw - clampedYaw;
        double overflowPitch = nextPitch - clampedPitch;

        YawGap = clampedYaw;
        PitchGap = clampedPitch;

        if (DeadzoneActive)
        {
            if (overflowYaw != 0.0)
            {
                CameraYaw += overflowYaw;
            }

            if (overflowPitch != 0.0)
            {
                CameraPitch += overflowPitch;
            }
        }

        PendingMouseX = 0.0;
        PendingMouseY = 0.0;
    }

    void UpdateCamera()
    {
        if (Owner == null || Owner.player == null)
        {
            return;
        }

        if (DeadzoneActive)
        {
            if (CameraPriorityMode)
            {
                Owner.A_SetViewAngle(CameraYaw);
                Owner.A_SetViewPitch(CameraPitch);
            }

            return;
        }

        YawGap = MoveTowardZero(YawGap, GapEase);
        PitchGap = MoveTowardZero(PitchGap, GapEase);

        CameraYaw = CameraYaw + (Owner.angle - CameraYaw) * CameraEase;
        CameraPitch = CameraPitch + (Owner.pitch - CameraPitch) * CameraEase;

        Owner.A_SetViewAngle(CameraYaw);
        Owner.A_SetViewPitch(CameraPitch);
    }

    double MoveTowardZero(double value, double step)
    {
        if (value > 0.0)
        {
            value -= step;
            if (value < 0.0)
            {
                value = 0.0;
            }
        }
        else if (value < 0.0)
        {
            value += step;
            if (value > 0.0)
            {
                value = 0.0;
            }
        }

        return value;
    }

    clearscope double GetYawGap()
    {
        return YawGap;
    }

    clearscope double GetPitchGap()
    {
        return PitchGap;
    }

    clearscope bool IsDeadzoneActive()
    {
        return DeadzoneActive;
    }

    clearscope bool IsCameraPriorityMode()
    {
        return CameraPriorityMode;
    }

    clearscope double GetYawLimit()
    {
        return DeadzoneYawLimit;
    }

    clearscope double GetPitchLimit()
    {
        return DeadzonePitchLimit;
    }
}