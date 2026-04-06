# Waza

Personal skill collection for Claude Code. Nine skills covering the complete engineering workflow: think, design, check, hunt, write, learn, read, english, health.

## Communication

- Do not use em dashes (U+2014) in any output. Use commas, periods, colons, or semicolons instead.
- This applies to all skill templates, report examples, progress lines, and any example output embedded in skill files.

## Structure

```
skills/
├── check/        -- code review before merging
├── design/       -- production-grade frontend UI
├── health/       -- Claude Code config audit
│   └── agents/   -- agent1-context.md, agent2-control.md
├── hunt/         -- systematic debugging
├── learn/        -- research to published output
├── read/         -- fetch URL or PDF as Markdown
├── think/        -- design and validate before building
└── write/        -- natural prose in Chinese and English
    └── references/  -- write-zh.md, write-en.md
.claude-plugin/
└── marketplace.json  -- plugin registry for npx distribution
install.sh            -- symlink installer
```

Each skill has a `SKILL.md` (loaded on demand) and a `README.md` (quick reference for humans).

## Verification

```bash
# All SKILL.md files have valid frontmatter
for f in skills/*/SKILL.md; do head -5 "$f" | grep -q "^name:" && echo "ok: $f" || echo "MISSING name: $f"; done

# Version consistency: SKILL.md must match marketplace.json
for skill in check design english health hunt learn read think write; do
  skill_ver=$(grep "^version:" "skills/$skill/SKILL.md" | awk '{print $2}')
  market_ver=$(python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); print([p['version'] for p in d['plugins'] if p['name']=='$skill'][0])")
  [ "$skill_ver" = "$market_ver" ] && echo "ok: $skill $skill_ver" || echo "MISMATCH: $skill SKILL=$skill_ver MARKET=$market_ver"
done

# Reference files exist for skills that use them
test -f skills/english/references/english-phrases.md && \
test -f skills/design/references/design-reference.md && \
test -f skills/read/references/read-methods.md && \
test -f skills/write/references/write-zh.md && \
test -f skills/write/references/write-en.md && \
test -f skills/health/agents/agent1-context.md && \
test -f skills/health/agents/agent2-control.md && echo "references: ok"

# marketplace.json is valid JSON
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))" && echo "marketplace.json: ok"
```

## Commit Convention

`{type}: {description}` -- types: feat, fix, refactor, docs, chore

## Release Convention (tw93/miaoyan style)

- Title: `V{version} {Codename} {emoji}` -- e.g., V1.3.0 Guardian
- Tag: `v{version}` (lowercase v)
- Body: HTML format, bilingual (English Changelog + 中文更新日志), one-to-one
- Each item: `<li><strong>Category</strong>: description.</li>` -- bold label summarizes the change, description is one concise sentence, no filler words
- Style: engineer-facing, no marketing language; lead with what changed, not why it matters
- Footer: update command `npx skills add tw93/Waza@latest` + star + repo link
