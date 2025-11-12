#!/bin/bash

# Tech Stack Detection Helper
# Quick shell script to detect tech stack from a repository
# Used as a helper for repo-analyzer agent
#
# Usage: ./setup/scripts/detect-tech-stack.sh <repo-path>
# Returns: JSON with detected tech stack

set -e  # Exit on error

# Check if path provided
if [ -z "$1" ]; then
    echo "Usage: $0 <repo-path>"
    exit 1
fi

REPO_PATH="$1"

# Check if path exists
if [ ! -d "$REPO_PATH" ]; then
    echo "{\"error\": \"Repository not found\", \"path\": \"$REPO_PATH\"}"
    exit 1
fi

# Initialize arrays
FRONTEND=()
BACKEND=()
DATABASE=()
OTHER=()
CONFIG_FILES=()

# Detect config files
if [ -f "$REPO_PATH/package.json" ]; then
    CONFIG_FILES+=("package.json")

    # Parse package.json for dependencies
    if command -v jq &> /dev/null; then
        # Frontend frameworks
        if jq -e '.dependencies.next or .devDependencies.next' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("Next.js")
        fi
        if jq -e '.dependencies.react or .devDependencies.react' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("React")
        fi
        if jq -e '.dependencies.vue or .devDependencies.vue' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("Vue")
        fi
        if jq -e '.dependencies["@angular/core"] or .devDependencies["@angular/core"]' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("Angular")
        fi
        if jq -e '.dependencies.svelte or .devDependencies.svelte' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("Svelte")
        fi

        # CSS frameworks
        if jq -e '.dependencies.tailwindcss or .devDependencies.tailwindcss' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("Tailwind CSS")
        fi
        if jq -e '.dependencies["@radix-ui/react"] or .devDependencies["@radix-ui/react"]' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            FRONTEND+=("Radix UI")
        fi

        # Backend frameworks (Node.js)
        if jq -e '.dependencies.express or .devDependencies.express' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            BACKEND+=("Express")
            BACKEND+=("Node.js")
        fi
        if jq -e '.dependencies.fastify or .devDependencies.fastify' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            BACKEND+=("Fastify")
            BACKEND+=("Node.js")
        fi
        if jq -e '.dependencies."@nestjs/core" or .devDependencies."@nestjs/core"' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            BACKEND+=("NestJS")
            BACKEND+=("Node.js")
        fi

        # Databases
        if jq -e '.dependencies."@supabase/supabase-js" or .devDependencies."@supabase/supabase-js"' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            DATABASE+=("Supabase")
        fi
        if jq -e '.dependencies.prisma or .devDependencies.prisma' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            DATABASE+=("Prisma")
        fi
        if jq -e '.dependencies.mongoose or .devDependencies.mongoose' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            DATABASE+=("MongoDB")
        fi
        if jq -e '.dependencies.pg or .devDependencies.pg' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            DATABASE+=("PostgreSQL")
        fi

        # Other tools
        if jq -e '.dependencies.typescript or .devDependencies.typescript' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            OTHER+=("TypeScript")
        fi
        if jq -e '.devDependencies.jest or .dependencies.jest' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            OTHER+=("Jest")
        fi
        if jq -e '.devDependencies.vitest or .dependencies.vitest' "$REPO_PATH/package.json" > /dev/null 2>&1; then
            OTHER+=("Vitest")
        fi
    fi
fi

if [ -f "$REPO_PATH/requirements.txt" ]; then
    CONFIG_FILES+=("requirements.txt")

    # Python frameworks
    if grep -iq "fastapi" "$REPO_PATH/requirements.txt"; then
        BACKEND+=("FastAPI")
        BACKEND+=("Python")
    fi
    if grep -iq "django" "$REPO_PATH/requirements.txt"; then
        BACKEND+=("Django")
        BACKEND+=("Python")
    fi
    if grep -iq "flask" "$REPO_PATH/requirements.txt"; then
        BACKEND+=("Flask")
        BACKEND+=("Python")
    fi

    # Python libraries
    if grep -iq "pydantic" "$REPO_PATH/requirements.txt"; then
        OTHER+=("Pydantic")
    fi
    if grep -iq "sqlalchemy" "$REPO_PATH/requirements.txt"; then
        DATABASE+=("SQLAlchemy")
    fi
    if grep -iq "psycopg2" "$REPO_PATH/requirements.txt"; then
        DATABASE+=("PostgreSQL")
    fi
    if grep -iq "pymongo" "$REPO_PATH/requirements.txt"; then
        DATABASE+=("MongoDB")
    fi
    if grep -iq "pytest" "$REPO_PATH/requirements.txt"; then
        OTHER+=("pytest")
    fi
fi

if [ -f "$REPO_PATH/pyproject.toml" ]; then
    CONFIG_FILES+=("pyproject.toml")
fi

if [ -f "$REPO_PATH/Gemfile" ]; then
    CONFIG_FILES+=("Gemfile")

    # Ruby frameworks
    if grep -q "rails" "$REPO_PATH/Gemfile"; then
        BACKEND+=("Ruby on Rails")
        BACKEND+=("Ruby")
    fi
    if grep -q "sinatra" "$REPO_PATH/Gemfile"; then
        BACKEND+=("Sinatra")
        BACKEND+=("Ruby")
    fi
