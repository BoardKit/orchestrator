#!/usr/bin/env node
import { readFileSync, existsSync } from 'fs';
import { join, basename } from 'path';
import { createHash } from 'crypto';

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
    type: 'guardrail' | 'domain' | 'base';
    enforcement: 'block' | 'suggest' | 'warn';
    priority: 'critical' | 'high' | 'medium' | 'low';
    scope?: string; // "all" | "orchestrator" | specific repo name
    alwaysActivate?: boolean; // If true, always activate when scope matches repo
    promptTriggers?: PromptTriggers;
    filePatterns?: string[];
}

interface SkillRules {
    version: string;
    skills: Record<string, SkillRule>;
}

interface MatchedSkill {
    name: string;
    matchType: 'keyword' | 'intent' | 'auto' | 'session';
    config: SkillRule;
    content?: string; // The actual skill markdown content
}

interface SessionState {
    repo: string;
    active_skills: string[];
    last_updated: string;
}

interface RepoConfig {
    repoName: string;
    repoType: string;
    orchestratorPath?: string;
}

/**
 * Read the skill.md content for a given skill name
 * Skill names are like "backend/base" → looks for .claude/skills/backend/base/skill.md
 */
function readSkillContent(projectDir: string, skillName: string): string | null {
    // Try multiple possible paths for the skill file
    const possiblePaths = [
        join(projectDir, '.claude', 'skills', skillName, 'skill.md'),
        join(projectDir, '.claude', 'skills', `${skillName}.md`),
    ];

    for (const skillPath of possiblePaths) {
        if (existsSync(skillPath)) {
            try {
                return readFileSync(skillPath, 'utf-8');
            } catch {
                // Continue to next path
            }
        }
    }

    return null;
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

/**
 * Get session-sticky skills from session state file
 * Skills that were activated via file edits stay active for the session
 */
function getSessionActiveSkills(projectDir: string): string[] {
    try {
        const hash = createHash('md5').update(projectDir).digest('hex');
        const sessionFile = `/tmp/claude-skills-${hash}.json`;

        if (existsSync(sessionFile)) {
            const content = readFileSync(sessionFile, 'utf-8');
            const session: SessionState = JSON.parse(content);
            return session.active_skills || [];
        }
    } catch (err) {
        // Session file doesn't exist or is invalid - that's fine
    }
    return [];
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

        // Track which skills have been added to avoid duplicates
        const addedSkills = new Set<string>();

        // SESSION-STICKY: Get skills from session state (persisted from file edits)
        const sessionSkills = getSessionActiveSkills(projectDir);
        for (const skillName of sessionSkills) {
            const config = rules.skills[skillName];
            if (config && !addedSkills.has(skillName)) {
                matchedSkills.push({ name: skillName, matchType: 'session', config });
                addedSkills.add(skillName);
            }
        }

        // Check each skill for matches
        for (const [skillName, config] of Object.entries(rules.skills)) {
            // Filter by scope first
            if (!skillMatchesScope(config, currentRepo)) {
                continue; // Skip skills not meant for this repo
            }

            // AUTO-ACTIVATE: If alwaysActivate is true and scope matches exactly
            if (config.alwaysActivate && config.scope === currentRepo && !addedSkills.has(skillName)) {
                matchedSkills.push({ name: skillName, matchType: 'auto', config });
                addedSkills.add(skillName);
                continue;
            }

            const triggers = config.promptTriggers;
            if (!triggers) {
                continue;
            }

            // Skip if already added via auto-activate
            if (addedSkills.has(skillName)) {
                continue;
            }

            // Keyword matching
            if (triggers.keywords) {
                const keywordMatch = triggers.keywords.some(kw =>
                    prompt.includes(kw.toLowerCase())
                );
                if (keywordMatch) {
                    matchedSkills.push({ name: skillName, matchType: 'keyword', config });
                    addedSkills.add(skillName);
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
                    addedSkills.add(skillName);
                }
            }
        }

        // Load skill content for matched skills
        for (const skill of matchedSkills) {
            const content = readSkillContent(projectDir, skill.name);
            if (content) {
                skill.content = content;
            }
        }

        // Filter to only skills with content (base/high priority always, others only if content found)
        const skillsWithContent = matchedSkills.filter(s => s.content);
        const skillsWithoutContent = matchedSkills.filter(s => !s.content);

        // Generate output if matches found
        if (matchedSkills.length > 0) {
            let output = '';

            // Inject skill content for high priority skills (base + critical + high)
            const highPrioritySkills = skillsWithContent.filter(
                s => s.config.type === 'base' || s.config.priority === 'critical' || s.config.priority === 'high'
            );

            if (highPrioritySkills.length > 0) {
                output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
                output += `📍 ACTIVE SKILLS (${currentRepo})\n`;
                output += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n';

                for (const skill of highPrioritySkills) {
                    output += `<!-- skill: ${skill.name} -->\n`;
                    output += skill.content + '\n';
                    output += `<!-- /skill: ${skill.name} -->\n\n`;
                }
            }

            // List medium/low priority skills as available (not auto-loaded)
            const optionalSkills = skillsWithContent.filter(
                s => s.config.priority === 'medium' || s.config.priority === 'low'
            );

            if (optionalSkills.length > 0 || skillsWithoutContent.length > 0) {
                output += '📌 Available skills (ask to activate): ';
                const availableNames = [
                    ...optionalSkills.map(s => s.name),
                    ...skillsWithoutContent.map(s => s.name)
                ];
                output += availableNames.join(', ') + '\n';
            }

            // Only output to stderr (terminal) - console.log goes to Claude's context
            process.stderr.write(`[Skills] Activated: ${highPrioritySkills.map(s => s.name).join(', ') || 'none'}\n`);
            console.log(output);
        }

        process.exit(0);
    } catch (err) {
        console.error('Error in skill-activation-prompt hook:', err);
        process.exit(0);
    }
}

main().catch(err => {
    console.error('Uncaught error:', err);
    process.exit(0);
});
