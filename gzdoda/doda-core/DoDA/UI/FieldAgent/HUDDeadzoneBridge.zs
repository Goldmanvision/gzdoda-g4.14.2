///////////////////////////
// DoDA/UI/FieldAgent/DeadzoneHUDBridge.zs
///////////////////////////

class DeadzoneHUDBridge : Object
{
    static DoDADeadzoneController GetController()
    {
        return DoDADeadzoneController(EventHandler.Find("DoDADeadzoneController"));
    }

    static bool IsDeadzoneAimActive()
    {
        let controller = GetController();
        return controller != null && controller.IsDeadzoneAimActive();
    }

    static double GetDeadzoneX()
    {
        let controller = GetController();
        return controller != null ? controller.GetDeadzoneX() : 0.0;
    }

    static double GetDeadzoneY()
    {
        let controller = GetController();
        return controller != null ? controller.GetDeadzoneY() : 0.0;
    }

    static double GetDeadzoneYawLimit()
    {
        let controller = GetController();
        return controller != null ? controller.GetDeadzoneYawLimit() : 0.0;
    }

    static double GetDeadzonePitchLimit()
    {
        let controller = GetController();
        return controller != null ? controller.GetDeadzonePitchLimit() : 0.0;
    }
}