# DoDA Scope Spinner Prompt Pack

## Usage Note
Use these prompts as standalone micro-project starters. Each prompt assumes the target sandbox has access to the current DoDA master handoff and any uploaded context files in Project Space. Keep the prompt body inside a copy block when pasting into a new project.

---

## 1. Input Gate and Mouse Capture

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design and verify the input gate that captures mouse movement only while deadzone aim is active, blocks default mouselook during that active window, and passes deltas to the controller without letting pawn or weapon tick become the primary input owner.

Constraints:
- Keep input ownership single-purpose.
- Do not move camera logic into presentation code.
- The controller remains the source of truth for deadzone state.
- The HUD and weapon layers may only read controller state.

Tasks:
- Define the minimal input flow from `InputProcess` to the deadzone controller.
- Identify the exact conditions under which mouse input should be consumed or ignored.
- Recommend a debug logging shape that exposes active state, delta values, consume flags, and mouselook blocking.
- Note any ZScript or engine-level constraints that would affect implementation.

Acceptance target:
A clean module brief that explains the input path, ownership boundaries, and the debug observations needed to verify correct mouse capture.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 2. Deadzone State Controller

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the deadzone state controller that owns active state, yaw gap, pitch gap, smoothing, limits, and pending mouse accumulation. This module must be the sole authority for deadzone math and must expose read-only state to HUD and weapon consumers.

Constraints:
- Single owner for deadzone math and state.
- No HUD drawing responsibilities.
- No weapon presentation responsibilities.
- Do not duplicate deadzone logic in multiple layers.

Tasks:
- Define the state variables the controller must track.
- Describe how mouse deltas should be accumulated, clamped, smoothed, and exposed.
- Identify what read-only query methods downstream modules need.
- Propose debug logging for offsets, thresholds, clamp state, and pending input.

Acceptance target:
A compact implementation brief for a standalone deadzone controller module, with clear ownership and interface boundaries.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 3. Deadzone HUD Overlay

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the HUD overlay that visualizes the deadzone: box, threshold indicators, and reticle dot. The HUD must be read-only, must not own aim math, and must only draw when deadzone mode is active.

Constraints:
- HUD is visual only.
- No controller state mutation.
- No input ownership.
- No camera manipulation.

Tasks:
- Define the HUD data it needs from the controller.
- Specify the draw logic for the box, threshold markers, and dot.
- Describe when the overlay should appear or hide.
- Recommend debug output that mirrors the on-screen state for validation.

Acceptance target:
A HUD implementation brief that keeps display logic separated from gameplay math and input capture.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 4. HUD-to-Controller Bridge

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design a read-only bridge between the HUD and the deadzone controller. The bridge should forward query calls only and must not become a second state owner.

Constraints:
- Read-only adapter only.
- No state duplication.
- No math recomputation.
- No hidden gameplay side effects.

Tasks:
- Define the narrow query surface the HUD should use.
- Describe how the bridge should decouple UI code from controller internals.
- Identify any naming or lifecycle concerns that could cause accidental ownership drift.
- Propose validation checks to ensure the bridge remains passive.

Acceptance target:
A small architectural brief that clarifies how the HUD reads controller state without owning it.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 5. Weapon State Consumer

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the weapon consumer layer that reads deadzone state for sprite positioning, hand selection behavior, and fire-trace direction. This module must consume controller state without rewriting camera or view state.

Constraints:
- Weapon logic is a consumer, not a controller.
- Do not move view-angle correction here.
- Do not duplicate deadzone math.
- Keep gameplay-relevant hand behavior explicit.

Tasks:
- Define how weapon sprite offset should be derived from controller state.
- Describe how the module should influence fire trace direction.
- Explain how hand selection should be resolved from deadzone position.
- Recommend logging fields for hand, offset, reload state, and trace origin.

Acceptance target:
A weapon-consumer brief that preserves controller authority while enabling gameplay-specific weapon behavior.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 6. Dual Pistol Ownership

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the dual-pistol ownership model where left and right pistols are separate gameplay entities with separate ammo and magazine state. Hand selection must be functional gameplay, not just a visual flip.

Constraints:
- Left and right pistols are distinct state holders.
- Ammo and magazine state must not be merged by convenience.
- Hand selection must remain deterministic and visible in debug output.
- Do not let the controller become weapon-specific.

Tasks:
- Define the ownership boundaries for each pistol instance.
- Describe how hand selection should map to active weapon state.
- Identify how reload and chamber logic should differ per hand.
- Recommend a clean naming scheme for left/right weapon modules.

