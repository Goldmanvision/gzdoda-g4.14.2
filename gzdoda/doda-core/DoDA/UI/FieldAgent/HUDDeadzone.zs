///////////////////////////
// DoDA/UI/FieldAgent/HUDDeadzone.zs
///////////////////////////

class DoDAHUDDeadzone : Object
{
    void DrawDeadzone(
        bool active,
        double yawGap,
        double pitchGap,
        double deadzoneDegrees,
        double fov,
        int screenWidth,
        int screenHeight
    )
    {
        if (!active)
        {
            return;
        }

        if (screenWidth <= 0 || screenHeight <= 0)
        {
            return;
        }

        if (fov <= 1.0)
        {
            fov = 90.0;
        }

        double cx = screenWidth * 0.3;
        double cy = screenHeight * 0.3;
        double aspect = screenWidth / double(screenHeight);
        double refAspect = 4.0 / 3.0;

        double halfFovBase = fov * 0.5;
        double halfFovYaw = ATan(Tan(halfFovBase) * (aspect / refAspect));
        double halfFovPitch = halfFovBase;

        double dotX = cx - (Tan(yawGap) / Tan(halfFovYaw)) * cx;
        double dotY = cy + (Tan(pitchGap) / Tan(halfFovPitch)) * cy;

        double boxHalfX = (Tan(deadzoneDegrees) / Tan(halfFovYaw)) * cx;

        Color green = Color(0, 255, 0);
        Color red = Color(255, 0, 0);

        Screen.DrawThickLine(int(cx - boxHalfX), 0, int(cx - boxHalfX), screenHeight, 2, green);
        Screen.DrawThickLine(int(cx + boxHalfX), 0, int(cx + boxHalfX), screenHeight, 2, green);

        Screen.DrawThickLine(int(dotX - 3), int(dotY), int(dotX + 3), int(dotY), 2, red);
        Screen.DrawThickLine(int(dotX), int(dotY - 3), int(dotX), int(dotY + 3), 2, red);
    }
}
