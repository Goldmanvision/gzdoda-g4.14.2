///////////////////////////
// DoDA/UI/FieldAgent/HUDDeadzone.zs
///////////////////////////

class DoDAHUDDeadzone : Object
{
    void DrawDeadzone(
        bool active,
        double deadzoneX,
        double deadzoneY,
        double yawLimit,
        double pitchLimit,
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

        double cx = screenWidth / 2.0;
        double cy = screenHeight / 2.0;

        if (fov <= 1.0)
        {
            fov = 90.0;
        }

        double aspect = screenWidth / double(screenHeight);
        double refAspect = 4.0 / 3.0;

        double halfFovBase = fov * 0.5;
        double halfFovYaw = ATan(Tan(halfFovBase) * (aspect / refAspect));
        double halfFovPitch = halfFovBase;

        double dotX = cx + deadzoneX;
        double dotY = cy + deadzoneY;

        double boxHalfWidth = (Tan(yawLimit) / Tan(halfFovYaw)) * cx;
        double boxHalfHeight = (Tan(pitchLimit) / Tan(halfFovPitch)) * cy;

        int left = int(cx - boxHalfWidth);
        int right = int(cx + boxHalfWidth);
        int top = int(cy - boxHalfHeight);
        int bottom = int(cy + boxHalfHeight);

        Color boxColor = Color(0, 255, 0);
        Color centerColor = Color(96, 255, 96);
        Color dotColor = Color(255, 0, 0);

        Screen.DrawThickLine(left, top, right, top, 2, boxColor);
        Screen.DrawThickLine(right, top, right, bottom, 2, boxColor);
        Screen.DrawThickLine(right, bottom, left, bottom, 2, boxColor);
        Screen.DrawThickLine(left, bottom, left, top, 2, boxColor);

        Screen.DrawThickLine(int(cx - 4), int(cy), int(cx + 4), int(cy), 1, centerColor);
        Screen.DrawThickLine(int(cx), int(cy - 4), int(cx), int(cy + 4), 1, centerColor);

        Screen.DrawThickLine(int(dotX - 3), int(dotY), int(dotX + 3), int(dotY), 2, dotColor);
        Screen.DrawThickLine(int(dotX), int(dotY - 3), int(dotX), int(dotY + 3), 2, dotColor);
    }
}