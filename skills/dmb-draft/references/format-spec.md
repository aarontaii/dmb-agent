# DMB output templates (canonical)

Derived from `260525_DMB_BR.docx` (published form) reconciled with prompt v2.7.
Open format decisions are marked TODO(G-n) and resolved in design doc section B.10.

## Message 1 — Market Moves

```
📣 *iFAST Daily Market Brew* 📣
*[Weekday, Month D, YYYY]*            <- TODO(G-8) date format

*[HEADLINE — max 15 words]*

🇺🇸 S&P 500: [level] ([X.XX]%) 📈  [no + on positives; minus on negatives]
🇺🇸 NASDAQ: [level] ([X.XX]%) 📈
🇪🇺 STOXX 600: [level] ([X.XX]%) 📈
🇯🇵 Nikkei 225: [level] ([X.XX]%) 📈
🇭🇰 Hang Seng: [level] ([X.XX]%) 📈
🇨🇳 CSI 300: [level] ([X.XX]%) 📈
🇸🇬 STI: [level] ([X.XX]%) 📈
🇲🇾 FBM KLCI: [level] ([X.XX]%) 📈
🇲🇾 FBM Small Cap: [level] ([X.XX]%) 📈
(returns in local currency terms, data as of [D Month YYYY])

• [Bullet 1 US equities]
• [Bullet 2 DM macro, if any]
• [Bullet 3 Asia ex-Malaysia]
• [Bullet 4 China macro, if any]
• [Bullet 5 FBM KLCI]
• [Bullet 6 Malaysia macro, if any]

💡 *Events Ahead*: 💡
• [Prose per day or logical group, bold day and event names, no forecasts, name the heaviest day]
• [Groups use • bullet prefix, one per logical cluster]
• [Format: • *Weekday* verbs *Event* specifics...]
When the events store returns zero pending events after the target date (common on
Fridays before the following week is seeded), render a single unbulleted line:
  No major events scheduled ahead.
The supervisor sees zero E candidates and `APPROVE EVENTS` with no arguments drops
the section.
```

TODO(G-1): sign convention and the down-move glyph (📉). TODO(G-2): refresh sanity bands.
Closed market line: `Market Closed ([Holiday Name])`. Never a prior-day price.

### Bullet contract

| Bullet | Fires | Contains | Never |
| --- | --- | --- | --- |
| 1 | always | S&P 500 + Nasdaq % moves + primary catalyst | levels; if US closed pivot to the 10-year Treasury yield |
| 2 | listed DM release or unlisted standard US release on target date | `[Indicator] rose/fell [X%] in [Month] ([X%] forecast; [Y%] prior), [context]`, one bullet per country | two bullets for the same country; announcing an absence (skip silently) |
| 3 | always | Hang Seng + CSI 300 % moves; Nikkei only if >±1.5% or dominant | STI; KOSPI unless >±3%; levels |
| 4 | listed China release | all China macro figures | repeating them in bullet 3 |
| 5 | always | day of week + % move + index level | prior-day level when Bursa closed |
| 6 | listed Malaysia release | — | silent skip if none |

## Message 2 — Intelligence

```
[Monday runs only]
- *(Sat)* [Entity] [what happened, key figures].
- *(Sun)* [Entity] [what happened, key figures].
2 to 4 bullets prefixed with `- `. Omit the section entirely Tue–Fri. Never write "no weekend developments".
MANDATORY on Monday runs and gated in code: the supplied sample is a Monday run and omits
this section, which is how the omission survived. A Monday run without it fails validation.

💡 *iFAST's 5 Things You Need To Know Today*: 💡
1. [Item 1, 25–40 words, entity first, past tense, one key number, one so-what,
   inline source from the approved list]
2. [Item 2]
3. [Item 3]
4. [Item 4]
5. [Item 5]

✅ *Key Takeaways*:
[2–3 sentences. Forward-looking signal or sharp observation. Never a summary of the items.]
```

## Message 3 — Part 3 (English only, never translated)

```
Part 3
*[Weekday, Month D, YYYY]*

*🇲🇾 MGS Yields*
MGS 3Y: [x.xx]%, [±x.x] bps
MGS 5Y: [x.xx]%, [±x.x] bps
MGS 10Y: [x.xx]%, [±x.x] bps
MGS 20Y: [x.xx]%, [±x.x] bps

*🇺🇸 UST Yields*
UST 2Y: [x.xx]%, [±x.x] bps
UST 5Y: [x.xx]%, [±x.x] bps
UST 10Y: [x.xx]%, [±x.x] bps
UST 20Y: [x.xx]%, [±x.x] bps

*FX Rate*
🇺🇸🇲🇾 USDMYR: [x.xxxx], [±x.xx]%
🇬🇧🇲🇾 GBPMYR: [x.xxxx], [±x.xx]%
🇪🇺🇲🇾 EURMYR: [x.xxxx], [±x.xx]%
🇦🇺🇲🇾 AUDMYR: [x.xxxx], [±x.xx]%
🇸🇬🇲🇾 SGDMYR: [x.xxxx], [±x.xx]%
🇨🇳🇲🇾 CNHMYR: [x.xxxx], [±x.xx]%
🇭🇰🇲🇾 HKDMYR: [x.xxxx], [±x.xx]%
🇺🇸🇨🇳 USDCNH: [x.xxxx], [±x.xx]%
🇦🇺🇺🇸 AUDUSD: [x.xxxx], [±x.xx]%

Source: Bloomberg Finance L.P., iFAST Compilations.
*Rates above are referring to spot rate and serve as an indication only, actual conversion rate will be different.
```

## Editorial footer (working group only, never sent)

- Dominant narrative: [classification] — [>=2 named signals]
- Holiday closures applied: [market: holiday] or omit
- Source conflicts: [range + sources] or omit
- Item shortfall: [count + reason] or omit
- Events store diff: [actuals captured / new / rescheduled / cancelled]
- FX/currency policy check: [finding, or "no qualifying development"] — always present


## Item source attribution — TODO(G-10)

The prompt mandates `[Source: Outlet (URL)]` inline on every item. The supplied sample
carries no attribution on any of its five items. Until G-10 is decided the validator warns
at draft stage and fails at final, and the source is always recorded in the structured draft
regardless of whether it is printed.
