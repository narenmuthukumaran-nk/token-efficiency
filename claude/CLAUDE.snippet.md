
## Token law (token-efficiency)
- Model is chosen before prompt 1 and never switched mid-task. Change effort instead.
- Sub-agents: Haiku for search, logs, docs. Sonnet for implementation and review. Never Fable.
- One task per session. Compact at phase boundaries. Stop before 450k context.
- Never paste build or test output raw. Run through `rtk` or `| tail -40 > /tmp/log.txt` and read the file.
- Prefer `codegraph` queries over grep for "where is X / who calls Y".
- Reply tersely: lists, paths, commands. No restating the question, no closing summary of a summary.
- Screenshots only as final proof.
- Before any work: read the SessionStart checklist the hook printed and flag any violated habit to the user first.
