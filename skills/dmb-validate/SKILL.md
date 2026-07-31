---
name: dmb-validate
description: Deterministic pre-send validator for the Daily Market Brew. Checks word counts, formatting, rounding, tier distribution, source allowlist, dedup and placeholders, and returns a pass/fail report.
metadata: { "openclaw": { "emoji": "🧪", "requires": { "bins": ["python3"] } } }
---

# Context

This skill exists so the model cannot ship a rule violation. It is code, not judgement:
`python3 {baseDir}/scripts/validate.py --draft <path> [--lang en|cn] [--stage draft|final]`.
It is the v2.7 FINAL CHECK list, executable.

# Instructions

1. Run the script against the draft or final files.
2. Report every failure with the rule id, the offending text and the fix required. Never
   summarise as "some issues".
3. Blocking failures stop the pipeline. Warnings are reported and continue.

# Checks (blocking unless marked warn)

- Dateline, scorecard `data as of` date and event dates all consistent with the target session.
- Headline word count <= 15. Each wrap bullet <= 40 words. Key Takeaways <= 3 sentences.
- Balanced single asterisks; no stray markdown; no em dash anywhere; no banned phrase.
- Scorecard: 9 indices present in fixed order, 2dp with explicit sign, comma thousands,
  full-stop decimals, each level inside its sanity band (outside band = warn + re-verify flag).
- Prose percentages 1dp; negative moves carry an explicit minus sign alongside the verb.
- Index point levels in prose only for FBM KLCI and FBM Small Cap.
- Items: exactly 5 in the final; 25 to 40 words each; entity-first; past tense marker; at
  least one figure; inline source on the approved-outlet list; no company twice.
- Tier and distribution caps: tiers 1/2/3 counts, >= 3 corporate in tier 2, tier 3 caps,
  <= 2 geopolitical, >= 5 corporate or market-specific overall.
- Ban list: no bullet 1 to 6 indicator reused in any item; no bullet catalyst company restated.
- No PENDING, TODO, TBD, XX or bracketed placeholder anywhere in a final file.
- Cross-check: every percentage quoted in prose matches the scorecard for the same index.
  This catches transposed or stale figures, the defect present in the supplied sample.
- Weekend Developments: 2 to 4 bullets on Monday runs, absent otherwise, never a written
  statement that there were none.
- One DM-macro bullet per country. Two US bullets is a failure.
- Every item carries a source. Warning at draft stage, failure at final. TODO(G-10).
- Part 3: 8 yields and 9 FX pairs present, fixed order, correct precision, disclaimer line present.
- Chinese mode: same section and bullet counts as English, figures byte-identical, asterisks balanced.

# Rules

- Never pass a draft with a blocking failure, whatever the time pressure.
- Never edit the draft. Report and hand back.

# Output format

`PASS` plus a count of warnings, or `FAIL` plus one line per failure: rule id, location, offending text.
