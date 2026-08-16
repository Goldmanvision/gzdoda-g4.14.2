# DoDA / GZDoom Coding-Agent Instructions

## Project root

This repository root is the `gzdoda/doda-core` PK3 source directory.

Important project paths:

- Root ZScript translation unit: `zscript.txt`
- Active ZScript source: `DoDA/`, according to the current
  `zscript.txt` include graph
- Local GZDoom/ZScript documentation: `ZDoom_Documentation/`
- Latest engine/compiler output: `console_log.txt`
- DoDA architecture reference: `doda-architecture.md`
- Maps: `maps/`
- Packaged artifact: `doda-core.pk3`

Do not work outside this project root unless explicitly instructed.

The unpacked `doda-core/` source directory is authoritative for editing.
`doda-core.pk3` is a packaged artifact, not the authoritative source for
implementation changes.

## Documentation authority

Use the local documentation corpus under `ZDoom_Documentation/` as the
primary authority for ZScript and documented GZDoom APIs.

Documentation lookup order:

1. Read `ZDoom_Documentation/__ZDoom_Docs_TOC.txt`.
2. Read the specific numbered topic file for the requested API or feature.
3. Search `ZDoom_Documentation/ZDoomDocs_FULL.txt` only when the relevant
   topic file cannot be identified or does not answer the question.
4. Use external web sources only after stating:
   `LOCAL DOCUMENTATION DOES NOT ANSWER THIS QUESTION`.

Never invent a ZScript language feature, GZDoom API member, event callback,
actor property, state syntax, flag, data lump rule, DoomEdNum, spawn ID, UDMF
placement rule, map metadata rule, or engine behavior.

Before proposing or editing code that uses a GZDoom/ZScript API:

- Read the relevant local documentation file.
- Report its exact local path.
- State whether the documentation directly supports the proposed use.
- If the local documentation does not support it, stop and ask for direction
  or identify the need for source-code or engine-version investigation.

Do not cite DoDA source files as authority for ZScript language semantics.
Cite local ZDoom documentation for language/API rules and cite DoDA source only
for project-specific implementation conventions.

## ZScript integration

- `zscript.txt` is the root translation unit and authoritative include order.
- Preserve `version "2.4"` in root `zscript.txt`.
- Do not add a version declaration to included `.zs` files.
- Inspect `zscript.txt` before adding, removing, moving, renaming, or changing
  any ZScript module.
- Add new includes in dependency-correct order.
- Do not change unrelated include order.
- Treat a source file as active only if it is included by the current
  `zscript.txt` and reachable from the configured runtime setup.
- The project currently contains active source under both `DoDA/` and `doda/`.
  Preserve existing include paths and case exactly unless an explicitly
  authorized task performs a validated source-layout consolidation.
- Do not assume case-only path changes are safe on all filesystems, in all
  archive tools, or in all GZDoom loading environments.

## Active-source authority

- `zscript.txt` is the root translation unit and authoritative include order.
- Treat a source file as active only if it is included by the current
  `zscript.txt` and reachable from the configured runtime setup.
- The active ZScript source tree is currently `DoDA/`.
- Do not assume paths under `doda/` exist or are active. Verify every path
  against the current repository and `zscript.txt` before citing or editing it.
- Never edit `DoDA/WeaponSystem/WeaponBase_bak.zs`. It is backup/orphan source.
- Treat `DoDA/Aim/DeadzoneController.zs` as legacy/orphan source unless the
  current `zscript.txt` and `MAPINFO` explicitly restore it to active runtime
  registration.
- Do not use a stale, backup, packed-PK3, historical, or orphan file as the
  source of truth when an active unpacked source file exists.
- The active weapon-base source is `DoDA/WeaponSystem/WeaponBase.zs` unless
  the current `zscript.txt` proves otherwise.
- Do not infer active source from filename, directory casing, timestamp, or
  package contents alone. Prove activity from the current translation unit and
  runtime registration/configuration.
- 

## Deadzone aim authority

