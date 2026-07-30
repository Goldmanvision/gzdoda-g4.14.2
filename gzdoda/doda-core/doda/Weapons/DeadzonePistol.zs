/*//////////////////////////|
// DoDA/Weapons/DeadzonePistol.zs
*///////////////////////////|*/

class DoDADeadzonePistol : Weapon
{
    Default
    {
        Weapon.SelectionOrder 400;
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 12;
        Weapon.AmmoType "Clip";
        Inventory.PickupMessage "DoDA deadzone pistol";
        Tag "DoDA Deadzone Pistol";
        +WEAPON.NOAUTOFIRE;
    }

    override void DoEffect()
    {
        Super.DoEffect();
    }

    action void DoDAApplyDeadzonePose()
    {
        if (self == null || self.player == null || self.player.mo == null)
        {
            return;
        }

        let fieldAgent = FieldAgent(self.player.mo);
        if (fieldAgent == null)
        {
            return;
        }

        double deadzoneX = fieldAgent.DeadzoneX;
        double deadzoneY = fieldAgent.DeadzoneY;

        double offsetX = deadzoneX * 1.2;
        double offsetY = 32.0 + (deadzoneY * 1.15);

        A_OverlayOffset(PSP_WEAPON, offsetX, offsetY, WOF_INTERPOLATE);
        A_OverlayScale(PSP_WEAPON, 1.0, 1.0, WOF_INTERPOLATE);
    }

    action void DoDAWeaponReadyTick()
    {
        A_WeaponReady(WRF_NOSECONDARY);
        DoDAApplyDeadzonePose();
    }

    action void DoDAWeaponFire()
    {
        if (self == null || self.player == null || self.player.mo == null)
        {
            return;
        }

        let fieldAgent = FieldAgent(self.player.mo);
        if (fieldAgent == null)
        {
            return;
        }

        double spread = fieldAgent.IsAiming ? 0.35 : 4.5;
        A_FireBullets(spread, spread, -1, 10, "BulletPuff");
        A_StartSound("weapons/pistol", CHAN_WEAPON);
        DoDAApplyDeadzonePose();
    }

    States
    {
    Select:
        PISG A 1 A_Raise;
        Loop;

    Deselect:
        PISG A 1 A_Lower;
        Loop;

    Ready:
        PISG A 1 DoDAWeaponReadyTick;
        Loop;

    Fire:
        PISG A 1 DoDAWeaponFire;
        PISG B 1 DoDAApplyDeadzonePose;
        PISG C 1 DoDAApplyDeadzonePose;
        Goto Ready;
    }
}