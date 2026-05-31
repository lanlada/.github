---
description: Batch and parallelize work; one call beats three
---

# Token Efficiency

Every extra tool call costs context tokens and wall-clock time. If an operation can be batched, scripted, or parallelized, do that instead of hand-rolling each step. Brief prose beats narration.

## Don't

- Write files one by one when `cp -R` from a reference produces the same output
- Run `pnpm add` separately for each package — bundle into one call
- Run `rm` separately for each path — bundle paths or use a glob
- Re-read a file you just wrote
- Run `ls` or `cat` "to verify" after a destructive command — the next failing step would surface the issue
- Echo or `printf` file contents through Bash — use Write or Edit
- Narrate internal thinking, restate context, or summarise what the user already saw

## Do

- Plan the full set of changes before the first tool call
- Group independent work into parallel tool calls in one message
- Group dependent shell steps into one Bash call with `&&`
- Prefer Edit over Write when changing an existing file — Edit sends only the diff
- Prefer `cp` / `mv` / glob deletion over re-generating identical content by hand
- Prefer `find / xargs / sed` over per-file Read+Edit loops for uniform changes
- Use package-manager scaffolders (`pnpm dlx ...`) instead of re-creating their output by hand

## Exceptions

- If the same tool type is about to fire three or more times in a row, stop and ask whether it can be one call
