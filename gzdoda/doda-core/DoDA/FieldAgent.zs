/*//////////////////////////|
// DoDA/FieldAgent.zs
*///////////////////////////|

class FieldAgent : DoomPlayer
{
    double DeadzoneX;
    double DeadzoneY;
    bool IsAiming;

Default
{
    Player.DisplayName "DoDA Agent";
    Player.StartItem "DoDAWeaponBase";
    Player.StartItem "Clip", 50;
    Player.StartItem "Fist";
    Player.StartItem "DoDADeadzonePistol";
    Player.StartItem "Clip", 24;
    Player.CrouchSprite "PLYC";
}
}