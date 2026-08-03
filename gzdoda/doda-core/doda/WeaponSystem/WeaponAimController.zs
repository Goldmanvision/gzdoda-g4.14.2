/*//////////////////////////|
// DoDA/WeaponSystem/WeaponAimController.zs
*///////////////////////////|

class DoDAWeaponAimController : Inventory
{
	const RecenterStep = 0.35;

	double PoseYaw;
	double PosePitch;

	Default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNCLEARABLE;
	}

	override void Tick()
	{
		Super.Tick();
		PoseYaw = MoveTowardZero(PoseYaw, RecenterStep);
		PosePitch = MoveTowardZero(PosePitch, RecenterStep);
	}

	void SetPose(double yaw, double pitch)
	{
		PoseYaw = yaw;
		PosePitch = pitch;
	}

	void ClearPose()
	{
		PoseYaw = 0.0;
		PosePitch = 0.0;
	}

	void GetPose(out double yaw, out double pitch)
	{
		yaw = PoseYaw;
		pitch = PosePitch;
	}

	double MoveTowardZero(double value, double step)
	{
		if(value > 0.0)
		{
			value -= step;
			if(value < 0.0)
			{
				value = 0.0;
			}
		}
		else if(value < 0.0)
		{
			value += step;
			if(value > 0.0)
			{
				value = 0.0;
			}
		}

		return value;
	}
}