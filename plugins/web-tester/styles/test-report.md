# Web Test Report Style Guide

This file defines the formatting and tone conventions for all output produced by the `web-tester` plugin agents.

---

## General Principles

- Be **specific** — every finding must reference a page path and scenario ID
- Be **actionable** — every failure must include the actual vs expected behaviour and a concrete fix
- Be **calibrated** — severity must reflect real user impact, not be inflated
- Be **honest about confidence** — always show the context confidence level so users know how much to trust the results
- Avoid filler: no "Great job!", no "As an AI...", no padding

---

## Severity Levels

| Label | When to use |
|-------|------------|
| `CRITICAL` | Broken functionality, accessibility blocker, severe performance failure, data loss risk |
| `WARNING` | Degraded experience, non-blocking but should be fixed, moderate accessibility violation |
| `INFO` | Minor issue, cosmetic concern, low-priority improvement |

---

## Status Indicators

Use these consistently across all tables:

| Symbol | Meaning |
|--------|---------|
| ✅ PASS | Met all expected conditions |
| ❌ FAIL | One or more expected conditions not met |
| ⚠️ WARN | Passed but with degraded metrics or minor issues |
| ⚠️ SKIP | Not executed — typically due to missing auth credentials |
| — | Not applicable for this scenario/dimension |

---

## Report Structure

The compiled report from `web-tester` must follow this exact section order:

```markdown
# Web Functional Test Report

**URL:** <base url>
**Area Tested:** <area name>
**Context Confidence:** HIGH | MEDIUM | LOW
**Context Source:** Area context file | UI inference only
**Tested:** <ISO 8601 timestamp>
**Scope:** smoke | full
**Scenarios Generated:** <N> | **Executed:** <N> | **Skipped:** <N>
**Overall Status:** PASS | PARTIAL | FAIL

---

## Executive Summary
[dimension health card table — one row per dimension]
[2–3 sentence paragraph below the table — optional detail on notable findings]

---

## Priority Fix List
[numbered list of top actionable items — max 5, ordered by impact]

---

## Scenario Summary
[table: scenario ID × functional/UI/A11y/perf columns]
[legend line beneath the table]

---

## Results by Area
[table: area name, status, scenarios run, issue count, critical count]

---

## Critical Issues (Must Fix)
[bullet list grouped by dimension — if none: "No critical issues found."]

## Warnings
[bullet list grouped by dimension sub-sections — if none: "No warnings found."]

## Skipped & Excluded Scenarios
[skipped table + excluded table — omit entire section if both are empty]
```

Do not reorder or omit sections. If a section has no findings, write the explicit "none found" note.

---

## Executive Summary Format

Replace the paragraph-only summary with a dimension health card table, followed by an optional short paragraph.

```markdown
## Executive Summary

| Dimension     | Status   | Summary                                               |
|---------------|----------|-------------------------------------------------------|
| Functional    | ✅ PASS  | <one sentence — what passed, any notable warn>        |
| UI            | ✅ PASS  | <one sentence>                                        |
| Accessibility | ⚠️ WARN  | <one sentence — how many issues, top issue name>      |
| Performance   | ⚠️ WARN  | <one sentence — key metric or missing optimisation>   |

<Optional 1–2 sentence paragraph for any cross-cutting observation not captured in the table.>
```

Rules:
- Status in the table must match the sub-agent's overall result for that dimension
- Summary column: one sentence maximum, written in present tense
- If a dimension produced no scenarios (e.g. performance not in scope), write `—` in Status and omit from the table

---

## Priority Fix List Format

A short, scannable list of the most impactful actions a developer should take after reading the report. Place this immediately after the Executive Summary, before the Scenario Summary.

```markdown
## Priority Fix List

1. **<Fix title>** — <one sentence: what to do and where> `[<SC-ID>]`
2. **<Fix title>** — <one sentence> `[<SC-ID>]`
...
```

Rules:
- Maximum 5 items — if there are more issues, surface only the highest severity ones here; the rest are in the Warnings section
- Order by severity first (CRITICAL before WARNING), then by estimated fix effort (quick wins before complex changes)
- Each item must be a concrete action, not a restatement of the finding — "Add `UseResponseCompression` to the ASP.NET Core pipeline" not "Fix compression"
- Reference the scenario ID in brackets at the end of each line
- If there are no issues at all, omit this section entirely

---

## Scenario Summary Table Format

