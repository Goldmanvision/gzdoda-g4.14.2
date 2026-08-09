///////////////////////////
// DoDA/UI/FieldAgent/HUDWeaponBridge.zs
///////////////////////////

// A reference class is used instead of a struct because the status-bar
// bridge returns weapon data to the HUD.
class DoDAWeaponHUDData : Object
{
    bool Available;
    bool Equipped;

    String Label;

    int MagazineRounds;
    int MagazineCapacity;
    bool ChamberLoaded;
}

class DoDAWeaponHUDBridge : Object
{
    static clearscope DoDAWeaponHUDData GetWeaponData(
        Weapon weapon,
        Weapon readyWeapon
    )
    {
        let pistol = DoDAPistol(weapon);

        if (pistol == null || !pistol.UsesWeaponHUD())
        {
            return null;
        }

        let data = new("DoDAWeaponHUDData");

        data.Available = true;
        data.Equipped = weapon == readyWeapon;
        data.MagazineRounds = pistol.GetMagazineRounds();
        data.MagazineCapacity = pistol.GetMagazineCapacity();
        data.ChamberLoaded = pistol.IsChamberLoaded();

        if (DoDAB92Left(weapon) != null)
        {
            data.Label = "LEFT B92";
        }
        else if (DoDAB92Right(weapon) != null)
        {
            data.Label = "RIGHT B92";
        }
        else
        {
            data.Label = "B92";
        }

        return data;
    }

    static clearscope DoDAWeaponHUDData GetActiveWeaponData(
        Weapon readyWeapon
    )
    {
        return GetWeaponData(readyWeapon, readyWeapon);
    }

    static clearscope DoDAWeaponHUDData GetCompanionWeaponData(
        Actor pawn,
        Weapon readyWeapon
    )
    {
        if (pawn == null || readyWeapon == null)
        {
            return null;
        }

        Name companionClass = 'None';

        if (DoDAB92Left(readyWeapon) != null)
        {
            companionClass = 'DoDAB92Right';
        }
        else if (DoDAB92Right(readyWeapon) != null)
        {
            companionClass = 'DoDAB92Left';
        }

        if (companionClass == 'None')
        {
            return null;
        }

        let companionWeapon = Weapon(
            pawn.FindInventory(companionClass)
        );

        return GetWeaponData(companionWeapon, readyWeapon);
    }

    static clearscope int GetReserveRounds(
        Weapon readyWeapon
    )
    {
        let pistol = DoDAPistol(readyWeapon);

        if (pistol == null || !pistol.UsesWeaponHUD())
        {
            return 0;
        }

        return pistol.GetReserveRounds();
    }
}