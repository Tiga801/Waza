<div align="center">
  <h1>Waza</h1>
  <p><b>🥷 Claude Code skills for the complete engineer: think, build, debug, write, learn.</b></p>
  <a href="https://github.com/tw93/Waza/stargazers"><img src="https://img.shields.io/github/stars/tw93/Waza?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/tw93/Waza/releases"><img src="https://img.shields.io/github/v/tag/tw93/Waza?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://twitter.com/AiTw93"><img src="https://img.shields.io/badge/follow-Tw93-red?style=flat-square&logo=Twitter" alt="Twitter"></a>
</div>

<br/>

## Why

Waza (技) is a Japanese martial arts term for technique: a move practiced until it becomes instinct. A good engineer does not just write code. They think through requirements, review their own work, debug systematically, design interfaces that feel intentional, read primary sources, write clearly, and learn new domains by producing output, not consuming content. Waza gives each of these habits a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills): you type the slash command, Claude follows the playbook. No framework overhead, no telemetry.

## Skills

| Skill | When | What it does |
| :--- | :--- | :--- |
| `/think` | Before building anything new | Challenges the problem, pressure-tests the design, validates architecture before any code is written. |
| `/check` | After a task, before merging | Reviews the diff, auto-fixes safe issues, batches judgment calls, verifies with evidence before claiming done. |
| `/hunt` | Any bug or unexpected behavior | Systematic debugging. Root cause confirmed before any fix is applied. |
| `/design` | Building frontend interfaces | Produces distinctive UI with a committed aesthetic direction. Avoids generic AI aesthetics. |
| `/read` | Any URL or PDF | Fetches content as clean Markdown via proxy cascade. |
| `/write` | Writing or editing prose | Enforces natural style for Chinese and English. Strips AI writing patterns. |
| `/learn` | Diving into an unfamiliar domain | Six-phase research workflow: collect, digest, outline, draft, refine, self-review and publish. |
| `/health` | Config feels off | Audits Claude Code setup: CLAUDE.md, rules, skills, hooks, MCP, behavior. |

## Install

**Single skill:**

```bash
claude plugin marketplace add tw93/Waza
claude plugin install health@waza
```

Replace `health` with any skill name.

**All skills:**

```bash
npx skills add tw93/Waza -g -y
```

**Local (clone + symlink):**

```bash
git clone https://github.com/tw93/Waza.git ~/www/waza
bash ~/www/waza/install.sh
```

## Background

Built from patterns accumulated across real projects. The `/health` skill is based on the six-layer framework described in [this post](https://tw93.fun/en/2026-03-12/claude.html).

## License

MIT
