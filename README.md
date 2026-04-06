<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/2h/waza.svg" width="120" />
  <h1>Waza</h1>
  <p><b>Claude Code skills for the complete engineer: think, build, debug, write, learn.</b></p>
  <a href="https://github.com/tw93/Waza/stargazers"><img src="https://img.shields.io/github/stars/tw93/Waza?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/tw93/Waza/releases"><img src="https://img.shields.io/github/v/tag/tw93/Waza?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://twitter.com/AiTw93"><img src="https://img.shields.io/badge/follow-Tw93-red?style=flat-square&logo=Twitter" alt="Twitter"></a>
</div>

<br/>

## Why

Waza (技) is a Japanese martial arts term for technique: a move practiced until it becomes instinct.

A good engineer does not just write code. They think through requirements, review their own work, debug systematically, design interfaces that feel intentional, and read primary sources. They write clearly, and learn new domains by producing output, not consuming content.

<img src="https://gw.alipayobjects.com/zos/k/qn/waza_concept_v3.svg" width="800" />


## Skills

Waza gives each of these habits a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills): you type the slash command, Claude follows the playbook. No framework overhead, no telemetry.

| Skill | When | What it does |
| :--- | :--- | :--- |
| [`/think`](skills/think) | Before building anything new | Challenges the problem, pressure-tests the design, validates architecture before any code is written. |
| [`/design`](skills/design) | Building frontend interfaces | Produces distinctive UI with a committed aesthetic direction, not generic defaults. |
| [`/check`](skills/check) | After a task, before merging | Reviews the diff, auto-fixes safe issues, batches judgment calls, verifies with evidence before claiming done. |
| [`/hunt`](skills/hunt) | Any bug or unexpected behavior | Systematic debugging. Root cause confirmed before any fix is applied. |
| [`/write`](skills/write) | Writing or editing prose | Rewrites prose to sound natural in Chinese and English. Strips AI writing patterns. |
| [`/learn`](skills/learn) | Diving into an unfamiliar domain | Six-phase research workflow: collect, digest, outline, fill in, refine, then self-review and publish. |
| [`/read`](skills/read) | Any URL or PDF | Fetches content as clean Markdown. |
| [`/health`](skills/health) | Auditing Claude Code setup | Checks CLAUDE.md, rules, skills, hooks, MCP, and behavior. Flags issues by severity. |

## English Coaching

Waza includes a passive English coaching template for non-native speakers. When enabled, Claude automatically corrects grammar and phrasing mistakes at the end of every reply, with the pattern name so you understand why.

```
😇 discuss about → discuss (Redundant preposition)
😇 I am very interest → I am very interested (Wrong verb form)
```

If you used the local install (`bash install.sh`), the script will prompt you during setup. If you installed via `npx`, add it manually:

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

Built from patterns accumulated across real projects. Each skill encodes a specific engineering habit as a repeatable playbook, so you do not have to remember the process, only trigger it. The `/health` skill is based on the six-layer framework described in [this post](https://tw93.fun/en/2026-03-12/claude.html).

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
