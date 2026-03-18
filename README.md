# Orchestrator



![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Supported-7F4DFF)
![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-Compatible-blue?logo=githubcopilot)

> 
> ## Now available as a standalone npm package: **[aspens](https://www.npmjs.com/package/aspens)**
>
> ```bash
> npm install -g aspens
> ```
>
> Generate AI-ready skills + CLAUDE.md for any repo. No cloning, no symlinks, no setup wizard.
>
> ```bash
> aspens scan .                    # See your repo's tech stack and domains
> aspens doc init .                # Generate skills + CLAUDE.md
> aspens doc sync --install-hook   # Auto-update on every commit
> aspens add agent all             # Add 9 AI agents
> aspens customize agents          # Tailor agents to your project
> ```
>
> **aspens** is the standalone CLI for individual repositories or multi-repo setups('hubs'). The **Orchestrator** (this repo) is the full framework for multi-repo organizations that want shared resources and cross-repo documentation synchronization and it you dont want to use the CLI. The package **aspens** would allow us to push updates to the users easier than the **orchestrator** repo, but the **orchestrator** repo allows for more flexible development, which you can take in any direction you want. 

---

**A self-configuring infrastructure for shared Claude Code resources across all projects in your organization.**

## What Is This?

The Orchestrator is a **shared AI infrastructure** for organizations using Claude Code (and is designed to be expandable to other AI tools) across multiple repositories.
Instead of duplicating agents, skills, prompts, and guidelines in every repo, you maintain them in **one place**, and each project auto-propagates them via symlinks.


**Key Features:**
- 📚 **Centralized Shared Resources** - One source of truth for agents, skills, hooks, commands, and guidelines (documentation) - they all live in *Orchestrator*. All repos can have access or just a subset by symlinking selected directories/resources into the repo
- 🤖 **Specialized Agents** - comes with several preconfigured specialized agents for wide-range of tasks. You can edit them as needed or add any number of agents
- 🤖 **Self-configuring** - Setup wizard that walks you through your entire configuration. You do not have to do it all by yourself
- 🔄 **Cross Repo Documentation Synchronization Agent** - This agent lives inside the *orchestrator* and its job is to keep **documentation in sync across all repos.** 
   - **How It Works**: From the *orchestrator* repo, you simply ask claude to activate the agent and ask it to update the documentation based on the last *n* commits. It is recommended to do this daily (if in active development) or after key codebase changes.
   - **NOTE: This agent is not automated** because documentation updates may require human review. 
- 🛠️ **Customizable** - Each repo can have its own agents, guidelines or skills. There is no one right way to use this orchestrator

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

This makes AI assistance **context-aware, more predictable and accurate**, and consistent across your entire engineering organization.

## Quick Start

**Go to [QUICKSTART.md](./QUICKSTART.md) for the complete  setup guide.**

Below is a brief overview:

### 1. Clone This Repository

