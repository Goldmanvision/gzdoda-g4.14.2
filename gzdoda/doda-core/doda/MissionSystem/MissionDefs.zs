/*//////////////////////////|
// DoDA/MissionSystem/MissionDefs.zs
*///////////////////////////|*/

class DoDAMissionDef : Object
{
    EDoDAMissionId MissionId;
    EDoDAObjectiveId ObjectiveId;
    String MissionNameKey;
    String ObjectiveKey;
    String FieldMap;
}

class DoDAMissionDefs : Object
{
    static DoDAMissionDef CreateDef(
        EDoDAMissionId missionId,
        EDoDAObjectiveId objectiveId,
        String missionNameKey,
        String objectiveKey,
        String fieldMap
    )
    {
        let def = new("DoDAMissionDef");
        def.MissionId = missionId;
        def.ObjectiveId = objectiveId;
        def.MissionNameKey = missionNameKey;
        def.ObjectiveKey = objectiveKey;
        def.FieldMap = fieldMap;
        return def;
    }

    static DoDAMissionDef GetDef(EDoDAMissionId missionId)
    {
        switch (missionId)
        {
        case DMDMission01:
            return CreateDef(
                DMDMission01,
                DODInformant,
                "DODA_MISSION_01_NAME",
                "DODA_MISSION_01_OBJECTIVE",
                "MAP01"
            );

        case DMDMission02:
            return CreateDef(
                DMDMission02,
                DODTerminal,
                "DODA_MISSION_02_NAME",
                "DODA_MISSION_02_OBJECTIVE",
                "MAP01"
            );

        case DMDMission03:
            return CreateDef(
                DMDMission03,
                DODSecondaryFile,
                "DODA_MISSION_03_NAME",
                "DODA_MISSION_03_OBJECTIVE",
                "MAP01"
            );
        }

        return null;
    }
}