```markdown
| ID      | Scenario name            | Functional | UI | A11y | Perf |
|---------|--------------------------|------------|----|----- |------|
| SC-001  | <name>                   | ✅ Pass    | ✅ | ✅   | ✅   |
| SC-002  | <name>                   | ❌ Fail    | ✅ | ✅   | —    |
```

> ✅ Pass · ❌ Fail · ⚠️ Warn · ⏭ Skip · — Not applicable

Rules:
- Always include the legend line immediately after the closing table row
- Show `—` when a scenario does not have a counterpart in that dimension
- Always use the status indicator symbols, never plain text
- Scenario names should be truncated at 45 characters with `…` if longer; ensure the truncation does not cut mid-word

---

## Issue Entry Format

Every entry in Critical Issues or Warnings must follow this structure — four labelled fields, no exceptions:

```
- [ ] SC-NNN `/<path>` — <short title of the failure>
  **Expected:** <what the scenario said should happen>
  **Actual:** <what actually happened>
  **Fix:** <concrete action — name the element, method, attribute, or setting to change>
  **Severity:** CRITICAL | WARNING
```

Rules:
- `Fix:` must be a specific, actionable instruction in second person ("Add `aria-label` to `#search-filter`", not "Fix the label")
- Do not exceed 5 lines of prose across all four fields combined
- For performance issues, `Fix:` must name a specific technique or configuration setting, not just "improve performance"

---

## Warnings Grouped by Dimension

The `## Warnings` section must be split into dimension sub-sections. Only include sub-sections that have findings.

```markdown
## Warnings

### Accessibility
- [ ] SC-NNN ...

### Performance
- [ ] SC-NNN ...

### Functional
- [ ] SC-NNN ...

### UI
- [ ] SC-NNN ...
```

If all warnings belong to one dimension, still use the sub-section heading — it makes the grouping explicit and consistent across runs.

If there are no warnings at all: write `No warnings found.` without sub-sections.

The same grouping applies to `## Critical Issues` when multiple dimensions have critical findings.

---

## Appendix Cross-References

When a dimension sub-section in Warnings or Critical Issues has a corresponding appendix, add a cross-reference line at the end of that sub-section:

```markdown
### Accessibility
- [ ] SC-009 ...
- [ ] SC-001 ...

*Full check results: see [Appendix — Accessibility Evidence](#appendix--accessibility-evidence)*
```

Apply this pattern for any appendix section present in the report (Accessibility Evidence, Performance Evidence, Functional Test Evidence).

---

## Skipped & Excluded Scenarios Format

Rename the section from `Skipped Scenarios` to `Skipped & Excluded Scenarios`. It contains two distinct tables.

**Skipped** — scenarios that were in scope but not executed at runtime (e.g. missing auth credentials):

```markdown
### Skipped at Runtime
| ID     | Scenario          | Reason                                      |
|--------|-------------------|---------------------------------------------|
| SC-006 | <scenario name>   | Requires WEBAPP_USERNAME / WEBAPP_PASSWORD  |
```

**Excluded** — scenarios that were deliberately out of scope for this run (e.g. smoke scope excludes non-critical paths). Pull these from the scenario manifest's excluded list:

```markdown
### Excluded from This Run (scope: smoke)
| Scenario                     | Reason                                                  |
|------------------------------|---------------------------------------------------------|
| Filter by region/language    | No filter control detected; deferred to full scope      |
| Combined category + price    | Combination test deferred to full scope                 |
```

Rules:
- If there are no skipped scenarios at runtime, omit the `### Skipped at Runtime` sub-section
- If scope is `full`, omit the `### Excluded from This Run` sub-section (nothing is excluded)
- If both sub-sections would be empty, omit the entire `## Skipped & Excluded Scenarios` section

---

## Confidence Notice

When `Context Confidence` is `LOW` or `MEDIUM`, include this notice immediately after the header block, before the Executive Summary:

**LOW:**
```
> ⚠ **Low confidence results** — No context file was found for this area. Scenarios were
> inferred from the site structure and may not reflect actual business requirements.
> Create `.xianix/web-test/contexts/<area>.md` to improve test quality.
```

**MEDIUM:**
```
> ℹ **Medium confidence results** — Context file found but missing Expected Outcomes or
> Business Rules. Consider completing `.xianix/web-test/contexts/<area>.md` for more
> precise scenario assertions.
```

---

## Tone

- Use **present tense** for findings: "The form submits without validation", not "The form submitted without validation"
- Use **second person** for recommendations: "Add a `<label>` element to each input"
- Be concise — a failure entry should not exceed 5 lines of prose across all four fields
- Performance recommendations must name a specific technique, not just say "improve performance"
