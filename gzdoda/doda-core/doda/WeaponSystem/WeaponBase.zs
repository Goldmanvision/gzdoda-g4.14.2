/*//////////////////////////|
// DoDA/WeaponSystem/WeaponBase.zs
//
// Right-hand Beretta baseline.
//
// - Semi-auto: one shot per click/release cycle.
// - One-tic firing animation.
// - Weapon pose offset disabled until deadzone input is verified.
// - Hipfire remains inaccurate; deadzone aim remains precise.
*///////////////////////////|*/

class DoDAPistol : Weapon
{
    double hipfireSpread;
    double deadzoneSpread;
    double leanAppliedOffset;
    bool hasReleasedTrigger;

    Default
    {
        Weapon.SlotNumber 2;
        Weapon.SelectionOrder 100;
        Weapon.AmmoType "Clip";
        Weapon.AmmoUse 1;
        Weapon.AmmoGive 0;
        Weapon.Kickback 100;
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        Tag "DoDA Test Weapon";
        Inventory.PickupMessage "Picked up the DoDA Test Weapon";
    }

    override void Tick()
    {
        Super.Tick();

        hipfireSpread = 6.0;
        deadzoneSpread = 0.15;
        leanAppliedOffset = 0.0;

        if (owner && owner.player)
        {
            if ((owner.player.cmd.buttons & BT_ATTACK) == 0)
            {
                hasReleasedTrigger = true;
            }
        }
    }

    action bool DoDA_CanFireSemiAuto()
    {
        if (!invoker.hasReleasedTrigger)
        {
            return false;
        }

        invoker.hasReleasedTrigger = false;
        return true;
    }

    action void DoDA_FireTrace()
    {
        FieldAgent agent = FieldAgent(self);
        if (agent == null || player == null)
        {
            return;
        }

        bool deadzoneActive = agent.IsDeadzoneAimActive();
        double spread = deadzoneActive ? invoker.deadzoneSpread : invoker.hipfireSpread;

        double randomAngle = FRandom[DoDASpread](0.0, 360.0);
        double randomRadius = FRandom[DoDASpread](0.0, spread);

        double fireYaw = angle + (cos(randomAngle) * randomRadius);
        double firePitch = pitch + (sin(randomAngle) * randomRadius);

        A_StartSound("weapons/pistol", CHAN_WEAPON);

        FLineTraceData trace;
        double attackZ =
            height * 0.5
            - floorclip
            + player.mo.AttackZOffset * player.crouchFactor;

        bool hit = LineTrace(
            fireYaw,
            2048,
            firePitch,
            0,
            attackZ,
            0,
            invoker.leanAppliedOffset,
            trace
        );

        if (!hit)
        {
            return;
        }

        if (
            trace.HitType == TRACE_HitWall
            || trace.HitType == TRACE_HitFloor
            || trace.HitType == TRACE_HitCeiling
        )
        {
            Spawn("BulletPuff", trace.HitLocation);
            return;
        }

        if (trace.HitType == TRACE_HitActor && trace.HitActor)
        {
            let target = trace.HitActor;
            double targetTop = target.Pos.Z + target.Height;
            double headBandStart = targetTop - (target.Height * 0.22);
            bool headshot = trace.HitLocation.Z >= headBandStart;
            int damage = headshot ? 35 : 10;

            target.DamageMobj(self, self, damage, 'Hitscan');
            Spawn("BulletPuff", trace.HitLocation);
        }
    }

    states
    {
    Spawn:
        B92L G -1;
        Stop;

    Ready:
        B92L G 1 A_WeaponReady;
        Loop;

    Deselect:
        B92L G 1 A_Lower;
        Loop;

    Select:
        B92L G 1 A_Raise;
        Loop;

    Fire:
        B92L G 0 DoDA_CanFireSemiAuto;
        B92L A 1;
        B92L B 1;
        B92L C 1 Bright DoDA_FireTrace;
        B92L D 1;
        B92L E 1;
        B92L F 1;
        B92L G 1;
        Goto Ready;
    }
}
