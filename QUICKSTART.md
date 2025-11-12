# Orchestrator - Quick Start Guide

**Complete step-by-step guide to setting up your organization's orchestrator.**

I know this is long but please follow each step carefully.

---

## Overview

This guide will walk you through:
1. Prerequisites and requirements
2. Initial setup with the setup wizard
3. Creating symlinks in your repositories
4. Verification and testing
5. Using the orchestrator
6. Troubleshooting

---

## Prerequisites

### 1. Operating System

- ✅ **macOS** or **Linux** (recommended - native symlink support)
- ⚠️ **Windows** - Requires Developer Mode enabled or administrator privileges

**Windows Users:** Enable Developer Mode:
```
Settings > Update & Security > For Developers > Developer Mode
```

### 2. Required Tools

- **Claude Code** - Download from [claude.com](https://claude.com/claude-code)
- **jq** - JSON processor for validation scripts
  ```bash
  # macOS
  brew install jq

  # Ubuntu/Debian
  sudo apt-get install jq

  # Check if installed
  jq --version
  ```

### 3. Your Repositories

Have your repositories ready:
- Know their paths relative to where you'll clone the orchestrator
- Have them cloned and accessible
- Know their tech stacks (or let the wizard auto-detect)

**Example directory structure:**
```
~/projects/
├── orchestrator/       # This repo (will be cloned here)
├── my-frontend/        # Your repo 1
├── my-backend/         # Your repo 2
└── shared-library/     # Your repo 3
```

---

## Step 1: Clone Orchestrator

```bash
# Navigate to your projects directory
cd ~/projects/  # or wherever you keep your repos

# Clone the orchestrator
git clone <orchestrator-repo-url> orchestrator

# Navigate into it
cd orchestrator

# Verify structure
ls -la
# Should see: setup/, shared/, dev/, README.md, CLAUDE.md, etc.
```

---

## Step 2: Run Setup Wizard

Open the orchestrator directory in Claude Code:

```bash
# From orchestrator directory
claude-code .
```

In Claude Code, run the setup wizard:

```
/setup-orchestrator
```

### What the Wizard Will Ask

The wizard will guide you through configuration. Here's what to expect:

#### 2.1: Organization Name

```
Q: What is your organization or project name?

```

**Tip:** Use a short, clear name (will appear in documentation).

#### 2.2: Number of Repositories

```
Q: How many repositories will this orchestrator manage?

Enter how many you will be configuring now.
```

**Tip:** Start with your main repositories. You can add more later.

#### 2.3: For Each Repository

The wizard will ask about each repository:

**Repository Name:**
```
Q: What is the short name for this repository?
   (lowercase, no spaces)

Examples: "app", "frontend", "backend", "core", "api"
```

**Repository Path:**
```
Q: What is the relative path from the orchestrator to this repository?

Examples: "../my-app", "../frontend", "../packages/core"
```

**Tip:** Use `../` for sibling directories. Example:
```
If structure is:
  projects/
    orchestrator/    (you are here)
    my-app/          (relative path: ../my-app)
```

**Repository Type:**
```
Q: What type of repository is this?

1. fullstack - Full-stack application (frontend + backend)
2. frontend - Frontend-only application
3. backend - Backend-only API or service
4. library - Shared library or package
5. service - Microservice
6. monorepo - Monorepo with multiple apps/packages
```

**Brief Description:**
```
Q: Brief description of this repository (one sentence):

Examples:
- "Main web application with React frontend and FastAPI backend"
- "Shared UI component library"
- "REST API service for user management"
```

**Tech Stack Detection:**

The wizard will now analyze your repository:
```
Analyzing repository at ../my-app...

📊 Detected Tech Stack:

Frontend: React, Next.js, TypeScript, Tailwind CSS
Backend: FastAPI, Python 3.11
Database: PostgreSQL, Supabase
Other: Docker, Jest

Detection confidence: high

Is this correct? (yes/no)
```

- **yes**: Use detected stack
- **no**: Manually specify each category

**If Manual:**
```
Q: Frontend frameworks/libraries (comma-separated):
   React, Next.js, Tailwind CSS

Q: Backend frameworks/languages (comma-separated):
   FastAPI, Python

Q: Database systems (comma-separated):
   PostgreSQL, Supabase

Q: Other important tools (comma-separated):
   Docker, TypeScript
```

**Repeat for all repositories...**

#### 2.4: Feature Selection

```
Q: Enable cross-repo documentation synchronization?
   (yes/no)
```
**Recommendation:** yes, this is one of the most important features for this setup.

```
Q: Generate database documentation guidelines?
   (yes/no)
```
**Recommendation:** yes if using databases -- or do it later.

```
Q: Generate detailed guidelines with examples?
   (yes/no)
```
**Recommendation:** yes for first setup -- this will add the initial documentation files. Strictly verify the accuracy.

### What the Wizard Generates

**This will take a while!**

The wizard will then:

1. **Generate SETUP_CONFIG.json** - Your configuration
2. **Analyze each repository** - Detect tech stacks
3. **Generate skills** - One per repository
4. **Generate guidelines** - Architecture, error handling, testing
5. **Generate CLAUDE.md** - Main context file
6. **Update README.md** - With your configuration
7. **Validate setup** - Check everything is correct

You'll see progress like:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generating Orchestrator Files...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Generating skill for app...
✅ Skill created: shared/skills/app-guidelines/

[2/3] Generating skill for backend...
✅ Skill created: shared/skills/backend-guidelines/

[3/3] Generating skill for library...
✅ Skill created: shared/skills/library-guidelines/

✅ Skill rules created: shared/skills/skill-rules.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Generating Guidelines...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Generated: shared/guidelines/architectural-principles.md
✅ Generated: shared/guidelines/error-handling.md
✅ Generated: shared/guidelines/testing-standards.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Validating Setup...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ SETUP_CONFIG.json exists and is valid JSON
✅ CLAUDE.md generated with no placeholders
✅ README.md generated
✅ skill-rules.json is valid JSON
✅ Each repo has a skill directory
✅ Guidelines directory populated
✅ No remaining {{PLACEHOLDER}} strings

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Setup Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 3: Create Symlinks

(You need symlinks to activate the functionalities from this repo.)


Now create symlinks in your repositories to use the shared resources:

```bash
# From orchestrator directory
./setup/scripts/create-symlinks.sh
```

**What this does:**
- Reads SETUP_CONFIG.json
- For each repository:
  - Creates `.claude/` directory if needed
  - Creates symlinks to `shared/skills`, `shared/hooks`, `shared/commands`
  - Validates symlinks work

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Orchestrator Symlink Creator
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Configuration: /path/to/orchestrator/SETUP_CONFIG.json

Organization: YourOrg

Repositories to process: 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Creating Symlinks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Repository: app
  Path: ../my-app
  ✓ Created skills symlink
  ✓ Created hooks symlink
  ✓ Created commands symlink
  ✓ Repository configured successfully

[2/3] Repository: backend
  Path: ../my-backend
  ✓ Created skills symlink
  ✓ Created hooks symlink
  ✓ Created commands symlink
  ✓ Repository configured successfully

[3/3] Repository: library
  Path: ../shared-library
  ✓ Created skills symlink
  ✓ Created hooks symlink
  ✓ Created commands symlink
  ✓ Repository configured successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Processed: 3 repositories
Success:   3

✓ All repositories configured successfully!

Next steps:
  1. Test skills by editing files in your repositories
  2. Verify skill activation works
  3. Delete the setup/ directory: rm -rf setup/
```

---

## Step 4: Verify Setup

Run the validation script to ensure everything is configured correctly:

```bash
# From orchestrator directory
./setup/scripts/validate-setup.sh
```

**What this checks:**
- Prerequisites installed (jq)
- Configuration files valid
- Generated files have no placeholders
- Skills created correctly
- Guidelines generated
- No template references remain

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Orchestrator Setup Validation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking Prerequisites...
✓ jq is installed

Checking Configuration...
✓ SETUP_CONFIG.json exists
✓ SETUP_CONFIG.json is valid JSON
  → Organization: YourOrg
  → Repositories: 3

Checking Generated Files...
✓ CLAUDE.md exists
✓ CLAUDE.md has no placeholders
✓ README.md exists
✓ README.md has no placeholders

Checking Skills Configuration...
✓ skill-rules.json exists
✓ skill-rules.json is valid JSON
  → Skills configured: 4

Checking Repository Skills...
✓ Skill directory exists: app-guidelines
  ✓ skill.md exists for app
  ✓ skill.md has no placeholders
  ✓ README.md exists for app
[... continues for all repos ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Validation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Checks: 45
Passed:       45
Failed:       0
Warnings:     0

✓ Setup validation passed!
```

---

## Step 5: Test the Orchestrator

### Test 1: Verify Symlinks

```bash
# Check symlinks exist in one of your repos
cd ../my-app/.claude
ls -la

# You should see:
# skills -> ../../orchestrator/shared/skills
# hooks -> ../../orchestrator/shared/hooks
# commands -> ../../orchestrator/shared/commands

# Test symlink works
cat skills/skill-rules.json
# Should display the JSON content
```

### Test 2: Test Skill Activation

1. **Open one of your repositories in Claude Code**
   ```bash
   cd ../my-app
   claude-code .
   ```

2. **Edit a file that matches your skill pattern**
   ```bash
   # For example, if you have a React app, edit a .tsx file
   # Open: src/components/Example.tsx
   ```

3. **Make a change and ask Claude something**
   ```
   # In Claude Code, type:
   "Help me improve this component"
   ```

4. **Verify skill activated**
   - You should see the skill provide context-aware guidance
   - It should reference your tech stack (React, Next.js, etc.)
   - It might suggest checking guidelines

### Test 3: Invoke an Agent

In Claude Code (in any repository):

```
# Example: Get code review
Can you review the authentication logic for best practices?
```

Claude should invoke the `code-architecture-reviewer` agent automatically.

### Test 4: Use a Slash Command

In Claude Code:

```
/dev-docs implement-user-authentication
```

Should create:
```
dev/active/implement-user-authentication/
├── implement-user-authentication-plan.md
├── implement-user-authentication-context.md
└── implement-user-authentication-tasks.md
```

---

## Step 6: Clean Up

Once everything is working, delete the setup directory:

```bash
# From orchestrator directory
rm -rf setup/

# Commit your configured orchestrator
git add .
git commit -m "Configure orchestrator for YourOrg"

# Optional: Push to your private repo
git remote set-url origin <your-private-repo>
git push -u origin main
```

---

## Step 7: Using the Orchestrator

### Daily Usage

**As a Developer:**
1. Edit files in your repositories
2. Skills auto-trigger with guidance
3. Ask Claude for help - agents provide specialized assistance
4. Reference guidelines when needed

**As an AI Agent:**
1. Read CLAUDE.md for resource discovery
2. Use skills for context-aware guidance
3. Invoke specialized agents for complex tasks
4. Reference guidelines for detailed patterns

### Common Commands

```bash
# Create dev docs for a complex task
/dev-docs feature-name

# Update dev docs before context reset
/dev-docs-update

# Validate orchestrator setup
./setup/scripts/validate-setup.sh

# Re-create symlinks if needed
./setup/scripts/create-symlinks.sh
```

### Invoking Agents

Agents are invoked automatically by Claude Code's Task tool, but you can request them:

```
# Code review
"Can you review this module for architectural issues?"

# Plan a refactoring
"I need to refactor the authentication system - can you create a plan?"

# Fix errors
"There are TypeScript errors - can you fix them?"

# Research
"What are best practices for error handling in FastAPI?"
```

---

## Troubleshooting

### Issue: Wizard Not Found

**Problem:** `/setup-orchestrator` command not recognized

**Solution:**
1. Ensure `setup/setup-wizard.md` exists
2. Check it's properly formatted with frontmatter
3. Restart Claude Code

### Issue: Repository Not Found During Setup

**Problem:** Wizard says "Repository not found at ../my-app"

**Solution:**
1. Verify the path is correct relative to orchestrator
2. Use `ls ../my-app` to check it exists
3. The wizard will allow you to continue (you can fix paths later)

### Issue: Tech Stack Not Detected

**Problem:** Wizard shows empty tech stack

**Solution:**
1. Choose "no" when asked if detection is correct
2. Manually specify your tech stack
3. Verify config files exist (package.json, requirements.txt, etc.)

### Issue: Symlinks Not Working

**Problem:** Symlink script fails or symlinks broken

**macOS/Linux:**
```bash
# Manually create symlinks
cd ../my-app/.claude
ln -sf ../../orchestrator/shared/skills skills
ln -sf ../../orchestrator/shared/hooks hooks
ln -sf ../../orchestrator/shared/commands commands
```

**Windows:**
```powershell
# Ensure Developer Mode is enabled
# Then use mklink:
cd ..\my-app\.claude
mklink /D skills ..\..\orchestrator\shared\skills
mklink /D hooks ..\..\orchestrator\shared\hooks
mklink /D commands ..\..\orchestrator\shared\commands
```

### Issue: Skills Not Triggering

**Problem:** Edit files but skills don't activate

**Check:**
1. Symlinks exist and work: `ls -la ../my-app/.claude/skills`
2. skill-rules.json is valid: `jq . shared/skills/skill-rules.json`
3. File patterns match: Check `skill-rules.json` for your repo's patterns
4. Hooks are executable: `chmod +x shared/hooks/*.sh`

### Issue: Validation Failures

**Problem:** validate-setup.sh reports errors

**Solution:**
1. Read the specific error messages
2. Check for remaining `{{PLACEHOLDERS}}` in files
3. Verify JSON files are valid: `jq . file.json`
4. Re-run setup wizard if needed

### Issue: jq Not Installed

**Problem:** Scripts fail with "jq: command not found"

**Solution:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# Verify
jq --version
```

---

## Advanced Configuration

### Adding a New Repository

**Option 1: Re-run Setup Wizard**
```bash
# Backup current config
cp SETUP_CONFIG.json SETUP_CONFIG.backup.json

# Re-clone orchestrator or restore setup/ directory
# Run wizard again
/setup-orchestrator
```

**Option 2: Manual Configuration**
1. Edit `SETUP_CONFIG.json` - add new repository
2. Generate skill: Invoke `skill-generator` agent
3. Update `shared/skills/skill-rules.json`
4. Run: `./setup/scripts/create-symlinks.sh`
5. Validate: `./setup/scripts/validate-setup.sh`

### Customizing Generated Skills

After setup, you can customize skills:

```bash
# Edit skill for your repo
vim shared/skills/app-guidelines/skill.md

# Add custom patterns, examples, or guidance
# Save and test
```

### Customizing Guidelines

```bash
# Edit guidelines with your org-specific patterns
vim shared/guidelines/error-handling.md

# Add examples, update patterns
# Reference from skills as needed
```

---

## Next Steps

Now that your orchestrator is set up:

1. **Explore the generated files**
   - Read `CLAUDE.md` to understand available resources
   - Check skills in `shared/skills/`
   - Review guidelines in `shared/guidelines/`

2. **Use in your daily work**
   - Let skills guide you as you code
   - Invoke agents when you need specialized help
   - Use `/dev-docs` for complex tasks

3. **Customize for your organization**
   - Add custom agents for specific workflows
   - Extend skills with org-specific patterns
   - Update guidelines with your best practices

4. **Share with your team**
   - Commit orchestrator to your organization's repo
   - Share setup guide with team members
   - Establish conventions for updates

---

## Getting Help

- **Documentation:** See [README.md](./README.md) for overview
- **AI Agent Context:** See [CLAUDE.md](./CLAUDE.md) for complete resource map
- **Dev Docs Pattern:** See [dev/README.md](./dev/README.md) for complex tasks

---

**Congratulations!** Your orchestrator is configured and ready to use. Happy coding! 