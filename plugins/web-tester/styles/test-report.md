# Web Test Report Style Guide

This file defines the formatting and tone conventions for all output produced by the `web-tester` plugin agents.

---

## General Principles

- Be **specific** — every finding must reference a page path and scenario ID
- Be **actionable** — every failure must include the actual vs expected behaviour
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
[2–3 sentences: overall health of the tested area, what passed, what needs attention]

---

## Scenario Summary
[table: scenario ID × functional/UI/A11y/perf columns]

---

## Results by Area
[table: area name, status, scenarios run, issue count, critical count]

---

## Critical Issues (Must Fix)
[bullet list — if none: "No critical issues found."]

## Warnings
[bullet list — if none: "No warnings found."]

## Skipped Scenarios
[table — omit section if no scenarios were skipped]
```

Do not reorder or omit sections. If a section has no findings, write the explicit "none found" note.

---

## Scenario Summary Table Format

```markdown
| ID      | Scenario name            | Functional | UI | A11y | Perf |
|---------|--------------------------|------------|----|----- |------|
| SC-001  | <name>                   | ✅ Pass    | ✅ | ✅   | ✅   |
| SC-002  | <name>                   | ❌ Fail    | ✅ | ✅   | —    |
```

Rules:
- Show `—` when a scenario does not have a counterpart in that dimension
- Always use the status indicator symbols, never plain text
- Scenario names should be truncated at 45 characters with `…` if longer

---

## Failure Entry Format

Every failure in the Critical Issues or Warnings sections must follow this structure:

```
- [ ] SC-NNN `/<path>` — <short title of the failure>
  **Expected:** <what the scenario said should happen>
  **Actual:** <what actually happened>
  **Severity:** CRITICAL | WARNING
```

---

## Confidence Notice

When `Context Confidence` is `LOW` or `MEDIUM`, include this notice immediately after the header block:

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
- Be concise — a failure entry should not exceed 5 lines of prose
- Performance recommendations should name a specific technique, not just say "improve performance"
