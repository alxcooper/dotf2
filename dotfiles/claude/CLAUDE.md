## Commit messages

Never add a `Co-Authored-By:` trailer (or any other Claude attribution line) to git commit messages.

## Bash path discipline

Never prefix read/search commands (grep, cat, sed, head, find, rg) with `cd <dir> && ` in a Bash
call — pass absolute paths instead. With Read() deny rules configured, the permission system
cannot resolve the search target after `cd` and escalates a manual approval prompt to the user.
This applies to subagents and forked skills too.
