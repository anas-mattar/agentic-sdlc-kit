# Quickstart: verifying the configurable cooling-off period by hand

Run from the repository root of a project (or a fixture) that has a Critical feature in the solo arm, with
`second-model-review.md` committed.

1. **Default, unchanged.** With no `coolingOffHours` in `kit-adoption.json`, run
   `pwsh -File scripts/enforcement-pack.ps1`. A review under 24 hours old fails with the same message as before;
   one over 24 hours old passes. No warning appears.

2. **A shorter period, justified.** Add:

   ```json
   { "coolingOffHours": 4, "coolingOffReason": "small tooling repo; reviewed same day" }
   ```

   Re-run. A review 5 hours old now passes, with one WARN naming 4 hours and quoting the reason. A review 3 hours old
   fails, and the message names 4h and the clause `declared in kit-adoption.json coolingOffHours;`.

3. **No reason.** Remove `coolingOffReason`. Re-run: 24 hours applies again, and one WARN says the declared 4 hours
   was set aside because no reason is recorded.

4. **A bad value.** Set `"coolingOffHours": 0`, then `1.5`, then `"8"`. Each time 24 applies. Run
   `pwsh -File scripts/verify-kit.ps1`: it names the field, the value it read, that 24 hours applies and how to fix it.

5. **Longer than the default.** Set `"coolingOffHours": 48`. No reason needed, no warning, and a review 30 hours old
   fails naming 48h.

6. **Team arm.** Declare two developers and a `human-pr-review.md`. The pack's output is the same whatever the two
   keys say; the doctor warns that the setting has no effect in team mode.

7. **Fixtures.** `pwsh -File tests/enforcement/Run-Tests.ps1 -Case CRIT-S03` still passes unchanged, and the new
   cases pass; then run the whole suite.
