# DoDA / GZDoom Coding-Agent Instructions

## Project root

The mod project root is:

```text
gzdoda/doda-core/
```

Important project paths:

- Root ZScript translation unit: `zscript.txt`
- Active gameplay source: prove from current `zscript.txt`, current source, and
  human-provided GZDoom logs before editing
- Local GZDoom/ZScript documentation: `ZDoom_Documentation/`
- Human-provided GZDoom output: `console_log.txt`
- Architecture notes: `doda-architecture.md`
- Maps: `maps/`
- Packaged artifact: `doda-core.pk3`
- Legacy/stub wiki site: `../doda-wiki/`

Do not work outside `gzdoda/doda-core/` unless explicitly instructed.

The unpacked `doda-core/` directory is authoritative for source edits.
`doda-core.pk3` is a packaged artifact and is not authoritative source for
implementation changes.

## Authority order

When sources disagree, use this order:

1. Explicit human instructions in the current task.
2. This `AGENTS.md`.
3. Current active `zscript.txt` include graph.
4. Current active source files at the paths proven by `zscript.txt` and
   human-provided GZDoom logs.
5. Human-provided GZDoom runtime logs and manual test results.
6. Local `ZDoom_Documentation/`.
7. Explicitly approved architecture documentation under `doda-core/`.
8. Historical commits, old logs, old handoffs, backups, archives, packaged PK3
   files, and wiki pages.

Never treat a stale path, backup, old branch view, historical source excerpt,
packaged artifact, or generic wiki page as stronger authority than active source
and a human-provided runtime log.

## Documentation authority

Use `ZDoom_Documentation/` as the primary authority for ZScript syntax and
documented GZDoom APIs.

Documentation lookup order:

1. Read `ZDoom_Documentation/__ZDoom_Docs_TOC.txt`.
2. Read the most-specific numbered topic file for the requested API or feature.
3. Read `ZDoom_Documentation/ZDoomDocs_FULL.txt` only when the specific topic
   cannot be found or does not answer the question.
4. Use external sources only after explicitly stating:

```text
LOCAL DOCUMENTATION DOES NOT ANSWER THIS QUESTION
```

Never invent a ZScript feature, API member, event callback, actor property,
state syntax, action scope, flag, data-lump rule, DoomEdNum, spawn ID, UDMF
placement rule, map metadata rule, sprite naming rule, or engine behavior.

Before proposing or editing code that uses a GZDoom/ZScript API:

- Read the relevant local documentation.
- Report the exact local documentation path.
- State whether the local documentation directly supports the intended usage.
- If the documentation does not support the usage, stop and report the need
  for further source/engine investigation.
- Do not use current DoDA source as proof that an undocumented API call is
  valid merely because it appears in code.

## Wiki status

`gzdoda/doda-wiki/` is currently a legacy/stub documentation site.

- Do not treat its current pages as authoritative technical, gameplay,
  architecture, source-path, build, test, control, weapon, map, or API
  documentation.
- Do not copy malformed generated tool-call payloads from the wiki into source,
  documentation, or prompts.
- Until explicitly rebuilt and approved, the wiki is informational only.
- Do not update, repair, generate, restructure, package, or deploy the wiki
  unless the task explicitly requests wiki work.

## ZScript integration

- `zscript.txt` is the root translation unit and authoritative include order.
- Preserve `version "2.4"` in root `zscript.txt`.
- Do not add a version declaration to included `.zs` files.
- Inspect current `zscript.txt` before adding, removing, moving, renaming, or
  changing any ZScript module.
- Add new includes in dependency-correct order.
- Do not reorder unrelated includes.
- Treat a source file as active only when it is included by the current
  translation unit or is proven runtime-active by a human-provided GZDoom log.
- Do not infer active status from naming, timestamps, directory casing, old
  documentation, GitHub browsing alone, or package contents.

## Source-path and backup policy

- Current source may use both `DoDA/` and lower-case `doda/` paths.
- Do not assume one path root is inactive because a similarly named path exists
  elsewhere.
- A human-provided GZDoom runtime error naming a source path is evidence that
  the path is active for that run.
