/*//////////////////////////
// DoDA/UI/FieldAgent/HUDDeadzone.zs
*///////////////////////////*/

class HUDDeadzone : StaticEventHandler
{
    override void OnRegister()
    {
        SetOrder(100);
        IsUiProcessor = false;
        RequireMouse = false;
    }

    override ui void RenderOverlay(RenderEvent e)
    {
        int pnum = ConsolePlayer;
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

        if (controller == null || !controller.IsDeadzoneActive())
        {
            return;
        }

        double w = Screen.GetWidth();
        double h = Screen.GetHeight();
        double cx = w * 0.5;
        double cy = h * 0.5;

        double yawLimit = controller.GetYawLimit();
        double pitchLimit = controller.GetPitchLimit();
        double yawGap = controller.GetYawGap();
        double pitchGap = controller.GetPitchGap();

        double yawFrac = (yawLimit > 0.0) ? (yawGap / yawLimit) : 0.0;
        double pitchFrac = (pitchLimit > 0.0) ? (pitchGap / pitchLimit) : 0.0;

        double ringRadius = 18.0;
        double markerX = cx + (yawFrac * ringRadius);
        double markerY = cy + (pitchFrac * ringRadius);

        Screen.DrawLine(cx - 10, cy, cx + 10, cy, color(255, 255, 255), 128);
        Screen.DrawLine(cx, cy - 10, cx, cy + 10, color(255, 255, 255), 128);
        Screen.DrawFrame(markerX - 3, markerY - 3, 6, 6);
    }
}