Acceptance target:
A short architecture brief for separate left/right pistol state management with gameplay-accurate hand swap behavior.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 7. Pistol Base Layer

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the shared pistol base layer that handles common ammo, reload, and state behavior for pistol subclasses while leaving hand-specific behavior to the left and right implementations.

Constraints:
- Shared logic only belongs here.
- Do not collapse the left/right pistols into a single visual-only variant.
- Keep hand selection as a higher-level gameplay concern.

Tasks:
- Identify the minimal shared state and methods the pistol base should provide.
- Separate reusable reload and ammo logic from hand-specific behavior.
- Note where subclass overrides should live.
- Recommend debug points for reload progression and chamber state.

Acceptance target:
A clean shared pistol-layer design that reduces duplication without erasing gameplay distinction.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 8. Tap-Hold Reload Grammar

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the tap-hold reload grammar inspired by Receiver-style manipulation, simplified for DoDA. The input should act as a trigger, while the weapon state machine decides what the action means.

Constraints:
- The input layer only signals intent.
- The weapon state machine owns interpretation.
- Avoid brittle one-input-one-action mapping.
- Keep the behavior intentionally simplified.

Tasks:
- Define the tap vs hold distinction in gameplay terms.
- Describe how eject, insert, rack, and auto-rack decisions should be separated.
- Identify the minimum state machine hooks needed to support the grammar.
- Recommend debug output that makes the action path legible.

Acceptance target:
A concise interaction model for reload input that preserves flexibility while remaining easy to reason about.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 9. Developer Debug Menu

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design a developer-only debug settings menu that can toggle systems, trigger resets, and expose verbose logging for input, deadzone, hand swap, camera, and trace behavior.

Constraints:
- Developer-only, not player-facing.
- Must support system toggles and reset actions.
- Logging clarity is a priority.
- The menu should help isolate ownership bugs.

Tasks:
- Define the debug menu categories and toggle groups.
- Specify what reset actions should exist per subsystem.
- Recommend log fields that make variable values easy to verify.
- Note any UI or configuration structure that would make this menu maintainable.

Acceptance target:
A developer debug menu brief that supports fast diagnosis of deadzone, weapon, and input problems.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 10. Camera Boundary Behavior

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the camera-side boundary behavior for the deadzone system without letting weapon presentation code directly rewrite camera state. The goal is to preserve the intended ARMA / DayZ-style free aim feel with GoldenEye-style handoff behavior.

Constraints:
- Camera remains separate from weapon presentation.
- No camera correction from weapon code.
- Keep boundary behavior explicit and testable.
- Controller state still owns deadzone intent.

Tasks:
- Define what should happen at the deadzone edge.
- Describe how handoff, clamping, or follow behavior should be selected.
- Identify what camera logs are needed for diagnosis.
- Note where a ZScript solution may stop and engine-level work may be required.

Acceptance target:
A boundary-behavior brief that clarifies how free aim transitions into camera follow without collapsing ownership.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 11. Fire Trace Consumption

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the fire-trace consumer path that uses deadzone and hand state to determine trace origin and direction. This module should not own the controller or camera logic.

Constraints:
- Trace logic consumes state only.
- No deadzone math duplication.
- No camera rewriting.
- Loggable and testable trace origin choices.

Tasks:
- Define the inputs the trace system needs from controller and weapon state.
- Describe how origin offset and direction should be resolved.
- Identify what trace results should be logged for debugging.
- Note any pitfalls in mixing visual offsets with gameplay trace logic.

Acceptance target:
A trace-consumption brief that ties weapon state to firing behavior without blurring subsystem ownership.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

## 12. Player Class Minimal Fixes

```text
You are helping with a GZDoom / ZScript gameplay module for DoDA.

Scope:
Design the minimal player-class changes required to support the deadzone system, with a strong bias against moving deadzone ownership into the player class.

Constraints:
- Player class setup only unless a genuine bug demands a minimal fix.
- Avoid making the player class a hidden controller.
- Keep the architecture modular.

Tasks:
- Identify the smallest player-class responsibilities required for the system to function.
- Describe what should explicitly not be added here.
- Note any lifecycle or initialization issues to watch for.
- Recommend diagnostic checks for player setup versus controller state.

Acceptance target:
A limited-scope player-class brief that protects the deadzone system from architectural drift.

Context note:
DoDA master handoff + uploaded Project Space context files.
```

---

## Prompting Rule
If you reuse these prompts in new projects, do not paste the entire source projects. Use the normalized module prompt plus a short context note referencing the living record and any uploaded context files.
