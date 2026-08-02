/*//////////////////////////|
// DoDA/FieldAgent.zs
*///////////////////////////|*/

class FieldAgent : DoomPlayer
{
	Default
	{
		Player.DisplayName "DoDA Agent";
		Player.StartItem "DoDAPistol";
		Player.StartItem "Clip", 50;
		Player.CrouchSprite "PLYC";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		if(FindInventory("DoDAWeaponAimController") == null)
		{
			GiveInventory("DoDAWeaponAimController", 1);
		}

		DoDAWeaponAimController aimController =
			DoDAWeaponAimController(
				FindInventory("DoDAWeaponAimController")
			);

		if(aimController != null)
		{
			aimController.SetPose(12.0, -4.0);

			Console.PrintF(
				"DoDA: Debug weapon pose applied. Yaw=12.0 Pitch=-4.0"
			);
		}
	}
}

/*
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
*/