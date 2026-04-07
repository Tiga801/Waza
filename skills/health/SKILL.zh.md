---
name: health
version: 3.0.0
description: 当 Claude 忽略指令、行为不一致、钩子异常或需要审计 MCP 服务器时调用。审计完整的六层配置栈并按严重程度标记问题。不用于调试代码或审查 PR。
allowed-tools:
  - Bash
  - Read
  - Agent
  - AskUserQuestion
---

# Claude Code 配置健康审计

使用六层框架审计当前项目的 Claude Code 配置：
`CLAUDE.md → rules → skills → hooks → subagents → verifiers`

目标是找出违规项并定位失调的层级，依据项目复杂度进行校准。

**输出语言：** 按顺序检查：(1) CLAUDE.md `## Communication` 规则（全局优先于本地）；(2) 用户最近对话消息的语言；(3) 默认英文。将检测到的语言应用于所有输出，包括进度行、报告和停止条件问题。

**重要：** 在第一次工具调用之前，以输出语言输出进度块：

```
Step 1/3: 收集配置数据 [1/10]
  · CLAUDE.md（全局 + 本地）· rules/ · settings.local.json · hooks
  · MCP 服务器 · skills 清单 + 安全扫描
  · 对话历史（最近 2 个会话）
```

## Step 0: 评估项目层级

选择层级：

| 层级 | 信号 | 预期配置 |
|------|------|----------|
| **Simple** | <500 个项目文件，1 名贡献者，无 CI | 仅 CLAUDE.md；0-1 个 skills；无 rules/；hooks 可选 |
| **Standard** | 500-5K 个项目文件，小团队或存在 CI | CLAUDE.md + 1-2 个 rules 文件；2-4 个 skills；基础 hooks |
| **Complex** | >5K 个项目文件，多贡献者，多语言，活跃 CI | 需要完整六层配置 |

**仅应用检测到的层级要求。**


## Step 1: 收集所有数据（单个 bash 块）

运行一个块收集数据。