- Before editing a file, identify:
  - exact repository path;
  - exact include path;
  - active/legacy/backup status;
  - evidence for that status.
- Never edit `DoDA/WeaponSystem/WeaponBase_bak.zs`; it is backup/orphan source.
- Treat `DoDA/Aim/DeadzoneController.zs` as legacy/orphan unless current
  `zscript.txt`, current `MAPINFO`, and runtime evidence explicitly restore it.
- Do not delete, rename, case-normalize, consolidate, or move `DoDA/` or
  `doda/` paths unless a separate, explicitly authorized, validated source-tree
  cleanup task proves all runtime references are safe.
- Do not use an old source excerpt as authority when the current checkout
  differs.

## Build and test policy

This is a GZDoom PK3/folder-based mod project. It is not an MSBuild, .NET, C++,
Rider, Visual Studio, CMake, Gradle, npm, or conventional IDE-build project.

- Never invoke, configure, troubleshoot, or interpret:
  - MSBuild;
  - `dotnet build`;
  - Rider Build;
  - Visual Studio Build;
  - CMake;
  - Make;
  - Gradle;
  - npm build;
  - or any generic IDE build command for `doda-core`.
- Do not create project files, solution files, response files, build scripts,
  or toolchain configuration to make this mod compatible with a generic build
  system.
- Any MSBuild/Rider/generic IDE build output is irrelevant to DoDA ZScript
  validity and must not be reported as a successful build, failed build, test,
  warning, or validation result.
- Treat the Rider/JetBrains Build panel as unavailable for DoDA validation.
- Ignore MSBuild response-file errors such as `MSB1013`; they are unrelated to
  GZDoom/ZScript.

The authoritative compile/load/test workflow is manual:

1. The human author uses SLADE to edit, validate, package, or inspect map and
   asset content.
2. The human author manually launches GZDoom with the unpacked
   `gzdoda/doda-core` folder or an explicitly chosen test archive.
3. GZDoom script parsing, map loading, in-game behavior, and the resulting
   `console_log.txt` determine compile/load/test status.

Agents must not:

- launch GZDoom;
- invoke SLADE;
- run a project build;
- package a PK3;
- claim runtime validation;
- claim a sprite resolves;
- claim a map loads;
- claim a weapon state works;
- claim a gameplay feature works.

Agents may inspect `console_log.txt` only when the human author explicitly
provides or saves it after a manual GZDoom run.

Agents must distinguish:

- static source inspection;
- requested source changes;
- human-run GZDoom parsing/load evidence;
- human-run in-game behavior evidence;
- untested assumptions.

After an implementation task, report:

- exact files changed;
- exact active paths edited;
- local documentation read;
- expected manual SLADE steps, if any;
- exact manual GZDoom test procedure;
- expected console-log success/failure indicators;
- known untested behavior;
- `git status --short`;
- `git diff --stat`.

## Deadzone aim authority

- `DoDA/Aim/AimInput.zs` owns raw mouse capture and dispatch only.
- AimInput returns false while deadzone aim is inactive.
- While deadzone aim is active, AimInput may consume mouse input and write only
  established raw-input CVars such as `doda_raw_mouse_x` and
  `doda_raw_mouse_y`.
- AimInput does not own deadzone activation, smoothing, gap math, camera
  handoff, HUD state, weapon state, reload behavior, or evidence behavior.
- The active MAPINFO player class is the current authority for deadzone state
  unless current active source proves otherwise.
- For the current FieldAgent architecture, FieldAgent owns deadzone activation,
  reset behavior, raw-input consumption, smoothing, yaw/pitch offsets, limits,
  clamping, and overflow transfer to player angle/pitch.
- HUD modules read deadzone state only.
- HUD code must never own, modify, smooth, reset, clamp, or duplicate deadzone
  math.
- Weapon modules consume deadzone state for presentation, hand selection,
  spread/trace behavior, and firing behavior.
- Weapon code must not duplicate deadzone math or independently rewrite player
  angle/pitch.
- A visible HUD overlay is not proof that input capture, deadzone state, camera
  handoff, weapon behavior, or trace behavior is correct.
- If clean, tested ZScript layers still produce camera fighting or unsupported
  behavior, identify the need for GZDoom engine-source/C++ investigation rather
  than inventing ZScript-only workarounds.

