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
- Your repositories (names, paths, types)
- Tech stacks (auto-detected, you confirm)
- Optional features (cross-repo doc sync, database docs)

### 3. Review Generated Files

The wizard will create:
- `SETUP_CONFIG.json` - Your configuration
- `CLAUDE.md` - Customized context file
- `shared/skills/` - Repository-specific skills
- `shared/guidelines/` - Tech stack-specific guidelines
- `README.md` - Updated with your org info

### 4. Delete This Directory

```bash
rm -rf setup/
git add .
git commit -m "Remove setup wizard after configuration"
```

---

## What's Inside setup/?

### Agents
- `setup-wizard.md` - Main setup orchestrator agent
- `repo-analyzer.md` - Scans your repos for tech stack detection
- `skill-generator.md` - Generates repository-specific skills
- `doc-generator.md` - Generates customized guidelines

### Templates
- `templates/CLAUDE.template.md` - Template for main context file
- `templates/README.template.md` - Template for README
- `templates/settings.json` - Standard settings.json for repositories
- `templates/skill-rules.template.json` - Template for skill triggers
- `templates/repo-skill-template/` - Template for generating repo skills
- `templates/guidelines/` - Templates for guidelines

### Scripts
- `scripts/create-symlinks.sh` - Creates symlinks in your repos
- `scripts/validate-setup.sh` - Validates setup completed correctly
- `scripts/detect-tech-stack.sh` - Helper for tech stack detection

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
3. Manually create skills in `shared/skills/`
4. Manually update `CLAUDE.md`
5. Run `setup/scripts/validate-setup.sh` to check

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
