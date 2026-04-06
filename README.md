<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/2h/waza.svg" width="120" />
  <h1>Waza</h1>
  <p><b>Claude Code skills for the complete engineer: design, solve, express, grow.</b></p>
  <a href="https://github.com/tw93/Waza/stargazers"><img src="https://img.shields.io/github/stars/tw93/Waza?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/tw93/Waza/releases"><img src="https://img.shields.io/github/v/tag/tw93/Waza?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://twitter.com/AiTw93"><img src="https://img.shields.io/badge/follow-Tw93-red?style=flat-square&logo=Twitter" alt="Twitter"></a>
</div>

<br/>

## Why

Waza (技) is a Japanese martial arts term for technique: a move practiced until it becomes instinct.

A good engineer does not just write code. They think through requirements, review their own work, debug systematically, design interfaces that feel intentional, and read primary sources. They write clearly, and learn new domains by producing output, not consuming content.

<img src="https://gw.alipayobjects.com/zos/k/qa/waza_repaired_v4.svg" width="800" />


## Skills

Each engineering habit gets a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills). Type the slash command, Claude follows the playbook.

| Skill | When | What it does |
| :--- | :--- | :--- |
| [`/think`](skills/think/SKILL.md) | Before building anything new | Challenges the problem, pressure-tests the design, validates architecture before any code is written. |
| [`/design`](skills/design/SKILL.md) | Building frontend interfaces | Produces distinctive UI with a committed aesthetic direction, not generic defaults. |
| [`/check`](skills/check/SKILL.md) | After a task, before merging | Reviews the diff, auto-fixes safe issues, blocks destructive commands via hooks, verifies with evidence. |
| [`/hunt`](skills/hunt/SKILL.md) | Any bug or unexpected behavior | Systematic debugging. Root cause confirmed before any fix is applied. |
| [`/write`](skills/write/SKILL.md) | Writing or editing prose | Rewrites prose to sound natural in Chinese and English. Strips AI writing patterns. |
| [`/learn`](skills/learn/SKILL.md) | Diving into an unfamiliar domain | Six-phase research workflow: collect, digest, outline, fill in, refine, then self-review and publish. |
| [`/read`](skills/read/SKILL.md) | Any URL or PDF | Fetches content as clean Markdown via proxy cascade script. |
| [`/health`](skills/health/SKILL.md) | Auditing Claude Code setup | Checks CLAUDE.md, rules, skills, hooks, MCP, and behavior. Flags issues by severity. |

Each skill is a folder, not just a markdown file. Skills include reference docs, helper scripts, scoped hooks, and gotchas sections built from real project failures. See Anthropic's [skill best practices](https://x.com/trq212/status/2033949937936085378) for the philosophy behind this structure.

## Statusline

A minimal Claude Code statusline that shows only what matters: context window usage, 5-hour quota, and 7-day quota, each with the time remaining until reset.

<img src="https://gw.alipayobjects.com/zos/k/3a/2Vlazb.png" width="800" />

Color coding: green below 70%, yellow at 70-85%, red above 85% for context; blue, magenta, red for quota thresholds. No progress bars, no noise.

```bash
# Point Claude Code at the script in ~/.claude/settings.json:
# "statusLine": { "type": "command", "command": "bash ~/www/waza/scripts/statusline.sh" }
```

Requires `jq`. No other dependencies.

## English Coaching

English should be every engineer's first language when working with AI. The model thinks in English, the best resources are in English, and writing clearly in English is a skill that compounds over time.

Passive grammar correction on every reply. Claude flags mistakes with the pattern name so you learn why.

> 😇 I very like this feature → I really like this feature (Unnatural phrasing)

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/main/templates/english-coaching.md >> ~/.claude/CLAUDE.md
```

## Install

**All skills:**

```bash
npx skills add tw93/Waza -g -y
```

**Single skill:**

```bash
# example: install the health skill
npx skills add tw93/Waza -a claude-code -s health -y
```

Replace `health` with any skill name. Requires Node 18+ and Claude Code.


## Background

Tools like Superpowers and gstack are impressive, but they are heavy. Too many skills, too much configuration, too steep a learning curve for engineers who just want to get things done.

Waza is the opposite: eight skills that cover the habits that actually matter. Each one does one thing, has a clear trigger, and stays out of the way. The goal is not completeness. It is the right amount, done well.

Built from patterns accumulated across real projects, then refined with 30 days of usage data (300+ sessions, 7 projects, 500 hours). Each gotcha in a skill traces back to a specific failure: a wrong code path that cost four rounds, a release announced before artifacts were uploaded, a server restarted eight times without reading the error. The `/health` skill is based on the six-layer framework described in [this post](https://tw93.fun/en/2026-03-12/claude.html).

## Support

- If Waza helped you, star the repo or [share it](https://twitter.com/intent/tweet?url=https://github.com/tw93/Waza&text=Waza%20-%20Claude%20Code%20skills%20for%20the%20complete%20engineer.) with friends.
- Have ideas or found bugs? Open an issue or PR.
- Like Waza? <a href="https://miaoyan.app/cats.html?name=Waza" target="_blank">Buy Tw93 a Coke</a> to support the project.

<details>
<summary>🥤 Supporters</summary>

<a href="https://miaoyan.app/cats.html?name=Waza"><img src="https://rawcdn.githack.com/tw93/MiaoYan/vercel/assets/sponsors.svg" width="1000" loading="lazy" /></a>

</details>

## License

MIT License. Feel free to use Waza and contribute.
