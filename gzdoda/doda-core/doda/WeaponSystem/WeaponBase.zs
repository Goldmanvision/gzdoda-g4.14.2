/*//////////////////////////|
// DoDA/WeaponSystem/WeaponBase.zs
*///////////////////////////|

class DoDAWeaponBase : DoomWeapon
{
    protected action void A_DoDAWeaponPose()
    {
        if (player == null)
        {
            return;
        }

        DoDAWeaponAimController aimController = DoDAWeaponAimController(player.FindInventory("DoDAWeaponAimController"));
        if (aimController == null)
        {
            return;
        }

        PSprite psp = player.GetPSprite(PSP_WEAPON);
        if (psp == null)
        {
            return;
        }

        double weaponYaw;
        double weaponPitch;
        aimController.GetWeaponPose(weaponYaw, weaponPitch);

        bool leftHand = aimController.IsWeaponHandSideLeft();
        double sideBase = leftHand ? -10.0 : 10.0;
        double xOffset = sideBase + weaponYaw * 0.3;
        double yOffset = weaponPitch * 0.25;

        psp.x = int(Clamp(xOffset, -28.0, 28.0));
        psp.y = int(WEAPONTOP + Clamp(yOffset, -10.0, 10.0));
    }

    protected action void A_DoDAWeaponFire()
    {
        if (player == null)
        {
            return;
        }

        Weapon weap = player.ReadyWeapon;
        if (weap == null || invoker != weap || stateinfo == null || stateinfo.mStateType != STATE_Psprite)
        {
            return;
        }

        if (!weap.DepleteAmmo(weap.bAltFire, true))
        {
            return;
        }

        DoDAWeaponAimController aimController = DoDAWeaponAimController(player.FindInventory("DoDAWeaponAimController"));

        double weaponYaw = Angle;
        double weaponPitch = Pitch;
        if (aimController != null)
        {
            aimController.GetMuzzleAlignment(weaponYaw, weaponPitch);
        }

        int damage = 5;
        player.LineAttack(weaponYaw, PLAYERMISSILERANGE, weaponPitch, damage, "Hitscan", "BulletPuff");
        player.SetPsprite(PSP_FLASH, weap.FindState("Flash"), true);
        player.A_StartSound("weapons/pistol", CHAN_WEAPON);

        if (aimController != null)
        {
            double namedPistolPitchKick = 8.0;
            double namedPistolYawKick = 2.5;
            aimController.ApplyRecoil(namedPistolPitchKick, namedPistolYawKick);
        }
    }
}

class DoDAPistol : DoDAWeaponBase
{
    Default
    {
        Weapon.SelectionOrder 1900;
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 20;
        Weapon.SlotNumber 0;
        Weapon.AmmoType "Clip";
        Inventory.MaxAmount 1;
        Inventory.Amount 1;
        +WEAPON.WIMPY_WEAPON;
        Inventory.PickupMessage "$PICKUP_PISTOL_DROPPED";
        Obituary "$OB_MPPISTOL";
        Tag "$TAG_PISTOL";
    }

    States
    {
    Ready:
        PISG A 0 A_DoDAWeaponPose;
        PISG A 1 A_WeaponReady;
        Loop;

    Deselect:
        PISG A 1 A_Lower;
        Loop;

    Select:
        PISG A 1 A_Raise;
        Goto Ready;

    Fire:
        PISG A 4 A_DoDAWeaponFire;
        PISG A 0 A_DoDAWeaponPose;
        PISG B 6 A_ReFire;
        PISG C 4;
        PISG B 5 A_ReFire;
        Goto Ready;

    Flash:
        PISF A 7 Bright A_Light1;
        Goto LightDone;
        PISF A 7 Bright A_Light1;
        Goto LightDone;

    Spawn:
        PIST A -1;
        Stop;
    }
}