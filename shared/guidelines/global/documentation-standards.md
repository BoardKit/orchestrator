# Documentation Standards

**Last Updated: 2025-11-12**

---

## Overview

This guideline establishes documentation standards for all repositories in your organization. Good documentation makes code maintainable, helps onboarding, and serves as a reference for current and future developers (human and AI).

---

## Core Principles

### 1. Document "Why", Not Just "What"

**Principle:** Explain the reasoning behind decisions, not just what the code does.

**Rationale:**
- Code shows "what" already
- "Why" explains context and trade-offs
- Helps future maintainers make informed decisions

**Application:**
```python
# Bad: States the obvious
def calculate_total(items):
    """Calculate total."""
    return sum(item.price for item in items)

# Good: Explains why and includes details
def calculate_total(items):
    """
    Calculate total price for items.

    Uses simple summation rather than running total to avoid
    floating-point accumulation errors. For large carts,
    consider using Decimal for currency precision.

    Args:
        items: List of items with price attribute

    Returns:
        Total price as float

    Example:
        >>> items = [Item(price=10.5), Item(price=20.3)]
        >>> calculate_total(items)
        30.8
    """
    return sum(item.price for item in items)
```

---

### 2. Keep Documentation Close to Code

**Principle:** Documentation should live near the code it describes.

**Rationale:**
- Easier to keep in sync
- Developers more likely to update it
- Less context switching

**Application:**
- Docstrings in code files
- README in each package/module
- Comments for complex logic
- Separate docs only when necessary

---

### 3. Update Documentation with Code

**Principle:** Documentation changes should accompany code changes.

**Rationale:**
- Prevents documentation drift
- Ensures accuracy
- Maintains trust in documentation

**Application:**
- Include doc updates in same PR as code changes
- Review documentation during code review
- Mark outdated docs clearly

---

### 4. Be Concise and Purposeful

**Principle:** Documentation should be as short as possible while remaining useful.

**Rationale:**
- Long documentation is rarely read fully
- Developers need quick answers, not essays
- Maintenance cost increases with length
- Quality over quantity - one good example beats four mediocre ones

**Application:**
- Add detailed descriptions **only** for complex/critical functionality
- Simple features need simple docs - don't over-explain
- Use one clear example per concept (not multiple variations)
- Keep documentation files under 500 lines when possible
- Reference other docs instead of duplicating content

**Examples:**

Bad: Over-explained for simple functionality
Good: Concise for simple functionality
Good: Detailed only when complexity warrants it

**Documentation File Length Guidelines:**
- Simple feature used in one place: < 200 lines
- Complex feature with multiple integrations: < 500 lines
- Comprehensive system documentation: < 800 lines
- If approaching these limits, split into focused files

**When to add multiple examples:**
- Different usage patterns exist (sync vs async, basic vs advanced)
- Edge cases need illustration
- Common mistakes need prevention

**When NOT to add multiple examples:**
- Feature is used in only one place in codebase
- Usage is straightforward and consistent
- Examples would be repetitive variations

---

## Code Documentation

### Python Docstrings (Google Style)

**Module docstring:**
```python
"""
Payment processing pipeline module.

This module implements the core pipeline for processing payments
with fraud detection, validation, and transaction logging.

Typical usage:
    from myapp.payments import PaymentPipeline
    pipeline = PaymentPipeline(payment_gateway)
    result = pipeline.process(payment_data)
"""
```

**Function/method docstring:**
```python
def process_payment(
    amount: Decimal,
    payment_method: PaymentMethod,
    customer_id: str,
    validate: bool = True
) -> PaymentResult:
    """
    Process a payment transaction with fraud detection.

    Processes the payment through these steps:
    1. Validate payment method and amount
    2. Run fraud detection checks
    3. Process with payment gateway
    4. Create transaction record

    Args:
        amount: Payment amount in USD (must be positive)
        payment_method: Payment method details (card, ACH, etc.)
        customer_id: Unique customer identifier
        validate: Whether to run validation checks (default: True)

    Returns:
        PaymentResult with transaction ID, status, and metadata

    Raises:
        ValidationError: If payment data is invalid
        FraudDetectionError: If transaction flagged as suspicious
        PaymentGatewayError: If gateway call fails

    Example:
        >>> method = PaymentMethod(type="card", token="tok_...")
        >>> result = process_payment(Decimal("99.99"), method, "cus_123")
        >>> print(result.status)
        'success'
    """
    # Implementation
```

