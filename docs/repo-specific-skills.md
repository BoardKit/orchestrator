# Repository-Specific Skills

The directory `shared/skills/repo-specific/` contains skills that auto-trigger for specific repositories. These skills are symlinked only to their respective repositories, not to all repos.

## Structure

Each repository typically has one `{repo-name}-guidelines` skill:

```
repo-specific/
├── frontend-guidelines/
│   └── skill.md
├── backend-guidelines/
│   └── skill.md
└── core-guidelines/
    └── skill.md
```

## Purpose

Repo-specific skills provide:
- Tech stack-specific development patterns
- Repository-specific best practices
- Framework-specific guidance
- Error handling patterns for the repo's technologies
- Testing patterns for the repo's test frameworks

## Generic vs Repo-Specific

**Generic skills** (in `shared/skills/generic/`):
- Available to ALL repositories
- Provide meta-functionality (skill-developer, orchestrator-guidelines)
- Trigger on orchestrator-level patterns

**Repo-specific skills** (in `shared/skills/repo-specific/`):
- Available ONLY to the specific repository
- Auto-trigger when editing files in that repository
- Provide repo-specific development guidance

## Skill Triggers

Repo-specific skills are configured in `shared/skills/skill-rules.json`:

```json
{
  "skills": [
    {
      "name": "frontend-guidelines",
      "filePatterns": [
        "**/frontend/**/*.tsx",
        "**/frontend/**/*.ts"
      ],
      "keywords": ["react", "component", "tailwind"]
    },
    {
      "name": "backend-guidelines",
      "filePatterns": [
        "**/backend/**/*.py"
      ],
      "keywords": ["fastapi", "endpoint", "pydantic"]
    }
  ]
}
```

## Creating Repo-Specific Skills

During setup, the wizard generates one skill per repository:

1. **Detects tech stack** (package.json, requirements.txt, etc.)
2. **Generates skill from template** using detected technologies
3. **Adds trigger rules** to skill-rules.json
4. **Symlinks to repo** (only that specific skill)

Skills are generated from templates in `setup/templates/skill-template.md`.

## Manual Creation

To manually create a repo-specific skill:

1. Create directory: `mkdir shared/skills/repo-specific/{repo-name}-guidelines`
2. Create skill file: `touch shared/skills/repo-specific/{repo-name}-guidelines/skill.md`
3. Add YAML frontmatter with name and description
4. Add trigger rules to `shared/skills/skill-rules.json`
5. Symlink to repo: See `setup/scripts/create-symlinks.sh` for examples
6. Test activation: Edit a file matching the pattern

## Symlinking

Repo-specific skills are symlinked during setup:

```bash
# In target repo
frontend/.claude/skills/{repo-name}-guidelines/ -> ../../orchestrator/shared/skills/repo-specific/{repo-name}-guidelines/
```

Only the specific repo's skill is symlinked, ensuring skills only activate when relevant.

## Skill Content Guidelines

Keep skill content focused:
- Main file (skill.md) < 500 lines
- Include tech stack patterns
- Reference shared guidelines for detailed patterns
- Provide examples specific to the repo's architecture
- Link to error-handling.md, testing-standards.md as needed
