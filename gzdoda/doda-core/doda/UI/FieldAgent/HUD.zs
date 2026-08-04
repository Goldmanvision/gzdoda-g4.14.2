/*//////////////////////////
// DoDA/UI/FieldAgent/HUD.zs
//
// HUD compositor.
// This is the one and only StatusBarClass.
// It owns no mission logic and no deadzone logic.
// It only coordinates draw modules.
*///////////////////////////*/

class DoDAHUD : BaseStatusBar
{
    private DoDAHUDTapline m_Tapline;

    override void Init()
    {
        Super.Init();

        m_Tapline = new("DoDAHUDTapline");
    }

    override void Draw(int state, double ticFrac)
    {
        Super.Draw(state, ticFrac);

        if (m_Tapline != null)
        {
            m_Tapline.DrawTapline(CPlayer);
        }
    }
}