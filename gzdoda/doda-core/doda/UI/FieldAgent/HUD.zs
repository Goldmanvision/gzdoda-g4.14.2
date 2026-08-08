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

        let agent = FieldAgent(CPlayer.mo);

        if (agent == null || !agent.IsDeadzoneAimActive())
        {
            return;
        }

        if (m_Deadzone == null)
        {
            return;
        }

        m_Deadzone.DrawDeadzone(
            true,
            agent.GetDeadzoneYawGap(),
            agent.GetDeadzonePitchGap(),
            agent.GetDeadzoneYawLimit(),
            agent.GetDeadzonePitchLimit(),
            CPlayer.FOV,
            Screen.GetWidth(),
            Screen.GetHeight()
        );
    }
}