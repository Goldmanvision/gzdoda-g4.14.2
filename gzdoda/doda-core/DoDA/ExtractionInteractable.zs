/*//////////////////////////|
// DoDA/ExtractionInteractable.zs
*///////////////////////////|

class DoDAExtractionInteractable : Actor
{
    Default
    {
        Radius 16;
        Height 32;

        +SOLID;
        +USESPECIAL;
    }

    override bool Used(Actor user)
    {
        if (user == null)
        {
            return false;
        }

        DoDAMissionDirector director =
            DoDAMissionDirector(EventHandler.Find("DoDAMissionDirector"));

        if (director == null)
        {
            Console.Printf("DoDA: MissionDirector not found.");
            return false;
        }

        if (director.GetMissionResult() != MISSION_SUCCESS)
        {
            Console.Printf("DoDA: Extraction denied. Mission not complete.");
            return false;
        }

        Console.Printf("DoDA: Extraction authorized.");

        level.ExitLevel(0, false);
        return true;
    }

    States
    {
    Spawn:
        BON1 C -1;
        Stop;
    }
}