# DoDA / GZDoom Coding-Agent Instructions

## Project root
This repository root is the `doda-core` PK3 source directory.

Important project paths:
- ZScript source: `DoDA/`
- Root ZScript translation unit: `zscript.txt`
- Local GZDoom/ZScript documentation: `ZDoom_Documentation/`
- Latest engine/compiler output: `console_log.txt`
- DoDA architecture reference: `doda-architecture.md`

Do not work outside this project root unless explicitly instructed.

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
actor property, state syntax, flag, or data lump rule.

Before proposing or editing code that uses a GZDoom/ZScript API:
- Read the relevant local document file.
- Report its exact local path.
- State whether the documentation directly supports the proposed use.
- If the local documentation does not support it, stop and ask for direction
  or identify the need for source-code/engine-version investigation.

## ZScript integration

- `zscript.txt` is the root translation unit and authoritative include order.
- Preserve `version "2.4"` in root `zscript.txt`.
- Do not add a version declaration to included `.zs` files.
- Inspect `zscript.txt` before adding, removing, moving, or renaming any
  ZScript module.
- Add new includes in dependency-correct order.
- Do not change unrelated include order.

## DoDA ownership constraints

- `DoDA/Aim/AimInput.zs` owns raw input capture and event dispatch only.
- `DoDA/Aim/DeadzoneController.zs` is the sole owner of deadzone activation,
  pending mouse accumulation, yaw/pitch offsets, smoothing, and limits.
- HUD modules read aim/controller state only. HUD code must never own or
  modify aim math.
- Weapon modules consume deadzone state for presentation, active-hand
  selection, and firing behavior. Weapon code must not rewrite camera/view state.
- Left and right pistols remain gameplay-distinct weapons with independent
  magazine/ammunition state.
- Do not duplicate state ownership or deadzone math across modules.

## Change policy

Before editing:
1. Inspect the relevant source files.
2. Read the relevant local ZDoom documentation.
3. Read `console_log.txt` if the task involves an existing error.
4. State the proposed files, behavior change, risks, and validation plan.

While editing:
- Make the smallest complete change.
- Preserve modular subsystem boundaries.
- Do not refactor unrelated code.
- Do not change sprites, graphics, maps, sounds, textures, or binary files
  unless explicitly requested.
- Do not alter `.idea/` project files.
- Do not commit, push, create branches, merge, or change Git configuration
  unless explicitly instructed.

## Required completion report

After any task, report:
- Local documentation files read.
- Source files inspected.
- Files changed.
- Exact behavior changed.
- Relevant `console_log.txt` result.
- Validation performed.
- Assumptions, engine-version risks, or unresolved questions.

When reporting that local documentation does not answer an API question:
- First read the complete most-specific local topic file.
- Quote the exact relevant passage or section heading.
- Distinguish `not documented locally` from `not found during initial lookup`.
- Do not cite DoDA source files as authority for ZScript language semantics.
  Cite local ZDoom documentation for language/API rules and cite DoDA source
  only for project-specific implementation conventions.\


## Inheritance-aware API research

Before stating that a class API, callback, property, or lifecycle behavior is
not documented locally:

1. Inspect the class declaration in the relevant DoDA source file.
2. Read the local documentation for the concrete class.
3. Identify and inspect every direct base class needed for the question.
4. Treat inherited methods, members, and callback behavior as documented by
   the base-class documentation unless the child-class documentation overrides it.
5. For EventHandler work, always inspect both:
  - `ZDoom_Documentation/0504-02EventHandler.txt`
  - `ZDoom_Documentation/0504-08StaticEventHandler.txt`
6. State separately:
  - child-class lifecycle behavior;
  - inherited input/event behavior;
  - project-specific usage.
  - 

Do not claim a change is validated unless it was actually tested in GZDoom.

