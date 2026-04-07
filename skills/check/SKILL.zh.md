---
name: check
description: 任何实现任务完成后或合并前调用。审查 diff，自动修复安全问题，对大型 diff 启动安全和架构专项审查员。不适用于探索想法或调试。
version: 3.1.0
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/scripts/check-destructive.sh"
          statusMessage: "Checking for destructive commands..."
---

# Check：发布前先审查

读取 diff，找出问题，安全可修复的直接修复，其余问题询问用户。在本次会话中验证通过之前，不得宣告完成。

## 获取 Diff

```bash
git fetch origin
git diff origin/main
```

如果基准分支不是 `main`，先询问再运行。如果已在基准分支上，停止并询问要审查哪些提交。

## 确定审查范围

统计 diff 数量并分类深度，以此决定启用哪些审查员。

```bash
git diff origin/main --stat | tail -1
```

| 深度 | 标准 | 审查员 |
|------|------|--------|
| **Quick（快速）** | 不超过 100 行，1-5 个文件 | 仅基础审查（本技能） |
| **Standard（标准）** | 100-500 行，或 6-10 个文件 | 基础 + 条件性专项 |
| **Deep（深度）** | 500+ 行，或 10+ 个文件，或涉及认证/支付/数据变更 | 基础 + 所有相关专项 + 对抗性检查 |

继续之前先声明深度。如果是 Quick，跳转到"我们构建了被要求的内容吗？"，执行标准单遍流程。如果是 Standard 或 Deep，完成标准流程后继续"专项审查"。

## 我们构建了被要求的内容吗？

读代码之前，检查范围偏移：
- 拉取最近的提交信息和任务文件
- diff 是否与声明目标一致？标记范围外的任何内容：不相关的文件、自行添加的内容、缺失的需求
- 打上标签：**on target（符合目标）** / **drift（偏移）** / **incomplete（不完整）**，记录但不阻塞

## 需要关注的内容

### 硬性停止（合并前必须修复）

以下内容没有商量余地：

- **破坏性自动执行**：任何被标记为"安全"或"自动运行"，却会修改用户可见状态（历史文件、配置文件、已存储的偏好、已安装软件、用户可检查的缓存条目）的任务，必须要求明确确认。"安全"意味着无副作用，而不是"可能无害"。如果一个任务删除或重写了用户可以看到的内容，默认不安全。
- **发布产物缺失**：带有空正文、缺少产物或未上传构建文件的 GitHub release 不算完成。在宣告完成之前，验证 release 模板中列出的每个产物都作为本地文件存在且已上传。
- **翻译文件命名冲突**：将文件放入语言特定目录（如 `_posts_en/`、`en/`）时，文件名不得重复语言后缀。先检查同目录已有文件的命名规范。
- **GitHub issue 或 PR 编号不匹配**：在评论、关闭或操作 GitHub issue 或 PR 之前，验证编号与本次会话中讨论的一致。不要依赖记忆。运行 `gh issue view N` 或 `gh pr view N` 确认标题匹配后再写入。
- **GitHub 评论风格**：PR 审查评论和 issue 回复必须简洁（1-2 句），读起来自然、友好。不要冗长，不要像报告，不要有 AI 腔调。如果一条评论需要超过 2 句话，应组织为列表，而不是段落。
- **注入与校验**：SQL、命令、路径注入；绕过系统入口校验的输入
- **共享状态**：未同步的写入、先检查后操作的竞态、缺少锁
- **外部信任**：来自 LLM、API 或用户输入的数据未经净化就送入命令或查询；凭据硬编码或写入日志
- **缺失 case**：枚举或 match 的完整性；对 diff 之外的同级值 grep 确认
- **diff 中的未知标识符**：diff 中引入的任何函数、方法、变量或类型名，如果在代码库中不存在，就是硬性停止。在编写或批准对某个标识符的引用之前，先 grep 搜索：`grep -r "identifier_name" .` — 如果 diff 之外没有结果，该标识符不存在。不要凭记忆假设名称正确。
- **依赖变更**：`package.json`、`Cargo.toml`、`go.mod` 或 `requirements.txt` 中意外新增或版本升级。标记任何 diff 明显不需要的新依赖。

### 软性信号（标记，不阻塞）

值得注意但不阻塞合并：

- 函数签名中不明显的副作用
- 应该命名为常量的魔法字面量
- 死代码、过时注释、与周围代码风格不一致
- 未覆盖测试的新路径
- 循环查询、缺少索引、无界增长

## 专项审查（仅 Standard 和 Deep）

加载 `references/persona-catalog.md` 确定哪些专项审查员对本次 diff 激活。

对每个激活的专项审查员：通过 Agent 工具启动，传入完整 diff 和 `agents/` 中对应的 agent 提示词。所有激活的专项审查员并行运行。

所有 agent 完成后，合并发现：
- 去重：如果两个专项审查员标记了相同的文件和行，保留更严重的发现并注明一致性
- 多位审查员对同一问题达成一致，提升其优先级

然后在呈现发现结果之前进入自动修复路由。

## 自动修复路由

对标准审查和专项审查的每个发现进行分类：

| 分类 | 定义 | 操作 |
|------|------|------|
| `safe_auto` | 明确、无风险：拼写错误、缺少 import、风格不一致 | 立即应用 |
| `gated_auto` | 可能正确但会改变行为：新路径的空值检查、新增错误处理 | 批量放入一个 AskUserQuestion |
| `manual` | 需要判断：架构、行为变更、安全权衡 | 在 sign-off 中呈现 |
| `advisory` | 仅供参考，无需代码变更 | 在 sign-off 中注明 |

