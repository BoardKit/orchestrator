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
