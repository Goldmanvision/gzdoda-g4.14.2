# Active Source Map

This map defines the active source file structure for DoDA, based on `zscript.txt` include order.

## Include Graph
- `DoDA/Aim/AimInput.zs`
- `DoDA/CharacterClasses/FieldAgent.zs`
- `DoDA/CharacterClasses/Analyst.zs`
- `DoDA/CharacterClasses/SAC.zs`
- `DoDA/UI/FieldAgent/HUDTapline.zs`
- `DoDA/UI/FieldAgent/HUDDeadzone.zs`
- `DoDA/UI/FieldAgent/HUDWeapon.zs`
- `DoDA/UI/FieldAgent/HUDWeaponBridge.zs`
- `DoDA/UI/FieldAgent/HUDDeadzoneBridge.zs`
- `DoDA/UI/FieldAgent/HUD.zs`
- `DoDA/Abilities/Lean/LeanInput.zs`
- `DoDA/Abilities/Lean/LeanController.zs`
- `DoDA/WeaponSystem/HandSwapController.zs`
- `DoDA/WeaponSystem/SpriteAnimator.zs`
- `DoDA/WeaponSystem/WeaponBase.zs`
- `DoDA/WeaponSystem/Weapons/Pistols/PistolBase.zs`
- `DoDA/WeaponSystem/Weapons/Pistols/B92Left.zs`
- `DoDA/WeaponSystem/Weapons/Pistols/B92Right.zs`
- `DoDA/WeaponSystem/Weapons/Shotguns/Shotgun.zs`
- `DoDA/WeaponSystem/Ammo/AmmoDispenser.zs`
- `DoDA/Range/Map03RangeStartHandler.zs`
- `DoDA/MissionSystem/...` (Various files)

## Status Indicators
- **ACTIVE**: Included by `zscript.txt` and confirmed by runtime evidence.
- **LEGACY**: Present in repository but not actively included or used.
- **UNRESOLVED**: Ambiguous status or path.
