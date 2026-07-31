#!/usr/bin/env python3
"""DMB macro events store: seed a week, refresh a day.

Design doc Part C. Two modes:
  seed    --from YYYY-MM-DD --to YYYY-MM-DD   -> write state/events/YYYY-Www.json
  refresh --target YYYY-MM-DD                  -> fill actuals, diff, append changelog

Source is pluggable behind CalendarSource so the HTML scraper can be swapped for the
licensed TradingEconomics API without touching store logic. TODO(G-5).
"""
from __future__ import annotations
import argparse, json, hashlib, os, sys, datetime as dt
from pathlib import Path

STATE = Path(os.environ.get("DMB_STATE", Path(__file__).resolve().parents[3] / "state"))
EVENTS = STATE / "events"
COUNTRIES = {"US": "United States", "CN": "China", "EA": "Euro Area",
             "JP": "Japan", "MY": "Malaysia"}
# TE grades importance globally; small markets get flagged low even when locally
# significant (all MY releases → 1, most CN → 1). Since the store is already scoped
# to five target markets, apply a per-country floor: keep everything from MY/CN,
# quality-gate the majors. Config `minImportance` sets the majors' floor.
MIN_IMPORTANCE_MAJOR = int(os.environ.get("DMB_MIN_IMPORTANCE", "2"))
MIN_IMPORTANCE_BY_ISO = {"US": MIN_IMPORTANCE_MAJOR, "EA": MIN_IMPORTANCE_MAJOR,
                         "JP": MIN_IMPORTANCE_MAJOR, "CN": 1, "MY": 1}


# --------------------------------------------------------------------------- sources
class CalendarSource:
    def fetch(self, start: dt.date, end: dt.date) -> list[dict]:
        raise NotImplementedError


class TEHtmlSource(CalendarSource):
    """Scrape the public server-rendered calendar table.

    Row shape: <tr data-country data-event data-url>
      td[0].class == "YYYY-MM-DD" (date), span.text == "HH:MM AM/PM" (ET),
        span.class contains "calendar-date-{1|2|3}" (importance)
      td[1] (nested) .calendar-iso → ISO code (US/CN/EA/JP/MY etc)
      td[2] <a class="calendar-event"> event name, <span class="calendar-reference"> reference
      td[3..6] .calendar-item: Actual, Previous, Consensus, Forecast (empty ⇒ None)

    The page's date range and country filters are cookie/UI state, not URL state.
    Bare fetch returns TE's current default window; the caller MUST validate it
    covers the requested window (validate_window does this).
    """
    BASE = "https://tradingeconomics.com"
    UA = ("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
          "(KHTML, like Gecko) Chrome/126.0 Safari/537.36")
    # TE per-country calendar slugs for the five markets we care about. Bare /calendar
    # relies on cookie state and silently omits MY and most of CN. Per-country pages
    # are the reliable source per design doc Part C.4.
    COUNTRY_PATHS = {
        "US": "/united-states/calendar", "CN": "/china/calendar",
        "EA": "/euro-area/calendar",     "JP": "/japan/calendar",
        "MY": "/malaysia/calendar",
    }

    def fetch(self, start, end):
        import urllib.request as _u
        from bs4 import BeautifulSoup
        try:
            from zoneinfo import ZoneInfo
        except ImportError:
            from backports.zoneinfo import ZoneInfo
        ET = ZoneInfo("America/New_York")
        s, e = start.isoformat(), end.isoformat()
        by_id: dict[str, dict] = {}
        for _iso, path in self.COUNTRY_PATHS.items():
            req = _u.Request(f"{self.BASE}{path}", headers={"User-Agent": self.UA})
            with _u.urlopen(req, timeout=30) as resp:
                html = resp.read().decode("utf-8", errors="replace")
            for row in self._parse_rows(html, ET, s, e):
                by_id.setdefault(row["_id"], row)  # first-wins dedup across pages
        return [{k: v for k, v in r.items() if k != "_id"} for r in by_id.values()]

    def _parse_rows(self, html, ET, s, e):
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html, "html.parser")
        tbl = soup.find("table", id="calendar")
        if tbl is None:
            raise RuntimeError("TE calendar table (#calendar) not present in fetched HTML")
        for tr in tbl.find_all("tr"):
            url = tr.get("data-url")
            if not url:
                continue
            tds = tr.find_all("td", recursive=False)
            if len(tds) < 7:
                continue
            date_cls = next((c for c in (tds[0].get("class") or []) if len(c) == 10 and c[4] == "-"), None)
            time_span = tds[0].find("span")
            if not date_cls or not time_span:
                continue
            time_txt = time_span.get_text(strip=True)
            try:
                t = dt.datetime.strptime(time_txt, "%I:%M %p").time()
            except ValueError:
                continue  # skip "All Day", "TENTATIVE" etc — no clean ET datetime
            importance = 0
            for c in time_span.get("class") or []:
                if c.startswith("calendar-date-") and c[14:].isdigit():
                    importance = int(c[14:]); break
            iso_cell = tds[1].find("td", class_="calendar-iso")
            iso = iso_cell.get_text(strip=True) if iso_cell else None
            if not iso:
                continue
            event_a = tds[2].find("a", class_="calendar-event")
            event = event_a.get_text(strip=True) if event_a else tds[2].get_text(strip=True)
            ref_span = tds[2].find("span", class_="calendar-reference")
            reference = ref_span.get_text(strip=True) if ref_span else None
            def _val(td):
                s = td.get_text(strip=True) if td is not None else ""
                return s or None
            actual, previous, consensus, forecast = (_val(tds[i]) for i in (3, 4, 5, 6))
            try:
                date_obj = dt.date.fromisoformat(date_cls)
            except ValueError:
                continue
            if not (s <= date_cls <= e):
                continue
            dt_et = dt.datetime.combine(date_obj, t, tzinfo=ET).isoformat()
            data_id = tr.get("data-id") or f"{iso}-{url}-{date_cls}-{time_txt}"
            yield {
                "_id": data_id,
                "iso": iso, "event": event, "reference": reference,
                "indicator_slug": url, "datetime_et": dt_et,
                "importance": importance, "previous": previous,
                "consensus": consensus, "forecast": forecast, "actual": actual,
            }


