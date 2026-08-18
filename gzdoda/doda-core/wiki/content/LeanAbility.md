# Lean Ability

## Overview
The lean ability allows for tactical view translation. It is composed of `DoDALeanInput` (for reading inputs) and `DoDALeanController` (for managing the lean state and view translation).

## DoDALeanInput
Responsible for reading Q (`BT_USER1`) and E (`BT_USER2`) buttons and edge detection.

### Key Methods
- `Update(PlayerPawn owner)`: Captures button states and updates `LeaningLeft`, `LeaningRight`, `LeaningLeftPressed`, and `LeaningRightPressed`.
- `IsLeaning()`: Returns true if either Q or E is held.

## DoDALeanController
Responsible for managing lean direction, smoothing, view translation, and hand locking.

### Key Methods
- `Update(...)`:
    - Handles scroll wheel inputs (`BT_USER4`) to adjust `LeanDistance` (lean amount) within [8.0, 40.0].
    - Calculates `LeanAmount` using smoothing (0.25).
    - Sets `AppliedOffset` based on `LeanAmount` and `LeanDistance`.
    - Updates `FieldAgent.LeanOffset` (if available).
    - Uses `owner.SetViewPos` to translate the camera view laterally.
- `IsLeanLocked()`: Returns true if a lean state is locked (Q or E held).
- `GetLockedHand()`: Returns the hand restricted during lean (`DoDAHandSwapController.Hand_Left` for Q, `Hand_Right` for E).
