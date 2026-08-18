# Character Classes

## Overview
DoDA features three playable character classes: `FieldAgent`, `Analyst`, and `SAC`. All classes inherit from `DoomPlayer` and implement a common deadzone aim system.

## Common Deadzone Aim
Each character class independently manages its deadzone state.

### Properties
- `DeadzoneAimActive`: Tracks if deadzone aim is currently active.
- `ReticleYawOffset` / `ReticlePitchOffset`: The signed angular gap between actor aim and red-dot aim.
- `DeadzoneYawLimit` / `DeadzonePitchLimit`: Constraints on how far the reticle can move.
- `SmoothedMouseX` / `SmoothedMouseY`: Smoothed per-tick deadzone input for trackball-like inertia.

### Methods
- `ResetDeadzoneAim()`: Resets all deadzone state variables and clears raw mouse CVars.
- `Tick()`: Manages deadzone activation based on `BT_ALTATTACK` (alt-fire) and debug CVars (`doda_debug_force_deadzone`).

## Class-Specific Details
- `FieldAgent`:
    - Extends deadzone activation logic to include lean states (triggered by `BT_USER1` and `BT_USER2`).
    - Starts with: `DoDAB92Left`, `DoDAB92Right`, `DoDAMP5KSD`, `DoDAHolster`, `Clip` (100).
- `Analyst`:
    - Basic deadzone implementation.
    - Starts with: `Clip` (100).
- `SAC`:
    - Basic deadzone implementation.
    - Starts with: `DoDAB92Left`, `DoDAB92Right`, `Clip` (100).
