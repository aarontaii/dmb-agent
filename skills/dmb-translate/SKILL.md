---
name: dmb-translate
description: Translates approved Daily Market Brew Part 1 and Part 2 into Chinese and re-applies WhatsApp bold formatting. Part 3 is never translated.
metadata: { "openclaw": { "emoji": "🀄" } }
---

# Context

The SOP requires Parts 1 and 2 in both English and Chinese; Part 3 goes out in English
only. Translation happens after approval, so it always reflects the approved text including
any supervisor edits.

TODO(G-4): confirm Simplified or Traditional, and whether Hong Kong receives a different
variant from Malaysia and Singapore. Until confirmed this skill emits Simplified and says so.

# Instructions

1. Take the approved English Message 1 and Message 2 from `state/drafts/<date>/final.*.en.txt`.
2. Translate narrative text only. Leave unchanged: index names, company names, tickers,
   indicator names in their conventional form, all figures, all percentages, all source
   attributions, and the emoji.
3. Re-apply single-asterisk bold independently for the Chinese text. Do not copy the English
   asterisk positions - span boundaries differ.
3a. Preserve all line-level formatting characters exactly: `•` bullet prefixes on wrap bullets
    and Events Ahead, `- ` bullet prefixes on Weekend Developments, `1.` through `5.` item
    numbering, and all section headers. Never strip or convert these.
4. Preserve section order, bullet count and the emoji headers exactly.
5. Write `final.msg1.cn.txt` and `final.msg2.cn.txt`, then run `dmb-validate` in Chinese mode.

# Rules

- Never translate Part 3.
- Never add, drop or merge a bullet or an item during translation.
- Word-count gates apply to the English original only; the Chinese is bound by fidelity.
- State the language rule explicitly in your own working notes - scheduled runs do not
  inherit a language from the channel.

# Output format

The two Chinese blocks, fenced, and a one-line confirmation that validation passed.
