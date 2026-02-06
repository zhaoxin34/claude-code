---
name: http-proxy
description: 当使用git、npm、uv、pip工具时，经常要访问非中国的网址，而我经常是从国内访问这些网址，所以使用代理会更快。
allowed-tools: Bash(export:*), Bash(unset:*)
---

# Enable the http proxy

## Instructions

```bash
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
```

# Disable the http proxy

使用完git、npm等工具后，需要关闭proxy

```bash
unset https_proxy http_proxy all_proxy

```
