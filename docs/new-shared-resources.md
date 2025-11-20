## Adding New Shared Resources

### Adding an Agent
```bash
1. Create shared/agents/global/new-agent.md (or shared/agents/{repo-name}/ for repo-specific)
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
1. Create shared/guidelines/global/new-guideline.md (or shared/guidelines/{repo-name}/ for repo-specific)
2. Update shared/guidelines/README.md (if exists)
3. Update CLAUDE.md discovery map
4. Reference from relevant agents/skills
```