**Class docstring:**
```python
class PaymentProcessor:
    """
    Main interface for payment processing operations.

    PaymentProcessor provides a unified API for processing payments,
    handling refunds, and managing payment methods across multiple
    payment gateways.

    Attributes:
        gateway: Payment gateway instance for processing
        config: Configuration settings for transactions

    Example:
        >>> from myapp.payments import PaymentProcessor
        >>> from myapp.gateways import StripeGateway
        >>> gateway = StripeGateway(api_key="sk_...")
        >>> processor = PaymentProcessor(gateway=gateway)
        >>> result = processor.charge(amount=99.99, customer="cus_123")
        >>> print(result.success)
        True
    """
```

---

### TypeScript/JavaScript (JSDoc)

**Function documentation:**
```typescript
/**
 * Fetch diagram from API by ID.
 *
 * Retrieves diagram data from the backend API and handles common
 * error cases like 404 (not found) and 401 (unauthorized).
 *
 * @param diagramId - Unique identifier for the diagram
 * @returns Promise resolving to diagram data
 * @throws {ApiError} If diagram not found or API request fails
 *
 * @example
 * ```typescript
 * const diagram = await fetchDiagram('abc123');
 * console.log(diagram.name); // "My Diagram"
 * ```
 */
export async function fetchDiagram(diagramId: string): Promise<Diagram> {
  // Implementation
}
```

**Component documentation:**
```typescript
/**
 * DiagramCard component displays a diagram summary with actions.
 *
 * Shows diagram name, creation date, and provides delete/edit actions.
 * Handles loading and error states gracefully.
 *
 * @param props - Component props
 * @param props.diagram - Diagram data to display
 * @param props.onDelete - Callback when delete is clicked
 * @param props.onEdit - Callback when edit is clicked
 *
 * @example
 * ```tsx
 * <DiagramCard
 *   diagram={diagram}
 *   onDelete={(id) => handleDelete(id)}
 *   onEdit={(id) => router.push(`/diagrams/${id}`)}
 * />
 * ```
 */
export function DiagramCard({ diagram, onDelete, onEdit }: DiagramCardProps) {
  // Implementation
}
```

---

### Inline Comments

**When to use comments:**
```python
# Good: Explains non-obvious logic
# Use binary search instead of linear to handle large datasets (>10k items)
result = binary_search(items, target)

# Good: Explains workaround
# Supabase client doesn't support batch deletes, so we delete individually
# TODO: Switch to batch API when available
for item in items:
    supabase.delete(item.id)

# Good: Explains complex algorithm
# Calculate layout using force-directed graph algorithm (Fruchterman-Reingold)
# Iterations: 50 (balanced between quality and performance)
positions = force_directed_layout(graph, iterations=50)

# Bad: States the obvious
# Increment counter
counter += 1

# Bad: Outdated comment
# Uses v1 API (actually using v2 now!)
response = api_v2_client.get(url)
```

---

## README Structure

### Repository README

**Standard sections:**

```markdown
# Repository Name

Brief one-line description.

## Overview

Detailed description of what this repository does and why it exists.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\```bash
# Installation instructions
\```

## Quick Start

\```python
# Simple usage example
\```

## Documentation

- [Full Documentation](link)
- [API Reference](link)
- [Contributing Guide](link)

## Development

\```bash
# Setup for development
\```

## Testing

\```bash
# How to run tests
\```

## License

License information
```

**Example: Python package README**
```markdown
# MyApp Core

Python package for data processing and analysis pipeline.

## Overview

MyApp Core provides a pipeline-based architecture for processing
data through multiple stages with validation, transformation,
and export capabilities.

## Features

- Multiple data formats (CSV, JSON, Parquet)
- Pluggable processor abstraction
- Pydantic-based validation
- Robust error handling and logging

## Installation

\```bash
pip install myapp-core
\```

## Quick Start

\```python
from myapp import DataPipeline
from myapp.processors import CSVProcessor

processor = CSVProcessor(config="config.yaml")
pipeline = DataPipeline(processor=processor)

result = pipeline.process("data.csv")
print(result.summary)  # Processing statistics
\```

[Rest of README...]
```

