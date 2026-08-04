/*//////////////////////////
// DoDA/Aim/AimReceiver.zs
*///////////////////////////*/

class DoDAAimReceiver : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name != "DoDA_DeadzoneMouse")
        {
            return;
        }

        int pnum = e.Player;
        PlayerInfo p = players[pnum];
        if (p == null || p.mo == null)
        {
            return;
        }

        FieldAgent agent = FieldAgent(p.mo);
        if (agent == null)
        {
            return;
        }

        agent.AimDeadzoneMouse(e.Args[0], e.Args[1]);
    }
}