在呈现任何内容之前，先应用所有 `safe_auto` 修复。将所有 `gated_auto` 项批量放入一次确认块。不要逐条单独询问。

## 对抗性检查（仅 Deep）

所有发现收集完成后，运行一次专注的对抗性检查。问题："如果我要通过这个具体的 diff 攻破这个系统，我会利用什么？"

四个检查角度（细节见 `references/persona-catalog.md`）：
1. **假设违反** — 这段代码假设什么始终成立？不成立时会发生什么？
2. **组合失败** — 这段新代码与系统其余部分并发运行时，什么会出问题？
3. **级联构造** — 什么样的有效操作序列会导致无效状态？
4. **滥用案例** — 第 1000 个请求、部署期间，或并发变更时会发生什么？

置信度低于 0.60 的对抗性发现不予提交。只提交有具体场景的发现。

## 如何处理发现

当正确答案无歧义时直接修复：明确的 bug、崩溃路径的空值检查、与周围代码一致的风格问题、简单的测试补充。

将其他所有内容批量放入一次 AskUserQuestion，当修复涉及行为变更、架构选择，或"正确"取决于意图时：

```
[N 项需要决策]

1. [硬性停止 / 信号] 问题：... 建议修复：... 保留 / 跳过？
2. ...
```

## GitHub 操作

所有 GitHub 交互使用 `gh` CLI。如果未安装 `gh`，运行 `brew install gh && gh auth login`（或引导用户完成其平台的安装）。

```bash
# 评论或关闭 issue 之前，验证编号
gh issue view 123 --json title,state --jq '.title'

# 合并前检查 CI 状态
gh pr checks

# 创建带结构化正文的 PR
gh pr create --title "..." --body "..."

# 审查 PR diff
gh pr diff 123

# 留下评论（保持 1-2 句，自然语气）
gh pr comment 123 --body "Looks good, one small fix applied."
```

当 `gh` 可以完成同样操作时，不要使用 GitHub MCP 或原始 API。`gh` 能干净地处理认证、分页和错误信息。

## 判断质量

除了正确性，还要问三个资深审查员会问的问题：

- **问题对了吗？** diff 解决的是真正需要的问题，还是略有偏差的版本？对错误问题给出技术正确的答案，是带了额外步骤的 bug。
- **方法成熟吗？** 实现是否符合该代码库和语言的惯用法，还是引入了会让下一个人困惑的模式？只有自己能维护的聪明代码是负债。
- **边界情况诚实吗？** 代码是否明确处理了失败模式和边界条件，还是在正常路径静默成功、在其他路径静默损坏？检查 nil、空值、零值、并发访问和上游失败时会发生什么。

这些不会单独阻塞合并，但任何一项答案为否都值得明确标记。

## 回归覆盖

对每条新代码路径：追踪它，检查是否有测试覆盖。如果这次变更修复了 bug，在宣告完成之前必须存在一个在旧代码上失败的测试。

## 验证

应用所有修复后，通过 `CLAUDE_SKILL_DIR` 运行本技能的 `scripts/run-tests.sh`，或项目的已知验证命令：

```bash
bash "$CLAUDE_SKILL_DIR/scripts/run-tests.sh"
```

如果未能自动检测，在继续之前询问用户验证命令。

粘贴完整输出。报告确切数字。完成的含义是：命令在本次会话中运行且通过。

如果不存在验证命令或命令失败：停止。不得宣告完成。继续之前询问用户如何验证。

如果在推理中出现以下任何短语，停下来先运行验证命令再继续：

- "should work now" / "should be fine"
- "probably correct" / "probably fixed"
- "seems to be working" / "appears to work"
- "I'm confident" / "clearly fixed"
- "trivial change, no need to verify"

这些是自我合理化，不是证据。验证已运行且通过 = 完成。其他情况 = 未完成。

## 常见陷阱

来自历史会话的真实失败，按频率排序：

- **评论了错误的 issue。** 在讨论 #255 时却评论了 #249。在评论或关闭之前，运行 `gh issue view N` 或 `gh pr view N` 确认标题。
- **PR 评论读起来像报告。** 用户不得不多次迭代评论语气。GitHub 评论应该是 1-2 句，自然，像同事之间，而不是结构化的审查输出。
- **上传产物之前就宣告 release 完成。** 推送了 GitHub release 但没有附上 .dmg/.zip/.sha256。验证 release 模板中列出的每个产物都作为本地文件存在且已上传。
- **语言后缀重复。** 将 `article.en.md` 放入 `_posts_en/`，生成了重复 URL。先检查目标目录中已有文件的命名规范。
- **跳过了"简单"变更的验证。** "只是一行修改"正是简单变更出问题的原因。有跳过的冲动时，仍然运行 `scripts/run-tests.sh`。
- **未设置环境变量就部署。** 推送到 Vercel 时 API 密钥只存在于本地 `.env.local`，每次请求都返回 401。部署前运行 `vercel env ls` 或等效命令，与本地密钥对比。
- **认证不匹配导致 git push 失败。** 两次推送失败后才发现远程是 HTTPS 但本地期望 SSH。在新项目中第一次推送之前，运行 `git remote -v` 并验证认证方式。

## Sign-off

```
files changed:    N (+X -Y)
scope:            on target / drift: [what]
review depth:     quick / standard / deep
hard stops:       N found, N fixed, N deferred
signals:          N noted
specialists:      [security, architecture] or none
new tests:        N
verification:     [command] -> pass / fail
```
