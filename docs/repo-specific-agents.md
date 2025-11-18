# Repository-Specific Agents

This directory contains agents that are specific to individual repositories. These agents are symlinked only to their respective repositories, not to all repos.

## Structure

Each repository can have its own specialized agent(s):

```
repo-specific/
├── frontend/
│   └── frontend-typescript-dev.md
├── backend/
│   └── backend-python-engineer.md
└── core/
    └── core-pipeline-dev.md
```

## When to Create Repo-Specific Agents

Create a repo-specific agent when:
- The agent provides guidance specific to one repository's tech stack
- The agent would not be useful in other repositories
- The repository has unique patterns or requirements

## Generic vs Repo-Specific

**Generic agents** (in `shared/agents/generic/`):
- Available to ALL repositories
- Provide universal functionality (code review, planning, documentation, refactoring, etc.)
- Examples: code-architecture-reviewer, refactor-planner, documentation-architect

**Repo-specific agents** (in `shared/agents/repo-specific/{repo-name}/`):
- Available ONLY to the specific repository
- Provide repo-specific guidance
- Examples: frontend-typescript-dev, backend-python-engineer

## Creating Repo-Specific Agents

During setup, the wizard will optionally generate repo-specific agents based on:
1. Repository name
2. Repository type (frontend, backend, fullstack, library, etc.)
3. Detected tech stack

Agents are generated from templates in `setup/templates/agent-template.md`.

## Manual Creation

To manually create a repo-specific agent:

1. Create directory: `mkdir shared/agents/repo-specific/{repo-name}`
2. Create agent file: `touch shared/agents/repo-specific/{repo-name}/{agent-name}.md`
3. Symlink to repo: See `setup/scripts/create-symlinks.sh` for examples
4. Test invocation: Use Task tool with `subagent_type: "agent-name"`

## Symlinking

Repo-specific agents are symlinked during setup:

```bash
# In target repo
frontend/.claude/agents/{repo-name}/ -> ../../orchestrator/shared/agents/repo-specific/{repo-name}/
```

Only the specific repo's agents directory is symlinked, ensuring namespace isolation.
