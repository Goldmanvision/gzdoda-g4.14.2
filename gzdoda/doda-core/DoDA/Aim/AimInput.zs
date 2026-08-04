/*//////////////////////////
// DoDA/Aim/AimInput.zs
*///////////////////////////*/

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