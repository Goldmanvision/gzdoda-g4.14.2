# Development

Development of DoDA relies on active source authority and manual testing.

## Workflow
1. **Source Inspection**: The active `zscript.txt` defines the load order and active modules.
2. **Implementation**: Changes should be modular and scoped to specific subsystems (Aim, WeaponSystem, etc.).
3. **Validation**: Runtime validation is strictly human-performed using GZDoom and SLADE. Agent-based validation is limited to static analysis.

## Contributing
- Refer to `doda-architecture.md` for project design principles.
- Use documented GZDoom/ZScript APIs; do not invent undocumented engine behaviors.
- Maintain consistency with existing file naming conventions and modular organization.
- When creating new modules, ensure they are added to `zscript.txt` in the correct dependency order.
