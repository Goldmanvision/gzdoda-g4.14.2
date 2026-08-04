/*//////////////////////////
// DoDA/Aim/AimReceiver.zs
*///////////////////////////*/

class DoDAAimReceiver : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name != "DoDA_DeadzoneMouse")
        {
            return;
        }

        int pnum = e.Player;
        if (pnum < 0 || pnum >= MAXPLAYERS)
        {
            return;
        }

        PlayerInfo p = Players[pnum];
        if (p == null || p.mo == null)
        {
            return;
        }

        DoDADeadzoneController controller =
            DoDADeadzoneController(p.mo.FindInventory("DoDADeadzoneController"));

        if (controller == null)
        {
            p.mo.GiveInventory("DoDADeadzoneController", 1);
            controller = DoDADeadzoneController(p.mo.FindInventory("DoDADeadzoneController"));
        }

        if (controller == null)
        {
            return;
        }

        controller.QueueMouseDelta(e.Args[0], e.Args[1]);
    }
}