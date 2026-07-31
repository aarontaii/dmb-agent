# DMB editorial rules (condensed from prompt v2.7, drafting-relevant parts only)

Rules that are enforced by `dmb-validate` are marked [CODE] and need not be re-checked by
the model. Everything unmarked is your judgement to get right.

## Events Ahead

- Filter: `status == pending AND date > target_session_date` from the events store.
- When zero events match — common on Fridays before the next week is seeded — the
  section renders as a single line "No major events scheduled ahead" with no bullets.
  Never fabricate events, never error, never explain the absence.

## Session and closures

- Target session: Mon -> prior Friday (+ Sat–Sun sweep, label *(Weekend)*), Tue -> Mon,
  Wed -> Tue, Thu -> Wed, Fri -> Thu. Datelines anchored to US Eastern. [CODE]
- Weekend news is eligible on Monday runs only.
- Each market's closure is checked against its own exchange calendar: NYSE/Nasdaq, HKEX,
  JPX/TSE, SSE, SGX, Bursa Malaysia, Euronext/national for Europe. A US holiday implies
  nothing about Asia or Europe. [CODE]
- If the target date was a holiday for a market, that closure is the complete answer for
  that market. Do not hunt for the last date it traded. Yahoo Finance can serve stale
  cached KLCI data on Bursa holidays: never trust it alone for closure status.

## Verification

- Broad feed first: Reuters, Bloomberg, CNBC markets news for the target date, FT where
  reachable. Not Reuters alone.
- Every result must carry the target session date as its publication date. Reject prior-day
  results even when republished.
- Prices and index levels come from the Bloomberg data email and are authoritative. Web
  figures are a cross-check only, and a disagreement blocks release. [CODE]
- All other material figures (macro actuals, earnings, deal values, any number inside the
  five items): >= 3 independent sources. Two is a starting point. Conflicts are stated as a
  range, never suppressed.
- CSI 300: check the Yahoo Finance at-close quote and cross-check the percentage against one
  broad-feed Asia wrap before marking N/A. FBM Small Cap: attempt the source order once,
  then N/A.
- Spot audit all items after drafting: reject on no match, wrong date, contradicting figure,
  or prior-day origin. Per item confirm: did it happen, which date, exact figure, named
  entity, market reaction.

## Standing checks, every session

1. FX / currency policy for Fed, ECB, BOJ, PBoC, BNM, BOE, RBA and their finance ministries.
   Fires only on a confirmed intervention, or a wire-reported genuine policy or tactical
   shift tied to a >= ±0.5% intraday move. Routine jawboning is dropped silently.
2. Major listing or IPO debut for the target date, scoped to the approved sources, run
   independently of the earnings pre-scan.
3. Earnings pre-scan: Apple, Microsoft, Nvidia, Amazon, Alphabet, Meta, Tesla, TSMC,
   Samsung, Alibaba, Tencent. Prioritise where results moved the share price.
4. Standard US release calendar against the target date (NFP, CPI, PCE, ISM, JOLTS,
   Consumer Confidence, UoM, GDP, jobless claims, retail sales, durable goods, Chicago PMI).
   With the scraped events store this is largely automatic; report any store diff in the footer.

## Narrative

Priority order for the dominant narrative: Fed policy, Treasury yields, mega-cap earnings,
macro surprise, China policy, energy, geopolitical escalation, major corporate deals.
Requires >= 2 supporting signals. Must explain the S&P 500, the Nasdaq and >= 1 Asian index,
unless the US was closed, in which case >= 2 markets that traded. A US closure is reported,
not explained. Classify as one of: Fed Day, Inflation Day, Rates Day, AI/Tech Day, China
Macro Day, Energy Day, Geopolitical Risk Day, Risk-On Day, Risk-Off Day, US Holiday Day.
The classification appears in the editorial footer only, never in a WhatsApp message.

## Items — tiers, caps, sources, rejects

