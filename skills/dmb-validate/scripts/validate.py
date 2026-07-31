#!/usr/bin/env python3
"""Deterministic DMB validator - prompt v2.7 FINAL CHECK, executable.

usage: validate.py --draft state/drafts/<date>/draft.json [--lang en|cn] [--stage draft|final]

Exit 0 = PASS (warnings allowed). Exit 1 = FAIL with one line per blocking failure.
Rule ids are stable so failures can be tracked over time.
"""
from __future__ import annotations
import argparse, json, re, sys, unicodedata

BANNED = ["it is worth noting", "it is important to highlight", "as we can see",
          "markets were impacted by", "in a significant development",
          "amid growing concerns", "market participants", "headwinds", "tailwinds",
          "risk sentiment", "investors digested"]
APPROVED = ["reuters.com", "bloomberg.com", "ft.com", "scmp.com", "asia.nikkei.com",
            "theedgemarkets.com", "theedgesingapore.com", "cnbc.com", "finance.yahoo.com"]
SCORECARD = ["S&P 500", "NASDAQ", "STOXX 600", "Nikkei 225", "Hang Seng",
             "CSI 300", "STI", "FBM KLCI", "FBM Small Cap"]
# TODO(G-2): refresh these bands at spec sign-off; the sample already breaches Nikkei.
BANDS = {"S&P 500": (3000, 7000), "NASDAQ": (10000, 25000), "STOXX 600": (300, 600),
         "Nikkei 225": (20000, 55000), "Hang Seng": (10000, 35000),
         "CSI 300": (2500, 6000), "STI": (2500, 5000), "FBM KLCI": (1200, 2000)}
PLACEHOLDERS = [r"\bPENDING\b", r"\bTODO\b", r"\bTBD\b", r"\bXX\b", r"\[[A-Z][^\]]*\]"]
FX_PAIRS = ["USDMYR", "GBPMYR", "EURMYR", "AUDMYR", "SGDMYR", "CNHMYR", "HKDMYR",
            "USDCNH", "AUDUSD"]

fails: list[str] = []
warns: list[str] = []


def fail(rule, where, text=""):
    fails.append(f"FAIL {rule} @ {where}: {text[:160]}")


def warn(rule, where, text=""):
    warns.append(f"WARN {rule} @ {where}: {text[:160]}")


def words(s: str) -> int:
    return len([w for w in re.split(r"\s+", re.sub(r"\*", "", s).strip()) if w])


def sentences(s: str) -> int:
    return len([x for x in re.split(r"(?<=[.!?])\s+", s.strip()) if x])


# ------------------------------------------------------------------ generic text gates
def check_text(label: str, s: str):
    if "—" in s or "–" in s:
        fail("STY-EMDASH", label, s)
    for b in BANNED:
        if b in s.lower():
            fail("STY-BANNED", label, b)
    if s.count("*") % 2:
        fail("FMT-ASTERISK", label, "unbalanced single asterisks")
    for pat in PLACEHOLDERS:
        m = re.search(pat, s)
        if m:
            fail("FMT-PLACEHOLDER", label, m.group(0))
    # prose percentages: 1dp, negatives carry an explicit minus
    for m in re.finditer(r"(\w+)\s+(\*?)(-?\d+(?:\.\d+)?)%", s):
        verb, _, num = m.group(1).lower(), m.group(2), m.group(3)
        if "." in num and len(num.split(".")[1]) != 1:
            warn("FMT-1DP", label, m.group(0))
        if verb in {"fell", "declined", "dropped", "slipped", "shed", "retreated"} and not num.startswith("-"):
            fail("FMT-NEGSIGN", label, m.group(0))


# ------------------------------------------------------------------ section gates
def check_part1(p1: dict):
    if words(p1.get("headline", "")) > 15:
        fail("P1-HEADLINE-LEN", "headline", p1.get("headline", ""))
    check_text("headline", p1.get("headline", ""))

    sc = p1.get("scorecard", {})
    for name in SCORECARD:
        row = sc.get(name)
        if row is None:
            fail("P1-SCORECARD-MISSING", name)
            continue
        if row.get("closed"):
            continue
        lvl, pct = row.get("level"), row.get("pct")
        if pct is None or (str(pct) != "N/A" and not re.fullmatch(r"[+-]?\d+\.\d{2}", str(pct))):
            fail("P1-SCORECARD-2DP", name, str(pct))
        lo, hi = BANDS.get(name, (None, None))
        if lo and isinstance(lvl, (int, float)) and not (lo <= lvl <= hi):
            warn("P1-SANITY-BAND", name, f"{lvl} outside {lo}-{hi}, re-verify")
        if isinstance(pct, str):
            try:
                if abs(float(pct)) > 5:
                    warn("P1-EXTREME", name, f"{pct}% extreme move, re-verify")
            except ValueError:
                pass  # PENDING or non-numeric marker — gate will catch format

    for i, b in enumerate(p1.get("bullets", []), start=1):
        t = b.get("text") or ""
        if not t:
            continue  # skipped bullet (no qualifying release)
        if words(t) > 40:
            fail("P1-BULLET-LEN", f"bullet {i}", t)
        check_text(f"bullet {i}", t)
        # index levels in prose are Malaysia-only
        if i in (1, 3) and re.search(r"\b\d{1,2},\d{3}(\.\d+)?\b", t):
            fail("P1-PROSE-LEVEL", f"bullet {i}", "index point level in a non-Malaysia bullet")
    if not any(b.get("id") == 5 for b in p1.get("bullets", [])):
        fail("P1-BULLET5-MISSING", "bullets", "FBM KLCI bullet is mandatory")



