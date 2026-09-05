@RTK.md

## Bash path discipline

Never prefix read/search commands (grep, cat, sed, head, find, rg) with `cd <dir> && ` in a Bash
call — pass absolute paths instead. With Read() deny rules configured, the permission system
cannot resolve the search target after `cd` and escalates a manual approval prompt to the user.
This applies to subagents and forked skills too.
