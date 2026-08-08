In WeaponBase.zs, we should probably get move the lean ability variables and functions into a seperate zscript file, as WeaponBase.zs should not control or own leaning. This should be it's own zscript file(s) under root/doda/abilities/lean

We should consider whether the Deadzone Aim System at this point should be a series C++ patterns built directly into the GZDOOM engine as a special fork for DoDA. If not, we need to figure out why we are unable to get the HUDDeadzone to draw to screen when Deadzone Aim Mode is active.

We need to sort out our CVARINFO, KEYCONF, and MENUDEFS.

We should go over the codebase and ensure that all the zscripts, methods, and patterns are organized, modular, and in the right places. As we go forward, we are going to want to edit functionality in smaller pieces as to not break other unrelated functionality. For instance, the lean system being in the weaponbase.zs file can cause errors with the weapon system while we work on leaning. We need to isolate the methods and patterns for better debugging and implementation.

The current iteration of the Deadzone Aim System moves the weapon sprite with mouse movement, but the camera is still fully active. The camera needs to lock in position while Deadzone Aim Mode is active until the Deadzone Aim reticle reaches the edges of the deadzone aim box and the mouse continues in that direction.