def check_scorecard_vs_bullets(p1: dict):
    """Percentages quoted in prose must match the scorecard for the same index.

    The sample publishes Hang Seng 0.86% / CSI 300 1.30% in the scorecard and 1.5% / 0.6%
    in bullet 3, transposed against each other. Design doc A.4.
    """
    sc = p1.get("scorecard", {})
    text = " ".join(b.get("text") or "" for b in p1.get("bullets", []))
    aliases = {"Hang Seng": ["Hang Seng"], "CSI 300": ["CSI 300"], "S&P 500": ["S&P 500"],
               "NASDAQ": ["Nasdaq", "NASDAQ"], "Nikkei 225": ["Nikkei"],
               "FBM KLCI": ["FBM KLCI"], "STOXX 600": ["STOXX 600"]}
    for name, alts in aliases.items():
        row = sc.get(name)
        if not row or row.get("closed") or row.get("pct") in (None, ""):
            continue
        try:
            want = abs(float(row["pct"]))
        except (ValueError, TypeError):
            continue  # PENDING marker, skip cross-check
        for alt in alts:
            for m in re.finditer(re.escape(alt) + r"[^.]{0,80}?\*?(-?\d+(?:\.\d+)?)%", text):
                got = abs(float(m.group(1)))
                if abs(got - want) > 0.051:   # 1dp prose vs 2dp scorecard
                    fail("XCHK-SCORECARD-PROSE", name,
                         f"prose {got}% vs scorecard {want}%")


def check_items(items: list[dict], stage: str):
    if stage == "final" and len(items) != 5:
        fail("P2-COUNT", "items", f"{len(items)} items in a final, expected 5")
    if stage == "draft" and len(items) != 15:
        warn("P2-POOL", "items", f"{len(items)} candidates, expected 15 (shortfall must be stated)")

    seen = set()
    geo = corp = 0
    tiers = {1: 0, 2: 0, 3: 0}
    for n, it in enumerate(items, start=1):
        t = it.get("text", "")
        w = words(t)
        if not 25 <= w <= 40:
            fail("P2-LEN", f"item {n}", f"{w} words")
        if not re.search(r"\d", t):
            fail("P2-NOFIGURE", f"item {n}", t)
        src = (it.get("source") or "").lower()
        if not any(a in src for a in APPROVED):
            fail("P2-SOURCE", f"item {n}", src or "missing source")
        ent = (it.get("entity") or "").lower()
        if ent and ent in seen:
            fail("P2-DUPLICATE-ENTITY", f"item {n}", ent)
        seen.add(ent)
        check_text(f"item {n}", t)
        tiers[int(it.get("tier", 0) or 0)] = tiers.get(int(it.get("tier", 0) or 0), 0) + 1
        if it.get("category") == "geopolitical":
            geo += 1
        if it.get("category") in {"corporate", "market"}:
            corp += 1
        if it.get("ban_hit"):
            fail("P2-BANLIST", f"item {n}", str(it["ban_hit"]))

    if geo > 2:
        fail("P2-GEO-CAP", "distribution", f"{geo} geopolitical items, max 2")
    if stage == "draft":
        if corp < 5:
            fail("P2-CORP-MIN", "distribution", f"{corp} corporate/market, min 5")
        if tiers.get(3, 0) > 2:
            fail("P2-TIER3-CAP", "distribution", f"{tiers.get(3)} tier-3 items, max 2")



def check_monday(d: dict):
    """Weekend Developments is mandatory on Monday runs and must never be announced absent.

    Found by verification against the sample: 260525_DMB_BR.docx is a Monday run (Friday
    target session) and omits the section entirely. Design doc B.10 row 10.
    """
    run_day = d.get("weekday") or d.get("run_weekday")
    wd = d.get("weekend_developments") or []
    if run_day == "Monday":
        if not 2 <= len(wd) <= 4:
            fail("P2-WEEKEND-MISSING", "weekend developments",
                 f"{len(wd)} bullets on a Monday run, expected 2 to 4")
    elif wd:
        fail("P2-WEEKEND-UNEXPECTED", "weekend developments",
             f"{len(wd)} bullets on a {run_day} target, section is Monday-only")
    blob = " ".join(x.get("text", "") for x in wd).lower()
    if "no weekend development" in blob:
        fail("P2-WEEKEND-NEGATION", "weekend developments",
             "never write that there were no weekend developments")


