/*//////////////////////////|
// DoDA/MissionSystem/MissionDirector.zs
*///////////////////////////|

class DoDAMissionDirector : EventHandler
{
    DoDAMissionResult MissionResult;
    int MissionIndex;
    int MissionPercentComplete;
    int MissionPhase;
    string MissionName;
    string MissionDescription;

    bool bIsSaveGame;
    bool bIsReopen;

    void ConfigureMissionForIndex(int index)
    {
        MissionIndex = index;

        if (index <= 0)
        {
            MissionName = "Mission 01";
            MissionDescription = "talk to INFORMANT.";
        }
        else if (index == 1)
        {
            MissionName = "Mission 02";
            MissionDescription = "collect evidence from TERMINAL.";
        }
        else
        {
            MissionName = "Mission 03";
            MissionDescription = "secure the SECONDARY FILE.";
        }
    }

    void LogMissionState(string label)
    {
        Console.Printf(
            "DoDA Director [%s] Map=%s Save=%d Reopen=%d Result=%d Index=%d Progress=%d Phase=%d Name=%s Description=%s",
            label,
            level.MapName,
            bIsSaveGame,
            bIsReopen,
            MissionResult,
            MissionIndex,
            MissionPercentComplete,
            MissionPhase,
            MissionName,
            MissionDescription
        );
    }

    void LogHUDSnapshot(string label)
    {
        Console.Printf(
            "DoDA HUD Snapshot [%s] Source=Director Map=%s Mission=%s Status=%d Progress=%d Phase=%d Objective=%s",
            label,
            level.MapName,
            MissionName,
            MissionResult,
            MissionPercentComplete,
            MissionPhase,
            MissionDescription
        );
    }

    override void WorldLoaded(WorldEvent e)
    {
        bIsSaveGame = e.IsSaveGame;
        bIsReopen = e.IsReopen;

        Console.Printf(
            "DoDA Director WorldLoaded: Map=%s Save=%d Reopen=%d",
            level.MapName,
            e.IsSaveGame,
            e.IsReopen
        );

        LogMissionState("before initialization gate");

        if (!e.IsSaveGame && !e.IsReopen)
        {
            int configuredIndex = 0;
            PlayerPawn playerPawn = players[consoleplayer].mo;
            DoDACampaignState campaignState = null;

            if (playerPawn != null)
            {
                campaignState = DoDACampaignState(
                    playerPawn.FindInventory("DoDACampaignState")
                );

                if (campaignState == null)
                {
                    playerPawn.GiveInventory("DoDACampaignState", 1);

                    campaignState = DoDACampaignState(
                        playerPawn.FindInventory("DoDACampaignState")
                    );
                }
            }

            if (campaignState != null)
            {
                campaignState.EnsureInitialized();
                configuredIndex = campaignState.GetNextMissionIndex();
            }
            else
            {
                Console.Printf("DoDA: CampaignState unavailable during WorldLoaded.");
            }

            MissionResult = MISSION_PENDING;
            MissionPercentComplete = 0;
            MissionPhase = 1;
            ConfigureMissionForIndex(configuredIndex);

            Console.Printf("DoDA Mission initialized as PENDING.");
        }
        else
        {
            Console.Printf("DoDA Director initialization skipped for save/reopen.");
        }

        LogMissionState("after initialization gate");
        LogHUDSnapshot("after WorldLoaded");

        if (level.MapName == "MAP02" && !e.IsSaveGame && !e.IsReopen)
        {
            Console.MidPrint(
                Font.GetFont("SmallFont"),
                "$DODA_DEBRIEF_CONFIRMED",
                true
            );

            Console.Printf("DoDA Debrief confirmation displayed.");
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
        Console.Printf("DoDA Director CompleteMission called.");
        LogMissionState("before CompleteMission");

        MissionResult = MISSION_SUCCESS;
        MissionPercentComplete = 100;
        MissionPhase = 2;
        MissionDescription = "log evidence on LAPTOP.";

        Console.Printf("DoDA Mission set to SUCCESS.");
        LogMissionState("after CompleteMission");
        LogHUDSnapshot("after CompleteMission");
    }
}