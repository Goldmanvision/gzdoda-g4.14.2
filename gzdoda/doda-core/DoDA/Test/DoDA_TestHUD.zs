///////////////////////////
// root/doda/hud.zsc
//
//////////////////////////

class DoDA_TestHUD : BaseStatusBar
{
    override void Init()
    {
        Super.Init();
        SetSize(0, 320, 200);
    }

    override void Draw(int state, double ticFrac)
    {
        Super.Draw(state, ticFrac);

        let plr = CPlayer;
        if (!plr || !plr.ReadyWeapon) return;

        let wpn = DoDA_TestWeapon(plr.ReadyWeapon);
        if (!wpn) return;

        if (!wpn.deadzoneActiveHUD)
        {
            return;
        }

        int screenW = Screen.GetWidth();
        int screenH = Screen.GetHeight();

        double cx = screenW / 2.0;
        double cy = screenH / 2.0;

        double aspect = screenW / double(screenH);
        double refAspect = 4.0 / 3.0;

        double halfFovBase = plr.FOV * 0.5;
        double halfFovYaw = atan(tan(halfFovBase) * (aspect / refAspect));
        double halfFovPitch = halfFovBase;

        double dotX = cx - (tan(wpn.yawGap) / tan(halfFovYaw)) * cx;
        double dotY = cy + (tan(wpn.pitchGap) / tan(halfFovPitch)) * cy;

        double boxHalfX = (tan(wpn.deadzoneDegrees) / tan(halfFovYaw)) * cx;
        double boxHalfY = (tan(wpn.deadzoneDegrees) / tan(halfFovPitch)) * cy;

        Screen.Dim(0x00FF00, 0.6, int(cx - boxHalfX), int(cy - boxHalfY), 2, int(boxHalfY * 2));
        Screen.Dim(0x00FF00, 0.6, int(cx + boxHalfX), int(cy - boxHalfY), 2, int(boxHalfY * 2));

        Screen.Dim(0xFF0000, 0.9, int(dotX - 3), int(dotY - 3), 6, 6);
    }
}
