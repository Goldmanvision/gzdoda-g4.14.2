///////////////////////////
// DoDA/Aim/AimInput.zs
///////////////////////////

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

        let controller = DoDADeadzoneController(EventHandler.Find("DoDADeadzoneController"));
        if (controller == null)
        {
            return false;
        }

        if (!controller.IsDeadzoneAimActive())
        {
            return false;
        }

        if (e.MouseX != 0 || e.MouseY != 0)
        {
            EventHandler.SendNetworkEvent("DoDA_DeadzoneMouse", e.MouseX, e.MouseY);
        }

        return true;
    }
}