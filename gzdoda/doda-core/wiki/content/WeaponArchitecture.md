# Weapon Architecture

## Overview
The DoDA weapon system is based on the `DoDAWeapon` class, which extends `Weapon`. It is designed for tactical gameplay with integrated deadzone aim and lean mechanics.

## DoDAWeapon Responsibilities
- Owns weapon state, including deadzone aim variables (`yawGap`, `pitchGap`), FOV management, and fire-control locks (`fireLockTics`).
- Manages lean input and controller (`DoDALeanInput`, `DoDALeanController`).
- Manages hand swap (`DoDAHandSwapController`) and sprite animation (`DoDASpriteAnimator`).
- Provides hooks for manual fire control (`HandleManualWeaponControl`), secondary actions (`HandleSecondaryWeaponAction`), and fire-state resolution (`GetFireState`).

## Deadzone Integration
- `FieldAgent` owns deadzone activation, reset, and raw-input consumption.
- `DoDAWeapon` subclasses read and consume deadzone state for presentation, hand selection, and trace origin.
- HUD modules read deadzone state for overlay rendering (`DoDAHUDDeadzone`).
- HUD code does not modify deadzone math.

## Weapon-Base Dispatch
- `UsesManualFireDispatch()` determines if the weapon uses `GetFireState` for advanced logic (e.g., burst fire, fire-mode selection).
