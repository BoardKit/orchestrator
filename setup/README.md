# ⚠️ SETUP WIZARD - DELETE THIS DIRECTORY AFTER SETUP

**This directory is ONLY needed during initial orchestrator configuration.**

---

## 🗑️ IMPORTANT: Delete After Setup

Once you complete the setup wizard, **DELETE THIS ENTIRE DIRECTORY**:

```bash
rm -rf setup/
```

This keeps your orchestrator repo clean and removes setup-only files that you'll never need again.

---

## Quick Start

### 1. Run the Setup Wizard

Open this repository in Claude Code and run:

```
/setup-orchestrator
```

### 2. Answer the Questions

The wizard will ask about:
- Your organization name
- Number of application repositories (orchestrator is automatically included)
- For each repository:
  - Name (short, lowercase)
  - Path (relative to orchestrator)
  - Type (fullstack/frontend/backend/library/service/monorepo)
  - Description (one sentence)
  - Tech stack (auto-detected, you can confirm/override)
- Optional features:
  - Database documentation
  - Detailed guidelines

Note: The orchestrator is always included as a repository, and cross-repo documentation synchronization is always enabled.

### 3. Review Generated Files

The wizard creates the following structure:

**In Orchestrator:**
```
orchestrator/
├── SETUP_CONFIG.json                     # Your configuration
├── CLAUDE.md                             # Customized context file
├── README.md                             # Updated with your org info
├── shared/
│   ├── skills/
│   │   ├── global/                       # Pre-existing global skills
│   │   ├── <repo-name>/                  # One directory per repo
│   │   │   └── skill.md                  # Repo-specific skill
│   │   └── skill-rules.json              # Updated with all skills
│   ├── guidelines/
│   │   ├── global/                       # Global guidelines
│   │   └── <repo-name>/                  # Repo-specific guidelines
│   │       ├── architectural-principles.md
│   │       ├── error-handling.md
│   │       ├── testing-standards.md
│   │       ├── cross-repo-patterns.md    # (if multiple repos)
│   │       └── DATABASE_*.md             # (if database docs enabled)
│   ├── agents/
│   │   └── <repo-name>/                  # (optional repo-specific agents)
│   └── settings/
│       └── <repo-name>/settings.json     # Per-repo settings
```

**In Each Application Repository:**
```
<repo-path>/
├── CLAUDE.md                             # Repo-specific context
└── .claude/
    ├── agents/
    │   ├── global/ → orchestrator/shared/agents/global/
    │   └── <repo-name>/ → orchestrator/shared/agents/<repo-name>/
    ├── skills/
    │   ├── global/ → orchestrator/shared/skills/global/
    │   └── <repo-name>/ → orchestrator/shared/skills/<repo-name>/
    ├── guidelines/
    │   ├── global/ → orchestrator/shared/guidelines/global/
    │   └── <repo-name>/ → orchestrator/shared/guidelines/<repo-name>/
    ├── commands/ → orchestrator/shared/commands/
    ├── hooks/ → orchestrator/shared/hooks/
    └── settings.json → orchestrator/shared/settings/<repo-name>/settings.json
```

### 4. Create Symlinks

After the wizard completes, run:

```bash
./setup/scripts/create-symlinks.sh
```

This creates all necessary symlinks in your repositories.

### 5. Validate Setup

```bash
./setup/scripts/validate-setup.sh
```

### 6. Delete This Directory

```bash
rm -rf setup/
git add .
git commit -m "Configure orchestrator for [YourOrg]"
```

---

## What's Inside setup/?

### Agents
- `setup-wizard.md` - Main setup orchestrator agent
- `repo-analyzer.md` - Scans your repos for tech stack detection
- `skill-generator.md` - Generates repository-specific skills
- `doc-generator.md` - Generates customized guidelines

### Templates
- `templates/CLAUDE.template.md` - Template for orchestrator CLAUDE.md
- `templates/repo-CLAUDE.template.md` - Template for repository CLAUDE.md
- `templates/README.template.md` - Template for README
- `templates/settings.json` - Standard settings.json for repositories
- `templates/skill-rules.template.json` - Template for skill triggers
- `templates/repo-skill-template/skill.template.md` - Template for repo skills
- `templates/guidelines/*.template.md` - Templates for guidelines

### Scripts
- `scripts/create-symlinks.sh` - Creates symlinks in your repos
- `scripts/validate-setup.sh` - Validates setup completed correctly
- `scripts/detect-tech-stack.sh` - Helper for tech stack detection
- `scripts/manage-gitignore.sh` - Updates .gitignore files

### Examples
- `examples/` - Example configurations for common tech stacks
  - `nextjs-fastapi.json` - Full-stack web app
  - `django-react.json` - Traditional full-stack
  - `express-vue.json` - Alternative stack
  - `python-library.json` - Single package
  - `monorepo.json` - Multiple services

---

## Re-running Setup

If you need to reconfigure your orchestrator later:

1. Re-clone the original orchestrator repository
2. Copy the `setup/` directory back to your orchestrator
3. Run the wizard again: `/setup-orchestrator`
4. It will overwrite your previous configuration

Or manually edit `SETUP_CONFIG.json` and regenerate files.

---

## Manual Setup (Advanced)

If you prefer not to use the wizard:

1. Copy an example from `setup/examples/` to `SETUP_CONFIG.json`
2. Edit `SETUP_CONFIG.json` with your information
3. Manually create the directory structure:
   ```bash
   # Create skill directories
   mkdir -p shared/skills/{repo-name}/

   # Create guideline directories
   mkdir -p shared/guidelines/{repo-name}/

   # Create settings directories
   mkdir -p shared/settings/
   ```
4. Copy templates and customize them
5. Run `setup/scripts/validate-setup.sh` to check

---

## Directory Structure After Setup

The correct structure follows this pattern:

```
shared/
├── agents/
│   ├── global/               # Global agents (pre-existing)
│   ├── orchestrator/         # Orchestrator-only agents
│   └── <repo-name>/          # Optional repo-specific agents
├── guidelines/
│   ├── global/               # Global guidelines
│   └── <repo-name>/          # Repo-specific guidelines
├── skills/
│   ├── global/               # Global skills (pre-existing)
│   └── <repo-name>/          # Repo-specific skills
├── settings/
│   └── <repo-name>/settings.json
├── commands/                 # Shared commands (pre-existing)
└── hooks/                    # Shared hooks (pre-existing)
```

Each repository gets symlinks to:
- Their own repo-specific directories (`<repo-name>/`)
- The global directories (`global/`)
- Shared resources (commands, hooks)

---

## Need Help?

- Read the main [README.md](../README.md) for architecture overview
- Check [QUICKSTART.md](../QUICKSTART.md) for detailed instructions
- See example configs in `examples/` for inspiration
- Review the generated `CLAUDE.md` for usage patterns

---

## Remember

**This directory serves no purpose after initial setup.**

Delete it to keep your orchestrator clean and professional!

```bash
rm -rf setup/
```

---

**End of Setup README**
