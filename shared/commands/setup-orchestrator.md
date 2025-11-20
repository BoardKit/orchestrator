---
description: Configure the orchestrator for your organization - first-time setup wizard (ORCHESTRATOR ONLY)
---

**⚠️ IMPORTANT:** This command should ONLY be run from the orchestrator repository, not from application repositories.

You are launching the **Orchestrator Setup Wizard** to configure this orchestrator for a new organization.

**Invoke the setup-wizard agent** using the Task tool:

```
Task tool with:
- subagent_type: "setup-wizard"
- description: "Configure orchestrator for organization"
- prompt: "Run the orchestrator setup wizard to configure this orchestrator instance for the user's organization. Guide them through the complete setup process including collecting organization info, analyzing repositories, generating skills, creating guidelines, and producing all necessary documentation."
```

The setup-wizard agent is located at `shared/agents/orchestrator/setup-wizard.md` and will handle the entire configuration process interactively.
