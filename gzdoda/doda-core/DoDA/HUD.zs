/*//////////////////////////|
// DoDA/HUD.zs
*///////////////////////////|

class DoDAHUD : BaseStatusBar
{
    override void Draw(int state, double TicFrac)
    {
        Super.Draw(state, TicFrac);

        Font font = Font.GetFont("DoDAPalmFont");
        int black = Font.FindFontColor("Black");

        String titleText = "FBI: DODA TAPLINE CONNECTED";
        String missionText = "MISSION: UNKNOWN";
        String statusText = "STATUS: UNKNOWN";
        String progressText = "PROGRESS: 0%";
        String phaseText = "PHASE: UNKNOWN";
        String objectiveText = "OBJECTIVE: UNKNOWN";

        DoDAMissionDirector director =
            DoDAMissionDirector(EventHandler.Find("DoDAMissionDirector"));

        if (director != null)
        {
            missionText = "MISSION: " .. director.GetMissionName();
            progressText = "PROGRESS: " .. director.GetMissionPercentComplete() .. "%";
            objectiveText = "OBJECTIVE: " .. director.GetMissionDescription();

            switch (director.GetMissionResult())
            {
            case MISSION_PENDING:
                statusText = "STATUS: PENDING";
                break;

            case MISSION_IN_PROGRESS:
                statusText = "STATUS: IN PROGRESS";
                break;

            case MISSION_SUCCESS:
                statusText = "STATUS: SUCCESS";
                break;

            case MISSION_FAILURE:
                statusText = "STATUS: FAILURE";
                break;

            case MISSION_ABORTED:
                statusText = "STATUS: ABORTED";
                break;
            }

            switch (director.GetMissionPhase())
            {
            case 1:
                phaseText = "PHASE: OBJECTIVE";
                break;

            case 2:
                phaseText = "PHASE: EXTRACTION";
                break;

            default:
                phaseText = "PHASE: UNKNOWN";
                break;
            }
        }

        int panelWidth = 540;
        int panelHeight = 225;
        int margin = 24;
        int padding = 16;
        int lineGap = 2;

        int panelX = Screen.GetWidth() - panelWidth - margin;
        int panelY = margin;

        int textX = panelX + padding + 4;

        int titleY = panelY + padding;
        int missionY = titleY + font.GetHeight() + lineGap;
        int statusY = missionY + font.GetHeight() + lineGap;
        int progressY = statusY + font.GetHeight() + lineGap;
        int phaseY = progressY + font.GetHeight() + lineGap;
        int objectiveY = phaseY + font.GetHeight() + lineGap;

        Screen.Clear(
            panelX,
            panelY,
            panelX + panelWidth,
            panelY + panelHeight,
            Color(196, 207, 163)
        );

        // Outer border
        Screen.DrawThickLine(panelX, panelY, panelX + panelWidth, panelY, 8.0, Color(0, 0, 0));
        Screen.DrawThickLine(panelX, panelY + panelHeight, panelX + panelWidth, panelY + panelHeight, 8.0, Color(0, 0, 0));
        Screen.DrawThickLine(panelX, panelY, panelX, panelY + panelHeight, 8.0, Color(0, 0, 0));
        Screen.DrawThickLine(panelX + panelWidth, panelY, panelX + panelWidth, panelY + panelHeight, 8.0, Color(0, 0, 0));

        // Inner border
        int inner = 6;
        Color innerBorderColor = Color(155, 188, 15);

        Screen.DrawThickLine(panelX + inner, panelY + inner, panelX + panelWidth - inner, panelY + inner, 8.0, innerBorderColor);
        Screen.DrawThickLine(panelX + inner, panelY + panelHeight - inner, panelX + panelWidth - inner, panelY + panelHeight - inner, 8.0, innerBorderColor);
        Screen.DrawThickLine(panelX + inner, panelY + inner, panelX + inner, panelY + panelHeight - inner, 8.0, innerBorderColor);
        Screen.DrawThickLine(panelX + panelWidth - inner, panelY + inner, panelX + panelWidth - inner, panelY + panelHeight - inner, 8.0, innerBorderColor);

        Screen.DrawText(font, black, textX, titleY, titleText);
        Screen.DrawText(font, black, textX, missionY, missionText);
        Screen.DrawText(font, black, textX, statusY, statusText);
        Screen.DrawText(font, black, textX, progressY, progressText);
        Screen.DrawText(font, black, textX, phaseY, phaseText);
        Screen.DrawText(font, black, textX, objectiveY, objectiveText);
    }
}