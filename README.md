# Orchestrator



![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Claude Code](https://img.shields.io/badge/Claude%20Code-Supported-7F4DFF)
![GitHub Copilot](https://img.shields.io/badge/GitHub%20Copilot-Compatible-blue?logo=githubcopilot)


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

**Time:** Depends on complexity of your repos. For mid-sized 2 repo structure it should take ~15 minutes. 

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
│       ├── chatmodes/                # Co-pilot agents
│       ├── commands/                 # Wrappers around agents/skills
│       ├── guidelines/               # Long-form documentation
│       │   └── global/               # Global guidelines (for all repos)
│       │   └── <repo-name>/          #  (OPTIONAL) Repo-specific guidelines (directory for each repo)
│       ├── settings/                 # Auto-trigger skills
│       ├── hooks/                    # Even-driven commands
│       ├── skills/                   # Small, focused behavior
│             └── global/             # Skill-developer, logging conventions, security-guardrails, testing-convention
│             └── <repo-name>/        #  (OPTIONAL) Repo-specific skills (directory per repo)
│      
│
├── repo-a/
│   └── .claude/
│       ├── agents/ 
│       │   └── global/               # symlink to orchestrator/shared/agents/global
│       │   └── <repo-a>/             # symlink to orchestrator/shared/agents/<repo-a>
│       ├── commands/                 # symlink to orchestrator/shared/commands
│       ├── guidelines/              
│       │   └── global/               # symlink to orchestrator/shared/guidelines/global
│       │   └── <repo-a>/             # symlink to orchestrator/shared/guidelines/<repo-a>
│       ├── hooks/                    # symlink to orchestrator/shared/hooks
│       ├── skills/
│             └── global/             # symlink to orchestrator/shared/skills/global
│             └── <repo-a>/           # symlink to orchestrator/shared/skills/<repo-a>
│       └── settings.json             # symlink to orchestrator/shared/settings/<repo-a>/settings.json
│    └── CLAUDE.md ->                 # Repo Specific Entry Point; MUST exist
│...

(you can have any number of repositories)

```

## BEFORE AND AFTER SETUP

There are many components that already exist in orchestrator before setup and the rest of the components get generated during setup. Here is a list of all components:
## Before Setup
Components that exist before setup:

### Global Agents
Intelligent agents that get distributed (via symlinks) to ALL repositories:
- `code-architecture-reviewer` - Code review for best practices
- `refactor-planner` - Plan complex refactorings
- `code-refactor-master` - Execute refactorings
- `plan-reviewer` - Review implementation plans
- `documentation-architect` - Create/update documentation
- `auto-error-resolver` - Fix errors automatically
- `web-research-specialist` - Research technologies and patterns

### Orchestrator Agents
- `cross-repo-doc-sync` - Synchronize documentation across repos

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


## After Setup

### Repository-Specific Skills
Auto-trigger based on the files you edit:
- `skill-developer` - Meta-skill for creating new skills
- **One skill per repository** - Generated based on your tech stack
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


## Extensions

This orchestrator is designed to be customized and extended for your organization's needs. Feel free to:
- Add any useful organization-specific agents
- Create custom skills
- Extend guidelines with your patterns


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