```bash
git clone <this-repo-url> orchestrator
cd orchestrator
````

### 2. Run Setup Wizard
‼️**IMPORTANT** ‼️ **This assumes you have Claude Code installed and running in terminal.**  Check installation [here](https://code.claude.com/docs/en/setup). 

Open in Claude Code and run:

```
/setup-orchestrator
```

The wizard will:
- Collect your organization information
- Scan your repositories to detect tech stacks
- Generate customized configuration files
- Create repository-specific skills and guidelines

**Time:** Depends on complexity of your repos. For mid-sized 2 repo structure it should take ~30 minutes. 

### 3. Create Symlinks

Symlinks connect each repository to the shared resources in the orchestrator.

```bash
./setup/scripts/create-symlinks.sh
```


### 4. Delete Setup Directory
Delete the setup directory to keep your orchestrator clean.

```bash
rm -rf setup/
```

**Done!** Your orchestrator is ready to use.


## Architecture

**How it works:**
1. All shared resources live in orchestrator/shared/

2. Repositories use symlinks to connect the shared resources from `orchestrator/shared/` to their own `.claude/` directory.

3. You ONLY need to update the orchestrator to update all repositories instantly.

4. Each repo can have its own agents and **MUST HAVE CLAUDE.md.**

**IMPORTANT! Below is how the orchestrator and each repo are structured:** If after setup your structure looks different(i.e. missing files), then it is not setup properly. You can ask Claude Code to help you fix it.
```
YourOrganization/
├── orchestrator/
│   └── shared/
│       ├── agents/
│       │   └── global/               # Global agents for all repos
│       │   └── orchestrator/         # Orchestrator-only agents
│       │   └── <repo-name>/          # (OPTIONAL) Repo-specific agents (directory for each repo)
│       ├── copilot-agents/           # GitHub Copilot custom agents (.agent.md files)
│       ├── commands/                 # Wrappers around agents/skills
│       ├── guidelines/               # Long-form documentation
│       │   └── global/               # Global guidelines (for all repos)
│       │   └── <repo-name>/          #  (OPTIONAL) Repo-specific guidelines (directory for each repo)
│       ├── settings/                 # Repository-specific settings files
│       │   └── <repo-name>/          # Directory per repository
│       │       └── settings.json     # Settings file for that repo
│       ├── hooks/                    # Event-driven scripts
│       ├── skills/                   # Small, focused behavior
│             └── global/             # Skill-developer, logging conventions, security-guardrails, testing-convention
│             └── <repo-name>/        #  (OPTIONAL) Repo-specific skills (directory per repo)
│      
│
├── repo-a/
│   ├── .claude/
│   │   ├── agents/
│   │   │   └── global/               # symlink to orchestrator/shared/agents/global
│   │   │   └── <repo-a>/             # symlink to orchestrator/shared/agents/<repo-a>
│   │   ├── commands/                 # symlink to orchestrator/shared/commands
│   │   ├── guidelines/
│   │   │   └── global/               # symlink to orchestrator/shared/guidelines/global
│   │   │   └── <repo-a>/             # symlink to orchestrator/shared/guidelines/<repo-a>
│   │   ├── hooks/                    # symlink to orchestrator/shared/hooks
│   │   ├── skills/
│   │         └── global/             # symlink to orchestrator/shared/skills/global
│   │         └── <repo-a>/           # symlink to orchestrator/shared/skills/<repo-a>
│   │   └── settings.json             # symlink to orchestrator/shared/settings/<repo-a>/settings.json
│   ├── .github/                      # (optional - if copilotAgents enabled)
│   │   └── agents/                   # symlink to orchestrator/shared/copilot-agents
│   └── CLAUDE.md                     # Repo Specific Entry Point; MUST exist
│...

(you can have any number of repositories)

