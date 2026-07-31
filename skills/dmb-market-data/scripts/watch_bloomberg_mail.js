// OpenClaw cron condition-trigger gate: fire once when today's Bloomberg email exists.
// Returns { fire, message?, state? }. Previous state arrives frozen as trigger.state.
// Requires cron.triggers.enabled — this runs headlessly with the agent's full tool policy.
const today = new Date().toLocaleDateString("en-CA", { timeZone: "Asia/Kuala_Lumpur" }); // YYYY-MM-DD
const stamp = today.slice(2).replace(/-/g, "");                                          // YYMMDD

if (trigger.state?.seen === today) {
  json({ fire: false, state: trigger.state });                 // already handled today
} else {
  const res = await tools.call("exec", {
    command: `python3 skills/dmb-market-data/scripts/parse_bloomberg_email.py --date ${today} >/dev/null 2>&1 && echo PRESENT || echo ABSENT`,
  });
  const present = String(res?.result?.details?.stdout ?? "").includes("PRESENT");
  json(present
    ? { fire: true,
        message: `Bloomberg Morning Brew Data (${stamp}) parsed for ${today}. Reconcile against the drafted figures and repost the review pack.`,
        state: { seen: today } }
    : { fire: false, state: { ...(trigger.state ?? {}), lastCheck: new Date().toISOString() } });
}
