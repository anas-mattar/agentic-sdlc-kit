# Enforcement assurance — the fixture harness

The kit grades everyone else's work. This is what grades the kit's. Feature 015; the law it
serves is `specs/015-enforcement-assurance/`.

**Kit-only.** Nothing under `tests/` flows down to an adopted project — it is not one of
`doc-lint.ps1`'s shipped surfaces, and the workflow that runs it is classified `kit-only` in
`kit-manifest.json`.

## Running it

```powershell
pwsh -File tests/enforcement/Run-Tests.ps1                      # everything
pwsh -File tests/enforcement/Run-Tests.ps1 -Case STRUCT-001     # one rule
pwsh -File tests/enforcement/Run-Tests.ps1 -Case fail -KeepRepo # keep the repositories to inspect
```

Requires **Pester 5** (`Install-Module Pester -RequiredVersion 5.7.1 -Scope CurrentUser`). The
runner refuses to use the Pester 3.4.0 that ships inside Windows PowerShell: its `Describe`/`It`
mean something different, and a harness that ran green under it would have asserted nothing.

No network at run time. Nothing is written to this repository.

## What a case is

```text
cases/<script>/<RULE-ID>/<pass|fail>/
├── recipe.json     the repository to build
├── command.json    which script to run, with which arguments, and the expected exit code
└── expected.txt    the normalised output, verbatim
```

`recipe.json` declares files and commits — never behaviour. `FixtureRepo.psm1` materialises it
into a **real temporary git repository**, because every defect feature 014's nine review rounds
found was about git reality: a truncated object, an empty `merge-base`, `%P` field ordering,
`core.quotepath`. A mock reproduces none of them. Shallow clones and deliberately corrupt
objects are first-class recipe states for the same reason.

```json
{
  "description": "prose, for the reader",
  "defaultBranch": "main",
  "commits": [
    { "branch": "main",      "message": "init", "write": { "README.md": "kit\n" } },
    { "branch": "001-thing", "message": "spec",
      "write":  { "specs/001-thing/spec.md": ["line one", "line two"] },
      "copy":   { "specs/001-thing/plan.md": "files/plan.md" },
      "delete": ["obsolete.md"] }
  ],
  "checkout": "001-thing",
  "shallow": 1,
  "truncateBlob": "specs/001-thing/plan.md"
}
```

`expected.txt` holds the output with two volatile things replaced: the fixture repository path
becomes `<ROOT>` and any hex run of 7 or more characters becomes `<SHA>`. Line endings are LF
and trailing whitespace is stripped, so a fixture's verdict cannot depend on the platform that
ran it.

## Two rules that are not style preferences

**Write expectations by hand.** Never compute one by calling a helper from the script under
test. Feature 014's B7 defect and GAP-025 both exist because a check and its evidence went
through the same parser: the two agreed with each other, and both were wrong. An expectation
that cannot execute cannot make that mistake.

**Write both directions over the same recipe.** A passing fixture that asserts "no failure
reported" is indistinguishable from a check that returned early and graded nothing — which is
GAP-027 exactly. The pair is what proves the rule fired.

## Coverage

`Coverage.Tests.ps1` scans the nine grading scripts for failure-emission sites and reports how
many are inventoried in `rules.json`. Until phase 6 it **reports**; T044 makes an uncovered site
a failure. What it asserts today is narrower and stricter: that the inventory is honest about
what it already claims — no stale rule, no rule missing a direction, no orphan case — and that
every grading script has an idiom entry, with any undeclared one saying so in writing.

**The scan is two passes, and the second one is the point.** `emission-idioms.json` declares how
each script actually emits a failure; that is the precise pass. A deliberately broad sweep then
looks for anything that merely *smells* like a failure; that is the recall pass. Lines the sweep
finds and the declaration does not are printed as `unclassified candidate(s)`.

That number exists because the first version of this scanner got it wrong in the way that is
hardest to notice. Six regexes modelled on `enforcement-pack.ps1` were applied to all nine
scripts and **silently undercounted three of them** — `doc-lint.ps1` missed its own headline
rule (which accumulates an object, not a string), `verify-kit.ps1` missed 7 of 16 sites (single
quotes), and `build-digests.ps1` missed all 10 of its real rules while counting the wrapper that
prints them. Every one still reported a plausible non-zero number.

**Partial blindness is worse than total blindness.** A script the scanner cannot see at all
reports `IDIOM UNDECLARED` and provokes a question. A script it half-sees reports a number
nobody questions. Watch the unclassified count, not the coverage percentage.
