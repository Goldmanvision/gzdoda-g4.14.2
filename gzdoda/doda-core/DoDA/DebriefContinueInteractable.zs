/*//////////////////////////|
// DoDA/DebriefContinueInteractable.zs
*///////////////////////////|

class DoDADebriefContinueInteractable : Actor
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

        Console.MidPrint(
            Font.GetFont("DoDAPalmFont"),
            "$DODA_RETURNING_TO_FIELD",
            true
        );

        Console.Printf("DoDA: Returning to field.");

        level.ChangeLevel("MAP01");
        return true;
    }

States
{
Spawn:
    PMAP A -1;
    Stop;

Activated:
	PMAP C 100;
    PMAP C -1
    {
        level.ExitLevel(0, false);
    }
    Stop;
}
}