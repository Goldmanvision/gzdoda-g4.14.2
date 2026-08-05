///////////////////////////
// DoDA/FieldAgent.zs
///////////////////////////

class FieldAgent : DoomPlayer
{
    Default
    {
        Player.DisplayName "Field Agent";
        Player.StartItem "DoDAB92Left";
        Player.StartItem "DoDAB92Right";
        Player.StartItem "Clip", 50;
    }

    override void Tick()
    {
        Super.Tick();

        if (player == null)
        {
            return;
        }

        bool deadzoneWanted = (player.cmd.buttons & BT_ALTATTACK) != 0;

        if (deadzoneWanted)
        {
            EventHandler.SendNetworkEvent("DoDA_SetDeadzone", 1);
        }
        else
        {
            EventHandler.SendNetworkEvent("DoDA_SetDeadzone", 0);
        }
    }
}