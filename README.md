# clawEC Agents

## 关于 clawEC

**clawEC** 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

官网：[https://www.clawec.com/?source=q-github-agent](https://www.clawec.com/?source=q-github-agent)

## 本仓库

**clawEC Agents** 是 clawEC 的 Agent 开源仓库：面向跨境电商场景的 **AI Agent** 定义与安装脚本。每个 Agent 负责理解业务意图、调度 `.clawec/skills/` 下的平台 API 能力，并按规定格式交付结果；可安装到 Cursor、Claude Code 等主流 AI 编程工具中使用。

## Agents

| Agent | 说明 | 定义 |
|-------|------|------|
| **clawec-product-search** | 可搜：亚马逊、1688、Shopee、Temu、Ozon、TikTok | [agents/clawec-product-search/AGENT.md](agents/clawec-product-search/AGENT.md) |
| **clawec-amazon** | 亚马逊专项：搜品、机会分析、ASIN、评论、畅销榜/新品榜 | [agents/clawec-amazon/AGENT.md](agents/clawec-amazon/AGENT.md) |
| **clawec-tiktok** | TikTok 专项：品类机会、达人趋势、雷达分 | [agents/clawec-tiktok/AGENT.md](agents/clawec-tiktok/AGENT.md) |
| **clawec-temu** | Temu 专项：关键词搜品与竞品调研 | [agents/clawec-temu/AGENT.md](agents/clawec-temu/AGENT.md) |
| **clawec-shopee** | Shopee（虾皮）专项：多站点关键词搜品 | [agents/clawec-shopee/AGENT.md](agents/clawec-shopee/AGENT.md) |
| **clawec-ozon** | Ozon 专项：俄罗斯及东欧关键词搜品 | [agents/clawec-ozon/AGENT.md](agents/clawec-ozon/AGENT.md) |

## 仓库结构

```text
clawec-agents/
├── README.md
├── agents/                    # Agent 源定义
│   └── clawec-<agent-name>/AGENT.md
├── .clawec/skills/            # Clawec API 技能（API 参数与脚本，供 Agent 读取）
│   └── clawec-<skill-name>/SKILL.md
└── scripts/install.sh
```

---

## 安装与使用

### Supported Tools

| 工具 | 输出位置 | 安装命令 |
|------|----------|----------|
| **Cursor** | `.cursor/skills/<agent>/SKILL.md` | `./scripts/install.sh --tool cursor .` |
| **Claude Code** | `.claude/agents/*.md`（可选 `--global` → `~/.claude/agents/`） | `./scripts/install.sh --tool claude-code .` |
| **Codex** | `.agents/skills/<agent>/SKILL.md` | `./scripts/install.sh --tool codex .` |
| **GitHub Copilot** | `~/.github/agents/` + `~/.copilot/agents/` | `./scripts/install.sh --tool copilot .` |
| **Antigravity** | `~/.gemini/antigravity/skills/clawec-<agent>/` | `./scripts/install.sh --tool antigravity .` |
| **Gemini CLI** | `~/.gemini/extensions/clawec-agents/` | `./scripts/install.sh --tool gemini-cli .` |
| **OpenCode** | `.opencode/agents/` | `./scripts/install.sh --tool opencode .` |
| **Aider** | `./CONVENTIONS.md` | `./scripts/install.sh --tool aider .` |
| **Windsurf** | `./.windsurfrules` | `./scripts/install.sh --tool windsurf .` |
| **OpenClaw** | `~/.openclaw/clawec-agents/<agent>/` | `./scripts/install.sh --tool openclaw .` |
| **Qwen Code** | `.qwen/agents/` | `./scripts/install.sh --tool qwen .` |
| **Kimi Code** | `~/.config/kimi/agents/<agent>/` | `./scripts/install.sh --tool kimi .` |

交互式多选安装（自动检测本机已安装工具）：

```bash
./scripts/install.sh --tool all
# 或非交互：./scripts/install.sh --no-interactive --tool all
# 并行：./scripts/install.sh --no-interactive --tool all --parallel
```

所有工具安装时，除 `--rules-only` 外都会同步项目下的 **`.clawec/skills/`**（Clawec API 文档）。Copilot / Antigravity / Gemini CLI / Kimi / OpenClaw 的 Agent 文件在用户目录；Cursor / Claude Code / Codex / OpenCode / Qwen / Aider / Windsurf 以**项目目录**为安装目标（命令末尾的 `.` 或路径）。

**快速安装：**

```bash
git clone git@github.com:clawEC/clawec-agents.git
cd your-ecommerce-project

# Cursor
/path/to/clawec-agents/scripts/install.sh --tool cursor .

# Claude Code
/path/to/clawec-agents/scripts/install.sh --tool claude-code .
```

一条命令安装：

```bash
export CLAWEC_SKILLS_GIT="https://github.com/clawEC/clawec-agents.git"
curl -fsSL https://raw.githubusercontent.com/clawEC/clawec-agents/main/scripts/install.sh | bash -s -- --tool claude-code .
```

仅更新 Agent 定义（已有 `.clawec/skills/`）：`./scripts/install.sh --tool <工具> . --rules-only`

### 前置条件

- macOS / Linux / WSL，已安装 `bash`
- 在**业务项目根目录**执行安装（命令中的 `.` 或你的项目路径）
- 已配置 **Clawec API Key**（见下一节）

### API Key 获取与环境变量

各 `.clawec/skills/` 下的接口调用都需要 Clawec API Key。Agent 与脚本统一从环境变量 **`CLAWEC_API_KEY`** 读取，请勿把 Key 写进代码或提交到 git。

#### 1. 获取 Key

1. 打开 [Clawec 注册页](https://www.clawec.com/?source=q-github-agent) 注册账号  
2. 登录后打开 [API Key 页面](https://www.clawec.com/api-key?source=q-github-agent) 创建或复制 Key  

#### 2. 写入环境变量

**当前终端会话（临时，关闭终端后失效）：**

```bash
export CLAWEC_API_KEY="你的密钥"
```

**长期生效（推荐，macOS / Linux zsh）：**

```bash
echo 'export CLAWEC_API_KEY="你的密钥"' >> ~/.zshrc
source ~/.zshrc
```

若使用 bash，将 `~/.zshrc` 改为 `~/.bashrc`。

**仅当前项目（可提交 `.env.example`，勿提交 `.env`）：**

在项目根目录创建 `.env`（并确保已在 `.gitignore` 中忽略 `.env`）：

```bash
CLAWEC_API_KEY=你的密钥
```

在 Cursor / 终端启动前加载：

```bash
set -a && source .env && set +a
```

#### 3. 验证是否生效

```bash
echo "${CLAWEC_API_KEY:+已设置（长度 ${#CLAWEC_API_KEY}）}${CLAWEC_API_KEY:-未设置}"
```

有输出「已设置」即可。在 Cursor 中若 Agent 调 API 仍报未配置 Key，请**重启 Cursor** 或从新开的集成终端里启动 Agent，确保进程能读到上述环境变量。

## License

发布时请添加 `LICENSE` 文件（如 MIT）。
