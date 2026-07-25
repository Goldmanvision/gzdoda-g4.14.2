/*//////////////////////////|
// DoDA/MissionOverlay.zs
*///////////////////////////|

class DoDAMissionOverlay : EventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        Font font = Font.GetFont("SmallFont");
        int white = Font.FindFontColor("White");
        String missionText = "UNKNOWN";

        DoDAMissionDirector director = DoDAMissionDirector(EventHandler.Find("DoDAMissionDirector"));
        if (director != null)
        {
            switch (director.GetMissionResult())
            {
            case MISSION_PENDING:
                missionText = "PENDING";
                break;

            case MISSION_IN_PROGRESS:
                missionText = "IN PROGRESS";
                break;

            case MISSION_SUCCESS:
                missionText = "SUCCESS";
                break;

            case MISSION_FAILURE:
                missionText = "FAILURE";
                break;

            case MISSION_ABORTED:
                missionText = "ABORTED";
                break;
            }
        }

        Screen.DrawText(font, white, 16, 16, "DoDA overlay probe");
        Screen.DrawText(font, white, 16, 28, "MISSION: " .. missionText);
    }
}