---
name: read
description: 当收到任何 URL、网页链接或 PDF 时调用。通过代理级联将内容抓取为简洁的 Markdown 并保存到 Downloads。不适用于仓库中已有的本地文件。
version: 3.0.0
allowed-tools:
  - Bash
  - Read
  - Write
---

# Read：将任意 URL 或 PDF 转为 Markdown

将任意 URL 或本地 PDF 转换为简洁的 Markdown 并保存。

## 路由

| 输入 | 方法 |
|------|------|
| `feishu.cn`、`larksuite.com` | 飞书 API 脚本 |
| `.pdf` URL 或本地 PDF 路径 | PDF 提取 |
| 其他所有内容 | 运行 `scripts/fetch.sh {url}`（代理级联，自动降级） |

路由完成后，加载 `references/read-methods.md` 获取所选方法的具体命令，然后执行。

## 输出格式

```
Title:  {标题}
Author: {作者}（如有）
Source: {平台}
URL:    {原始 URL}

Summary
{3-5 句摘要}

Content
{完整 Markdown，超长时截断至 200 行}
```

## 保存

默认保存到 `~/Downloads/{title}.md`，并带有 YAML frontmatter。
仅当用户说"只预览"或"不要保存"时跳过。告知用户保存路径。

保存并报告路径后停止。除非被问到，否则不分析、评论或讨论内容。如果内容在 200 行处被截断，说明截断情况并提议继续。

## 说明

- r.jina.ai 和 defuddle.md 无需 API 密钥
- 网络故障：如有本地代理环境变量，可在命令前添加
- 长内容：使用 `| head -n 200` 先预览
- GitHub URL：优先使用 `gh` CLI，而不是直接抓取
