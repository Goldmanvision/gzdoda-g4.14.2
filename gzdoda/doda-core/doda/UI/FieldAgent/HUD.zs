
///////////////////////////
// DoDA/UI/FieldAgent/HUD.zs
///////////////////////////

class DoDAHUD : BaseStatusBar
{
    private DoDAHUDTapline m_Tapline;
    private DoDAHUDDeadzone m_Deadzone;

    override void Init()
    {
        Super.Init();

        m_Tapline = new("DoDAHUDTapline");
        m_Deadzone = new("DoDAHUDDeadzone");
    }

    override void Draw(int state, double ticFrac)
    {
        Super.Draw(state, ticFrac);

        if (m_Tapline != null)
        {
            m_Tapline.DrawTapline(CPlayer);
        }

        if (CPlayer == null || CPlayer.mo == null)
        {
            return;
        }

        if (!DeadzoneHUDBridge.IsDeadzoneAimActive())
        {
            return;
        }

        int screenWidth = Screen.GetWidth();
        int screenHeight = Screen.GetHeight();
        double cx = screenWidth / 2.0;
        double cy = screenHeight / 2.0;
        double fov = CPlayer.FOV;
        double yawGap = DeadzoneHUDBridge.GetDeadzoneX();
        double pitchGap = DeadzoneHUDBridge.GetDeadzoneY();
        double deadzoneDegrees = DeadzoneHUDBridge.GetDeadzoneYawLimit();

        if (m_Deadzone != null)
        {
            m_Deadzone.DrawDeadzone(
                true,
                yawGap,
                pitchGap,
                deadzoneDegrees,
                fov,
                screenWidth,
                screenHeight
            );
        }

        double aspect = screenWidth / double(screenHeight);
        double refAspect = 4.0 / 3.0;

        if (fov <= 1.0)
        {
            fov = 90.0;
        }

        double halfFovBase = fov * 0.5;
        double halfFovYaw = ATan(Tan(halfFovBase) * (aspect / refAspect));
        double halfFovPitch = halfFovBase;

        double dotX = cx - (Tan(yawGap) / Tan(halfFovYaw)) * cx;
        double dotY = cy + (Tan(pitchGap) / Tan(halfFovPitch)) * cy;

        double boxHalfX = (Tan(deadzoneDegrees * 1.25) / Tan(halfFovYaw)) * cx;
        double boxHalfY = (Tan(deadzoneDegrees * 1.25) / Tan(halfFovPitch)) * cy;

        int left = int(cx - boxHalfX);
        int top = int(cy - boxHalfY);
        int width = int(boxHalfX * 2);
        int height = int(boxHalfY * 2);

        Screen.DrawFrame(left, top, width, height);
        Screen.Dim(Color(0, 255, 0), 0.20, left, top, width, 2);
        Screen.Dim(Color(0, 255, 0), 0.20, left, top + height - 2, width, 2);
        Screen.Dim(Color(0, 255, 0), 0.15, left, top, 2, height);
        Screen.Dim(Color(0, 255, 0), 0.15, left + width - 2, top, 2, height);
        Screen.Dim(Color(255, 0, 0), 0.95, int(dotX - 1), int(dotY - 1), 3, 3);
    }
}