```

## Resources Overview
For in depth details on all the resources in the orchestrator, see: [docs/orchestrator-resources.md](./docs/orchestrator-resources.md)

### Pre-Configured (Ready to Use)
During setup, symlinks are created to connect each repository to the shared resources in the orchestrator.

**Global Agents** (`shared/agents/global/`)
9 specialized agents for code review, refactoring, planning, documentation, error fixing, web research, UX/UI design, and copywriting. Available to all repos via symlinks.

**Orchestrator Agents** (`shared/agents/orchestrator/`)
Agents that run ONLY from the orchestrator repository (NOT symlinked to application repos):
- `cross-repo-doc-sync` - Keeps orchestrator docs aligned with your evolving codebase
- `codebase-auditor` - Audits codebase for drift between documentation and implementation
- `gtm-strategist` - Go-to-market strategy and positioning guidance

**Copilot Agents** (`shared/copilot-agents/`)
GitHub Copilot custom agent configurations for specialized AI personas (code review, refactoring, documentation, etc.). Optionally symlinked to each repo's `.github/agents/` for VS Code/Copilot integration (enabled via setup wizard).

**Hooks** (`shared/hooks/`)
Event-driven scripts that auto-suggest skills and track file changes.

**Commands** (`shared/commands/`)
Slash commands like `/dev-docs` for creating planning docs and `/setup-orchestrator` for initial configuration.

**Global Skills** (`shared/skills/global/`)
Meta-skill for creating new skills. Auto-triggers when working on the skill system.

**Global Guidelines** (`shared/guidelines/global/`)
Documentation standards that all agents and skills follow. Language-agnostic best practices.

### Generated During Setup

**Repo-Specific Resources** (one set per repository)
The wizard generates custom skills, guidelines, and optionally agents tailored to each repo's tech stack. Skills auto-trigger when sending a message in Claude Code in that repo, guidelines provide tech-specific patterns, and agents offer specialized assistance.

## How It Works

### Day-to-Day Usage

**1. Skills Auto-Trigger After a Message To Claude**
- Edit a file in your repo → Orchestrator detects the file path and tech stack
- Relevant skill activates automatically on your next prompt
- Example: Edit `backend/app/main.py` → Python/FastAPI skill provides error handling patterns and best practices

**2. Ask Claude Code for Help (Agents Invoke Automatically)**
- Just describe what you need in natural language
- Claude Code automatically launches the right agent (or specifically ask Claude to use an agent's name)
- Examples:
  - "Review my authentication code" → `code-architecture-reviewer` agent runs
   - "Use code-architecture-reviewer agent to review my authentication code" → explicitly invokes that agent
  - "Help me plan a refactor" → `refactor-planner` agent creates a plan
  - "Fix these TypeScript errors" → `auto-error-resolver` agent fixes them

**3. Use Slash Commands for Complex Tasks**
- `/dev-docs feature-name and description` → Creates planning docs (plan.md, context.md, tasks.md)
- `/dev-docs-update` → Updates dev docs before context reset
- `/setup-orchestrator` → Runs first-time setup wizard

**4. Guidelines Reference (When Needed)**
- Skills and agents reference guidelines automatically
- You can read them directly for detailed patterns:
  - `shared/guidelines/<repo-name>/error-handling.md` - Error patterns for your stack
  - `shared/guidelines/<repo-name>/testing-standards.md` - Testing strategies
  - `shared/guidelines/<repo-name>/architectural-principles.md` - System architecture

**5. Cross Repo Documentation Sync (Orchestrator Only)**
- **IMPORTANT:** This agent is ONLY available when working in the orchestrator repository
- From the *orchestrator* repo, ask Claude to use `cross-repo-doc-sync` agent to update documentation
- Examples:
   - "Use cross-repo-doc-sync agent to update documentation based on the last 5 commits from all repos"
   - "Use cross-repo-doc-sync agent to update documentation based on the last 3 commits in repo-a"
   - "Update the documentation using cross-repo-doc-sync agent based on all commits from today"

**6. Everything Stays in Sync**
- Update an agent in orchestrator → All repos get the update via symlinks
- No manual copying, no version drift
- One source of truth for all AI resources

## Setup Process Details

The wizard:
1. Collects org name, repo count, and repo details (name, path, type)
2. Scans repos to detect tech stacks
3. Generates `SETUP_CONFIG.json`, customizes `CLAUDE.md`, and updates `README.md` in orchestrator.
4. Creates `CLAUDE.md` for each repo. 
5. Creates repo-specific skills (auto-trigger for each repo's tech stack)
6. Generates repo-specific guidelines (error handling, testing, architecture)
7. Creates settings.json for each repo (links skills/hooks)
8. Validates all generated files

## Compatibility

### Operating Systems
- ✅ **macOS** - Native symlink support
- ✅ **Linux** - Native symlink support
- ⚠️ **Windows** - Requires Developer Mode or administrator privileges for symlinks

### AI Coding Tools
- ✅ **Claude Code** (primary target)
- ✅ **GitHub Copilot** (simplified compatibility):
   - Uses basic agent markdown files in `shared/copilot-agents/`
   - Less comprehensive than Claude Code agents but functional
   - Can be used alongside Claude Code infrastructure
   - Custom agents work as chat references rather than full skill integration
   - **Cost-effective for routine tasks** - Leverage Copilot for simpler queries and code completion
   - **Smart token allocation** - Use Copilot for basic tasks, preserve Claude Code tokens for complex reasoning and architecture work
   - **Budget optimization** - Allocate easier development tasks to Copilot while reserving Claude's full capabilities for critical problem-solving
- ✅ **Any tool** respecting `.claude/` directory structure


## Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - Detailed setup guide **(start here!)**
- **[CLAUDE.md](./CLAUDE.md)** - Complete resource discovery for AI agents
- **[shared/agents/README.md](./shared/agents/README.md)** - Agent capabilities guide
- **[dev/README.md](./dev/README.md)** - Dev docs pattern explanation

**Additional reference docs:**
- **[docs/reconfiguration.md](./docs/reconfiguration.md)** - Reconfiguration
- **[docs/troubleshooting.md](./docs/troubleshooting.md)** - Troubleshooting
- **[docs/supported-tech-stacks.md](./docs/supported-tech-stacks.md)** - Supported tech stacks
- **[docs/new-shared-resources.md](./docs/new-shared-resources.md)** - Adding new shared resources
- **[docs/skills_vs_guidelines.md](./docs/skills_vs_guidelines.md)** - Skills vs Guidelines
- **[docs/repo-specific-agents.md](./docs/repo-specific-agents.md)** - Repo-specific agents
- **[docs/repo-specific-skills.md](./docs/repo-specific-skills.md)** - Repo-specific skills
- **[docs/orchestrator-resources.md](./docs/orchestrator-resources.md)** - Orchestrator resources


## Extensions

This orchestrator is designed to be customized and extended for your organization's needs. Feel free to:
- Add any useful organization-specific agents
- Create custom skills
- Extend guidelines with your patterns


## 🧠 Credits & Inspiration

**Created by:** [mvoutov](https://github.com/mvoutov)

**Built while working on [BoardKit](https://github.com/boardkit) and [Tutor Kit](https://tutorkit.ai)** — an AI-powered whiteboard and a virtual tutor platform / interview prep intelligence platform.
> <a href="https://tutorkit.ai"><img src="https://tutorkit.ai/logo.png" alt="Tutor Kit" width="50"></a> **[Tutor Kit](https://tutorkit.ai)** (tutorkit.ai) empowers learners to reach their full potential through intelligent, adaptive preparation — combining personalized tutoring with AI-driven interview coaching that learns who you are, identifies what you lack, and guides you to where you need to be.

This project grew out of the need to manage shared AI resources across the projects' multi-repo architecture.

Inspired by the Reddit post [**“Claude Code is a Beast – Tips from 6 Months of Hardcore Use”**](https://www.reddit.com/r/ClaudeAI/comments/1oivjvm/claude_code_is_a_beast_tips_from_6_months_of/),  
I expanded the idea into a full **orchestrator system** for syncing documentation and AI resources across repositories.  

Its key feature — a **cross-repo documentation synchronization agent** — keeps docs aligned with your evolving codebase, ensuring AI agents always have up-to-date context.


I hope this project is useful to you! If you find any issues or have suggestions for improvements, I'd love to hear your feedback.


---

## Also See: aspens CLI

If you want AI-ready documentation without the full orchestrator setup, check out **[aspens](https://www.npmjs.com/package/aspens)** — a standalone CLI that generates and maintains skills for any repo.

```bash
npx aspens scan .                    # See your repo's tech stack
npx aspens doc init .                # Generate skills + CLAUDE.md
npx aspens doc sync --install-hook   # Auto-update on every commit
npx aspens add agent all             # Add 9 AI agents
npx aspens customize agents          # Tailor agents to your project
```

**Orchestrator vs aspens:**

| | Orchestrator | aspens |
|---|---|---|
| **Best for** | Multi-repo orgs with shared resources | Individual repos, quick setup |
| **Setup** | Clone + setup wizard (~30 min) | `npx aspens doc init` (~2 min) |
| **Shared resources** | Symlinked across repos | Per-repo |
| **Cross-repo sync** | Built-in agent | Not yet |
| **Agents** | 9 global + orchestrator-only | 9 bundled, customizable |

The orchestrator is where agents and skills are authored and tested. aspens packages them for easy distribution.

---

**Ready to get started?** See [QUICKSTART.md](./QUICKSTART.md) for the full setup guide!
