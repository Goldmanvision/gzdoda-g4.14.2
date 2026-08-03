class DoDAHUDDeadzone : Object
{
    void DrawDeadzone(PlayerInfo currentPlayer)
    {
        PlayerPawn playerPawn = currentPlayer != null ? currentPlayer.mo : null;
        FieldAgent agent = FieldAgent(playerPawn);

        if (agent == null || !agent.IsDeadzoneAimActive())
        {
            return;
        }

        int screenWidth = Screen.GetWidth();
        int screenHeight = Screen.GetHeight();

        int centerX = screenWidth / 2;
        int centerY = screenHeight / 2;

        int deadzoneHalfWidth = screenWidth / 8;
        int deadzoneHalfHeight = screenHeight / 8;

        int left = centerX - deadzoneHalfWidth;
        int right = centerX + deadzoneHalfWidth;
        int top = centerY - deadzoneHalfHeight;
        int bottom = centerY + deadzoneHalfHeight;

        int dotX = centerX + int(agent.GetDeadzoneX());
        int dotY = centerY + int(agent.GetDeadzoneY());

        Color boxColor = Color(0, 255, 0);
        Color centerColor = Color(96, 255, 96);
        Color dotColor = Color(255, 0, 0);

        Screen.DrawThickLine(left, top, right, top, 1.5, boxColor);
        Screen.DrawThickLine(right, top, right, bottom, 1.5, boxColor);
        Screen.DrawThickLine(right, bottom, left, bottom, 1.5, boxColor);
        Screen.DrawThickLine(left, bottom, left, top, 1.5, boxColor);

        Screen.DrawThickLine(centerX - 4, centerY, centerX + 4, centerY, 1.0, centerColor);
        Screen.DrawThickLine(centerX, centerY - 4, centerX, centerY + 4, 1.0, centerColor);

        Screen.DrawThickLine(dotX - 3, dotY, dotX + 3, dotY, 2.0, dotColor);
        Screen.DrawThickLine(dotX, dotY - 3, dotX, dotY + 3, 2.0, dotColor);
    }
}