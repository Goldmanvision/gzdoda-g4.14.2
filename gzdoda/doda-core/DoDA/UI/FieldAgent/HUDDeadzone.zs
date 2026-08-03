class DoDAHUDDeadzone : Object
{
    void DrawDeadzone(PlayerInfo currentPlayer)
    {
        if (currentPlayer == null || currentPlayer.mo == null)
        {
            return;
        }

        PlayerPawn playerPawn = currentPlayer.mo;
        FieldAgent agent = FieldAgent(playerPawn);

        bool hasWeaponState = false;
        bool weaponDeadzoneActive = false;
        double yawGap = 0.0;
        double pitchGap = 0.0;
        double deadzoneDegrees = 0.0;

        if (currentPlayer.ReadyWeapon != null)
        {
            let weaponState = DoDAPistol(currentPlayer.ReadyWeapon);
            if (weaponState != null)
            {
                hasWeaponState = true;
                weaponDeadzoneActive = weaponState.deadzoneActiveHUD;
                yawGap = weaponState.yawGap;
                pitchGap = weaponState.pitchGap;
                deadzoneDegrees = weaponState.deadzoneDegrees;
            }
        }

        if (!hasWeaponState || !weaponDeadzoneActive)
        {
            if (agent == null || !agent.IsDeadzoneAimActive())
            {
                return;
            }
        }

        int screenWidth = Screen.GetWidth();
        int screenHeight = Screen.GetHeight();

        int centerX = screenWidth / 2;
        int centerY = screenHeight / 2;

        double aspect = screenWidth / double(screenHeight);
        double refAspect = 4.0 / 3.0;
        double halfFovBase = currentPlayer.FOV * 0.5;
        double halfFovYaw = atan(tan(halfFovBase) * (aspect / refAspect));
        double halfFovPitch = halfFovBase;

        double dotX = centerX - (tan(yawGap) / tan(halfFovYaw)) * centerX;
        double dotY = centerY + (tan(pitchGap) / tan(halfFovPitch)) * centerY;

        double boxHalfWidth = 0.0;
        double boxHalfHeight = 0.0;

        if (hasWeaponState && weaponDeadzoneActive)
        {
            boxHalfWidth = (tan(deadzoneDegrees) / tan(halfFovYaw)) * centerX;
            boxHalfHeight = (tan(deadzoneDegrees) / tan(halfFovPitch)) * centerY;
        }
        else
        {
            boxHalfWidth = screenWidth / 8.0;
            boxHalfHeight = screenHeight / 8.0;
            dotX = centerX + int(agent.GetDeadzoneX());
            dotY = centerY + int(agent.GetDeadzoneY());
        }

        int left = int(centerX - boxHalfWidth);
        int right = int(centerX + boxHalfWidth);
        int top = int(centerY - boxHalfHeight);
        int bottom = int(centerY + boxHalfHeight);

        Color boxColor = Color(0, 255, 0);
        Color centerColor = Color(96, 255, 96);
        Color dotColor = Color(255, 0, 0);

        Screen.DrawThickLine(left, top, right, top, 2, boxColor);
        Screen.DrawThickLine(right, top, right, bottom, 2, boxColor);
        Screen.DrawThickLine(right, bottom, left, bottom, 2, boxColor);
        Screen.DrawThickLine(left, bottom, left, top, 2, boxColor);

        Screen.DrawThickLine(centerX - 4, centerY, centerX + 4, centerY, 1, centerColor);
        Screen.DrawThickLine(centerX, centerY - 4, centerX, centerY + 4, 1, centerColor);

        Screen.DrawThickLine(int(dotX - 3), int(dotY), int(dotX + 3), int(dotY), 2, dotColor);
        Screen.DrawThickLine(int(dotX), int(dotY - 3), int(dotX), int(dotY + 3), 2, dotColor);
    }
}