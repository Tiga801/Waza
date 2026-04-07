# Waza

Claude Code 个人技能集合，包含八个技能，覆盖完整的工程工作流：think、design、check、hunt、write、learn、read、health。

## 通信规范

- 所有输出中不得使用全角破折号（U+2014），请改用逗号、句号、冒号或分号。
- 该规范适用于所有技能模板、报告示例、进度行，以及技能文件中嵌入的任何示例输出。

## 目录结构

```
skills/
├── check/        -- 合并前的代码审查
│   ├── agents/   -- reviewer-security.md, reviewer-architecture.md
│   └── references/  -- persona-catalog.md
├── design/       -- 生产级前端 UI
├── health/       -- Claude Code 配置审计
│   └── agents/   -- inspector-context.md, inspector-control.md
├── hunt/         -- 系统化调试
├── learn/        -- 从研究到发布输出
├── read/         -- 将 URL 或 PDF 转为 Markdown
├── think/        -- 构建前的设计与验证
└── write/        -- 中英文自然散文写作
    └── references/  -- write-zh.md, write-en.md
.claude-plugin/
└── marketplace.json  -- npx 分发的插件注册表
install.sh            -- 符号链接安装脚本
```

每个技能均有一个 `SKILL.md`（由 Claude 按需加载），辅助内容存放于子目录中。

## 验证

```bash
# 所有 SKILL.md 文件具有有效的 frontmatter
for f in skills/*/SKILL.md; do head -5 "$f" | grep -q "^name:" && echo "ok: $f" || echo "MISSING name: $f"; done

# 版本一致性：SKILL.md 版本必须与 marketplace.json 一致
for skill in check design health hunt learn read think write; do
  skill_ver=$(grep "^version:" "skills/$skill/SKILL.md" | awk '{print $2}')
  market_ver=$(python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); print([p['version'] for p in d['plugins'] if p['name']=='$skill'][0])")
  [ "$skill_ver" = "$market_ver" ] && echo "ok: $skill $skill_ver" || echo "MISMATCH: $skill SKILL=$skill_ver MARKET=$market_ver"
done

# 验证依赖引用文件是否存在
test -f skills/design/references/design-reference.md && \
test -f skills/read/references/read-methods.md && \
test -f skills/write/references/write-zh.md && \
test -f skills/write/references/write-en.md && \
test -f skills/health/agents/inspector-context.md && \
test -f skills/health/agents/inspector-control.md && \
test -f skills/check/agents/reviewer-security.md && \
test -f skills/check/agents/reviewer-architecture.md && \
test -f skills/check/references/persona-catalog.md && echo "references: ok"

# marketplace.json 为有效 JSON
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))" && echo "marketplace.json: ok"
```

## 提交规范

`{type}: {description}` -- 类型：feat、fix、refactor、docs、chore

## 发布规范（tw93/miaoyan 风格）

- 标题：`V{version} {Codename} {emoji}` -- 例如：V1.3.0 Guardian
- 标签：`v{version}`（小写 v）
- 正文：HTML 格式，双语（English Changelog + 中文更新日志），一一对应
- 每条：`<li><strong>Category</strong>: description.</li>` -- 加粗标签概括变更内容，描述为一句简洁说明，不加冗余修饰
- 风格：面向工程师，无营销语言；以变更内容为先，不阐述原因
- 页脚：更新命令 `npx skills add tw63/Waza@latest` + star + 仓库链接
