class DoDAAimInput : StaticEventHandler
{
    override void OnRegister()
    {
        RequireMouse = true;
        SetOrder(-100);
    }

    override bool InputProcess(InputEvent e)
    {
        if (e.Type != InputEvent.Type_Mouse)
        {
            return false;
        }

        if (e.MouseX == 0 && e.MouseY == 0)
        {
            return false;
        }

        EventHandler.SendNetworkEvent("DoDA_DeadzoneMouse", e.MouseX, e.MouseY, 0);
        return true;
    }
}

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