- `DoDA/Aim/AimInput.zs` owns raw mouse capture and dispatch only.
- AimInput must return false while deadzone aim is inactive.
- While deadzone aim is active, AimInput may consume mouse input and write only
  raw input values to the established `doda_raw_mouse_x` and
  `doda_raw_mouse_y` user CVars.
- AimInput must not own deadzone activation, smoothing, gap math, camera
  handoff, HUD state, weapon state, or reload behavior.
- `DoDA/CharacterClasses/FieldAgent.zs` is the active deadzone authority for
  the current MAPINFO player class.
- FieldAgent solely owns deadzone activation, reset behavior, raw-mouse
  consumption, smoothing, yaw/pitch reticle offsets, deadzone limits, clamping,
  and transfer of input overflow to player angle/pitch.
- HUD modules read FieldAgent deadzone state only. HUD code must never own,
  modify, smooth, reset, clamp, or duplicate deadzone math.
- Weapon modules consume FieldAgent deadzone state for presentation,
  active-hand selection, spread/trace behavior, and firing behavior.
- Weapon code must not write camera/view state, player angle/pitch, or
  duplicate deadzone math.
- Do not treat a visible HUD overlay as proof that input capture, controller
  state, camera handoff, weapon consumption, or trace behavior is correct.
- If deadzone behavior still feels like camera fighting after the active layers
  are clean and validated, identify the need for GZDoom engine-source or C++
  investigation rather than inventing ZScript-only workarounds.

## Player classes

- MAPINFO currently configures `FieldAgent` as the active player class unless
  current MAPINFO is explicitly changed.
- `Analyst` and `SAC` are included experimental player classes unless MAPINFO
  is explicitly updated to expose them.
- Do not make feature changes independently in FieldAgent, Analyst, and SAC.
- If FieldAgent, Analyst, and SAC must remain playable, first propose a shared,
  documented deadzone abstraction while retaining one per-player owner of
  runtime state.
- Do not claim Analyst or SAC behavior is validated merely because the classes
  compile or are included.
- Do not silently change default player class selection or player start
  inventory.

## Weapon and ammo authority

- `DoDA/WeaponSystem/HandSwapController.zs` owns desired-hand resolution only.
- `DoDA/WeaponSystem/SpriteAnimator.zs` owns weapon PSprite presentation only.
- Lean input/controller code owns lean input/state and any documented lean
  camera offset behavior; weapon code consumes lean output where needed.
- Left and right B92 pistols are gameplay-distinct weapons, not merely
  mirrored or flipped presentation.
- Each B92 inventory instance retains independent magazine rounds and chamber
  state.
- `Clip` is the intentionally shared loose-reserve ammo pool for the current
  B92 design.
- A shared-reserve-ammo change must not reset, refill, replace, or otherwise
  mutate either pistol's independent magazine/chamber state.
- Do not change the shared-reserve design to separate per-hand reserve pools
  without an explicit gameplay design decision.
- Do not silently restore default starting pistols. Starting loadout is map and
  test-harness policy, not a weapon-system fallback.
- Do not claim dual-B92 functionality is complete based on a solo-right or
  solo-left test.
- Treat a solo weapon test, a weapon pickup test, a hand-swap test, a reload
  test, and a dual-pistol persistence test as distinct validation cases.

## Shooting-range regression policy

- The first shooting-range map is an isolated regression harness, not mission
  content.
- Prefer `MAP03` for the shooting range unless an explicit map-slot decision
  changes this.
- Do not modify MAP01 mission flow or MAP02 debrief behavior unless explicitly
  instructed.
- The shooting-range baseline is an unarmed FieldAgent.
- The range supplies one-time pickup stations for `DoDAB92Right` and
  `DoDAB92Left`.
- The range supplies a repeatable/infinite `Clip` ammo dispenser.
- The ammo dispenser may add only the existing shared `Clip` reserve ammo.
- The ammo dispenser must not grant weapons, duplicate weapon inventory,
  reset pistol state, refill magazines directly, alter chamber state, or
  advance mission/campaign state.
- Do not invent DoomEdNums, spawn IDs, UDMF actor-placement rules, pickup
  behavior, map metadata, or dispenser behavior. Inspect current MAPINFO,
  active actor classes, map format, map assets, and existing map conventions
  first.
