# Orchestrator



![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Supported-7F4DFF)
![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-Compatible-blue?logo=githubcopilot)


**A self-configuring infrastructure for shared Claude Code resources across all projects in your organization.**

## What Is This?

The Orchestrator is a **shared AI infrastructure** for organizations using Claude Code tools (and eventually expand for other AI tools) across multiple repositories.
Instead of duplicating agents, skills, prompts, and guidelines in every repo, you maintain them in **one place**, and each project auto-propagates them via symlinks.

**Key Features:**
- 🤖 **Self-configuring** - Setup wizard auto-detects your tech stacks
- 🔄 **Documentation Synchronization** - Changes propagate automatically
- 📋 **Consistent patterns** across all your projects
- 🎯 **Single source of truth** for shared resources
- 🛠️ **Customizable** - Each repo keeps its own context and repo-specific agents

## Why This Exists 

Any organization (including us!) using AI coding assistants faces challenges like:
- duplicated agents (if you even use any) across the board
- inconsistent/outdated documentation
- large multi-repo codebases with no shared context

This creates **hallucinations, unpredictable responses, and agents that get lost in long and complex tasks**.

The Orchestrator solves all these problems by:

- keeping up-to-date documentation
- centralizing best practices and patterns for your codebase
- reducing duplicated efforts across multiple repositories

This makes AI assistance context-aware, more predictable and accurate, and consistent across your entire engineering organization.

## Quick Start

### 1. Clone This Repository

```bash
git clone <this-repo-url> orchestrator
cd orchestrator
```

### 2. Run Setup Wizard

Open in Claude Code and run:

```
/setup-orchestrator
```

The wizard will:
- Collect your organization information
- Scan your repositories to detect tech stacks
- Generate customized configuration files
- Create repository-specific skills and guidelines

**Time:** Depends on complexity of your repos. 

### 3. Create Symlinks

```bash
./setup/scripts/create-symlinks.sh
```

This creates symlinks in all your repositories to use the shared resources.

### 4. Delete Setup Directory

```bash
rm -rf setup/
```

**Done!** Your orchestrator is ready to use.


## Architecture

```
YourOrganization/
├── orchestrator/                  # Central shared AI infrastructure
│   └── shared/
│       ├── agents/                # Global agents
│       ├── skills/                # Auto-trigger skills
│       ├── hooks/                 # Repo event hooks
│       ├── commands/              # Slash commands
│       └── guidelines/            # Reference documentation
│
├── repo-a/
│   └── .claude/
│       ├── agents/                # Repo-specific agents
│       ├── skills  -> symlink to orchestrator/shared/skills
│       ├── hooks   -> symlink to orchestrator/shared/hooks
│       ├── commands -> symlink to orchestrator/shared/commands
│       └── CLAUDE.md
│
├── repo-b/
│   └── .claude/                   # Same structure

```

**How it works:**
1. All shared resources live in orchestrator/shared/.
Repositories use symlinks to reference these shared resources.
Updating the orchestrator updates all repositories instantly.
Each repo still keeps its own agents and CLAUDE.md for local context.


## What Gets Generated

When you run the setup wizard, the orchestrator generates:

### Shared Agents
Intelligent agents you can invoke in any repository:
- `code-architecture-reviewer` - Code review for best practices
- `refactor-planner` - Plan complex refactorings
- `code-refactor-master` - Execute refactorings
- `plan-reviewer` - Review implementation plans
- `documentation-architect` - Create/update documentation
- `auto-error-resolver` - Fix errors automatically
- `web-research-specialist` - Research technologies and patterns
- `cross-repo-doc-sync` - Synchronize documentation across repos (optional)

### Repository-Specific Skills
Auto-trigger based on the files you edit:
- `skill-developer` - Meta-skill for creating new skills
- **One skill per repository** - Generated based on your tech stack

### Hooks
Automatically run on events:
- `skill-activation-prompt` - Suggests relevant skills
- `post-tool-use-tracker` - Tracks file changes for skill activation

### Commands
Slash commands available in any repo:
- `/dev-docs` - Create development documentation for complex tasks
- `/dev-docs-update` - Update dev docs before context resets

