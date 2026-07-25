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
            MissionPhase = 1;
            MissionName = "Mission 01";
            MissionDescription = "talk to INFORMANT.";

            Console.Printf("DoDA: Mission initialized as PENDING.");

            if (level.MapName == "MAP02")
            {
                Console.MidPrint(
                    Font.GetFont("SmallFont"),
                    "$DODA_DEBRIEF_CONFIRMED",
                    true
                );

                Console.Printf("DoDA: Debrief confirmation displayed.");
            }
        }
    }

    clearscope DoDAMissionResult GetMissionResult()
    {
        return MissionResult;
    }

    clearscope int GetMissionIndex()
    {
        return MissionIndex;
    }

    clearscope int GetMissionPercentComplete()
    {
        return MissionPercentComplete;
    }

    clearscope int GetMissionPhase()
    {
        return MissionPhase;
    }

    clearscope String GetMissionName()
    {
        return MissionName;
    }

    clearscope String GetMissionDescription()
    {
        return MissionDescription;
    }

    void CompleteMission()
    {
        MissionResult = MISSION_SUCCESS;
        MissionPercentComplete = 100;
        MissionPhase = 2;
        MissionDescription = "log evidence on LAPTOP.";
        Console.Printf("DoDA: Mission set to SUCCESS.");
    }
}