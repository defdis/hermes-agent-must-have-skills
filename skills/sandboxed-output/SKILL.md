---
name: sandboxed-output
description: "Use when processing large outputs: logs, test runs, API responses, browser snapshots, big files. Load data in code, print only findings — never paste raw output into context. Companion to output-skill/full-output-enforcement."
metadata:
  hermes:
    tags: [context-window, token-efficiency, logs, debugging, data-analysis]
    category: engineering
    related_skills: [full-output-enforcement, code-review-graph, debugging-and-error-recovery]
---

# Sandboxed Output: big data in code, findings in context

Every tool call that dumps raw data into the context window burns the session.
A 50-line log is fine. A 3000-line test output, an access log, a JSON API
response, a browser snapshot — that floods context and gets compressed away
before you needed it. The fix is mechanical: **run the data through code,
print only the findings.**

Methodology adapted from mksglu/context-mode (ELv2), reimplemented with
Hermes-native tools: `execute_code` + Hermes file tools.

## The one rule

> Raw data goes from source → file/code → short summary in context.
> Never: source → context → back into a tool → context again.

If you catch yourself about to paste a wall of output into a reply, or about
to call a tool knowing its output is bigger than 20 lines — stop and use the
loop below instead.

## The loop

Data lives **inside** `execute_code` (hermes_tools), which can call tools and
keep data in Python variables. Only `print()` output enters context.

```python
from hermes_tools import terminal, web_extract, write_file

# big output stays in a Python string, never reaches context
r = terminal("pytest -q 2>&1")
fails = [l for l in r["output"].splitlines() if "FAILED" in l or "ERROR" in l]
print(f"{r['exit_code']=}, {len(fails)} fails")
print("\n".join(fails[:10]))  # only the summary matters
```

Tool-to-replacement map:

|instead of|do|why|
|---|---|---|
|`terminal()` with big raw output|`execute_code` + `terminal()` + filter|stdout cap 50KB is a guardrail, not a design. `head`/`tail`/`grep` in Python; sort/dedupe/count in code, not by eye|
|full log/JSON/CSV in an output|`read_file` for a small window, `execute_code`+`read_file` or Python I/O for analysis|counts, diffs, errors as short prints|
|`search_files` output you plan to re-filter later|save the matches with `execute_code` to a workspace file, then process batch-wise|huge output truncated to next_offset anyway|
|piping everything through `head`/`tail`|do filters in code|pipes hide real exit codes and data|
|fetch URL → paste into analysis|`execute_code` + `web_extract`/`terminal(curl)` → parse in code|extract fields, counts, then print a few lines|

In-Browser alternative (for agent-browser flows): `browser_exec` with Python
code — same principle: aggregate inside one call, print only findings.
Workspace files persist across `browser_exec` calls for multi-step jobs.

## When small and direct beats sandboxed

- Single tool call where you need to reason over the whole result — just use it
- <20-line, expected output: reading one file, one `git log -5`
- Anything where the model must *read carefully* everything (short config,
  short code section, a short email) — direct call is correct
- Edit operations (`patch`, `write_file`) — not for this loop; these are already terse

## Hard rules

1. **print() is the only thing that enters context** — no print = wasted call; print findings, not data dumps
2. Be specific in what you print: error IDs, line numbers, exact values, not just counts
3. Print enough context that the next step doesn't need the raw data again
4. Files you need to edit: use normal `read_file`/`patch` directly — this loop is for *analysis*
5. For multi-item collection tasks: append batch results to a workspace JSON/CSV file as you go, then read back and aggregate once — don't recompute in your head
6. Don't re-fetch or re-read data that's already in context — use it

## Worked examples

### Parse a huge build/test output
```python
from hermes_tools import terminal
r = terminal("npm test 2>&1", timeout=300)
out = r["output"]
print("exit:", r["exit_code"], "| lines:", out.count("\n"))
for l in out.splitlines():
    if l.startswith(("FAIL", "ERROR", "✗")):
        print(l[:160])
m = [l for l in out.splitlines() if "Tests:" in l]
print("\n".join(m))
```

### Filter an access log for patterns
```python
import re, collections
hits = collections.Counter()
codes = collections.Counter()
for line in open("/var/log/nginx/access.log"):
    m = re.match(r'\S+ \S+ \S+ \[[^\]]+\] "(\S+) (\S+)[^"]*" (\d+)', line)
    if m: hits[f"{m[1]} {m[2]}"] += 1; codes[m[3]] += 1
print("top paths:", hits.most_common(5))
print("statuses:", codes.most_common())
```

### Digest a long web page
```python
from hermes_tools import web_extract
r = web_extract(["https://example.com/big-doc"], char_limit=40000)
text = r["results"][0]["content"]
keys = [l for l in text.splitlines() if l.startswith(("## ", "### "))]
print(f"{len(text)} chars, {len(keys)} headings")
print("\n".join(keys[:40]))   # structure only; then extract pieces on demand
```