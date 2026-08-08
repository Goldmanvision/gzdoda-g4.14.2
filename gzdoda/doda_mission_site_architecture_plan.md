# DoDA Mission-Site Architecture Plan

## Goal
Build a mission-site pipeline for DoDA that supports procedurally generated mission areas with authored content, while preserving authored intent and using scarcity as a tuning layer only. The system should stay inside mission/world population logic and not leak into aim, HUD, or weapon authority.

## Architecture

### 1. Generator layer
**Responsibility:** Build the mission-site structure.

**Owns:**
- Mission template selection.
- Room graph or area skeleton.
- Slot placement.
- Seed handling.
- Slot count / density rules.

**Suggested files:**
- `MissionSystem/MissionSiteGenerator.zs`
- `MissionSystem/MissionSiteTemplate.zs`
- `MissionSystem/MissionSiteSeed.zs`

### 2. Authored slot layer
**Responsibility:** Define authored opportunities inside a generated mission site.

**Owns:**
- Slot type.
- Slot family.
- Tier / rarity band.
- Allowed spawn table.
- Whether the slot can resolve to empty.

**Suggested files:**
- `MissionSystem/Things/MissionSlot.zs`
- `MissionSystem/Things/MissionCacheSlot.zs`
- `MissionSystem/Things/MissionSupplySlot.zs`
- `MissionSystem/Things/MissionEvidenceSlot.zs`

### 3. Scarcity layer
**Responsibility:** Resolve a slot into a real actor, bundle, or nothing.

**Owns:**
- Global fill-rate control.
- Per-family tables.
- Empty fallback.
- Debug profiles.
- Optional world-state modifiers.

**Suggested files:**
- `MissionSystem/MissionScarcitySpawner.zs`
- `MissionSystem/MissionFamilySpawner.zs`
- `MissionSystem/MissionScarcityConfig.zs`
- `MissionSystem/MissionSlotResolver.zs`

## Core pattern to borrow
Use the pattern from the handoff:
- a neutral empty placeholder,
- a central scarcity gate,
- one replacement spawner per content family,
- optional curated bundle spawners.

For DoDA, that means the pattern belongs in mission-site population or loot/evidence/supply systems, not in player input, camera, or weapons.

## Data flow
1. Mission starts or mission area initializes.
2. Generator picks a template and creates authored slots.
3. Each slot asks the scarcity layer for a resolved result.
4. Scarcity returns a real actor, a bundle, or `NothingItem`.
5. The slot spawns the result or remains empty.
6. Mission state records the resulting population for debug and post-mission reporting.

## Minimal ZScript skeleton
```zs
class MissionSiteGenerator : Actor
{
    int SiteSeed;
    int SlotCount;

    void GenerateSite()
    {
        // 1. Select template
        // 2. Build room or area skeleton
        // 3. Spawn authored slots
        // 4. Resolve each slot through scarcity
    }
}

class MissionSiteTemplate : Object
{
    name TemplateId;
    int BaseSlotCount;
    int MinFillRate;
    int MaxFillRate;
}

class MissionSlot : Actor
{
    name SlotFamily;
    int SlotTier;
    bool bResolved;
    name ResolvedResult;

    void ResolveSlot()
    {
        // Ask scarcity layer for a result.
        // If result is NothingItem or None, stay empty.
        // Otherwise spawn the resolved actor.
    }
}

class MissionScarcitySpawner : RandomSpawner
{
    override Name ChooseSpawn()
    {
        // Apply global fill modifier.
        // Apply family-specific table logic.
        // Return a real spawn or NothingItem.
    }
}

class NothingItem : Actor
{
    Default
    {
        +NOINTERACTION;
        +NOBLOCKMAP;
        +NOSECTOR;
    }

    States
    {
    Spawn:
        TNT1 A 1;
        Stop;
    }
}
```

## Repo file map
### Already present and relevant
- `MissionSystem/MissionDefs.zs`
- `MissionSystem/MissionState.zs`
- `MissionSystem/MissionManager.zs`
- `MissionSystem/MissionDirector.zs`
- `MissionSystem/LastMissionReport.zs`
- `MissionSystem/DebugTrigger.zs`
- `MissionSystem/Things/MissionPickup.zs`
- `MissionSystem/Things/MissionInteractable.zs`
- `MissionSystem/Things/MissionTerminal.zs`
- `MissionSystem/Things/ExtractionInteractable.zs`
- `MissionSystem/Things/DeployMissionInteractable.zs`
- `MissionSystem/Things/ObjectivePickup.zs`
- `MissionSystem/Things/MissionPickupMarkers.zs`

### Recommended additions
- `MissionSystem/MissionSiteGenerator.zs`
- `MissionSystem/MissionSiteTemplate.zs`
- `MissionSystem/MissionScarcitySpawner.zs`
- `MissionSystem/MissionScarcityConfig.zs`
- `MissionSystem/MissionFamilySpawner.zs`
- `MissionSystem/MissionSlotResolver.zs`
- `MissionSystem/Things/MissionSlot.zs`
- `MissionSystem/Things/MissionCacheSlot.zs`
- `MissionSystem/Things/MissionSupplySlot.zs`
- `MissionSystem/Things/MissionEvidenceSlot.zs`

## Phase plan
### Phase 1: Slot-first prototype
- Define `MissionSlot` and slot families.
- Add a basic `NothingItem` placeholder.
- Add a single scarcity resolver with one global multiplier.
- Make mission-site population deterministic from a seed.

### Phase 2: Family spawners
- Add per-family replacement tables.
- Separate supply, evidence, cache, and objective-related slots.
- Add debug output for slot resolution.

### Phase 3: Generator integration
- Hook slot generation into mission initialization.
- Generate slots from template data.
- Support authored mission area templates.

### Phase 4: World-state modifiers
- Add difficulty scaling.
- Add region or mission-type scarcity modifiers.
- Add test profiles for debugging and balancing.

### Phase 5: Reporting and tuning
- Record how many slots resolved to real items vs empty.
- Store mission-site population statistics in mission reports.
- Use those stats for balancing and iteration.

## What to avoid
- Do not place scarcity logic in `AimInput`.
- Do not place scarcity logic in `DeadzoneController`.
- Do not place scarcity logic in `HUD` or `HUDDeadzone`.
- Do not place scarcity logic in `WeaponBase`.

## Implementation rule
Authored content decides what can exist. The generator decides where it can exist. The scarcity layer decides whether it actually exists in a given run.

That separation keeps the system modular and makes it compatible with procedural mission areas without erasing authored design intent.
