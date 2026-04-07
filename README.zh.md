<div align="center">
  <img src="https://gw.alipayobjects.com/zos/k/2h/waza.svg" width="120" />
  <h1>Waza</h1>
  <p><b>将你已知的工程习惯，转化为 Claude 可以执行的技能。</b></p>
  <a href="https://github.com/tw93/Waza/stargazers"><img src="https://img.shields.io/github/stars/tw93/Waza?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/tw93/Waza/releases"><img src="https://img.shields.io/github/v/tag/tw93/Waza?label=version&style=flat-square" alt="Version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square" alt="License"></a>
  <a href="https://twitter.com/AiTw93"><img src="https://img.shields.io/badge/follow-Tw93-red?style=flat-square&logo=Twitter" alt="Twitter"></a>
</div>

<br/>

## 为什么

Waza（技）是日本武术中的术语，意指技法：一个经过反复练习直至成为本能的动作。

优秀的工程师不只是写代码。他们深入思考需求、自我审视工作成果、系统化地调试问题、设计有意图感的接口，并阅读第一手资料。他们写作清晰，通过产出成果而非消费内容来学习新领域。

AI 让你更快。但它不会让你思考更清晰、交付更谨慎、理解更深入。Waza 将这些工程习惯逐一转化为 Claude 可以执行的技能。

<img src="https://gw.alipayobjects.com/zos/k/qa/waza_repaired_v4.svg" width="800" />

## 技能

每种工程习惯对应一个 [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills)。输入斜杠命令，Claude 按照剧本执行。

| 技能 | 使用时机 | 做什么 |
| :--- | :--- | :--- |
| [`/think`](skills/think/SKILL.md) | 开始构建任何新东西之前 | 质疑问题本身，压力测试设计方案，在写任何代码之前验证架构。 |
| [`/design`](skills/design/SKILL.md) | 构建前端界面时 | 以明确的审美方向产出有特色的 UI，而非通用的默认样式。 |
| [`/check`](skills/check/SKILL.md) | 完成任务后、合并之前 | 审查 diff，自动修复安全问题，通过 hooks 拦截破坏性命令，并以证据验证结果。 |
| [`/hunt`](skills/hunt/SKILL.md) | 遇到任何 bug 或异常行为时 | 系统化调试。在应用任何修复之前确认根本原因。 |
| [`/write`](skills/write/SKILL.md) | 写作或编辑文章时 | 将文章改写为自然流畅的中文或英文，去除 AI 写作模式。 |
| [`/learn`](skills/learn/SKILL.md) | 深入陌生领域时 | 六阶段研究工作流：收集、消化、提纲、填充、精炼，然后自我审阅并发布。 |
| [`/read`](skills/read/SKILL.md) | 任何 URL 或 PDF | 通过代理级联脚本将内容抓取为干净的 Markdown，内置微信和飞书专属处理器。 |
| [`/health`](skills/health/SKILL.md) | 审计 Claude Code 配置时 | 检查 CLAUDE.md、rules、skills、hooks、MCP 和行为模式，按严重程度标记问题。 |

每个技能是一个文件夹，而非单纯的 Markdown 文件。技能包含参考文档、辅助脚本、作用域限定的 hooks，以及从真实项目失败中提炼的注意事项章节。

## 扩展功能

**状态栏（Statusline）**

一个极简的 Claude Code 状态栏，只显示最重要的信息：上下文窗口用量、5 小时配额和 7 天配额，以及各自距重置的剩余时间。

<img src="https://gw.alipayobjects.com/zos/k/y9/RUgevg.png" width="800" />

颜色编码：上下文低于 70% 为绿色，70-85% 为黄色，85% 以上为红色；配额阈值分别为蓝色、品红色和红色。无进度条，无噪音。

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/main/scripts/setup-statusline.sh | bash
```

**英语写作辅导（English Coaching）**

英语应当是每位工程师与 AI 协作时的第一语言。模型用英语思考，最好的资源是英文的，而用英语清晰表达是一种随时间复利增长的技能。

每次回复自动进行语法纠错。Claude 标注错误时会附上模式名称，帮助你理解原因。

> 😇 it is not good to be read → it's hard to read (Unnatural phrasing)

```bash
curl -sL https://raw.githubusercontent.com/tw93/Waza/main/templates/coaching-en.md >> ~/.claude/CLAUDE.md
```

## 安装

```bash
npx skills add tw93/Waza -g -y
```

安装单个技能：

```bash
npx skills add tw93/Waza -a claude-code -s health -y
```

将 `health` 替换为任意技能名称。需要 Node 18+ 和 Claude Code。

## 背景

Superpowers 和 gstack 等工具令人印象深刻，但过于沉重。技能太多、配置太复杂、对于只想完成工作的工程师来说学习曲线太陡峭。

沉重的技能集合还有一个更深层的问题：作者写下的每条规则都会成为上限。模型只能做指令规定的事情，无法超越它们生长。Waza 采取相反的方式：每个技能陈述目标和重要约束，然后退到一旁。随着模型持续进步，这种克制会带来复利回报。

Waza 恰恰相反：八个技能，覆盖真正重要的工程习惯。每一个只做一件事，有明确的触发时机，不会越俎代庖。目标不是面面俱到，而是恰到好处、做到精致。

从真实项目中积累的模式提炼而来，再经真实使用数据打磨。每个技能中的注意事项都源自一次具体的失败：一条错误的代码路径耗费了四轮调试，一次发布在制品上传之前就宣布了，一台服务器重启了八次却没有阅读错误信息。30 天，300+ 个会话，7 个项目，500 小时。

`/health` 技能基于[这篇文章](https://tw93.fun/en/2026-03-12/claude.html)中描述的六层框架。

## 支持

- 如果 Waza 对你有帮助，请给仓库加星，或[分享给朋友](https://twitter.com/intent/tweet?url=https://github.com/tw93/Waza&text=Waza%20-%20Claude%20Code%20skills%20for%20the%20complete%20engineer.)。
- 有想法或发现 bug？欢迎提 issue 或 PR。
- 喜欢 Waza？<a href="https://miaoyan.app/cats.html?name=Waza" target="_blank">请 Tw93 喝杯可乐</a>以支持项目。

<details>
<summary>🥤 支持者</summary>

<a href="https://miaoyan.app/cats.html?name=Waza"><img src="https://rawcdn.githack.com/tw93/MiaoYan/vercel/assets/sponsors.svg" width="1000" loading="lazy" /></a>

</details>

## 许可证

MIT License。欢迎自由使用 Waza 并贡献代码。