```bash
P=$(pwd)
SETTINGS="$P/.claude/settings.local.json"

echo "[1/10] 层级指标..."
echo "=== TIER METRICS ==="
echo "project_files: $(git -C "$P" ls-files 2>/dev/null | wc -l || find "$P" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/dist/*" -not -path "*/build/*" | wc -l)"
echo "contributors: $(git -C "$P" log -n 500 --format='%ae' 2>/dev/null | sort -u | wc -l)"
echo "ci_workflows:  $(ls "$P/.github/workflows/"*.yml "$P/.github/workflows/"*.yaml 2>/dev/null | wc -l)"
echo "skills:        $(find "$P/.claude/skills" -name "SKILL.md" 2>/dev/null | grep -v '/health/SKILL.md' | wc -l)"
echo "claude_md_lines: $(wc -l < "$P/CLAUDE.md" 2>/dev/null)"

echo "[2/10] CLAUDE.md（全局 + 本地）..."
echo "=== CLAUDE.md (global) ===" ; cat ~/.claude/CLAUDE.md 2>/dev/null || echo "(none)"
echo "=== CLAUDE.md (local) ===" ; cat "$P/CLAUDE.md" 2>/dev/null || echo "(none)"

echo "[3/10] Settings、hooks、MCP..."
echo "=== settings.local.json ===" ; cat "$SETTINGS" 2>/dev/null || echo "(none)"

echo "[4/10] Rules + skill 描述..."
echo "=== rules/ ===" ; find "$P/.claude/rules" -name "*.md" 2>/dev/null | while IFS= read -r f; do echo "--- $f ---"; cat "$f"; done
echo "=== skill descriptions ===" ; { [ -d "$P/.claude/skills" ] && grep -r "^description:" "$P/.claude/skills" 2>/dev/null; grep -r "^description:" ~/.claude/skills 2>/dev/null; } | sort -u

echo "[5/10] 上下文预算估算..."
echo "=== STARTUP CONTEXT ESTIMATE ==="
echo "global_claude_words: $(wc -w < ~/.claude/CLAUDE.md 2>/dev/null | tr -d ' ' || echo 0)"
echo "local_claude_words: $(wc -w < "$P/CLAUDE.md" 2>/dev/null | tr -d ' ' || echo 0)"
echo "rules_words: $(find "$P/.claude/rules" -name "*.md" 2>/dev/null | while IFS= read -r f; do cat "$f"; done | wc -w | tr -d ' ')"
echo "skill_desc_words: $({ [ -d "$P/.claude/skills" ] && grep -r "^description:" "$P/.claude/skills" 2>/dev/null; grep -r "^description:" ~/.claude/skills 2>/dev/null; } | wc -w | tr -d ' ')"
python3 -c "
import json, sys
try:
    d = json.load(open('$SETTINGS'))
except Exception as e:
    msg = '(unavailable: settings.local.json missing or malformed)'
    print('=== hooks ==='); print(msg)
    print('=== MCP ==='); print(msg)
    print('=== MCP FILESYSTEM ==='); print(msg)
    print('=== allowedTools count ==='); print(msg)
    sys.exit(0)

print('=== hooks ===')
print(json.dumps(d.get('hooks', {}), indent=2))

print('=== MCP ===')
s = d.get('mcpServers', d.get('enabledMcpjsonServers', {}))
names = list(s.keys()) if isinstance(s, dict) else list(s)
n = len(names)
print(f'servers({n}):', ', '.join(names))
est = n * 25 * 200
print(f'est_tokens: ~{est} ({round(est/2000)}% of 200K)')

print('=== MCP FILESYSTEM ===')
if isinstance(s, list):
    print('filesystem_present: (array format -- check .mcp.json)')
    print('allowedDirectories: (not detectable)')
else:
    fs = s.get('filesystem') if isinstance(s, dict) else None; a = []
    if isinstance(fs, dict):
        a = fs.get('allowedDirectories') or (fs.get('config', {}).get('allowedDirectories') if isinstance(fs.get('config'), dict) else [])
        if not a and isinstance(fs.get('args'), list):
            args = fs['args']
            for i, v in enumerate(args):
                if v in ('--allowed-directories', '--allowedDirectories') and i+1 < len(args): a = [args[i+1]]; break
            if not a: a = [v for v in args if v.startswith('/') or (v.startswith('~') and len(v) > 1)]
    print('filesystem_present:', 'yes' if fs else 'no')
    print('allowedDirectories:', a or '(missing or not detected)')

print('=== allowedTools count ===')
print(len(d.get('permissions', {}).get('allow', [])))
" 2>/dev/null || echo "(unavailable)"
echo "[6/10] 嵌套 CLAUDE.md + gitignore..."
echo "=== NESTED CLAUDE.md ===" ; find "$P" -maxdepth 4 -name "CLAUDE.md" -not -path "$P/CLAUDE.md" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null || echo "(none)"
echo "=== GITIGNORE ==="
_GITIGNORE_HIT=$(git -C "$P" check-ignore -v .claude/settings.local.json 2>/dev/null || true)
if [ -n "$_GITIGNORE_HIT" ]; then
  _GITIGNORE_SOURCE=${_GITIGNORE_HIT%%:*}
  case "$_GITIGNORE_SOURCE" in
    .gitignore|.claude/.gitignore)
      echo "settings.local.json: gitignored"
      ;;
    *)
      echo "settings.local.json: ignored only by non-project rule ($_GITIGNORE_SOURCE) -- add a repo-local ignore rule"
      ;;
  esac
else
  echo "settings.local.json: NOT gitignored -- risk of committing tokens/credentials"
fi
echo "[7/10] HANDOFF.md + MEMORY.md..."
echo "=== HANDOFF.md ===" ; cat "$P/HANDOFF.md" 2>/dev/null || echo "(none)"
echo "=== MEMORY.md ===" ; cat "$HOME/.claude/projects/-$(pwd | sed 's|[/_]|-|g; s|^-||')/memory/MEMORY.md" 2>/dev/null | head -50 || echo "(none)"

echo "[8/10] 对话提取（最近 2 个会话）..."
echo "=== CONVERSATION FILES ==="
PROJECT_PATH=$(pwd | sed 's|[/_]|-|g; s|^-||')
CONVO_DIR=~/.claude/projects/-${PROJECT_PATH}
ls -lhS "$CONVO_DIR"/*.jsonl 2>/dev/null | head -10

echo "=== CONVERSATION EXTRACT (up to 2 most recent, confidence improves with more files) ==="
# 跳过当前活跃会话，它可能尚未完整。
_PREV_FILES=$(ls -t "$CONVO_DIR"/*.jsonl 2>/dev/null | tail -n +2 | head -2)
if [ -n "$_PREV_FILES" ]; then
  echo "$_PREV_FILES" | while IFS= read -r F; do
    [ -f "$F" ] || continue
    echo "--- file: $F ---"
    head -c 512000 "$F" | jq -r '
      if .type == "user" then "USER: " + ((.message.content // "") | if type == "array" then map(select(.type == "text") | .text) | join(" ") else . end)
      elif .type == "assistant" then
        "ASSISTANT: " + ((.message.content // []) | map(select(.type == "text") | .text) | join("\n"))
      else empty
      end
    ' 2>/dev/null | grep -v "^ASSISTANT: $" | head -150 || echo "(unavailable: jq not installed or parse error)"
  done
else
  echo "(no conversation files)"
fi

echo "=== MCP ACCESS DENIALS ==="
ls -t "$CONVO_DIR"/*.jsonl 2>/dev/null | head -5 | while IFS= read -r F; do
  head -c 1048576 "$F" | grep -Em 2 'Access denied - path outside allowed directories|tool-results/.+ not in ' 2>/dev/null
done | head -20

# --- Skill 扫描 ---
# 通过 frontmatter name 字段排除自身，在不同安装路径下保持稳定。
SELF_SKILL=$( (grep -rl '^name: health$' "$P/.claude/skills" "$HOME/.claude/skills" 2>/dev/null || true) | grep 'SKILL.md' | head -1)
[ -z "$SELF_SKILL" ] && SELF_SKILL="health/SKILL.md"

echo "[9/10] Skill 清单 + frontmatter + 来源..."
echo "=== SKILL INVENTORY ==="
for DIR in "$P/.claude/skills" "$HOME/.claude/skills"; do
  [ -d "$DIR" ] || continue
  find -L "$DIR" -maxdepth 4 -name "SKILL.md" 2>/dev/null | grep -v "$SELF_SKILL" | while IFS= read -r f; do
    WORDS=$(wc -w < "$f" | tr -d ' ')
    IS_LINK="no"; LINK_TARGET=""
    SKILL_DIR=$(dirname "$f")
    if [ -L "$SKILL_DIR" ]; then
      IS_LINK="yes"; LINK_TARGET=$(readlink -f "$SKILL_DIR")
    fi
    echo "path=$f words=$WORDS symlink=$IS_LINK target=$LINK_TARGET"
  done
done

echo "=== SKILL FRONTMATTER ==="
for DIR in "$P/.claude/skills" "$HOME/.claude/skills"; do
  [ -d "$DIR" ] || continue
  find -L "$DIR" -maxdepth 4 -name "SKILL.md" 2>/dev/null | grep -v "$SELF_SKILL" | while IFS= read -r f; do
    if head -1 "$f" | grep -q '^---'; then
      echo "frontmatter=yes path=$f"
      sed -n '2,/^---$/p' "$f" | head -10
    else
      echo "frontmatter=MISSING path=$f"
    fi
  done
done

echo "=== SKILL SYMLINK PROVENANCE ==="
for DIR in "$P/.claude/skills" "$HOME/.claude/skills"; do
  [ -d "$DIR" ] || continue
  find "$DIR" -maxdepth 1 -type l 2>/dev/null | while IFS= read -r link; do
    TARGET=$(readlink -f "$link")
    echo "link=$(basename "$link") target=$TARGET"
    GIT_ROOT=$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ -n "$GIT_ROOT" ]; then
      REMOTE=$(git -C "$GIT_ROOT" remote get-url origin 2>/dev/null || echo "unknown")
      COMMIT=$(git -C "$GIT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
      echo "  git_remote=$REMOTE commit=$COMMIT"
    fi
  done
done

echo "[10/10] Skill 内容样本 + 安全扫描..."
echo "=== SKILL FULL CONTENT (sample: up to 3 skills, 60 lines each) ==="
{ for DIR in "$P/.claude/skills" "$HOME/.claude/skills"; do
    [ -d "$DIR" ] || continue
    find -L "$DIR" -maxdepth 4 -name "SKILL.md" 2>/dev/null | grep -v "$SELF_SKILL"
  done
} | head -3 | while IFS= read -r f; do
  echo "--- FULL: $f ---"
  head -60 "$f"
done
```

