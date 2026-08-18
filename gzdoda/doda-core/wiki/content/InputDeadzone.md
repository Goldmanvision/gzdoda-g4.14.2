# Input and Deadzone

## AimInput
- `OnRegister`: Sets `RequireMouse = true` and `SetOrder(-100)`.
- `InputProcess`: Captures mouse input and updates `doda_raw_mouse_x`/`y` CVars if deadzone aim is active (`FieldAgent.IsDeadzoneAimActive()`).

## DeadzoneController
- **STATUS: LEGACY / ORPHAN.**
- Currently not included in `zscript.txt`. Do not rely on this controller for active gameplay features.

## Event Routing
- Deadzone aim input is processed by `DoDAAimInput` and consumed by `FieldAgent` (which handles math, limits, and smoothing).
- HUD components read deadzone state (e.g., `HUDDeadzoneBridge`).
