class FieldAgent : DoomPlayer
{
    private bool m_IsDeadzoneAimMode;
    private double m_AimX;
    private double m_AimY;

    Default
    {
        Player.DisplayName "DoDA Agent";
        Player.StartItem "DoDAPistol";
        Player.StartItem "Clip", 50;
        Player.CrouchSprite "PLYC";
        Health 100;
        Radius 16;
        Height 56;
        Player.ViewHeight 41;
        Player.JumpZ 8;
        Speed 1;
        Player.ColorRange 0, 0;
    }

    override void Tick()
    {
        Super.Tick();

        if (player == null)
        {
            return;
        }

        bool deadzoneRequested = (player.cmd.buttons & BT_ALTATTACK) != 0;
        SetDeadzoneAimMode(deadzoneRequested);

        if (!m_IsDeadzoneAimMode)
        {
            m_AimX = 0.0;
            m_AimY = 0.0;
        }
    }

    void SetDeadzoneAimMode(bool enabled)
    {
        m_IsDeadzoneAimMode = enabled;
        if (!enabled)
        {
            m_AimX = 0.0;
            m_AimY = 0.0;
        }
    }

    clearscope bool IsDeadzoneAimActive()
    {
        return m_IsDeadzoneAimMode;
    }

    clearscope double GetDeadzoneX()
    {
        return m_AimX;
    }

    clearscope double GetDeadzoneY()
    {
        return m_AimY;
    }

    void AimDeadzoneMouse(int mouseX, int mouseY)
    {
        if (!m_IsDeadzoneAimMode || player == null)
        {
            return;
        }

        double dx = mouseX * 1.5;
        double dy = mouseY * 1.5;

        double nextX = m_AimX + dx;
        double nextY = m_AimY + dy;

        double limitX = Screen.GetWidth() / 8.0;
        double limitY = Screen.GetHeight() / 8.0;

        double clampedX = Clamp(nextX, -limitX, limitX);
        double clampedY = Clamp(nextY, -limitY, limitY);

        double overflowX = nextX - clampedX;
        double overflowY = nextY - clampedY;

        m_AimX = clampedX;
        m_AimY = clampedY;

        if (overflowX != 0.0)
        {
            A_SetViewAngle(angle + overflowX * 0.35);
        }

        if (overflowY != 0.0)
        {
            A_SetViewPitch(pitch - overflowY * 0.25);
        }
    }
}