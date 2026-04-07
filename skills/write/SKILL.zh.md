---
name: write
description: 仅当被明确要求用中文或英文撰写、编辑或润色散文时调用。去除 AI 写作模式，重写为自然语言。不适用于代码注释、提交信息或内联文档。
version: 3.0.0
disable-model-invocation: true
---

# 写作风格 / Writing Style

检测**被编辑文本**（不是用户的指令）的语言：
- 含中文字符 → 加载 `references/write-zh.md`
- 否则（英文、混合、不确定）→ load `references/write-en.md`

如果受众不明确（博客读者？RFC？邮件？），先问清楚再编辑。同一内容写给初级工程师和写给高级架构师，读起来应该完全不同。

执行顺序: 读取对应规则文件，严格按规则处理，输出修改后的内容。

输出修改后的内容后，停止。除非用户主动询问，否则不解释改动。
