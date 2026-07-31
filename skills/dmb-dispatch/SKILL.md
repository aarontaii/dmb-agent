---
name: dmb-dispatch
description: Sends the approved Daily Market Brew to the advisor WhatsApp groups in Malaysia, Singapore and Hong Kong, idempotently, with per-group send receipts.
metadata: { "openclaw": { "emoji": "📤", "requires": { "bins": ["bash"] } } }
---

# Context

Called only by `dmb-review-gate` after an approval. This is the last step and the one with
the largest blast radius: a duplicate or premature send is visible to every advisor.

# Instructions

1. Verify `state/drafts/<date>/decision.json` shows `approved` and that its draft hash matches
   the files you are about to send. A mismatch aborts the send.
2. Pre-flight the channel. Outbound WhatsApp needs an active listener for the account; check
   before the first send, not after a failure.
3. Send in reading order, per group, with a short delay between messages:
   Message 1 EN, Message 1 CN, Message 2 EN, Message 2 CN, Part 3 EN.
   `bash {baseDir}/scripts/dispatch.sh --date <date> --group <region>`
4. Write a receipt per group per message index to `state/drafts/<date>/receipts.jsonl` keyed
   on draft hash. On any retry, skip every message that already has a receipt.
5. Post the receipt summary and the audit id back to the working group.

TODO(G-4): if Hong Kong takes a different Chinese variant, dispatch per region rather than
broadcasting one payload to all three.
TODO(G-9): the email leg to MY/SG/HK advisors is required by the SOP and is not yet wired here.

# Error handling

- A single group fails: continue with the others, report exactly which group and which
  message index failed, and leave those receipts unwritten so a retry resumes cleanly.
- Channel not connected: abort before sending anything and alert the working group.

# Rules

- Never send without a matching approved decision file.
- Never re-send a message that has a receipt.
- Never edit content at this stage. If something looks wrong, abort and report.