class TEApiSource(CalendarSource):
    """Licensed API: GET /calendar/country/{country}?c=KEY&d1=&d2=  TODO(G-5)."""
    def fetch(self, start, end):
        raise NotImplementedError("TODO: implement once a TE API key is provisioned.")


def get_source() -> CalendarSource:
    return {"tradingeconomics-html": TEHtmlSource,
            "tradingeconomics-api": TEApiSource}[
        os.environ.get("DMB_CALENDAR_SOURCE", "tradingeconomics-html")]()


# --------------------------------------------------------------------------- helpers
def week_key(d: dt.date) -> str:
    iso = d.isocalendar()
    return f"{iso[0]}-W{iso[1]:02d}"


def event_id(row: dict, date: str) -> str:
    tail = row["indicator_slug"].rstrip("/").split("/")[-1]
    return f"{row['iso'].lower()}-{tail}-{date}"


def to_myt(et_iso: str) -> str:
    d = dt.datetime.fromisoformat(et_iso)
    return (d.astimezone(dt.timezone(dt.timedelta(hours=8)))).isoformat()


def normalise(rows: list[dict]) -> list[dict]:
    out = []
    for r in rows:
        if r["iso"] not in COUNTRIES:
            continue
        if int(r.get("importance") or 0) < MIN_IMPORTANCE_BY_ISO[r["iso"]]:
            continue
        date = r["datetime_et"][:10]
        out.append({
            "id": event_id(r, date), "country": COUNTRIES[r["iso"]], "iso": r["iso"],
            "event": r["event"], "reference": r.get("reference"),
            "indicator_slug": r["indicator_slug"], "datetime_et": r["datetime_et"],
            "datetime_myt": to_myt(r["datetime_et"]), "date": date,
            "day": dt.date.fromisoformat(date).strftime("%A"),
            "importance": int(r.get("importance") or 0),
            "previous": r.get("previous"), "consensus": r.get("consensus"),
            "forecast": r.get("forecast"), "actual": r.get("actual"),
            "status": "pending",
            "first_seen": dt.datetime.now().astimezone().isoformat(),
            "last_checked": None, "rescheduled_from": None,
        })
    return out


def validate_window(rows, start, end):
    """Fail loudly rather than seeding a stale week."""
    if not rows:
        sys.exit("FAIL: source returned no rows for the requested window")
    dates = {r["date"] for r in rows}
    if not any(start.isoformat() <= d <= end.isoformat() for d in dates):
        sys.exit(f"FAIL: returned dates {min(dates)}..{max(dates)} do not intersect "
                 f"requested window {start}..{end}. Refusing to write the store.")


