/*//////////////////////////
// DoDA/FieldAgent.zs
*///////////////////////////*/

class FieldAgent : DoomPlayer
{
    private bool m_DeadzoneControllerGiven;

    Default
    {
        Player.DisplayName "DoDA Agent";
        Player.StartItem "DoDAPistol";
        Player.StartItem "Clip", 50;
        Player.CrouchSprite "PLYC";
        Health 100;
        Radius 16;
        Height 56;
        Player.ViewHeight 41;
        Player.JumpZ 8;
        Speed 1;
        Player.ColorRange 0, 0;
    }

    override void Tick()
    {
        Super.Tick();

        if (player == null)
        {
            return;
        }

        if (!m_DeadzoneControllerGiven)
        {
            DoDAEnsureDeadzoneController();
            m_DeadzoneControllerGiven = true;
        }
    }

    void DoDAEnsureDeadzoneController()
    {
        if (FindInventory("DoDADeadzoneController") == null)
        {
            GiveInventory("DoDADeadzoneController", 1);
        }
    }
}