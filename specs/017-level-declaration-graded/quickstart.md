# Quickstart: Level Declaration Graded

**Feature**: `017-level-declaration-graded` | **Date**: 2026-10-11

How to see each behaviour once it is built. Run from the repository root.

## 1. Arm the floor

Add to `kit-adoption.json`:

```json
{ "criticalSurfaces": ["src/auth/"] }
```

## 2. See a Standard feature fail

On a `NNN-` branch declared Standard, put `src/auth/login.ps1` in a phase's Territory in
`tasks.md`, then:

```text
pwsh -File scripts/enforcement-pack.ps1
```

Expect a `LevelSurface:` failure naming the feature, level, path and glob, and exit 1.

## 3. Take each way forward

- Promote: set `**Delivery Level**: Critical` and fill the Critical lane's requirements. The
  check passes.
- Narrow: remove the path from the Territory. The check passes.
- Except: add the two Surface Exception lines to `spec.md` (the path must be a Territory
  entry). The check passes and lists the exception. Because the spec is already approved,
  also add an `**Amendment approved by**` line and name the approver in the commit message
  (constitution I).

## 4. See the unarmed state

Remove the key. The run prints one `LevelSurface: not armed` line and the verdict is what it
was before this feature.

## 5. Level Rationale

On a spec carrying `**Rationale Rule**: 1`, delete one trigger bullet. Expect a
`LevelRationale:` failure naming the missing trigger. Mark a trigger `applies` on a Standard
feature. Expect the contradiction failure.

## 6. Prove it

```text
pwsh -File tests/enforcement/Run-Tests.ps1
pwsh -File scripts/ritual-checks.ps1
```

Both are the commands CI runs.
