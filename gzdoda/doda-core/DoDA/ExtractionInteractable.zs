/*//////////////////////////|
// DoDA/ExtractionInteractable.zs
*///////////////////////////|

class DoDAExtractionInteractable : Actor
{
    bool Activated;

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

        if (Activated)
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
            Console.MidPrint(
                Font.GetFont("SmallFont"),
                "$DODA_EXTRACTION_LOCKED",
                true
            );

            Console.Printf("DoDA: Extraction denied. Mission not complete.");
            return false;
        }

        Activated = true;

        Console.MidPrint(
            Font.GetFont("SmallFont"),
            "$DODA_EXTRACTION_AUTHORIZED",
            true
        );

        Console.Printf("DoDA: Extraction authorized.");

        SetStateLabel("Activated");
        return true;
    }

    States
    {
    Spawn:
        PMAP A -1;
        Stop;

    Activated:
        PMAP C 100;
        TNT1 A 0
        {
            level.ExitLevel(0, false);
        }
        Stop;
    }
}