## Step 1b: MCP 在线检测

bash 块完成后，对 settings 中列出的每个 MCP 服务器尝试调用并验证其是否实际响应。在启动分析代理之前执行此步骤。

对 Step 1 中找到的每个服务器名称：
1. 尝试列出其可用工具（例如调用该服务器的 `list_tools` 或其他已知轻量工具）。
2. 调用成功则标记 `live=yes`。
3. 调用失败或超时则标记 `live=no`，记录错误信息。

将结果记录为表格：

```
MCP Live Status:
  server_name    live=yes  (N tools available)
  other_server   live=no   error: connection refused / tool not found / API key invalid
```

将此表格传递给 Agent 1，纳入 MCP 发现章节。

**如果需要 API 密钥**：在服务器配置中查找相关环境变量名（如 `XCRAWL_API_KEY`、`OPENAI_API_KEY`）。不要验证密钥值本身，只记录该环境变量是否已设置：`echo $VAR_NAME | head -c 5`（仅 5 个字符，不要打印完整密钥）。

## 注意事项

在解读 Step 1 输出之前，检查以下已知的失败模式。

**数据收集静默失败**
- `jq` 未安装：对话提取打印 `(unavailable: jq not installed or parse error)`。BEHAVIOR 章节将为空，视为 [INSUFFICIENT DATA]，而非发现项。
- `python3` 不在 PATH：所有 MCP/hooks/allowedTools 章节打印 `(unavailable)`。当数据源本身失败时，不要标记这些区域。
- `settings.local.json` 不存在：hooks、MCP 和 allowedTools 均显示 `(unavailable)`。这对于仅使用全局 settings 的项目是正常现象，不是配置错误。

