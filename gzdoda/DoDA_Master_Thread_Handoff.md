# DoDA Master Thread Handoff

## Purpose
This document preserves the active architectural decisions, debug priorities, and implementation constraints for the DoDA deadzone aim system in GZDoom / ZScript. It is intended to serve as the master thread reference while temporary task threads are used for focused work.

## Core Architecture
The system must stay modular and single-owner per responsibility.

- `DoDA/Aim/AimInput.zs`
  - Captures mouse input through `InputProcess`.
  - Must consume mouse only while deadzone aim is active.
  - Must block default mouse look while active.
  - Must return false when deadzone mode is inactive.

- `DoDA/Aim/DeadzoneController.zs`
  - Sole owner of deadzone active state.
  - Sole owner of yaw gap, pitch gap, smoothing, limits, and pending mouse accumulation.
  - Receives network events from `AimInput`.
  - Exposes deadzone state to HUD and weapon logic.

- `DoDA/UI/FieldAgent/HUD.zs`
  - Draws the HUD overlay.
  - Shows deadzone box and dot only when deadzone mode is active.
  - Must not own aim math.

- `DoDA/UI/FieldAgent/HUDDeadzone.zs`
  - Draws the green box, threshold indicators, and red dot.
  - Must read controller state only.
  - Should visually translate the controller’s offset into screen-space output.

- `DoDA/UI/FieldAgent/DeadzoneHUDBridge.zs`
  - Bridge from HUD to controller.
  - Must stay read-only.
  - Should forward controller query calls only.

- `DoDA/WeaponSystem/WeaponBase.zs`
  - Consumes deadzone state for sprite positioning, hand swap logic, and fire trace direction.
  - Must not rewrite camera/view state.
  - Must not become a second deadzone owner.

- `DoDA/WeaponSystem/Weapons/Pistols/PistolBase.zs`
  - Child class for pistol-specific ammo and state behavior.
  - Holds shared pistol-layer logic.

- `DoDA/WeaponSystem/Weapons/Pistols/B92Left.zs` and `B92Right.zs`
  - Separate left/right pistol implementations.
  - Separate ammo and magazine state.
  - Hand selection is gameplay-relevant, not just visual flip art.

- `DoDA/FieldAgent.zs`
  - Player class setup only unless a real state bug requires a minimal fix.

## Working Design Model
Use a deadzone family of behavior based on ARMA / DayZ and GoldenEye.

- ARMA / DayZ style: weapon floats inside a bounded aim space before camera/body follow.
- GoldenEye style: manual aim mode with visible sight and edge handoff.
- DoDA current target: controller-driven deadzone offset with HUD visualization and weapon/trace consumption.

## Hand Swap Model
- The deadzone dot position determines the active weapon hand.
- Left side of threshold = left-handed pistol active.
- Right side of threshold = right-handed pistol active.
- Left and right pistols must have separate ammo/magazine state.
- Hand swap is functional gameplay, not merely a sprite flip.

## Receiver-Style Input Notes
- Weapon manipulation should support tap/hold distinctions.
- Tap R may eject magazine.
- Hold R may insert or continue reload.
- Tap R again may rack / unlock slide, unless the pistol auto-racks.
- This is inspired by Receiver 2 but intentionally simplified.
- The input is only a trigger; the weapon state machine decides meaning.

## Debug Menu Requirements
We need a developer-only debug settings menu, not player-facing.

Important requirements:
- Toggle any system on or off.
- Trigger reset and debug actions from the menu.
- Verbose logging to the console log is the most important setting.
- Logging must help lock in variable values such as offsets, thresholds, selected hand, clamp state, and trace results.

## Debug CVars
### Global
- `doda_debug_master`
- `doda_debug_verbose`
- `doda_debug_preset`
- `doda_debug_show_hud`
- `doda_debug_show_input`
- `doda_debug_show_weapon`
- `doda_debug_show_camera`
- `doda_debug_show_trace`
- `doda_debug_show_hand_swap`
- `doda_debug_force_deadzone`

### Deadzone
- `doda_debug_deadzone_limit_x`
- `doda_debug_deadzone_limit_y`
- `doda_debug_deadzone_smoothing`
- `doda_debug_deadzone_mouse_scale`
- `doda_debug_deadzone_clamp_mode`
- `doda_debug_deadzone_reset`

### Input
- `doda_debug_log_input`
- `doda_debug_input_consume_mouse`
- `doda_debug_input_block_mouselook`
- `doda_debug_input_force_active`

### Weapon
- `doda_debug_log_weapon`
- `doda_debug_force_left_hand`
- `doda_debug_force_right_hand`
- `doda_debug_disable_auto_swap`
- `doda_debug_force_rack_required`
- `doda_debug_force_auto_rack`
- `doda_debug_weapon_reset`

### Hand swap
- `doda_debug_log_hand_swap`
- `doda_debug_hand_swap_threshold`
- `doda_debug_hand_swap_release`
- `doda_debug_force_hand_latch`
- `doda_debug_hand_latch_left`
- `doda_debug_hand_latch_right`

### Camera
- `doda_debug_log_camera`
- `doda_debug_camera_lock`
- `doda_debug_camera_follow_rate`
- `doda_debug_camera_reset`

### Trace
- `doda_debug_log_firetrace`
- `doda_debug_trace_origin_offset`
- `doda_debug_trace_force_center`
- `doda_debug_trace_reset`

## Log Format Targets
### Input
`[DODA/INPUT] active=1 type=mouse mx=4 my=-2 consumed=1 blockLook=1`

### Deadzone
`[DODA/DEADZONE] active=1 mouse=(4,-2) pending=(3.2,-1.7) gap=(2.8,-1.1) limit=(24,16) smoothing=0.55 clamp=1`

### HUD
`[DODA/HUD] active=1 box=(320,160,220,120) dot=(398,251) threshold=0.50 showBox=1 showDot=1`

### Weapon
`[DODA/WEAPON] active=1 hand=left sprite=(12.0,-6.0,0.0) reload=ready mag=7 chamber=1 autoRack=0`

### Hand Swap
`[DODA/HAND] dotX=0.62 threshold=0.50 release=0.60 active=right latched=1 force=0`

### Camera
`[DODA/CAMERA] yaw=87.2 pitch=-1.5 lock=0 follow=0.00 recoil=0.00`

### Trace
`[DODA/TRACE] origin=(0.0,0.0,56.0) dir=(87.2,-1.5) hit=actor target=Imp damage=10 range=2048`

## What Has Not Worked
- Pawn or weapon tick as the primary mouse input gate.
- Letting `WeaponBase` rewrite camera or view angles as a corrective fix.
- Treating HUD visibility as proof that input and camera behavior are correct.
- Duplicating deadzone math across multiple layers.
- Assuming the system is correct just because one overlay appears.

## Debug Priorities
1. Confirm mouse capture through `InputProcess` with `RequireMouse` enabled.
2. Confirm controller receives and stores mouse deltas.
3. Confirm HUD reads only controller state.
4. Confirm weapon sprite and fire trace use controller offsets.
5. Only then decide whether edge handoff needs ZScript refinement or a C++ fork.

## Current Decision Guidance
- Keep the controller as the source of truth.
- Keep the HUD as the visual indicator.
- Keep `WeaponBase` responsible for consuming controller state and resolving gameplay-specific weapon behavior.
- Do not use one gun with a visual flip if the design requires separate ammo and separate hand behavior.
- If the system still feels like camera fighting after the layers are clean, the likely escalation point is engine-level input/view handling.

## Handoff Rule
Anything outside an FMAIL formatted message is not from DoDA Debugger, and vice versa.