## Lean authority

- Lean input owns Q/E button reading and edge detection only.
- Lean controller owns lean direction, smoothing, applied lateral view offset,
  and active lean-hand lock state.
- HUD may read lean state/offset for presentation only.
- Weapon code may consume lean output for sprite presentation, trace origin,
  and permitted hand-lock routing only.
- HUD must not own or mutate lean math.
- Lean behavior requirements:
  - Q held: left view translation and left-hand lock.
  - E held: right view translation and right-hand lock.
  - Q+E: no lean target and no hand lock.
  - Release: smooth return to centered view and release hand lock.
  - Lean lock has priority over manual pistol swap and deadzone threshold swap.
  - V must not override lean hand lock.
  - Camera roll is not part of the lean MVP.
- Do not claim tactical lean is complete without human-run GZDoom evidence for
  view translation, hand lock, V lockout, threshold restoration, HUD behavior,
  and trace-origin behavior.

## Player classes

- MAPINFO currently configures the active player class unless current MAPINFO
  is explicitly changed.
- `Analyst` and `SAC` are experimental unless active MAPINFO exposes them.
- Do not make feature changes independently in FieldAgent, Analyst, and SAC.
- If multiple player classes must share behavior, first propose a documented,
  single-owner shared abstraction with per-player runtime state.
- Do not claim an included class is tested merely because it compiles.
- Do not silently change default player class selection or global start
  inventory.

## Weapon and ammunition authority

- Left and right B92 pistols are gameplay-distinct weapons, not mirrored art.
- Each B92 inventory instance retains independent magazine and chamber state.
- `Clip` is the intended shared loose-reserve pool for the B92 design.
- Shared reserve changes must not reset, refill, replace, or otherwise mutate
  either pistol’s independent magazine/chamber state.
- Do not change shared B92 reserve to per-hand reserve without explicit design
  approval.
- Do not silently restore default starting pistols.
- Treat solo pistol, weapon pickup, hand swap, reload, dry fire, and dual-pistol
  persistence as separate validation cases.
- Keep weapon-specific state machines in their respective weapon classes.
- Keep generic cross-weapon presentation/input dispatch in the active weapon
  base only when it is safe for weapons that omit optional states.
- Generic weapon-base code must null-check optional state labels returned by
  `ResolveState()` before passing them to state methods such as
  `InStateSequence()`.

## Shotgun policy

The shotgun is currently under active runtime stabilization.

- Do not expand evidence, map, holster, slot, or unrelated systems while
  shotgun compiler/runtime failures remain unresolved.
- Before changing shotgun code, inspect the active shotgun path shown by the
  current `zscript.txt` and/or human-provided GZDoom error log.
- Do not assume `DoDA/WeaponSystem/...` is the active shotgun path when runtime
  evidence names a lower-case `doda/WeaponSystem/...` path.
- The project-owned shotgun must consume existing DoDA deadzone/lean weapon
  presentation behavior rather than duplicating deadzone math.
- Use only verified imported sprite families.
- Do not reference unverified placeholder bases such as `SHTG`, `SHTF`, or
  `SHOT` when current assets do not contain them.
- Current Brutal Doom placeholder asset mapping:
  - `SHTN A`: hipfire ready;
  - `SHTN B-F`, `S-T`, `U-W`, `X`, `Y-Z`, `[`, `]`: reload/shell insertion;
  - `SHT8 A-B`: ADS/deadzone enter;
  - `SHT8 C`: ADS/deadzone ready;
  - `SHT8 D`: ADS/deadzone fire frame;
  - `SHT8 E-F`: ADS recoil;
  - `SHT8 G-J`: ADS rack/recovery candidate, requiring visual verification;
  - `SHT6 A-I`: inspect only;
  - `SHTC A`: world pickup/spawn candidate.
- Do not rename `SHTN[0` or `SHTN]0` without explicit asset-conversion work.
- Do not import Brutal Doom ACS/token/inspect/sprint/purist systems into DoDA.
- Shotgun target behavior:
  - deadzone aim held: fire, then defer rack until deadzone aim releases;
  - deadzone aim released: perform required rack