---

### Package/Module README

**For subdirectories:**

```markdown
# Module Name

## Purpose

What this module does and why it exists.

## Structure

\```
module/
├── __init__.py
├── core.py       # Core functionality
├── utils.py      # Helper utilities
└── models.py     # Data models
\```

## Usage

\```python
from module import function
result = function(args)
\```

## Design Decisions

Why this module is structured this way, trade-offs made, etc.
```

---

## CLAUDE.md Conventions

### Purpose of CLAUDE.md

**CLAUDE.md is the discovery hub for AI agents.** It tells agents:
- What resources exist (skills, agents, guidelines, commands)
- When to use each resource
- How to invoke agents
- Where to find detailed information

---

### CLAUDE.md Structure

**Standard sections:**

1. **Repository Overview** - What this repo does
2. **Resource Discovery Map** - Lists all resources with when-to-use
3. **How Resources Work** - Explains mechanics (skills, agents, hooks)
4. **File Structure** - Commented directory tree
5. **Critical Conventions** - Important patterns to follow
6. **Troubleshooting** - Common issues and solutions (inline, not separate file)
7. **When to Use What** - Decision tree for choosing resources
8. **Cross-References** - Links to other docs

---

### CLAUDE.md Best Practices

```markdown
# Good: Explicit and actionable
**When to reference:**
- Implementing error handling in any repo
- Adding new API endpoints or routes
- Handling external service failures or malformed inputs
- Setting up logging

**Referenced by:**
- app-guidelines skill (repo-specific)
- core-guidelines skill (repo-specific)
- All agents dealing with error scenarios

# Bad: Vague
**About:** Error handling stuff
**Used by:** Various things
```

---

### When to Update CLAUDE.md

**Update when:**
- Adding new skill (add to discovery map)
- Adding new agent (add to agent list)
- Adding new guideline (add to guidelines list)
- Changing resource structure
- Adding new workflow patterns

**Don't update for:**
- Implementation details (those go in code)
- Temporary experiments
- Repo-specific code changes

---

## Dev Docs Pattern

### Three-File Structure

**When to use:** Complex tasks requiring planning and tracking

**Files:**
1. **{task}-plan.md** - Strategic plan, architecture decisions
2. **{task}-context.md** - Current state, decisions made, progress
3. **{task}-tasks.md** - Checklist format for tracking completion

---

### Plan File

**Purpose:** Strategic plan and architecture

**Sections:**
```markdown
## Overview
Brief description of the task

## Goals
What we're trying to achieve

## Scope
What's in scope and out of scope

## Architecture
High-level design decisions

## Implementation Phases
1. Phase 1...
2. Phase 2...

## Risks
Potential issues and mitigations

## Success Criteria
How we'll know we're done
```

---

### Context File

**Purpose:** Track state, decisions, and progress

**Sections:**
```markdown
## Session Progress

### ✅ Completed
- Task 1
- Task 2

### 🟡 In Progress
- Task 3

### ⏳ Not Started
- Task 4

## Key Decisions

### Decision 1: Choice Made
**Decision:** What was decided
**Rationale:** Why
**Impact:** What it affects

## Key Files
- file1.py: What it does
- file2.ts: What it does

## Notes for AI Agents
Specific guidance for agents continuing this work
```

---

### Tasks File

**Purpose:** Granular checklist for tracking

**Format:**
```markdown
## Phase 1: Setup

- [x] Task 1
- [x] Task 2
- [ ] Task 3
- [ ] Task 4

**Status:** 50% complete (2/4 tasks)

## Phase 2: Implementation

- [ ] Task 5
- [ ] Task 6

**Status:** Not started
```

---

### Dev Docs Location

**For single-repo work:**
```
repo/dev/active/task-name/
├── task-name-plan.md
├── task-name-context.md
└── task-name-tasks.md
```

**For cross-repo work:**
```
orchestrator/dev/active/task-name/
├── task-name-plan.md
├── task-name-context.md
└── task-name-tasks.md
```

---

## Documentation Tools

### Python: Sphinx (if needed)

**For larger packages:**
```bash
# Install
pip install sphinx

# Generate docs
cd docs/
make html

# View
open _build/html/index.html
```