- Tier 1 (1–4): in-scope central bank decisions, major macro data, geopolitical/tariff,
  energy only when policy or geopolitically driven (OPEC+, sanctions, supply disruption,
  government or regulatory emergency orders on supply or grid reliability). Raw commodity
  price moves are not Tier 1. FX/currency-policy findings land here.
- Tier 2 (5–12): earnings, M&A, IPOs, guidance, CEO changes, analyst calls, regulatory
  actions, US and European primarily. >= 3 corporate. [CODE]
- Tier 3 (13–15): China/HK and Malaysia, with a Japan/Korea/Taiwan/Singapore corporate
  fallback only if China/HK plus Malaysia cannot fill 2 of 3. Leave a slot empty rather than
  padding, and note the shortfall.
- Caps: <= 2 geopolitical across all 15; >= 5 corporate or market-specific; Tier 3 max 2
  total, max 1 China/HK, max 1 Malaysia. Malaysian contract wins only above RM500 mn;
  Malaysian earnings need a revenue or profit figure and a share price move. [CODE]
- Central banks in scope: Fed, ECB, BOJ, PBoC, BNM, BOE, RBA. All others ignored.
- Approved sources only: reuters.com, bloomberg.com, ft.com, scmp.com, asia.nikkei.com,
  theedgemarkets.com, theedgesingapore.com, cnbc.com, finance.yahoo.com. [CODE]
  A wire byline on a non-approved host attributes to the wire: write `[Source: reuters.com]`
  with no URL rather than discarding the item.
- Reject without exception: index-level moves as items; opinion polls, approval ratings,
  sentiment surveys; currency moves with no policy catalyst; commodity moves with no named
  company share reaction; small-cap initiations under USD500 mn; natural disasters unless a
  listed company above USD1 bn moved with a stated percentage; strategy overhauls with no
  share move and no figure; previews or forward-looking statements; art, cultural or CSR
  events; criminal arrests with no market impact. Korea single stocks only on ±3%+ with a
  cited catalyst. No STI index stories; Singapore corporate only with figures from
  theedgesingapore.com.
- Ban list: any indicator used in bullets 1–6 is banned from all items, even reframed. No
  company named as a bullet catalyst reappears unless the news is genuinely distinct. No
  company twice. [CODE]
- So-what defaults: share price reaction for earnings, guidance and single-stock news; deal
  mechanics for JVs, alliances and deal structures; deal mechanics or a distinct listed
  company's reaction for private and unlisted entities. Never force a share price onto an
  entity that has none.
- Star the four flag conditions: an in-scope central bank decision, a geopolitical or tariff
  development, an M&A/JV/IPO, a material Asia or Malaysia corporate story meeting Tier 3
  criteria. An FX item earns the star only if it is an actual decision.

## Style

- British English: stabilise, programme, centre, labour, recognised. USD, bn, tril, mn.
  y/y, m/m.
- Bloomberg/FT/Reuters register. Active voice only. Vary sentence length. Every claim
  attributed to a named source, company statement, data release or official.
- No em dashes under any circumstances. [CODE]
- Approved verbs: rose, fell, climbed, declined, advanced, retreated, edged higher, slipped,
  gained, shed, jumped, dropped, held steady, narrowed, widened.
- Banned phrases: "it is worth noting", "it is important to highlight", "as we can see",
  "markets were impacted by", "in a significant development", "amid growing concerns",
  "market participants", "headwinds", "tailwinds", "risk sentiment", "investors digested". [CODE]
- Bold with single asterisks: company names, index names, percentage moves, price levels,
  USD/RM figures, indicator names, catalysts, day names. Over-bolding is acceptable,
  under-bolding is not.
- Numbers: comma thousands, full-stop decimals. Scorecard 2dp; positives carry no sign,
  negatives carry an explicit minus. Prose 1dp with an explicit minus sign on negatives
  alongside the verb. [CODE]
- No preamble. Start with the header.
