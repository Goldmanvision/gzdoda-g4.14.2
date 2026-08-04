///////////////////////////
// DoDA/Aim/AimInput.zs
///////////////////////////

class DoDAAimInput : StaticEventHandler
{
    override void OnRegister()
    {
        RequireMouse = true;
        IsUiProcessor = true;
        SetOrder(-100);
    }

    override bool UiProcess(UiEvent e)
    {
        if (e.MouseX != 0 || e.MouseY != 0)
        {
            EventHandler.SendNetworkEvent("DoDA_DeadzoneMouse", e.MouseX, e.MouseY);
        }

        return false;
    }
}