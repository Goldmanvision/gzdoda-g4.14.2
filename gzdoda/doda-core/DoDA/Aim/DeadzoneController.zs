///////////////////////////
// DoDA/Aim/DeadzoneController.zs
///////////////////////////

class DoDADeadzoneController : StaticEventHandler
{
    bool DeadzoneActive;
    bool CameraPriorityMode;

    double YawGap;
    double PitchGap;
    double DeadzoneYawLimit;
    double DeadzonePitchLimit;

    double PendingMouseX;
    double PendingMouseY;

    override void OnRegister()
    {
        DeadzoneYawLimit = 12.0;
        DeadzonePitchLimit = 8.0;
        SetOrder(-90);
    }

    override void WorldTick()
    {
        ApplyPendingMouse();
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name == "DoDA_DeadzoneMouse")
        {
            PendingMouseX += e.Args[0];
            PendingMouseY += e.Args[1];
            return;
        }

        if (e.Name == "DoDA_SetDeadzone")
        {
            EnableDeadzone(e.Args[0] != 0);
            return;
        }
    }

    void EnableDeadzone(bool enabled)
    {
        if (DeadzoneActive == enabled)
        {
            return;
        }

        DeadzoneActive = enabled;

        if (!enabled)
        {
            PendingMouseX = 0.0;
            PendingMouseY = 0.0;
            YawGap = 0.0;
            PitchGap = 0.0;
        }

        Console.Printf("DoDA deadzone: %s", enabled ? "ON" : "OFF");
    }

    void ApplyPendingMouse()
    {
        if (!DeadzoneActive)
        {
            PendingMouseX = 0.0;
            PendingMouseY = 0.0;
            return;
        }

        if (PendingMouseX == 0.0 && PendingMouseY == 0.0)
        {
            return;
        }

        YawGap = Clamp(YawGap + (PendingMouseX * 1.5), -DeadzoneYawLimit, DeadzoneYawLimit);
        PitchGap = Clamp(PitchGap + (PendingMouseY * 1.5), -DeadzonePitchLimit, DeadzonePitchLimit);

        PendingMouseX = 0.0;
        PendingMouseY = 0.0;
    }

    clearscope bool IsDeadzoneAimActive()
    {
        return DeadzoneActive;
    }

    clearscope double GetDeadzoneX()
    {
        return YawGap;
    }

    clearscope double GetDeadzoneY()
    {
        return PitchGap;
    }

    clearscope double GetDeadzoneYawLimit()
    {
        return DeadzoneYawLimit;
    }

    clearscope double GetDeadzonePitchLimit()
    {
        return DeadzonePitchLimit;
    }
}