- Do not edit maps, WAD/DBS files, sprites, graphics, sounds, textures, or
  binary files unless the task explicitly authorizes those changes.
- A shooting-range task must include an actual GZDoom sandbox validation plan
  for:
    1. unarmed spawn;
    2. right-B92 pickup;
    3. left-B92 pickup;
    4. repeated infinite-ammo-dispenser use;
    5. predictable shared Clip reserve increases;
    6. no weapon duplication from the dispenser;
    7. independent left/right magazine and chamber persistence;
    8. deadzone threshold hand switching;
    9. selected-hand firing;
    10. dry fire;
    11. lowest-loaded eligible pistol reload selection;
    12. active and companion weapon HUD data;
    13. death, restart, and map-reset behavior.
- A successful solo-right test does not validate the dual-pistol system.
- Do not claim dual-B92 support is fixed or complete without a recorded
  in-game range test using both B92 pickups.

## Change policy

Before editing:

1. Inspect the relevant active source files.
2. Inspect `zscript.txt` and identify the active include path for every source
   file that would be changed.
3. Read the relevant local ZDoom documentation.
4. Read `console_log.txt` if the task involves an existing error, load result,
   or gameplay regression.
5. State the proposed files, behavior change, risks, source-authority status,
   and validation plan.
6. If maps or pickups are involved, establish current map format and actor
   placement/spawn registration before proposing changes.

While editing:

- Make the smallest complete change.
- Preserve modular subsystem boundaries.
- Do not refactor unrelated code.
- Do not modify unrelated include order.
- Do not change sprites, graphics, maps, sounds, textures, binary files, or
  packaged PK3 files unless explicitly requested.
- Do not alter `.idea/` project files.
- Do not commit, push, create branches, merge, or change Git configuration
  unless explicitly instructed.
- Do not leave duplicate ownership, partial patches,

## Build and test policy

- This is a GZDoom PK3/folder-based mod project, not an MSBuild, .NET, C++,
  Rider, Visual Studio, CMake, Gradle, npm, or conventional IDE-build project.
- Never invoke, configure, troubleshoot, or interpret MSBuild, dotnet build,
  Rider Build, Visual Studio Build, CMake, Make, Gradle, npm build, or any
  generic IDE build command for `doda-core`.
- Do not create project files, solution files, response files, build scripts,
  or toolchain configuration in an attempt to make the mod compatible with
  MSBuild or any other generic build system.
- Any MSBuild, Rider, or generic IDE build output is irrelevant to DoDA ZScript
  validity and must not be reported as a successful build, failed build, test,
  warning, or validation result.
- The only authoritative compile/load/test workflow is manual:
  1. The human author opens, edits, validates, or packages maps/assets with
     SLADE.
  2. The human author manually launches GZDoom with the unpacked
     `gzdoda/doda-core` directory or explicitly chosen test archive.
  3. GZDoom script parsing, map loading, in-game behavior, and
     `console_log.txt` determine whether the project compiled and tested.
- Junie and other coding agents must not attempt to launch GZDoom, invoke
  SLADE, execute a project build, package a PK3, or claim runtime validation.
- Agents may inspect `console_log.txt` only when the human author explicitly
  provides or saves it after a manual GZDoom run.
- Agents must distinguish:
  - static source inspection;
  - requested code changes;
  - human-run GZDoom compilation/load evidence;
  - human-run in-game behavioral evidence.
- Do not claim that ZScript compiles, MAP03 loads, a sprite resolves, a weapon
  state works, or a gameplay behavior is validated unless the human author has
  manually run GZDoom and supplied the relevant `console_log.txt` or direct
  test result.
- After an implementation task, agents must provide:
  - exact files changed;
  - expected manual SLADE steps, if any;
  - exact manual GZDoom test procedure;
  - expected console-log success/failure indicators;
  - known untested behavior.
- Treat the Rider/JetBrains Build panel as unavailable for DoDA validation.
  Ignore MSBuild errors such as MSB1013 and response-file errors; they are
  unrelated to GZDoom/ZScript.