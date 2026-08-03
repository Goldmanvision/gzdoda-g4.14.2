///////////////////////////
// root/doda/player.zsc
//
//////////////////////////
class DoDA_TestPlayer : DoomPlayer
{
    Default
    {
        Player.DisplayName "DoDA Tester";
        Player.StartItem "DoDA_TestWeapon", 1;
        Player.StartItem "Clip", 50;
        Player.WeaponSlot 2, "DoDA_TestWeapon";

        Health 100;
        Radius 16;
        Height 56;
        Player.ViewHeight 41;
        Player.JumpZ 8;
        Speed 1;
        PainChance 255;
        Player.ColorRange 0, 0;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();

        if (player)
        {
            player.ReadyWeapon = Weapon(FindInventory("DoDA_TestWeapon"));
            player.PendingWeapon = player.ReadyWeapon;
        }
    }
}
