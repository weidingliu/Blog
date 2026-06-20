# Blog

基于 Hugo 构建的个人博客原型仓库，按“内容、配置、自动化全部版本化”的方式组织，便于长期维护、迁移和审计。

## 原型覆盖范围

- 使用 Hugo 作为静态站点生成器，主题通过 Hugo Module 引入 `github.com/adityatelange/hugo-PaperMod`。
- 站点配置集中在 `config.yaml`，自定义资源放在 `assets/` 与 `static/`，不直接改动主题源码。
- 内容采用 Markdown 与 Front Matter，示例文章遵循 `content/posts/YYYY/MM-DD-slug.md` 命名规范。
- 提供 `Dockerfile`、`docker-compose.yml`、GitHub Pages 工作流、Dependabot 配置与迁移脚本。
- 代码采用 MIT 许可证，文章内容默认采用 CC BY-SA 4.0；文章页脚通过站点扩展模板统一声明。

## 目录约定

```text
.
├── .github/workflows/deploy.yml    # GitHub Pages 部署
├── archetypes/default.md           # 新文章模板
├── assets/css/extended/            # 站点自定义样式
├── config.yaml                     # Hugo 主配置
├── content/
│   ├── about/
│   └── posts/YYYY/MM-DD-slug.md
├── layouts/partials/extend_footer.html
├── scripts/migrate-markdown.sh     # 迁移脚本原型
├── static/images/                  # 统一静态图片目录
└── Dockerfile / docker-compose.yml
```

## 本地环境

### 方式一：直接安装 Hugo

优先使用系统包管理器安装 Hugo Extended，随后确认版本：

```bash
hugo version
```

常见安装方式：

```bash
# macOS (Homebrew)
brew install hugo

# Windows (Chocolatey)
choco install hugo-extended

# Ubuntu / Debian
sudo apt-get update
sudo apt-get install -y hugo

# Ubuntu / Debian（若系统仓库版本过旧，可退回 Snap）
sudo snap install hugo
```

说明：

- 当前仓库使用 Hugo Module 主题，CI 与容器环境会额外提供 Go 运行时以解析模块依赖。
- 如果本机未安装 Go，建议直接使用下方 Docker 方式，避免额外环境差异。
- 如果首次拉取 Hugo Module 遇到 TLS/HTTP2 不稳定，可临时设置 `GIT_HTTP_VERSION=HTTP/1.1` 再执行构建；仓库内的 Docker 与 CI 已默认带上该环境变量。
- 某些发行版的 `apt` 仓库 Hugo 版本可能偏旧；如果缺少 Extended 能力，优先切换到 Docker 或 Snap 方式，并保持 README 中记录的固定版本策略。

### 方式二：使用 Docker

仓库包含固定 Hugo 版本的容器配置，本地无需额外安装 Go：

```bash
cp .env.example .env
docker compose up preview
```

首次构建会拉取基础镜像与 Hugo Module 依赖。为了降低资源占用，当前容器仅包含 Hugo、Go、Git 与必要系统工具。

## 常用命令

### 本地预览

```bash
hugo server -D --disableFastRender
```

或使用容器：

```bash
docker compose up preview
```

### 生产构建

```bash
hugo --minify
```

输出目录为 `public/`，该目录已加入 `.gitignore`。

### 新建文章

```bash
hugo new content/posts/2026/06-20-my-post.md
```

### 批量迁移内容

```bash
./scripts/migrate-markdown.sh \
	--title "My Imported Post" \
	--date 2026-06-20 \
	--source /path/to/source.md
```

脚本会生成符合规范的目标文件，例如 `content/posts/2026/06-20-my-imported-post.md`。

## 主题与内容管理

- 主题依赖通过 `go.mod` / `go.sum` 锁定，不直接修改主题源码。
- 站点元信息、导航、社交链接与许可声明统一在 `config.yaml` 管理。
- 自定义样式放在 `assets/css/extended/`，静态图片放在 `static/images/`。
- 文章内容与样式分离，更换主题时只需调整配置与少量扩展模板。

## 自动化与部署

### Git 与忽略规则

- 仓库是博客的单一事实来源。
- 需要提交的内容包括配置、内容、脚本、工作流与许可文件。
- 已忽略：`public/`、`_vendor/`、`.env`、系统临时文件与编辑器缓存。

### GitHub Pages

推送到 `main` 分支后，GitHub Actions 会在 `ubuntu-22.04` 上执行：

1. 检出仓库。
2. 调用 `actions/configure-pages` 初始化 GitHub Pages 工作流上下文。
3. 安装 Go 与 Hugo Extended。
4. 执行 `hugo --minify`。
5. 将 `public/` 部署到 GitHub Pages。

首次启用时，还需要到仓库设置页将 Pages 的构建来源切换为 GitHub Actions：

1. 打开 `Settings -> Pages`。
2. 在 `Build and deployment` 下把 `Source` 设为 `GitHub Actions`。
3. 重新运行 [deploy.yml](/root/Blog/.github/workflows/deploy.yml) 工作流。

仓库已包含 [static/CNAME](/root/Blog/static/CNAME) 作为当前自定义域名文件。当前配置的域名是 `blog.lwd123.cc`；如果后续迁移域名，直接修改该文件并同步更新 [config.yaml](/root/Blog/config.yaml#L1) 即可。

## 安全与合规

- 所有敏感信息仅通过环境变量注入，本地使用 `.env`，并提供 `.env.example` 模板。
- 工作流使用固定的 `ubuntu-22.04`，权限限制为 Pages 发布所需最小集合。
- 依赖版本通过 `go.sum` 锁定，并启用 Dependabot 进行定期检查。
- 兼容支持 `_headers` 的平台时，可直接使用 [static/_headers](/root/Blog/static/_headers) 下发 HSTS、CSP、`X-Frame-Options`、`X-Content-Type-Options` 等安全头。
- GitHub Pages 原生不支持自定义响应头；若生产环境必须强制 CSP/HSTS，建议在 CDN 或反向代理层补齐并先在预发布环境验证。
- 自定义 404 页面位于 [layouts/404.html](/root/Blog/layouts/404.html)。
- 仓库层面无法直接开启 `main` 分支保护、PR Review、域名锁或账号 2FA，这些仍需在 Git 托管平台和域名注册商后台显式配置。

## 许可

- 仓库中的代码、配置与脚本采用 [LICENSE](/root/Blog/LICENSE) 中声明的 MIT 许可证。
- 博客文章内容默认采用 CC BY-SA 4.0；该声明会在 README 与文章页脚中同时展示。
- 第三方组件与许可证说明见 [THIRD_PARTY_NOTICES.md](/root/Blog/THIRD_PARTY_NOTICES.md)，其中包含 Hugo 与 PaperMod 的上游许可证信息。

## 迁移与复现

### 新环境最短路径

```bash
git clone <仓库地址> --recurse-submodules
cd Blog
hugo --minify
```

若未准备本机环境，可改用：

```bash
git clone <仓库地址> --recurse-submodules
cd Blog
cp .env.example .env
docker compose up preview
```

### 后续维护建议

1. 升级 Hugo 时，同步调整 `Dockerfile` 与 CI 中的版本号并重新构建验证。
2. 更新主题时，通过更新 `go.mod` / `go.sum` 锁定版本并检查自定义扩展模板兼容性。
3. 在首次提交原型或迁移快照后执行 `git tag -s <tag-name>` 创建签名标签，再推送标签到远端。
4. 在仓库平台中开启分支保护与 PR Review，并在域名注册商后台开启注册锁、转移锁和账号两步验证。