fi

# Check for specific config files
if [ -f "$REPO_PATH/next.config.js" ] || [ -f "$REPO_PATH/next.config.mjs" ]; then
    CONFIG_FILES+=("next.config.js")
    if [[ ! " ${FRONTEND[@]} " =~ " Next.js " ]]; then
        FRONTEND+=("Next.js")
    fi
fi

if [ -f "$REPO_PATH/nuxt.config.js" ] || [ -f "$REPO_PATH/nuxt.config.ts" ]; then
    CONFIG_FILES+=("nuxt.config.js")
    FRONTEND+=("Nuxt.js")
fi

if [ -f "$REPO_PATH/angular.json" ]; then
    CONFIG_FILES+=("angular.json")
    if [[ ! " ${FRONTEND[@]} " =~ " Angular " ]]; then
        FRONTEND+=("Angular")
    fi
fi

# Check for Docker
if [ -f "$REPO_PATH/Dockerfile" ] || [ -f "$REPO_PATH/docker-compose.yml" ]; then
    OTHER+=("Docker")
fi

# Check for Prisma
if [ -d "$REPO_PATH/prisma" ]; then
    if [[ ! " ${DATABASE[@]} " =~ " Prisma " ]]; then
        DATABASE+=("Prisma")
    fi
fi

# Detect primary language from file count
TS_COUNT=$(find "$REPO_PATH" -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')
JS_COUNT=$(find "$REPO_PATH" -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l | tr -d ' ')
PY_COUNT=$(find "$REPO_PATH" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
RB_COUNT=$(find "$REPO_PATH" -name "*.rb" 2>/dev/null | wc -l | tr -d ' ')

PRIMARY_LANG="Unknown"
if [ $TS_COUNT -gt 10 ]; then
    PRIMARY_LANG="TypeScript"
    if [[ ! " ${OTHER[@]} " =~ " TypeScript " ]]; then
        OTHER+=("TypeScript")
    fi
elif [ $JS_COUNT -gt 10 ]; then
    PRIMARY_LANG="JavaScript"
elif [ $PY_COUNT -gt 10 ]; then
    PRIMARY_LANG="Python"
elif [ $RB_COUNT -gt 10 ]; then
    PRIMARY_LANG="Ruby"
fi

# Determine confidence
CONFIDENCE="low"
if [ ${#CONFIG_FILES[@]} -ge 2 ] && [ ${#FRONTEND[@]} -gt 0 ] || [ ${#BACKEND[@]} -gt 0 ]; then
    CONFIDENCE="high"
elif [ ${#CONFIG_FILES[@]} -ge 1 ]; then
    CONFIDENCE="medium"
fi

# Build JSON output
echo "{"
echo "  \"repositoryPath\": \"$REPO_PATH\","
echo "  \"analysisComplete\": true,"
echo "  \"detectionConfidence\": \"$CONFIDENCE\","
echo "  \"techStack\": {"

# Frontend
echo -n "    \"frontend\": ["
if [ ${#FRONTEND[@]} -gt 0 ]; then
    for i in "${!FRONTEND[@]}"; do
        echo -n "\"${FRONTEND[$i]}\""
        if [ $i -lt $((${#FRONTEND[@]} - 1)) ]; then
            echo -n ", "
        fi
    done
fi
echo "],"

# Backend
echo -n "    \"backend\": ["
if [ ${#BACKEND[@]} -gt 0 ]; then
    for i in "${!BACKEND[@]}"; do
        echo -n "\"${BACKEND[$i]}\""
        if [ $i -lt $((${#BACKEND[@]} - 1)) ]; then
            echo -n ", "
        fi
    done
fi
echo "],"

# Database
echo -n "    \"database\": ["
if [ ${#DATABASE[@]} -gt 0 ]; then
    for i in "${!DATABASE[@]}"; do
        echo -n "\"${DATABASE[$i]}\""
        if [ $i -lt $((${#DATABASE[@]} - 1)) ]; then
            echo -n ", "
        fi
    done
fi
echo "],"

# Other
echo -n "    \"other\": ["
if [ ${#OTHER[@]} -gt 0 ]; then
    for i in "${!OTHER[@]}"; do
        echo -n "\"${OTHER[$i]}\""
        if [ $i -lt $((${#OTHER[@]} - 1)) ]; then
            echo -n ", "
        fi
    done
fi
echo "]"

echo "  },"
echo "  \"detectedFiles\": {"
echo -n "    \"configFiles\": ["
if [ ${#CONFIG_FILES[@]} -gt 0 ]; then
    for i in "${!CONFIG_FILES[@]}"; do
        echo -n "\"${CONFIG_FILES[$i]}\""
        if [ $i -lt $((${#CONFIG_FILES[@]} - 1)) ]; then
            echo -n ", "
        fi
    done
fi
echo "],"
echo "    \"primaryLanguage\": \"$PRIMARY_LANG\""
echo "  }"
echo "}"
