///////////////////////////
// DoDA/Aim/DeadzoneController.zs
///////////////////////////

class DoDADeadzoneController : EventHandler
{
    bool DeadzoneActive;

    double YawGap;
    double PitchGap;
    double DeadzoneYawLimit;
    double DeadzonePitchLimit;

    override void OnRegister()
    {
        DeadzoneYawLimit = 24.0;
        DeadzonePitchLimit = 16.0;
        SetOrder(-90);
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
            YawGap = 0.0;
            PitchGap = 0.0;
        }

        Console.Printf("DoDA deadzone: %s", enabled ? "ON" : "OFF");
    }

    void SetGaps(double yawGap, double pitchGap)
    {
        YawGap = yawGap;
        PitchGap = pitchGap;
    }

    clearscope bool IsDeadzoneAimActive() { return DeadzoneActive; }
    clearscope double GetDeadzoneX() { return YawGap; }
    clearscope double GetDeadzoneY() { return PitchGap; }
    clearscope double GetDeadzoneYawLimit() { return DeadzoneYawLimit; }
    clearscope double GetDeadzonePitchLimit() { return DeadzonePitchLimit; }
}