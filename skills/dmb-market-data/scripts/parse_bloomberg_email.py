#!/usr/bin/env python3
"""Parse the Bloomberg 'Morning Brew Data' email into state/marketdata/<date>.json.

Sender:  mybloomberg3@ifastfinancial.com
Subject: [YYMMDD]_Morning Brew Data   e.g. 260710_Morning Brew Data

Mailbox access is pluggable. TODO(G-6): choose Microsoft Graph (recommended, app-only
Mail.Read scoped to the research mailbox), IMAP, or forward-to-Gmail. Nothing else in the
pipeline cares which one wins.

Exits non-zero unless all 9 indices, 8 yields and 9 FX pairs are present. Partial data is
a hold, not a degraded send.
"""
from __future__ import annotations
import argparse, json, os, re, sys, datetime as dt
from pathlib import Path

STATE = Path(os.environ.get("DMB_STATE", Path(__file__).resolve().parents[3] / "state"))
OUT = STATE / "marketdata"

INDICES = ["S&P 500", "NASDAQ", "STOXX 600", "Nikkei 225", "Hang Seng",
           "CSI 300", "STI", "FBM KLCI", "FBM Small Cap"]
MGS = ["3Y", "5Y", "10Y", "20Y"]
UST = ["2Y", "5Y", "10Y", "20Y"]
FX = ["USDMYR", "GBPMYR", "EURMYR", "AUDMYR", "SGDMYR",
      "CNHMYR", "HKDMYR", "USDCNH", "AUDUSD"]


class Mailbox:
    def fetch_body(self, subject_prefix: str) -> str:
        raise NotImplementedError


class GraphMailbox(Mailbox):
    """TODO(G-6): app-only token, GET /users/{mailbox}/messages?$search=subject."""
    def fetch_body(self, subject_prefix):
        raise NotImplementedError("Implement Microsoft Graph fetch.")


class ImapMailbox(Mailbox):
    """TODO(G-6): imaplib search HEADER SUBJECT <prefix>, newest message."""
    def fetch_body(self, subject_prefix):
        raise NotImplementedError("Implement IMAP fetch.")


class FileMailbox(Mailbox):
    """Directory-backed mailbox for phase-1 shadow (G-6).

    DMB_MAILBOX_DIR (from config.fileMailboxDir): scan for `*.eml` whose body
    contains `subject_prefix` (e.g. `260728_Morning Brew Data`), newest mtime wins.
    DMB_EMAIL_FILE: single-file override for ad-hoc parser rehearsals.
    """
    def fetch_body(self, subject_prefix):
        one = os.environ.get("DMB_EMAIL_FILE")
        if one:
            return Path(one).read_text(encoding="utf-8")
        dir_env = os.environ.get("DMB_MAILBOX_DIR")
        if not dir_env:
            sys.exit("FAIL: FileMailbox needs DMB_MAILBOX_DIR or DMB_EMAIL_FILE.")
        d = Path(dir_env)
        if not d.is_dir():
            sys.exit(f"FAIL: DMB_MAILBOX_DIR is not a directory: {d}")
        matches = []
        for p in d.glob("*.eml"):
            try:
                if subject_prefix in p.read_text(encoding="utf-8", errors="replace"):
                    matches.append(p)
            except OSError:
                continue
        if not matches:
            sys.exit(f"FAIL: no .eml in {d} matches subject '{subject_prefix}'. "
                     f"Drop the Bloomberg email into the mailbox dir and retry.")
        return max(matches, key=lambda p: p.stat().st_mtime).read_text(encoding="utf-8")


def get_mailbox() -> Mailbox:
    return {"graph": GraphMailbox, "imap": ImapMailbox, "file": FileMailbox}[
        os.environ.get("DMB_MAILBOX", "file")]()


NUM = r"([-+]?[\d,]+(?:\.\d+)?)"


def parse(body: str) -> dict:
    """Label-driven extraction. Adjust the patterns once a real email is in hand."""
    def grab(label, pattern):
        m = re.search(pattern, body, re.IGNORECASE)
        return m.groups() if m else None

    data = {"indices": {}, "mgs": {}, "ust": {}, "fx": {}}
    for name in INDICES:
        g = grab(name, rf"{re.escape(name)}[^\d+-]{{0,20}}{NUM}[^\d+-]{{1,20}}{NUM}\s*%")
        if g:
            data["indices"][name] = {"level": float(g[0].replace(",", "")),
                                     "pct": float(g[1])}
    for t in MGS:
        g = grab(t, rf"MGS\s*{t}[^\d+-]{{0,10}}{NUM}\s*%[^\d+-]{{0,10}}{NUM}\s*bps")
        if g:
            data["mgs"][t] = {"yield": float(g[0]), "bps": float(g[1])}
    for t in UST:
        g = grab(t, rf"UST\s*{t}[^\d+-]{{0,10}}{NUM}\s*%[^\d+-]{{0,10}}{NUM}\s*bps")
        if g:
            data["ust"][t] = {"yield": float(g[0]), "bps": float(g[1])}
    for p in FX:
        g = grab(p, rf"{p}[^\d+-]{{0,10}}{NUM}[^\d+-]{{0,10}}{NUM}\s*%")
        if g:
            data["fx"][p] = {"rate": float(g[0].replace(",", "")), "pct": float(g[1])}
    return data


def assert_complete(d: dict):
    missing = ([f"index:{i}" for i in INDICES if i not in d["indices"]]
               + [f"mgs:{t}" for t in MGS if t not in d["mgs"]]
               + [f"ust:{t}" for t in UST if t not in d["ust"]]
               + [f"fx:{p}" for p in FX if p not in d["fx"]])
    if missing:
        sys.exit("FAIL incomplete Bloomberg data, holding draft. Missing: " + ", ".join(missing))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", required=True, help="YYYY-MM-DD (today, MYT)")
    a = ap.parse_args()
    d = dt.date.fromisoformat(a.date)
    body = get_mailbox().fetch_body(d.strftime("%y%m%d") + "_Morning Brew Data")
    data = parse(body)
    assert_complete(data)
    data["parsed_at"] = dt.datetime.now().astimezone().isoformat()
    data["source"] = "Bloomberg Finance L.P."
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / f"{a.date}.json").write_text(json.dumps(data, indent=2), encoding="utf-8")
    print(json.dumps({"status": "ok", "indices": len(data["indices"]),
                      "yields": len(data["mgs"]) + len(data["ust"]), "fx": len(data["fx"])}))


if __name__ == "__main__":
    main()
