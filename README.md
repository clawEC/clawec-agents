# clawEC Agents

## 关于 clawEC

**clawEC** 是一款面向跨境电商场景的 AI 智能体协同平台，以「你的跨境电商 AI 团队」为品牌主张，将选品、调研、运营、上架、营销、客服、采购、合规等环节沉淀为可执行的 SOP（标准作业程序），通过多智能体（「虾员工」）分工协作与 7×24 小时自动化任务，帮助卖家在单人或少人条件下完成跨境业务闭环，降低对专业运营团队与复杂本地部署的依赖。

官网：[https://www.clawec.com/?source=q-github-agent](https://www.clawec.com/?source=q-github-agent)

## 本仓库

**clawEC Agents** 是 clawEC 的 Agent 开源仓库：面向跨境电商场景的 **AI Agent** 定义与安装脚本。每个 Agent 负责理解业务意图、调度 `.clawec/skills/` 下的平台 API 能力，并按规定格式交付结果；可安装到 Cursor、Claude Code 等主流 AI 编程工具中使用。

当前技能覆盖 **Amazon / TikTok / Shopee / Ozon** 四大平台共 **91** 个 API Skill（选品、榜单、趋势、详情、流量词、达人/直播/品牌等）。

## Agents

与站内默认官方员工对齐（对话入口含 `item_id`）：

| Agent | 说明 | 技能数 | 站内对话 | 定义 |
|-------|------|--------|----------|------|
| **clawec-amazon** | 亚马逊：选品、ABA/关键词、类目集中度、竞品、ASIN 详情/趋势/预测/评论、流量分析 | 20 | [/chat?item_id=a7111554-68ee-4e90-bfc7-bb2e14d7a9c3](https://www.clawec.com/chat?item_id=a7111554-68ee-4e90-bfc7-bb2e14d7a9c3) | [agents/clawec-amazon/AGENT.md](agents/clawec-amazon/AGENT.md) |
| **clawec-tiktok** | TikTok：商品/店铺/达人/直播/视频、类目市场与热销/新品榜 | 33 | [/chat?item_id=34b45822-8376-40d0-ab03-f408e7c9f72b](https://www.clawec.com/chat?item_id=34b45822-8376-40d0-ab03-f408e7c9f72b) | [agents/clawec-tiktok/AGENT.md](agents/clawec-tiktok/AGENT.md) |
| **clawec-shopee** | Shopee：商品/店铺/品牌/热搜词检索、榜单、趋势与详情 | 21 | [/chat?item_id=f78a4cc6-2f07-43fa-a703-1fe97dbedc32](https://www.clawec.com/chat?item_id=f78a4cc6-2f07-43fa-a703-1fe97dbedc32) | [agents/clawec-shopee/AGENT.md](agents/clawec-shopee/AGENT.md) |
| **clawec-ozon** | Ozon：类目/商品/店铺/品牌/关键词榜单、详情、趋势快照与流量词 | 17 | [/chat?item_id=94745faf-20e5-4a38-b027-9f180a2e3084](https://www.clawec.com/chat?item_id=94745faf-20e5-4a38-b027-9f180a2e3084) | [agents/clawec-ozon/AGENT.md](agents/clawec-ozon/AGENT.md) |

## 仓库结构

```text
clawec-agents/
├── README.md
├── agents/                    # Agent 源定义
│   └── clawec-<agent-name>/AGENT.md
├── skills/                    # Clawec API 技能源（安装时同步到用户项目的 .clawec/skills/）
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

所有工具安装时，除 `--rules-only` 外都会将本仓库 **`skills/`** 同步到目标项目的 **`.clawec/skills/`**（Clawec API 文档；Agent 内链接亦会改写为该路径）。Copilot / Antigravity / Gemini CLI / Kimi / OpenClaw 的 Agent 文件在用户目录；Cursor / Claude Code / Codex / OpenCode / Qwen / Aider / Windsurf 以**项目目录**为安装目标（命令末尾的 `.` 或路径）。

**快速安装：**

```bash
git clone https://github.com/uni-infiniteai/clawec-agents.git
cd your-ecommerce-project

# Cursor
/path/to/clawec-agents/scripts/install.sh --tool cursor .

# Claude Code
/path/to/clawec-agents/scripts/install.sh --tool claude-code .
```

一条命令安装：

```bash
export CLAWEC_SKILLS_GIT="https://github.com/uni-infiniteai/clawec-agents.git"
curl -fsSL https://raw.githubusercontent.com/uni-infiniteai/clawec-agents/main/scripts/install.sh | bash -s -- --tool claude-code .
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

## License

本项目采用 [MIT License](https://github.com/uni-infiniteai/clawec-agents?tab=MIT-1-ov-file#readme)。
