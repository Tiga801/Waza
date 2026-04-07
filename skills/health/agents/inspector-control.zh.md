仅使用粘贴的数据。不要读取文件。

[粘贴 Step 1 输出章节：settings.local.json、GITIGNORE、CLAUDE.md（全局）、CLAUDE.md（本地）、hooks、MCP FILESYSTEM、MCP ACCESS DENIALS、allowedTools count、skill 描述、CONVERSATION EXTRACT]

层级：[SIMPLE / STANDARD / COMPLEX]。仅应用对应层级的规则。

## Part A: 控制 + 验证层

Hooks 检查：
- SIMPLE: Hooks 为可选项。仅标记损坏的 hooks，例如错误的文件类型。
- STANDARD+: 项目主要语言应有 PostToolUse hooks。
- COMPLEX: 所有在对话中频繁编辑的文件类型均应有 hooks。
- ALL: 如果 hooks 存在，验证 schema：
  - 每个条目需要 `matcher` 和一个 `hooks` 数组
  - 每个 hook 需要 `type: "command"` 和 `command`
  - 文件路径可通过 `$CLAUDE_TOOL_INPUT_FILE_PATH` 获取
  - 缺少 `matcher` 会触发所有工具调用
- ALL: 标记每次编辑都运行完整测试套件的情况，对即时反馈应优先使用快速检查。
- ALL: 标记没有输出截断的命令，无边界输出会淹没上下文。
- ALL: 标记没有明确失败反馈的命令。

allowedTools 卫生，ALL：
- 仅标记真正危险的操作：sudo *、根路径强制删除、*>* 和 git push --force origin main
- 不要标记：路径硬编码命令、调试/测试命令、brew/launchctl/维护命令，这些都是正常的个人工作流条目

凭证暴露，ALL：
- 项目作用域的密钥仅在已提交、共享或存储于未 gitignore 的项目文件中时才标记 [!]
- 将 GITIGNORE 章节中的 `ignored only by non-project rule (...)` 视为不充分；建议添加仓库本地 ignore 规则。
- 不要仅因为凭证有意存储在 `~/.mcp.json` 等用户作用域文件中就标记它们

MCP 配置，STANDARD+：
- 检查 enabledMcpjsonServers 数量，>6 个可能影响性能
- 检查 filesystem MCP 是否配置了 allowedDirectories
- 如果 `~/.claude/projects/.../tool-results/*` 拒绝访问显示出现问题，输出一个追加最小缺失路径的 `python3` 单行命令

模型名称验证，ALL：
- 检查 settings.local.json 中的 `model` 字段。有效的模型 ID 遵循 `claude-*` 模式（如 `claude-opus-4-6`、`claude-sonnet-4-6`、`claude-haiku-4-5-20251001`）。任何非 `claude-*` 的模型 ID（如第三方别名或过时名称）都标记 [!]，错误的模型名称会静默浪费整个会话且无任何输出。
- 如果模型名称看起来像第三方别名或包含非常规字符，标记以供人工验证。

提示缓存卫生，ALL：
- 检查 CLAUDE.md 或 hooks 中系统上下文是否包含动态时间戳/日期，这会破坏提示缓存
- 检查 hooks 或 skills 是否以非确定性方式重排工具定义
- 标记会话中途模型切换，如 Opus→Haiku→Opus，这会重建缓存且可能更昂贵
- 如果检测到模型切换，建议改用子代理

三层防御一致性，STANDARD+：
- 对 CLAUDE.md NEVER/ALWAYS 条目中的每条关键规则，检查是否满足：
  1. CLAUDE.md 声明了规则：意图层
  2. Skill 教授了该规则的方法/工作流：知识层
  3. Hook 确定性地强制执行：控制层
- 标记仅存在于单层的规则，单层规则是脆弱的：
  - 仅 CLAUDE.md 的规则：Claude 在上下文压力下可能忽略
  - 仅 Hook 的规则：无边缘情况灵活性，无教学
  - 仅 Skill 的规则：无强制执行，无持续感知
- 优先关注安全关键规则：文件保护、测试要求、部署门控

验证检查：
- SIMPLE: 不需要正式的验证章节。仅在 Claude 未运行任何检查就声明完成时标记。
- STANDARD+: CLAUDE.md 应有包含每任务完成条件的 Verification 章节。
- COMPLEX: 对话中的每种任务类型都应映射到一个验证命令或 skill。

子代理卫生，STANDARD+：
- 标记 hooks 中缺少明确工具限制或隔离模式的 Agent 工具调用。
- 标记 hooks 中没有输出格式约束的子代理提示，自由格式输出会污染父上下文。

## Part B: 行为模式审计

数据来源：最近 3 个对话文件。仅标记明确证据。对每项发现标记 [HIGH CONFIDENCE] 或 [LOW CONFIDENCE]。

1. 规则违反：引用 NEVER/ALWAYS 规则和观察到的违规。不做推断。
2. 重复纠正：在至少 2 个对话中多次纠正同一问题。
3. 缺失的本地模式：在对话中反复强化但本地 CLAUDE.md 中缺失的项目特定行为。
4. 缺失的全局模式：`~/.claude/CLAUDE.md` 中缺失的跨项目行为。
5. Skill 频率，STANDARD+：仅报告直接观察到的使用情况。少于 3 个会话时标记 [INSUFFICIENT DATA]。对于已验证的每月 <1 次 skills，退役到 AGENTS.md 文档。
6. 反模式：仅标记可直接观察的情况：
   - Claude 未运行验证就声明完成
   - 用户跨会话重复解释相同上下文，缺少 HANDOFF.md 或 memory
   - 超过 20 轮的长会话未使用 /compact 或 /clear

输出：仅使用项目符号，两个章节：
[CONTROL LAYER: hooks 问题 | 待移除的 allowedTools | 缓存卫生 | 三层缺口 | 验证缺口 | 子代理问题]
[BEHAVIOR: 规则违反 | 重复纠正 | 待添加到本地 CLAUDE.md | 待添加到全局 CLAUDE.md | skill 频率 | 反模式（每项标注置信度）]
