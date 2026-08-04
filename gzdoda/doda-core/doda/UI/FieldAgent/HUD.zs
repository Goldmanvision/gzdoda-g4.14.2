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

        if (m_Deadzone != null && CPlayer != null && CPlayer.mo != null)
        {
            bool active = DeadzoneHUDBridge.IsDeadzoneAimActive();
            double deadzoneX = DeadzoneHUDBridge.GetDeadzoneX();
            double deadzoneY = DeadzoneHUDBridge.GetDeadzoneY();
            double yawLimit = DeadzoneHUDBridge.GetDeadzoneYawLimit();
            double pitchLimit = DeadzoneHUDBridge.GetDeadzonePitchLimit();
            double fov = CPlayer.FOV;
            int screenWidth = Screen.GetWidth();
            int screenHeight = Screen.GetHeight();

            m_Deadzone.DrawDeadzone(
                active,
                deadzoneX,
                deadzoneY,
                yawLimit,
                pitchLimit,
                fov,
                screenWidth,
                screenHeight
            );
        }
    }
}