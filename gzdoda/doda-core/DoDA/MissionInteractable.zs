/*//////////////////////////|
// DoDA/MissionInteractable.zs
*///////////////////////////|

class DoDAMissionInteractable : Actor
{
    private bool mHasBeenUsed;

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

        if (mHasBeenUsed)
        {
            Console.Printf("DoDA: Mission interactable already used.");
            return false;
        }

        DoDAMissionDirector director =
            DoDAMissionDirector(EventHandler.Find("DoDAMissionDirector"));

        if (director == null)
        {
            Console.Printf("DoDA: MissionDirector not found.");
            return false;
        }

        mHasBeenUsed = true;

        Console.Printf("DoDA: Mission interactable used.");

        director.CompleteMission();

        Console.Printf("DoDA: MissionDirector mission status updated.");

        SetStateLabel("Activated");
        return true;
    }

    States
    {
    Spawn:
        BON1 A -1;
        Stop;

    Activated:
        BON1 B -1;
        Stop;
    }
}