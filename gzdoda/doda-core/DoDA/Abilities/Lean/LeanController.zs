///////////////////////////
// DoDA/Abilities/Lean/LeanController.zs
///////////////////////////

class DoDALeanController : Object
{
    double LeanAmount;
    double LeanDistance;
    double AppliedOffset;

    bool WasScrollUp;
    bool WasScrollDown;

    void Reset()
    {
        LeanAmount = 0.0;
        LeanDistance = 20.0;
        AppliedOffset = 0.0;

        WasScrollUp = false;
        WasScrollDown = false;
    }

    play void Update(
        PlayerPawn owner,
        bool leaningLeft,
        bool leaningRight,
        bool scrollUp,
        bool scrollDown
    )
    {
        if (owner == null)
        {
            return;
        }

        if (LeanDistance <= 0.0)
        {
            LeanDistance = 20.0;
        }

        double leanSmoothing = 0.25;
        double scrollStep = 2.0;
        double minLeanDistance = 8.0;
        double maxLeanDistance = 40.0;

        bool isLeaning = leaningLeft || leaningRight;

        if (isLeaning)
        {
            if (scrollUp && !WasScrollUp)
            {
                LeanDistance = Clamp(
                    LeanDistance + scrollStep,
                    minLeanDistance,
                    maxLeanDistance
                );
            }

            if (scrollDown && !WasScrollDown)
            {
                LeanDistance = Clamp(
                    LeanDistance - scrollStep,
                    minLeanDistance,
                    maxLeanDistance
                );
            }
        }

        WasScrollUp = scrollUp;
        WasScrollDown = scrollDown;

        double targetLean = 0.0;

        if (leaningLeft && !leaningRight)
        {
            targetLean = -1.0;
        }
        else if (leaningRight && !leaningLeft)
        {
            targetLean = 1.0;
        }

        LeanAmount += (targetLean - LeanAmount) * leanSmoothing;

        AppliedOffset = LeanAmount * LeanDistance;

        double rightX = Cos(owner.angle - 90.0);
        double rightY = Sin(owner.angle - 90.0);

        owner.SetViewPos(
            (
                rightX * AppliedOffset,
                rightY * AppliedOffset,
                0.0
            ),
            VPSF_ABSOLUTEOFFSET
        );
    }

    clearscope double GetLeanAmount()
    {
        return LeanAmount;
    }

    clearscope double GetLeanDistance()
    {
        return LeanDistance;
    }

    clearscope double GetAppliedOffset()
    {
        return AppliedOffset;
    }
}