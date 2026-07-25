/*//////////////////////////|
// DoDA/DebugPickup.zs
*///////////////////////////|

class DoDAMissionCompletePickup : Inventory
{
    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.Icon "EVI1A0";
        Inventory.PickupMessage "Mission item acquired.";
        +INVENTORY.INVBAR;
    }

    States
    {
Spawn:
    BON1 A -1;
    Stop;
    }

    override bool Use(bool pickup)
    {
        Console.Printf("Mission item used.");

        DoDAMissionDirector director = DoDAMissionDirector(EventHandler.Find("DoDAMissionDirector"));
        if (director != null)
        {
            director.CompleteMission();
            Console.Printf("DoDA: MissionDirector mission status updated.");
        }
        else
        {
            Console.Printf("DoDA: MissionDirector not found.");
        }

        return true;
    }
}