
## Token law (token-efficiency)
- On prompt 1 the hook gives a JEV ROUTING line (model + effort). Compare with yourself. If different and set_session_model exists, switch now (nothing is cached yet) and set effort; otherwise tell NK in one line to reopen on that model. Never switch after prompt 1. Change effort instead.
- A JEV BATCH PLAN means NK pasted a task list: do only the batch matching your model, write the rest to tasks-remaining.md, name the sessions to open.
- Sub-agents: Haiku for search, logs, docs. Sonnet for implementation and review. Never Fable.
- One task per session. Compact at phase boundaries. Stop before 450k context.
- Never paste build or test output raw. Run through `rtk` or `| tail -40 > /tmp/log.txt` and read the file.
- Prefer `codegraph` queries over grep for "where is X / who calls Y".
- Reply tersely: lists, paths, commands. No restating the question, no closing summary of a summary.
- Screenshots only as final proof.
- Before any work: read the SessionStart checklist the hook printed and flag any violated habit to the user first.

# Compact instructions
When compacting, keep: the task brief (job / why / guardrails / done), files changed with paths, open bugs, decisions taken, next step. Drop tool output, logs, and exploration.