### Guidelines
Tech stack-specific reference documentation:
- `architectural-principles.md` - Your system architecture
- `error-handling.md` - Error patterns for your tech stacks
- `testing-standards.md` - Testing strategies for your frameworks
- `cross-repo-patterns.md` - Multi-repo workflows (if applicable)
- `documentation-standards.md` - Documentation conventions
- Database documentation (optional, if enabled)

---

## How It Works

### For You (The Developer)
1. Edit a file in any of your repositories
2. Skills auto-trigger with relevant guidance
3. Invoke agents when you need help
4. Use slash commands for complex tasks
5. Reference guidelines when needed

### For AI Agents
1. Read `CLAUDE.md` for complete resource discovery
2. Use repo-specific skills for context-aware guidance
3. Invoke specialized agents for complex tasks
4. Reference guidelines for detailed patterns
5. Use dev docs for long-running tasks


## Setup Process Details

### What the Setup Wizard Does

1. **Collects Information**
   - Your organization name
   - Number of repositories
   - For each repo: name, path, type, description

2. **Analyzes Your Repositories**
   - Scans package.json, requirements.txt, etc.
   - Auto-detects frameworks (React, Next.js, FastAPI, Django, etc.)
   - Identifies file patterns and keywords

3. **Generates Configuration**
   - Creates `SETUP_CONFIG.json` with your configuration
   - Generates `CLAUDE.md` customized for your organization
   - Updates `README.md` with your repo information

4. **Creates Repository-Specific Skills**
   - One skill per repository
   - Includes tech stack-specific guidance
   - Auto-triggers when editing files in that repo

5. **Generates Guidelines**
   - Error handling patterns for your tech stacks
   - Testing strategies for your frameworks
   - Architecture documentation for your setup

6. **Validates Setup**
   - Checks all files generated correctly
   - Verifies no placeholders remain
   - Validates JSON files

## Compatibility

### Operating Systems
- ✅ **macOS** - Native symlink support
- ✅ **Linux** - Native symlink support
- ⚠️ **Windows** - Requires Developer Mode or administrator privileges for symlinks

### AI Coding Tools
- ✅ **Claude Code** (primary target)
- ✅ **GitHub Copilot** (agents work as chatmodes)
- ✅ **Any tool** respecting `.claude/` directory structure


## Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - Detailed setup guide **(start here!)**
- **[CLAUDE.md](./CLAUDE.md)** - Complete resource discovery for AI agents
- **[shared/agents/README.md](./shared/agents/README.md)** - Agent capabilities guide
- **[dev/README.md](./dev/README.md)** - Dev docs pattern explanation

Additional reference docs:
- **[docs/reconfiguration.md](./docs/reconfiguration.md)** - Reconfiguration
- **[docs/troubleshooting.md](./docs/troubleshooting.md)** - Troubleshooting
- **[docs/supported-tech-stacks.md](./docs/supported-tech-stacks.md)** - Supported tech stacks
- **[docs/new-shared-resources.md](./docs/new-shared-resources.md)** - Adding new shared resources



## Contributing

This orchestrator is designed to be customized for your organization. Feel free to:
- Add organization-specific agents
- Create custom skills
- Extend guidelines with your patterns
- Improve the setup wizard

---

## 🧠 Credits & Inspiration

**Created by:** [mvoutov](https://github.com/mvoutov)  
**Built while working on [BoardKit](https://github.com/boardkit)** — an AI-powered whiteboard.

This project grew out of the need to manage shared AI resources across BoardKit’s multi-repo architecture.

Inspired by the Reddit post [**“Claude Code is a Beast – Tips from 6 Months of Hardcore Use”**](https://www.reddit.com/r/ClaudeAI/comments/1oivjvm/claude_code_is_a_beast_tips_from_6_months_of/),  
I expanded the idea into a full **orchestrator system** for syncing documentation and AI resources across repositories.  

Its key feature — a **cross-repo documentation synchronization agent** — keeps docs aligned with your evolving codebase, ensuring AI agents always have up-to-date context.


I hope this project is useful to you! If you find any issues or have suggestions for improvements, I'd love to hear your feedback.


---

**Ready to get started?** See [QUICKSTART.md](./QUICKSTART.md) for the full setup guide!
