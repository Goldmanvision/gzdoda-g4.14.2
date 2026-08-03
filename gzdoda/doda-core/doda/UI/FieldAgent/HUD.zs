/*//////////////////////////|
// DoDA/UI/FieldAgent/HUD.zs
//
// HUD compositor.
// This is the one and only StatusBarClass.
// It owns no mission logic and no deadzone logic.
// It only coordinates draw modules.
*///////////////////////////|*/

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

        if (m_Deadzone != null)
        {
            m_Deadzone.DrawDeadzone(CPlayer);
        }
    }
}