def log_change(kind: str, payload: dict):
    EVENTS.mkdir(parents=True, exist_ok=True)
    with (EVENTS / "changelog.jsonl").open("a", encoding="utf-8") as fh:
        fh.write(json.dumps({"at": dt.datetime.now().astimezone().isoformat(),
                             "kind": kind, **payload}, ensure_ascii=False) + "\n")


# --------------------------------------------------------------------------- modes
def seed(start: dt.date, end: dt.date):
    rows = normalise(get_source().fetch(start, end))
    validate_window(rows, start, end)
    store = {"week": week_key(start), "seeded_at": dt.datetime.now().astimezone().isoformat(),
             "source": os.environ.get("DMB_CALENDAR_SOURCE", "tradingeconomics-html"),
             "window": {"from": start.isoformat(), "to": end.isoformat()},
             "events": rows}
    EVENTS.mkdir(parents=True, exist_ok=True)
    (EVENTS / f"{store['week']}.json").write_text(
        json.dumps(store, indent=2, ensure_ascii=False), encoding="utf-8")
    log_change("seed", {"week": store["week"], "count": len(rows)})
    by_country = {}
    for r in rows:
        by_country[r["country"]] = by_country.get(r["country"], 0) + 1
    high = [f"{r['event']} ({r['country']}, {r['day']})" for r in rows if r["importance"] >= 3]
    print(json.dumps({"week": store["week"], "total": len(rows),
                      "by_country": by_country, "high_impact": high}, ensure_ascii=False))


def refresh(target: dt.date):
    wk = EVENTS / f"{week_key(target)}.json"
    if not wk.exists():
        sys.exit(f"FAIL: no store for {week_key(target)}. Run seed first.")
    store = json.loads(wk.read_text(encoding="utf-8"))
    end = dt.date.fromisoformat(store["window"]["to"])
    fresh = {r["id"]: r for r in normalise(get_source().fetch(target - dt.timedelta(days=1), end))}
    validate_window(list(fresh.values()), target - dt.timedelta(days=1), end)

    known = {e["id"]: e for e in store["events"]}
    diff = {"actuals": 0, "new": 0, "rescheduled": 0, "cancelled": 0}
    now = dt.datetime.now().astimezone().isoformat()

    for eid, new in fresh.items():
        old = known.get(eid)
        if old is None:
            new["first_seen"] = now
            known[eid] = new
            diff["new"] += 1
            log_change("new_event", {"id": eid, "event": new["event"], "date": new["date"]})
            old = new
        if new["datetime_et"] != old["datetime_et"]:
            log_change("rescheduled", {"id": eid, "from": old["datetime_et"], "to": new["datetime_et"]})
            old["rescheduled_from"] = old["datetime_et"]
            old.update({k: new[k] for k in ("datetime_et", "datetime_myt", "date", "day")})
            old["status"] = "pending"
            diff["rescheduled"] += 1
        for field in ("previous", "consensus", "forecast"):
            if new.get(field) and new[field] != old.get(field):
                old[field] = new[field]
        if new.get("actual") and new["actual"] != old.get("actual"):
            log_change("actual", {"id": eid, "actual": new["actual"],
                                  "was": old.get("actual")})
            old["actual"] = new["actual"]
        if old["date"] <= target.isoformat() and old.get("actual"):
            if old["status"] != "done":
                diff["actuals"] += 1
            old["status"] = "done"
        old["last_checked"] = now

    for eid, old in known.items():
        if eid not in fresh and old["status"] == "pending" and old["date"] >= target.isoformat():
            old["status"] = "cancelled"
            diff["cancelled"] += 1
            log_change("cancelled", {"id": eid, "event": old["event"]})

    store["events"] = list(known.values())
    wk.write_text(json.dumps(store, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(diff))


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="mode", required=True)
    s = sub.add_parser("seed"); s.add_argument("--from", dest="start", required=True); s.add_argument("--to", dest="end", required=True)
    r = sub.add_parser("refresh"); r.add_argument("--target", required=True)
    a = ap.parse_args()
    if a.mode == "seed":
        seed(dt.date.fromisoformat(a.start), dt.date.fromisoformat(a.end))
    else:
        refresh(dt.date.fromisoformat(a.target))
