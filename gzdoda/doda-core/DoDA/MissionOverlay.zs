/*//////////////////////////|
// DoDA/MissionOverlay.zs
*///////////////////////////|

class DoDAMissionOverlay : StaticEventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        Font font = Font.GetFont("SmallFont");
        int white = Font.FindFontColor("White");

        Screen.DrawText(font, white, 16, 16, "DoDA overlay probe");
        Screen.DrawText(font, white, 16, 28, "MISSION: PENDING");
    }
}