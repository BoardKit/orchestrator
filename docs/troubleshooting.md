
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
