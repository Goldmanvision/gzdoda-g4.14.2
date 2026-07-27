/*//////////////////////////|
// DoDA/MissionSystem/Things/MissionCompletePickup.zs
*///////////////////////////|*/

class DoDAMissionCompletePickup : Inventory
{
    Default
    {
        Radius 20;
        Height 16;
        Scale 0.3;

        Inventory.Amount 1;
        Inventory.MaxAmount 1;

        +COUNTITEM;
        +INVENTORY.INVBAR;
    }

    override bool Use(bool pickup)
    {
        if (Owner == null)
        {
            Console.Printf("DoDA: Mission pickup has no inventory owner.");
            return false;
        }

        DoDACampaignState campaignState =
            DoDACampaignState(Owner.FindInventory("DoDACampaignState"));

        if (campaignState == null)
        {
            Console.Printf("DoDA: CampaignState not found for mission pickup.");
            return false;
        }

        if (level.MapName != "MAP01")
        {
            Console.MidPrint(
                Font.GetFont("SmallFont"),
                "$DODA_INACTIVE_OBJECTIVE",
                true
            );

            Console.Printf(
                "DoDA: Mission pickup use denied. Map=%s NextMissionIndex=%d",
                level.MapName,
                campaignState.GetNextMissionIndex()
            );

            return false;
        }

        if (campaignState.GetNextMissionIndex() < 0 || campaignState.GetNextMissionIndex() > 1)
        {
            Console.MidPrint(
                Font.GetFont("SmallFont"),
                "$DODA_INACTIVE_OBJECTIVE",
                true
            );

            Console.Printf(
                "DoDA: Mission pickup use denied. Map=%s NextMissionIndex=%d",
                level.MapName,
                campaignState.GetNextMissionIndex()
            );

            return false;
        }

        DoDAMissionDirector director =
            DoDAMissionDirector(EventHandler.Find("DoDAMissionDirector"));

        if (director == null)
        {
            Console.Printf("DoDA: MissionDirector not found for mission pickup.");
            return false;
        }

        if (director.GetMissionPercentComplete() >= 100)
        {
            Console.Printf("DoDA: Mission pickup ignored. Mission already complete.");
            return false;
        }

        Console.Printf("DoDA: Mission item used from player inventory.");

        director.CompleteMission();

        Console.MidPrint(
            Font.GetFont("SmallFont"),
            "$DODA_MISSION_COMPLETE",
            true
        );

        return true;
    }

    States
    {
    Spawn:
        EVI1 A -1;
        Stop;
    }
}