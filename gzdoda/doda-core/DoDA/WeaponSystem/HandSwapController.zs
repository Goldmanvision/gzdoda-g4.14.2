///////////////////////////
// DoDA/WeaponSystem/HandSwapController.zs
///////////////////////////

class DoDAHandSwapController : Object
{
    const Hand_Left = 0;
    const Hand_Right = 1;

    int CurrentHand;
    int DesiredHand;

    bool Initialized;

    void Reset(int initialHand)
    {
        CurrentHand = initialHand;
        DesiredHand = initialHand;
        Initialized = true;
    }

    void SetCurrentHand(int hand)
    {
        if (!Initialized)
        {
            Reset(hand);
            return;
        }

        CurrentHand = hand;
    }

    int ResolveDesiredHand(
        bool deadzoneActive,
        double yawGap,
        double yawLimit,
        bool leaningLeftPressed,
        bool leaningRightPressed,
        bool isLeaning,
        bool devSwapPressed
    )
    {
        if (!Initialized)
        {
            Reset(Hand_Right);
        }

        // Directional thresholds deliberately leave a broad center hold band.
        // A weapon remains selected through that band instead of oscillating
        // whenever the crosshair crosses the exact middle of the deadzone.
        double switchToRightAt = -yawLimit * 0.30;
        double switchToLeftAt = yawLimit * 0.30;

        DesiredHand = CurrentHand;

        // Lean is an explicit, temporary hand preference.
        if (leaningLeftPressed)
        {
            DesiredHand = Hand_Left;
            return DesiredHand;
        }

        if (leaningRightPressed)
        {
            DesiredHand = Hand_Right;
            return DesiredHand;
        }

        if (isLeaning)
        {
            return DesiredHand;
        }

        // Development toggle swaps the actual requested weapon hand.
        if (devSwapPressed)
        {
            if (CurrentHand == Hand_Left)
            {
                DesiredHand = Hand_Right;
            }
            else
            {
                DesiredHand = Hand_Left;
            }

            return DesiredHand;
        }

        // Outside deadzone aim, do not force an inventory weapon switch.
        if (!deadzoneActive)
        {
            return DesiredHand;
        }

        // Negative yawGap is screen-right under the active coordinate contract.
        if (yawGap <= switchToRightAt)
        {
            DesiredHand = Hand_Right;
        }
        else if (yawGap >= switchToLeftAt)
        {
            DesiredHand = Hand_Left;
        }

        return DesiredHand;
    }

    clearscope int GetCurrentHand()
    {
        return CurrentHand;
    }

    clearscope int GetDesiredHand()
    {
        return DesiredHand;
    }

    clearscope bool NeedsWeaponSwap()
    {
        return DesiredHand != CurrentHand;
    }
}