**MEMORY.md 路径构建**
- 路径通过对 `pwd` 执行 `sed 's|[/_]|-|g'` 构建。非常规字符会产生错误的项目键。如果 MEMORY.md 显示 `(none)` 但用户提到了以前的会话，请在标记 [!] 之前手动验证路径。

**对话提取范围**
- 仅采样最近 2 个 `.jsonl` 文件，跳过当前活跃会话。少于 2 个文件的发现信号较低，始终标记 [LOW CONFIDENCE]。

**MCP token 估算**
- 假设每个服务器约 25 个工具，每个工具约 200 个 token。工具数量过多或过少的服务器会导致较大的高估/低估。视为方向性参考，非精确值。

**层级误判边缘情况**
- bash 块排除了 `node_modules/`、`dist/` 和 `build/`，但并非所有生成目录。包含 `.next/`、`__pycache__/` 或 `.turbo/` 输出的 Monorepo 可能导致文件数虚高，误触发 COMPLEX 层级。如果层级判断感觉不对，请手动复核。

## Step 2: 按层级调整深度进行分析

Step 1 完成后，输出数据摘要行、层级行和步骤指示器：

```
Data collected: {X} CLAUDE.md words · {Y} rules words · {Z} skills found · {N} conversation files sampled
Tier: {SIMPLE/STANDARD/COMPLEX} -- {file_count} files · {contributor_count} contributors · CI: {present/absent}
Step 2/3: {SIMPLE: "本地分析中" | STANDARD/COMPLEX: "启动并行分析代理"}
```

