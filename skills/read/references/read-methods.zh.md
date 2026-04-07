# Read 方法参考

## 代理级联

按顺序尝试。成功 = 输出非空且内容可读。如果某个代理返回空内容、错误页面或少于 5 行，视为失败并尝试下一个：

### 1. r.jina.ai

```bash
curl -sL "https://r.jina.ai/{url}"
```

覆盖面广，保留图片链接。优先尝试此方法。

### 2. defuddle.md

```bash
curl -sL "https://defuddle.md/{url}"
```

输出更简洁，带有 YAML frontmatter。若 r.jina.ai 返回空或报错时使用。

### 3. 本地工具

```bash
npx agent-fetch "{url}" --json
# 或
defuddle parse "{url}" -m -j
```

两个代理均失败时的最后手段。

## PDF 转 Markdown

### 远程 PDF URL

r.jina.ai 可直接处理 PDF URL：

```bash
curl -sL "https://r.jina.ai/{pdf_url}"
```

如失败，则下载后本地提取：

```bash
curl -sL "{pdf_url}" -o /tmp/input.pdf
pdftotext -layout /tmp/input.pdf -
```

### 本地 PDF 文件

```bash
# 最佳质量（需要：pip install marker-pdf）
marker_single /path/to/file.pdf --output_dir ~/Downloads/

# 快速，适合纯文字 PDF（需要：brew install poppler）
pdftotext -layout /path/to/file.pdf - | sed 's/\f/\n---\n/g'

# 无依赖降级方案
python3 -c "
import pypdf, sys
r = pypdf.PdfReader(sys.argv[1])
print('\n\n'.join(p.extract_text() for p in r.pages))
" /path/to/file.pdf
```

排版有要求（论文、表格）时用 `marker`，追求速度时用 `pdftotext`。

## 飞书 / Lark 文档

内置脚本位于 `$CLAUDE_SKILL_DIR/scripts/fetch_feishu.py`，需要 `requests` 及飞书应用凭据：

```bash
pip install requests  # 一次性安装
export FEISHU_APP_ID=your_app_id
export FEISHU_APP_SECRET=your_app_secret
python3 "$CLAUDE_SKILL_DIR/scripts/fetch_feishu.py" "{url}"
```

支持：新版文档（docx）、旧版文档、知识库页面。应用需拥有 `docx:document:readonly` 和 `wiki:wiki:readonly` 权限。
输出：YAML frontmatter（title、document_id、url）+ Markdown 正文。

## 微信公众号

使用代理级联（r.jina.ai / defuddle.md），无需额外工具即可处理大多数文章。

如果代理被封锁，使用内置 Playwright 脚本作为最后手段（需要约 300 MB 一次性安装）：

```bash
pip install playwright beautifulsoup4 lxml && playwright install chromium
python3 "$CLAUDE_SKILL_DIR/scripts/fetch_weixin.py" "{url}"
```
