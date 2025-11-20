#!/usr/bin/env node
import { readFileSync, existsSync } from 'fs';
import { join, basename } from 'path';

interface HookInput {
    session_id: string;
    transcript_path: string;
    cwd: string;
    permission_mode: string;
    prompt: string;
}

interface PromptTriggers {
    keywords?: string[];
    intentPatterns?: string[];
}

interface SkillRule {
    type: 'guardrail' | 'domain';
    enforcement: 'block' | 'suggest' | 'warn';
    priority: 'critical' | 'high' | 'medium' | 'low';
    scope?: string; // "all" | "orchestrator" | specific repo name
    promptTriggers?: PromptTriggers;
}

interface SkillRules {
    version: string;
    skills: Record<string, SkillRule>;
}

interface MatchedSkill {
    name: string;
    matchType: 'keyword' | 'intent';
    config: SkillRule;
}

interface RepoConfig {
    repoName: string;
    repoType: string;
    orchestratorPath?: string;
}

/**
 * Detect which repository we're currently in
 * Returns the repo name (e.g., "frontend", "backend", "orchestrator")
 */
function detectCurrentRepo(projectDir: string): string {
    // Try to read repo config file
    const configPath = join(projectDir, '.claude', 'repo-config.json');
    if (existsSync(configPath)) {
        try {
            const config: RepoConfig = JSON.parse(readFileSync(configPath, 'utf-8'));
            return config.repoName;
        } catch (err) {
            // Fall through to directory-based detection
        }
    }

    // Fallback: detect from directory name
    // If projectDir contains "orchestrator" → orchestrator repo
    // Otherwise, use the last directory name
    const dirName = basename(projectDir);

    if (dirName.includes('orchestrator') || projectDir.includes('/orchestrator')) {
        return 'orchestrator';
    }

    // Return directory name as repo name
    return dirName;
}

/**
 * Check if a skill's scope matches the current repository
 */
function skillMatchesScope(skillConfig: SkillRule, currentRepo: string): boolean {
    const scope = skillConfig.scope || 'all'; // Default to 'all' if not specified

    if (scope === 'all') {
        return true; // Available to all repos
    }

    if (scope === currentRepo) {
        return true; // Scope matches current repo
    }

    return false; // Scope doesn't match
}

async function main() {
    try {
        // Read input from stdin
        const input = readFileSync(0, 'utf-8');
        const data: HookInput = JSON.parse(input);
        const prompt = data.prompt.toLowerCase();

        // Load skill rules
        const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
        const rulesPath = join(projectDir, '.claude', 'skills', 'skill-rules.json');

        if (!existsSync(rulesPath)) {
            // No skill rules file, exit silently
            process.exit(0);
        }

        const rules: SkillRules = JSON.parse(readFileSync(rulesPath, 'utf-8'));

        // Detect current repository
        const currentRepo = detectCurrentRepo(projectDir);

        const matchedSkills: MatchedSkill[] = [];

        // Check each skill for matches
        for (const [skillName, config] of Object.entries(rules.skills)) {
            // Filter by scope first
            if (!skillMatchesScope(config, currentRepo)) {
                continue; // Skip skills not meant for this repo
            }

            const triggers = config.promptTriggers;
            if (!triggers) {
                continue;
            }

            // Keyword matching
            if (triggers.keywords) {
                const keywordMatch = triggers.keywords.some(kw =>
                    prompt.includes(kw.toLowerCase())
                );
                if (keywordMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'keyword', config });
                    continue;
                }
            }

            // Intent pattern matching
            if (triggers.intentPatterns) {
                const intentMatch = triggers.intentPatterns.some(pattern => {
                    const regex = new RegExp(pattern, 'i');
                    return regex.test(prompt);
                });
                if (intentMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'intent', config });
                }
            }
        }

        // Generate output if matches found
        if (matchedSkills.length > 0) {
            let output = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
            output += '🎯 SKILL ACTIVATION CHECK\n';
            output += `📍 Repository: ${currentRepo}\n`;
            output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n';

            // Group by priority
            const critical = matchedSkills.filter(s => s.config.priority === 'critical');
            const high = matchedSkills.filter(s => s.config.priority === 'high');
            const medium = matchedSkills.filter(s => s.config.priority === 'medium');
            const low = matchedSkills.filter(s => s.config.priority === 'low');

            if (critical.length > 0) {
                output += '⚠️  CRITICAL SKILLS (REQUIRED):\n';
                critical.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (high.length > 0) {
                output += '📚 RECOMMENDED SKILLS:\n';
                high.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (medium.length > 0) {
                output += '💡 SUGGESTED SKILLS:\n';
                medium.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            if (low.length > 0) {
                output += '📌 OPTIONAL SKILLS:\n';
                low.forEach(s => output += `  → ${s.name}\n`);
                output += '\n';
            }

            output += 'ACTION: Use Skill tool BEFORE responding\n';
            output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';

            console.log(output);
        }

        process.exit(0);
    } catch (err) {
        console.error('Error in skill-activation-prompt hook:', err);
        process.exit(1);
    }
}

main().catch(err => {
    console.error('Uncaught error:', err);
    process.exit(1);
});
