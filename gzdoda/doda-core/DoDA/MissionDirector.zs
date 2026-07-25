/*//////////////////////////|
// DoDA/MissionDirector.zs
*///////////////////////////|

class DoDAMissionDirector : EventHandler
{
    DoDAMissionResult MissionResult;
    int MissionIndex;
    int MissionPercentComplete;
    int MissionPhase;
    string MissionName;
    string MissionDescription;

    override void WorldLoaded(WorldEvent e)
    {
        if (!e.IsSaveGame && !e.IsReopen)
        {
            MissionResult = MISSION_PENDING;
            MissionIndex = 0;
            MissionPercentComplete = 0;
            MissionPhase = 0;
            MissionName = "Mission 01";
            MissionDescription = "Mission description pending.";
            Console.Printf("DoDA: Mission initialized as PENDING.");
        }
    }

    clearscope DoDAMissionResult GetMissionResult()
    {
        return MissionResult;
    }

    void CompleteMission()
    {
        MissionResult = MISSION_SUCCESS;
        Console.Printf("DoDA: Mission set to SUCCESS.");
    }
}