SIMPLE：在上方输出"本地分析中"。不要启动子代理。从 Step 1 进行分析，优先检查核心配置，除非有明显证据否则跳过对话重度交叉验证。

STANDARD/COMPLEX：在上方输出"启动并行分析代理"，然后列出包含检查数的覆盖范围：

```
  · Agent 1: CLAUDE.md (6 checks) · rules (2) · skills (5) · MCP (3) · security (6)
  · Agent 2: hooks (5 checks) · allowedTools (2) · behavior (6) · three-layer defense (3)
```

并行启动**两个子代理**。将所有数据内联粘贴，不要传递文件路径。粘贴前，将所有凭证值（API 密钥、token、密码）替换为 `[REDACTED]`，仅粘贴结构性数据。

**备用方案：** 如果任一子代理失败（API 错误、超时或空结果），不要中止。改为从 Step 1 数据在本地分析该层，并在报告受影响章节中注明"(analyzed locally -- subagent unavailable)"。

### Agent 1 -- 上下文 + 安全审计（无需对话数据）

从此 skill 目录读取 `agents/inspector-context.md`。其中说明了需要粘贴的 Step 1 章节和完整审计清单。

### Agent 2 -- 控制 + 行为审计（使用对话证据）

从此 skill 目录读取 `agents/inspector-control.md`。其中说明了需要粘贴的 Step 1 章节和完整审计清单。

## Step 3: 综合并呈现

在撰写报告之前，以输出语言输出进度行：

```
Step 3/3: 综合报告中
```

将本地分析和所有代理输出整合为一份报告：

---

**健康报告：{project}（{tier} 层级，{file_count} 个文件）**

### [PASS] 通过项

以紧凑表格呈现已通过的检查项。仅包含与检测到的层级相关的检查。最多 5 行。有发现项的检查不在此列出。

| 检查项 | 详情 |
|--------|------|
| settings.local.json 已 gitignore | ok |
| 无嵌套 CLAUDE.md | ok |
| Skill 安全扫描 | 无标记 |

### [!] 严重 -- 立即修复

违反的规则、缺失的验证定义、危险的 allowedTools、MCP 开销 >12.5%、必要路径 `Access denied`、活跃的缓存破坏者，以及安全发现项。

### [~] 结构性 -- 尽快修复

属于其他位置的 CLAUDE.md 内容、缺失的 hooks、过大的 skill 描述、单层关键规则、模型切换、验证器缺口、子代理权限缺口，以及 skill 结构问题。

### [-] 渐进式 -- 锦上添花

待添加的新模式、待删除的过时项、全局与本地的放置优化、上下文卫生、HANDOFF.md 采用、skill 调用调优，以及来源问题。

---

如果三个问题章节均为空，以输出语言输出一行简短说明，如：`所有相关检查均已通过。无需修复。`

## 非目标
- 未经确认，绝不自动应用修复。
- 不对简单项目应用复杂层级检查。
- 标记问题，而非替代架构判断。


**停止条件：** 报告完成后，以输出语言提问：
> "需要我起草变更方案吗？我可以分层处理：全局 CLAUDE.md / 本地 CLAUDE.md / rules / hooks / skills / MCP。"

未经明确确认，不做任何编辑。
