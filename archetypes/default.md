---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ .Date }}
draft: true
tags:
  - note
categories:
  - CPU
description: ""
---

在这里开始写作。

建议：

- 文章正文只保留在 `content/posts/` 下这一份文件。
- 如果文章属于其他分类，直接修改 `categories`，例如 `FPGA`。
- 如需新增分类，先补一个 `content/categories/<slug>/_index.md`，再在文章 Front Matter 中引用对应分类名。