---

### TypeScript: TypeDoc (if needed)

**For API documentation:**
```bash
# Install
npm install --save-dev typedoc

# Generate
npx typedoc src/

# View
open docs/index.html
```

---

### API Documentation

**For REST APIs, use OpenAPI/Swagger:**

```python
# FastAPI automatically generates OpenAPI docs
from fastapi import FastAPI

app = FastAPI(
    title="MyApp API",
    description="API for data processing and management",
    version="1.0.0"
)

@app.get("/items/{item_id}", summary="Get item by ID")
async def get_item(item_id: str):
    """
    Retrieve an item by its unique identifier.

    Returns item data including name, status, and metadata.
    """
    return item

# Docs available at /docs (Swagger UI) and /redoc (ReDoc)
```

---

## Anti-Patterns

### ❌ Don't: Write documentation after the fact

**Bad:**
```
1. Write all code
2. Commit
3. Remember to write docs
4. Write docs (usually forget or rush)
```

**Good:**
```
1. Write doc comment / docstring
2. Implement function
3. Test
4. Commit (docs and code together)
```

---

### ❌ Don't: Duplicate information

**Bad:**
```markdown
# README.md
Installation: pip install myapp

# INSTALL.md
Installation: pip install myapp

# docs/installation.md
Installation: pip install myapp
```

**Good:**
```markdown
# README.md
Installation: See [docs/installation.md](docs/installation.md)

# docs/installation.md
Installation:
\```bash
pip install myapp
\```

(All installation details here)
```

---

### ❌ Don't: Write overly detailed comments

**Bad:**
```python
# Create a variable named counter and set it to zero
counter = 0

# Loop through each item in the items list
for item in items:
    # Add the item's price to the counter
    counter += item.price

# Return the counter variable
return counter
```

**Good:**
```python
def calculate_total(items):
    """Calculate total price of items."""
    return sum(item.price for item in items)
```

---

### ❌ Don't: Leave TODO comments indefinitely

**Bad:**
```python
# TODO: Fix this someday
# Temporary hack
def process():
    # This is broken but works for now
    return hacky_solution()
```

**Good:**
```python
# TODO(#123): Replace with proper solution when API v2 is released
# Current workaround for v1 API limitation (see issue #123)
def process():
    return workaround_solution()
```

With issue tracking:
```
Issue #123: Replace process() workaround with v2 API
- Current: Uses workaround due to v1 API limitation
- Goal: Switch to v2 API when available
- File: src/process.py:42
```

---

## Documentation Checklist

### For New Features

- [ ] Code has docstrings (Python) or JSDoc (TypeScript)
- [ ] Complex logic has inline comments explaining "why"
- [ ] README updated if public API changed
- [ ] CLAUDE.md updated if new resource added
- [ ] Examples provided for non-trivial usage
- [ ] Error conditions documented
- [ ] Dev docs created for complex features

### For Bug Fixes

- [ ] Comment explains what bug was and why fix works
- [ ] Update any incorrect documentation
- [ ] Add note to CHANGELOG if significant

### For Refactoring

- [ ] Update comments if logic changed
- [ ] Update docstrings if signatures changed
- [ ] Update README if usage changed
- [ ] Note architectural changes in commit message

---

## Dev Docs Lifecycle

**After a feature is merged:**
1. **Delete** dev docs from `dev/active/[task-name]/` — they served their purpose
2. **Optional archive**: Move to `dev/archive/[task-name]/` if you want historical reference
3. **Never leave stale dev docs** in `dev/active/` — it confuses future agents

**Why delete:** Dev docs are working documents, not permanent documentation. Once the code is merged, the code IS the documentation. Keeping old dev docs around creates confusion about what's current.

**What to keep instead:**
- Update `CLAUDE.md` if architecture changed
- Update guidelines if patterns changed
- Update README if public API changed

---

## Referenced By

- documentation-architect agent
- All agents creating documentation
- Skills referencing guidelines

---

## See Also

- `guidelines/architectural-principles.md` - Documenting architecture decisions
- `guidelines/cross-repo-patterns.md` - Documenting cross-repo features
- CLAUDE.md - Example of discovery hub documentation
- dev/README.md - Dev docs pattern explanation

---

**End of Documentation Standards**