def check_dm_bullets(bullets: list[dict]):
    """One DM-macro bullet per country/region. The sample splits US CPI and US UoM."""
    seen = {}
    for b in bullets:
        if b.get("id") != 2:
            continue
        c = (b.get("country") or "?").lower()
        seen[c] = seen.get(c, 0) + 1
    for c, n in seen.items():
        if n > 1:
            fail("P1-DM-DUPLICATE-COUNTRY", f"bullet 2 ({c})",
                 f"{n} bullets for the same country, prompt allows one")


def check_item_sources_present(items: list[dict], require_url: bool):
    """TODO(G-10): the prompt mandates inline [Source: Outlet (URL)]; the sample shows none.
    Until G-10 is decided, absence is a warning at draft stage and a failure at final."""
    for n, it in enumerate(items, start=1):
        if not it.get("source"):
            (fail if require_url else warn)("P2-SOURCE-MISSING", f"item {n}", "no source field")


def check_takeaways(s: str):
    if sentences(s) > 3:
        fail("P2-TAKEAWAY-LEN", "key takeaways", f"{sentences(s)} sentences, max 3")
    check_text("key takeaways", s)


def check_part3(p3: dict):
    for t in ("3Y", "5Y", "10Y", "20Y"):
        if t not in p3.get("mgs", {}):
            fail("P3-MGS-MISSING", t)
    for t in ("2Y", "5Y", "10Y", "20Y"):
        if t not in p3.get("ust", {}):
            fail("P3-UST-MISSING", t)
    for i, p in enumerate(FX_PAIRS):
        if p not in p3.get("fx", {}):
            fail("P3-FX-MISSING", p)
    if "spot rate" not in (p3.get("disclaimer") or "").lower():
        fail("P3-DISCLAIMER", "part3", "disclaimer line missing")


def check_dates(d: dict):
    target = d.get("target_session_date")
    if not target:
        fail("DAT-TARGET", "meta", "no target_session_date")
        return
    if d.get("part1", {}).get("data_as_of") != target:
        fail("DAT-ASOF", "scorecard", f"data as of {d.get('part1',{}).get('data_as_of')} != target {target}")
    for e in d.get("events_ahead", []):
        if isinstance(e, str):
            continue  # prose events_ahead — date check not applicable
        if e.get("date", "") <= target:
            fail("DAT-EVENTS-AHEAD", e.get("event", "?"), f"{e.get('date')} not after {target}")
        if e.get("status") != "pending":
            fail("DAT-EVENTS-STATUS", e.get("event", "?"), e.get("status", "?"))


def check_cn(d: dict):
    en, cn = d.get("en", {}), d.get("cn", {})
    if len(en.get("bullets", [])) != len(cn.get("bullets", [])):
        fail("CN-BULLET-COUNT", "part1", "bullet count differs from English")
    if len(en.get("items", [])) != len(cn.get("items", [])):
        fail("CN-ITEM-COUNT", "part2", "item count differs from English")
    nums = lambda s: re.findall(r"[-+]?\d[\d,]*(?:\.\d+)?", s)
    if nums(json.dumps(en, ensure_ascii=False)) != nums(json.dumps(cn, ensure_ascii=False)):
        fail("CN-FIGURES", "all", "figures differ between English and Chinese")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--draft", required=True)
    ap.add_argument("--lang", default="en", choices=["en", "cn"])
    ap.add_argument("--stage", default="draft", choices=["draft", "final"])
    a = ap.parse_args()
    d = json.load(open(a.draft, encoding="utf-8"))

    check_dates(d)
    check_monday(d)
    if "part1" in d:
        check_part1(d["part1"])
        check_dm_bullets(d["part1"].get("bullets", []))
        check_scorecard_vs_bullets(d["part1"])
    check_items(d.get("items", []), a.stage)
    check_item_sources_present(d.get("items", []), require_url=(a.stage == "final"))
    check_takeaways(d.get("key_takeaways", ""))
    if a.stage == "final":
        if "part3" in d:
            check_part3(d["part3"])
        if a.lang == "cn" or "cn" in d:
            check_cn(d)

    for w in warns:
        print(w)
    if fails:
        for f in fails:
            print(f)
        print(f"FAIL: {len(fails)} blocking, {len(warns)} warnings")
        sys.exit(1)
    print(f"PASS: 0 blocking, {len(warns)} warnings")


if __name__ == "__main__":
    main()
