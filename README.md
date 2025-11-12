# Orchestrator

**A self-configuring infrastructure for shared Claude Code resources across all projects in your organization.**

---

## What Is This?

The Orchestrator provides **shared AI infrastructure** (agents, skills, hooks, commands, guidelines) used by other projects in your organization via symlinks.

**Key Features:**
- 🤖 **Self-configuring** - Setup wizard auto-detects your tech stacks
- 🔄 **Update once, all repos benefit** - Changes propagate automatically
- 📋 **Consistent patterns** across all your projects
- 🎯 **Single source of truth** for shared resources
- 🛠️ **Customizable** - Each repo keeps its own context and repo-specific agents

---

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

**Time:** 5-10 minutes

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

---

## Architecture

```
YourOrganization/
├── orchestrator/          # Shared infrastructure (this repo)
│   └── shared/
│       ├── agents/                 # Intelligent agents
│       ├── skills/                 # Auto-trigger patterns
│       ├── hooks/                  # Auto-run scripts
│       ├── commands/               # Slash commands
│       └── guidelines/             # Reference documentation
│
├── your-repo-1/              # Your first project
│   └── .claude/
│       ├── agents/                 # Repo-specific agents
│       ├── skills/    -> ../../orchestrator/shared/skills     # SYMLINK
│       ├── hooks/     -> ../../orchestrator/shared/hooks      # SYMLINK
│       └── commands/  -> ../../orchestrator/shared/commands   # SYMLINK
│
├── your-repo-2/              # Your second project
│   └── .claude/
│       └── ...  (same structure)
```

**How it works:**
1. Shared resources live in `orchestrator/shared/`
2. Your repositories symlink to these shared resources
3. Updates in orchestrator propagate automatically to all repos
4. Each repo maintains its own repo-specific agents and CLAUDE.md

---

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

---

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

### Supported Tech Stacks

The orchestrator auto-detects:

**Frontend:**
- React, Next.js, Vue, Nuxt, Angular, Svelte
- Tailwind CSS, Radix UI, Material-UI, Bootstrap
- Vite, Webpack

**Backend:**
- FastAPI, Django, Flask (Python)
- Express, NestJS, Fastify (Node.js)
- Ruby on Rails, Sinatra (Ruby)

**Database:**
- PostgreSQL, MySQL, MongoDB
- Supabase, Prisma, SQLAlchemy, Mongoose

**Other:**
- TypeScript, Docker, GraphQL
- Jest, Vitest, pytest
- And many more...

Can't find your stack? The wizard allows manual specification!

---

## Adding New Shared Resources

### Adding an Agent
```bash
1. Create shared/agents/new-agent.md
2. Update shared/agents/README.md
3. Update CLAUDE.md discovery map
```

### Adding a Skill
```bash
1. Create shared/skills/new-skill/ directory
2. Update shared/skills/skill-rules.json with triggers
3. Update CLAUDE.md discovery map
```

### Adding a Guideline
```bash
1. Create shared/guidelines/new-guideline.md
2. Update shared/guidelines/README.md
3. Update CLAUDE.md discovery map
4. Reference from relevant agents/skills
```

---

## Compatibility

### Operating Systems
- ✅ **macOS** - Native symlink support
- ✅ **Linux** - Native symlink support
- ⚠️ **Windows** - Requires Developer Mode or administrator privileges for symlinks

### AI Coding Tools
- ✅ **Claude Code** (primary target)
- ✅ **GitHub Copilot** (agents work as chatmodes)
- ✅ **Any tool** respecting `.claude/` directory structure

---

## Troubleshooting

### Symlinks Not Working
```bash
cd your-repo/.claude
ln -sf ../../orchestrator/shared/skills skills
ln -sf ../../orchestrator/shared/hooks hooks
ln -sf ../../orchestrator/shared/commands commands
```

### Hooks Not Executable
```bash
chmod +x orchestrator/shared/hooks/*.sh
```

### Skills Not Triggering
```bash
# Validate skill-rules.json
cat orchestrator/shared/skills/skill-rules.json | jq .
```

### Setup Validation
```bash
# Run comprehensive validation
./setup/scripts/validate-setup.sh
```

---

## Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - Detailed setup guide (start here!)
- **[CLAUDE.md](./CLAUDE.md)** - Complete resource discovery for AI agents
- **[shared/agents/README.md](./shared/agents/README.md)** - Agent capabilities guide
- **[shared/guidelines/README.md](./shared/guidelines/README.md)** - Guidelines index
- **[dev/README.md](./dev/README.md)** - Dev docs pattern explanation

---

## Advanced Features

### Cross-Repo Documentation Sync
If enabled, the `cross-repo-doc-sync` agent keeps your orchestrator documentation synchronized with changes in your repositories.

### Dev Docs Pattern
For complex tasks spanning multiple sessions, use the `/dev-docs` command to create persistent documentation that survives context resets.

### Custom Tech Stack Support
Can't find your framework? The setup wizard allows manual tech stack specification, and you can customize generated skills afterward.

---

## Reconfiguration

Need to add a new repository or change tech stacks?

**Option 1: Re-run Setup (Recommended)**
```bash
# Backup current config if needed
cp SETUP_CONFIG.json SETUP_CONFIG.backup.json

# Re-clone orchestrator or restore setup/ directory
# Then run wizard again
/setup-orchestrator
```

**Option 2: Manual Edit**
1. Edit `SETUP_CONFIG.json`
2. Re-run skill generator or doc generator agents
3. Run validation: `./setup/scripts/validate-setup.sh`

**Option 3: Partial Re-setup**
1. Talk to Claude Code to update specific parts
2. Use `/dev-docs` to create a task for updating configuration
---

## Contributing

This orchestrator is designed to be customized for your organization. Feel free to:
- Add organization-specific agents
- Create custom skills
- Extend guidelines with your patterns
- Improve the setup wizard

---

## 🧠 Credits & Inspiration

**Created by:** [mvoutov](https://github.com/mvoutov)  
**Built while working on [BoardKit](https://github.com/mvoutov/boardkit)** — an AI-powered whiteboard.

This project grew out of the need to manage shared AI resources across BoardKit’s multi-repo architecture.

Inspired by the Reddit post [**“Building a Cross-Repo Documentation Sync Agent with Claude Code”**](https://www.reddit.com/r/ClaudeAI/comments/1n8z1y3/building_a_crossrepo_documentation_sync_agent/),  
I expanded the idea into a full **orchestrator system** for syncing documentation and AI resources across repositories.  

Its key feature — a **cross-repo documentation synchronization agent** — keeps docs aligned with your evolving codebase, ensuring AI agents always have up-to-date context.


I hope this project is useful to you! If you find any issues or have suggestions for improvements, I'd love to hear your feedback.


---

**Ready to get started?** See [QUICKSTART.md](./QUICKSTART.md) for the full setup guide!
