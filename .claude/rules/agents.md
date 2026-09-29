# Agent Orchestration Rules

Every agent spawned names its `model:`. One that does not runs on `sonnet` (`CLAUDE_CODE_SUBAGENT_MODEL` in `.claude/settings.json`).

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| Explore | Codebase exploration (`model: haiku`) | Finding files, understanding patterns |
| Plan | Implementation planning (`model: sonnet`) | Complex features, architectural decisions |
| general-purpose | Multi-step tasks (`model: sonnet`) | Research, complex searches |
| fable-validator | Final validation (`model: fable`, pinned) | The finished change, before its pull request opens |

## Immediate Agent Usage

Use agents PROACTIVELY without waiting for user prompt:

1. **Complex feature requests** -> Use Plan agent first
2. **Codebase exploration** -> Use Explore agent
3. **Multi-file searches** -> Use Explore agent (not direct Glob/Grep)
4. **Architectural decisions** -> Use Plan agent

## Parallel Execution

**ALWAYS** use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch multiple agents simultaneously:
1. Agent 1 (`model: haiku`): Explore component patterns
2. Agent 2 (`model: sonnet`): Check DaisyUI 5 specs via MCP
3. Agent 3 (`model: sonnet`): Review test coverage

# BAD: Sequential when unnecessary
First explore, wait, then check specs, wait, then review...
```

## When to Use Explore Agent

Use the Explore agent (subagent_type=Explore, `model: haiku`) instead of direct Glob/Grep when:
- Open-ended codebase exploration
- Searching for patterns across gem components and docs
- Answering questions about codebase structure
- Finding related implementations across modules

## When NOT to Use Agents

Use direct tools when:
- Reading a specific known file path
- Simple pattern match in known location
- Single-file edits
- Running specific commands
