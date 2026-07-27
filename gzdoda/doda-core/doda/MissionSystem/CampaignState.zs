/*//////////////////////////|
// DoDA/MissionSystem/CampaignState.zs
*///////////////////////////|

class DoDACampaignState : Inventory
{
    int NextMissionIndex;
    bool WasLoggedThisMap;

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

        if (Owner == null)
        {
            return;
        }

        if (WasLoggedThisMap)
        {
            return;
        }

        WasLoggedThisMap = true;

        Console.Printf(
            "DoDA CampaignState observed: Map=%s NextMissionIndex=%d OwnerClass=%s",
            level.MapName,
            NextMissionIndex,
            Owner.GetClassName()
        );
    }

    void MarkMapSeen()
    {
        WasLoggedThisMap = false;
    }

    clearscope int GetNextMissionIndex()
    {
        return NextMissionIndex;
    }

    void EnsureInitialized()
    {
        Console.Printf(
            "DoDA CampaignState initialized: Map=%s NextMissionIndex=%d",
            level.MapName,
            NextMissionIndex
        );
    }

    void AdvanceToNextMission()
    {
        NextMissionIndex = NextMissionIndex + 1;
        WasLoggedThisMap = false;

        Console.Printf(
            "DoDA CampaignState advanced: Map=%s NextMissionIndex=%d",
            level.MapName,
            NextMissionIndex
        );
    }
}