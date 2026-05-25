#!/usr/bin/env bash
#
# Install clawEC agents & API skills into a target project and/or user config dirs.
# API skills: repo skills/ → target .clawec/skills/
#
# Usage:
#   ./scripts/install.sh cursor .                    # legacy: tool + target
#   ./scripts/install.sh --tool cursor /path/to/app
#   ./scripts/install.sh --tool all                  # interactive (TTY) or auto-detect
#   ./scripts/install.sh --no-interactive --tool all
#   ./scripts/install.sh --tool claude-code . --global
#   ./scripts/install.sh --tool cursor . --rules-only
#
# Supported tools:
#   claude-code   → .claude/agents/  (+ ~/.claude/agents/ with --global)
#   copilot       → ~/.github/agents/ + ~/.copilot/agents/
#   antigravity   → ~/.gemini/antigravity/skills/clawec-<agent>/
#   gemini-cli    → ~/.gemini/extensions/clawec-agents/
#   opencode      → .opencode/agents/
#   cursor        → .cursor/skills/<agent>/SKILL.md
#   aider         → ./CONVENTIONS.md
#   windsurf      → ./.windsurfrules
#   openclaw      → ~/.openclaw/clawec-agents/<agent>/
#   qwen          → .qwen/agents/
#   kimi          → ~/.config/kimi/agents/<agent>/
#   codex         → .agents/skills/<agent>/SKILL.md
#   all           → install selected/detected tools
#
# Flags:
#   --tool <name>       Tool to install (default: cursor if first arg is a tool name)
#   --interactive       Force interactive tool picker
#   --no-interactive    Skip picker; with --tool all, install all detected tools
#   --parallel          Install multiple tools in parallel
#   --jobs N            Max parallel jobs (default: nproc or 4)
#   --global            Also install claude-code agents to ~/.claude/agents/
#   --rules-only        Agents only; skip .clawec/skills/ (must already exist)
#   --help              Show help
#
# Environment:
#   CLAWEC_SKILLS_REPO   Path to clawec-agents repo
#   CLAWEC_SKILLS_GIT    Git URL when repo not present (curl one-liner)

set -euo pipefail

ALL_TOOLS=(claude-code copilot antigravity gemini-cli opencode cursor codex aider windsurf openclaw qwen kimi)

TOOL=""
TARGET="."
RULES_ONLY=false
CLAUDE_GLOBAL=false
INTERACTIVE_MODE="auto"
USE_PARALLEL=false
PARALLEL_JOBS=""

parse_args() {
  local -a pos=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --rules-only) RULES_ONLY=true; shift ;;
      --global) CLAUDE_GLOBAL=true; shift ;;
      --interactive) INTERACTIVE_MODE="yes"; shift ;;
      --no-interactive) INTERACTIVE_MODE="no"; shift ;;
      --parallel) USE_PARALLEL=true; shift ;;
      --jobs) PARALLEL_JOBS="${2:-}"; shift 2 ;;
      --help|-h)
        sed -n '3,38p' "$0" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
      --tool)
        TOOL="${2:-}"
        INTERACTIVE_MODE="no"
        shift 2
        ;;
      --*)
        echo "ERR Unknown option: $1" >&2
        exit 1
        ;;
      *)
        pos+=("$1")
        shift
        ;;
    esac
  done
  if [[ -z "$TOOL" && ${#pos[@]} -ge 1 ]]; then
    TOOL="${pos[0]}"
    [[ ${#pos[@]} -ge 2 ]] && TARGET="${pos[1]}"
  elif [[ ${#pos[@]} -ge 1 ]]; then
    # --tool <name> <target>
    TARGET="${pos[0]}"
  fi
  [[ -n "$TOOL" ]] || TOOL="cursor"
}

parse_args "$@"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -n "${CLAWEC_SKILLS_REPO:-}" ]]; then
  REPO_ROOT="$(cd "$CLAWEC_SKILLS_REPO" && pwd)"
fi

CLEANUP_REPO=""

clone_repo_if_needed() {
  if [[ -d "$REPO_ROOT/agents" ]]; then
    return 0
  fi
  local url="${CLAWEC_SKILLS_GIT:-https://github.com/clawEC/clawec-agents.git}"
  local tmp
  tmp="$(mktemp -d)"
  echo ">> Cloning skills repo from $url ..."
  if ! git clone --depth 1 "$url" "$tmp" 2>/dev/null; then
    echo "ERROR: Cannot find agents/ and git clone failed." >&2
    echo "  Clone manually or set CLAWEC_SKILLS_REPO=/path/to/clawec-agents" >&2
    rm -rf "$tmp"
    exit 1
  fi
  REPO_ROOT="$tmp"
  CLEANUP_REPO="$tmp"
}

parallel_jobs_default() {
  local n
  n=$(nproc 2>/dev/null) && [[ -n "$n" ]] && echo "$n" && return
  n=$(sysctl -n hw.ncpu 2>/dev/null) && [[ -n "$n" ]] && echo "$n" && return
  echo 4
}
[[ -n "$PARALLEL_JOBS" ]] || PARALLEL_JOBS="$(parallel_jobs_default)"

clone_repo_if_needed

TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || {
  echo "ERROR: Target directory does not exist: $TARGET" >&2
  exit 1
}

ok() { echo "OK  $*"; }
info() { echo ">> $*"; }
warn() { echo "!!  $*"; }
err() { echo "ERR $*" >&2; }

rewrite_agent_paths() {
  sed -e 's|\](\.\./\.\./\.clawec/skills/|](.clawec/skills/|g' \
      -e 's|\](\.\./\.\./skills/|](.clawec/skills/|g'
}

fm_get() {
  local file="$1" key="$2"
  awk -v k="$key" '
    BEGIN { infm=0 }
    /^---$/ { infm++; next }
    infm==1 && $0 ~ "^" k ":" {
      sub("^" k ": ?", "")
      gsub(/^["'\'']|["'\'']$/, "")
      print
      exit
    }
  ' "$file"
}

get_agent_body() {
  awk 'BEGIN{n=0} /^---$/{n++; next} n>=2' "$1"
}

yaml_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

agent_count() {
  local n=0 d
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -f "$d/AGENT.md" ]] && n=$((n + 1))
  done
  echo "$n"
}

require_agents() {
  if [[ "$(agent_count)" -eq 0 ]]; then
    err "No agents/*/AGENT.md found under $REPO_ROOT"
    exit 1
  fi
}

install_clawec_api_skills() {
  local api_skills_src="$REPO_ROOT/skills"
  [[ -d "$api_skills_src" ]] || api_skills_src="$REPO_ROOT/.clawec/skills"
  [[ -d "$api_skills_src" ]] || return 0

  mkdir -p "$TARGET/.clawec"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$api_skills_src/" "$TARGET/.clawec/skills/"
  else
    rm -rf "$TARGET/.clawec/skills"
    mkdir -p "$TARGET/.clawec"
    cp -R "$api_skills_src" "$TARGET/.clawec/skills"
  fi
  ok ".clawec/skills/ -> $TARGET/.clawec/skills/"

  if [[ -d "$TARGET/skills" ]]; then
    rm -rf "$TARGET/skills"
    info "removed legacy skills/"
  fi
}

maybe_install_api_skills() {
  if [[ "$RULES_ONLY" == true ]]; then
    info "Agents only (--rules-only). Ensure .clawec/skills/ exists under $TARGET"
    return 0
  fi
  install_clawec_api_skills
}

install_md_agents_to_dir() {
  local dest="$1"
  local count=0 d agent_file slug out
  mkdir -p "$dest"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    out="$dest/${slug}.md"
    rewrite_agent_paths < "$agent_file" > "$out"
    ok "agent $out"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }
}

install_claude_code() {
  install_md_agents_to_dir "$TARGET/.claude/agents"
  maybe_install_api_skills
  if [[ -d "$TARGET/agents" && "$(cd "$TARGET" && pwd)" != "$(cd "$REPO_ROOT" && pwd)" ]]; then
    rm -rf "$TARGET/agents"
    info "removed legacy agents/ (installed copy in project)"
  fi
  if [[ "$CLAUDE_GLOBAL" == true ]]; then
    install_md_agents_to_dir "${HOME}/.claude/agents"
    info "also installed to ~/.claude/agents/ (--global)"
  fi
}

install_copilot() {
  local dest_github="${HOME}/.github/agents"
  local dest_copilot="${HOME}/.copilot/agents"
  install_md_agents_to_dir "$dest_github"
  local count=0 d agent_file slug out
  mkdir -p "$dest_copilot"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    out="$dest_copilot/${slug}.md"
    rewrite_agent_paths < "$agent_file" > "$out"
    count=$((count + 1))
  done
  ok "copilot: $count agents -> $dest_github + $dest_copilot"
  warn "Copilot: verify VS Code setting 'chat.agentFilesLocations' includes install paths"
  maybe_install_api_skills
}

install_antigravity() {
  local dest="${HOME}/.gemini/antigravity/skills"
  local count=0 d agent_file slug name desc out_dir out_file
  mkdir -p "$dest"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    name="$(fm_get "$agent_file" name)"
    desc="$(fm_get "$agent_file" description)"
    out_dir="$dest/$slug"
    out_file="$out_dir/SKILL.md"
    mkdir -p "$out_dir"
    {
      echo "---"
      echo "name: $slug"
      echo "description: $desc"
      echo "---"
      echo ""
      rewrite_agent_paths < <(get_agent_body "$agent_file")
    } > "$out_file"
    ok "skill $out_file"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }
  maybe_install_api_skills
}

install_gemini_cli() {
  local dest="${HOME}/.gemini/extensions/clawec-agents"
  local count=0 d agent_file slug name desc out_dir
  mkdir -p "$dest/skills"
  cat > "$dest/gemini-extension.json" <<'EOF'
{
  "name": "clawec-agents",
  "version": "1.0.0",
  "description": "clawEC cross-border ecommerce agents"
}
EOF
  ok "manifest $dest/gemini-extension.json"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    desc="$(fm_get "$agent_file" description)"
    out_dir="$dest/skills/$slug"
    mkdir -p "$out_dir"
    {
      echo "---"
      echo "name: $slug"
      echo "description: $desc"
      echo "---"
      echo ""
      rewrite_agent_paths < <(get_agent_body "$agent_file")
    } > "$out_dir/SKILL.md"
    ok "skill $out_dir/SKILL.md"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }
  maybe_install_api_skills
}

install_opencode() {
  install_md_agents_to_dir "$TARGET/.opencode/agents"
  warn "OpenCode: project-scoped at $TARGET/.opencode/agents/"
  maybe_install_api_skills
}

install_cursor() {
  local cursor_skills_dir="$TARGET/.cursor/skills"
  local count=0 d agent_file slug out_dir out_file
  mkdir -p "$cursor_skills_dir"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    out_dir="$cursor_skills_dir/$slug"
    out_file="$out_dir/SKILL.md"
    mkdir -p "$out_dir"
    rewrite_agent_paths < "$agent_file" > "$out_file"
    ok "skill $out_file  (@$slug)"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }

  maybe_install_api_skills

  if [[ -d "$TARGET/agents" && "$(cd "$TARGET" && pwd)" != "$(cd "$REPO_ROOT" && pwd)" ]]; then
    rm -rf "$TARGET/agents"
    info "removed legacy agents/ (installed copy in project)"
  fi
  local legacy_rule
  for legacy_rule in "$TARGET/.cursor/rules"/clawec-*.mdc; do
    [[ -f "$legacy_rule" ]] || continue
    rm -f "$legacy_rule"
    info "removed legacy rule $(basename "$legacy_rule")"
  done
}

install_codex() {
  local codex_skills_dir="$TARGET/.agents/skills"
  local count=0 d agent_file slug out_dir out_file
  mkdir -p "$codex_skills_dir"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    out_dir="$codex_skills_dir/$slug"
    out_file="$out_dir/SKILL.md"
    mkdir -p "$out_dir"
    rewrite_agent_paths < "$agent_file" > "$out_file"
    ok "skill $out_file  (\$${slug})"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }
  warn "Codex: project-scoped at $TARGET/.agents/skills/ — invoke with \$<skill-name> or /skills"
  maybe_install_api_skills
}

install_aider() {
  local dest="$TARGET/CONVENTIONS.md"
  if [[ -f "$dest" ]]; then
    warn "Aider: CONVENTIONS.md already exists (remove to reinstall)"
    maybe_install_api_skills
    return 0
  fi
  {
    echo "# clawEC Agents — Aider Conventions"
    echo ""
    echo "Generated by clawec-agents install.sh. Reference an agent by name in your session."
    echo ""
    local d agent_file slug
    for d in "$REPO_ROOT"/agents/*/; do
      [[ -d "$d" ]] || continue
      agent_file="$d/AGENT.md"
      [[ -f "$agent_file" ]] || continue
      slug="$(basename "$d")"
      echo "---"
      echo ""
      echo "## Agent: $slug"
      echo ""
      rewrite_agent_paths < "$agent_file"
      echo ""
    done
  } > "$dest"
  ok "Aider: $dest"
  warn "Aider: project-scoped at $dest"
  maybe_install_api_skills
}

install_windsurf() {
  local dest="$TARGET/.windsurfrules"
  if [[ -f "$dest" ]]; then
    warn "Windsurf: .windsurfrules already exists (remove to reinstall)"
    maybe_install_api_skills
    return 0
  fi
  {
    echo "# clawEC Agents"
    echo ""
    local d agent_file slug
    for d in "$REPO_ROOT"/agents/*/; do
      [[ -d "$d" ]] || continue
      agent_file="$d/AGENT.md"
      [[ -f "$agent_file" ]] || continue
      slug="$(basename "$d")"
      echo "## $slug"
      echo ""
      rewrite_agent_paths < "$agent_file"
      echo ""
    done
  } > "$dest"
  ok "Windsurf: $dest"
  maybe_install_api_skills
}

install_openclaw() {
  local dest="${HOME}/.openclaw/clawec-agents"
  local count=0 d agent_file slug name desc
  mkdir -p "$dest"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    name="$(fm_get "$agent_file" name)"
    desc="$(fm_get "$agent_file" description)"
    mkdir -p "$dest/$slug"
    {
      echo "# $name"
      echo ""
      echo "$desc"
    } > "$dest/$slug/SOUL.md"
    {
      echo "Name: $name"
      echo "Description: $desc"
    } > "$dest/$slug/IDENTITY.md"
    {
      echo "# $name — Operations"
      echo ""
      rewrite_agent_paths < <(get_agent_body "$agent_file")
    } > "$dest/$slug/AGENTS.md"
    if command -v openclaw >/dev/null 2>&1; then
      openclaw agents add "$slug" --workspace "$dest/$slug" --non-interactive 2>/dev/null || true
    fi
    ok "workspace $dest/$slug"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }
  if command -v openclaw >/dev/null 2>&1; then
    warn "OpenClaw: run 'openclaw gateway restart' to activate new agents"
  fi
  maybe_install_api_skills
}

install_qwen() {
  install_md_agents_to_dir "$TARGET/.qwen/agents"
  warn "Qwen Code: project-scoped at $TARGET/.qwen/agents/"
  maybe_install_api_skills
}

install_kimi() {
  local dest="${HOME}/.config/kimi/agents"
  local count=0 d agent_file slug name desc esc
  mkdir -p "$dest"
  for d in "$REPO_ROOT"/agents/*/; do
    [[ -d "$d" ]] || continue
    agent_file="$d/AGENT.md"
    [[ -f "$agent_file" ]] || continue
    slug="$(basename "$d")"
    name="$(fm_get "$agent_file" name)"
    desc="$(fm_get "$agent_file" description)"
    esc="$(yaml_escape "$desc")"
    mkdir -p "$dest/$slug"
    cat > "$dest/$slug/agent.yaml" <<EOF
name: $slug
description: "$esc"
version: "1.0"
EOF
    rewrite_agent_paths < <(get_agent_body "$agent_file") > "$dest/$slug/system.md"
    ok "kimi $dest/$slug/agent.yaml"
    count=$((count + 1))
  done
  [[ "$count" -gt 0 ]] || { err "No agents found"; return 1; }
  info "Usage: kimi --agent-file ~/.config/kimi/agents/<agent>/agent.yaml"
  maybe_install_api_skills
}

install_tool() {
  require_agents
  case "$1" in
    claude-code|claude) install_claude_code ;;
    copilot)            install_copilot ;;
    antigravity)        install_antigravity ;;
    gemini-cli)         install_gemini_cli ;;
    opencode)           install_opencode ;;
    cursor)             install_cursor ;;
    codex)              install_codex ;;
    aider)              install_aider ;;
    windsurf)           install_windsurf ;;
    openclaw)           install_openclaw ;;
    qwen)               install_qwen ;;
    kimi)               install_kimi ;;
    *)
      err "Unknown tool: $1"
      return 1
      ;;
  esac
}

tool_done_message() {
  case "$1" in
    cursor)
      echo "  Cursor @clawec-<agent>  (Skills list)  →  $TARGET"
      echo "  API: .clawec/skills/*/SKILL.md  |  CLAWEC_API_KEY"
      ;;
    claude-code|claude)
      echo "  Claude Code /agents  →  $TARGET/.claude/agents/"
      ;;
    copilot)
      echo "  Copilot agents  →  ~/.github/agents/ + ~/.copilot/agents/"
      ;;
    antigravity)
      echo "  Antigravity @clawec-<agent>  →  ~/.gemini/antigravity/skills/"
      ;;
    gemini-cli)
      echo "  Gemini CLI extension  →  ~/.gemini/extensions/clawec-agents/"
      ;;
    opencode)
      echo "  OpenCode @clawec-<agent>  →  $TARGET/.opencode/agents/"
      ;;
    codex)
      echo "  Codex \$clawec-<agent> or /skills  →  $TARGET/.agents/skills/"
      echo "  API: .clawec/skills/*/SKILL.md  |  CLAWEC_API_KEY"
      ;;
    aider)
      echo "  Aider CONVENTIONS.md  →  $TARGET/CONVENTIONS.md"
      ;;
    windsurf)
      echo "  Windsurf .windsurfrules  →  $TARGET/.windsurfrules"
      ;;
    openclaw)
      echo "  OpenClaw workspaces  →  ~/.openclaw/clawec-agents/"
      ;;
    qwen)
      echo "  Qwen SubAgents  →  $TARGET/.qwen/agents/"
      ;;
    kimi)
      echo "  Kimi agents  →  ~/.config/kimi/agents/"
      ;;
  esac
}

# --- Tool detection ---
detect_claude_code() { [[ -d "${HOME}/.claude" ]] || command -v claude >/dev/null 2>&1; }
detect_copilot()      { command -v code >/dev/null 2>&1 || [[ -d "${HOME}/.github" || -d "${HOME}/.copilot" ]]; }
detect_antigravity()  { [[ -d "${HOME}/.gemini/antigravity/skills" ]] || [[ -d "${HOME}/.gemini" ]]; }
detect_gemini_cli()   { command -v gemini >/dev/null 2>&1 || [[ -d "${HOME}/.gemini" ]]; }
detect_opencode()     { command -v opencode >/dev/null 2>&1 || [[ -d "${HOME}/.config/opencode" ]]; }
detect_cursor()       { command -v cursor >/dev/null 2>&1 || [[ -d "${HOME}/.cursor" ]]; }
detect_codex()        { command -v codex >/dev/null 2>&1 || [[ -d "${HOME}/.codex" || -d "${HOME}/.agents" ]]; }
detect_aider()        { command -v aider >/dev/null 2>&1; }
detect_openclaw()     { command -v openclaw >/dev/null 2>&1 || [[ -d "${HOME}/.openclaw" ]]; }
detect_windsurf()     { command -v windsurf >/dev/null 2>&1 || [[ -d "${HOME}/.codeium" ]]; }
detect_qwen()         { command -v qwen >/dev/null 2>&1 || [[ -d "${HOME}/.qwen" ]]; }
detect_kimi()         { command -v kimi >/dev/null 2>&1 || [[ -d "${HOME}/.config/kimi" ]]; }

is_detected() {
  case "$1" in
    claude-code) detect_claude_code ;;
    copilot)     detect_copilot ;;
    antigravity) detect_antigravity ;;
    gemini-cli)  detect_gemini_cli ;;
    opencode)    detect_opencode ;;
    cursor)      detect_cursor ;;
    codex)       detect_codex ;;
    aider)       detect_aider ;;
    openclaw)    detect_openclaw ;;
    windsurf)    detect_windsurf ;;
    qwen)        detect_qwen ;;
    kimi)        detect_kimi ;;
    *)           return 1 ;;
  esac
}

tool_label() {
  case "$1" in
    claude-code) printf "%-14s  %s" "Claude Code"  ".claude/agents" ;;
    copilot)     printf "%-14s  %s" "Copilot"      "~/.github + ~/.copilot" ;;
    antigravity) printf "%-14s  %s" "Antigravity"  "~/.gemini/antigravity/skills" ;;
    gemini-cli)  printf "%-14s  %s" "Gemini CLI"   "~/.gemini/extensions/clawec-agents" ;;
    opencode)    printf "%-14s  %s" "OpenCode"     ".opencode/agents" ;;
    cursor)      printf "%-14s  %s" "Cursor"       ".cursor/skills" ;;
    codex)       printf "%-14s  %s" "Codex"        ".agents/skills" ;;
    aider)       printf "%-14s  %s" "Aider"        "CONVENTIONS.md" ;;
    windsurf)    printf "%-14s  %s" "Windsurf"     ".windsurfrules" ;;
    openclaw)    printf "%-14s  %s" "OpenClaw"     "~/.openclaw/clawec-agents" ;;
    qwen)        printf "%-14s  %s" "Qwen Code"    ".qwen/agents" ;;
    kimi)        printf "%-14s  %s" "Kimi Code"    "~/.config/kimi/agents" ;;
  esac
}

interactive_select() {
  local -a selected=()
  local -a detected_map=()
  local t i
  for t in "${ALL_TOOLS[@]}"; do
    if is_detected "$t" 2>/dev/null; then
      selected+=(1); detected_map+=(1)
    else
      selected+=(0); detected_map+=(0)
    fi
  done

  while true; do
    echo ""
    echo "  clawEC Agents — Tool Installer"
    echo "  Target project: $TARGET"
    echo "  [*] = detected on this machine"
    echo ""
    i=0
    for t in "${ALL_TOOLS[@]}"; do
      local num=$((i + 1))
      local label dot chk
      label="$(tool_label "$t")"
      if [[ "${detected_map[$i]}" == "1" ]]; then dot="[*]"; else dot="[ ]"; fi
      if [[ "${selected[$i]}" == "1" ]]; then chk="[x]"; else chk="[ ]"; fi
      printf "  %s  %2s)  %s  %s  %s\n" "$chk" "$num" "$dot" "$label"
      i=$((i + 1))
    done
    echo ""
    echo "  [1-${#ALL_TOOLS[@]}] toggle  [a] all  [n] none  [d] detected"
    echo "  [Enter] install  [q] quit"
    echo ""
    printf "  >> "
    read -r input </dev/tty || input="q"

    case "$input" in
      q|Q) ok "Aborted."; exit 0 ;;
      a|A) for ((j=0; j<${#ALL_TOOLS[@]}; j++)); do selected[$j]=1; done ;;
      n|N) for ((j=0; j<${#ALL_TOOLS[@]}; j++)); do selected[$j]=0; done ;;
      d|D) for ((j=0; j<${#ALL_TOOLS[@]}; j++)); do selected[$j]="${detected_map[$j]}"; done ;;
      "")
        local any=false s
        for s in "${selected[@]}"; do [[ "$s" == "1" ]] && any=true && break; done
        $any && break
        warn "Nothing selected."
        ;;
      *)
        local num idx toggled=false
        for num in $input; do
          if [[ "$num" =~ ^[0-9]+$ ]]; then
            idx=$((num - 1))
            if (( idx >= 0 && idx < ${#ALL_TOOLS[@]} )); then
              if [[ "${selected[$idx]}" == "1" ]]; then selected[$idx]=0; else selected[$idx]=1; fi
              toggled=true
            fi
          fi
        done
        $toggled || warn "Invalid input."
        ;;
    esac
  done

  SELECTED_TOOLS=()
  i=0
  for t in "${ALL_TOOLS[@]}"; do
    [[ "${selected[$i]}" == "1" ]] && SELECTED_TOOLS+=("$t")
    i=$((i + 1))
  done
}

SELECTED_TOOLS=()

resolve_tools() {
  if [[ "$TOOL" == "all" ]]; then
    local use_interactive=false
    if [[ "$INTERACTIVE_MODE" == "yes" ]]; then
      use_interactive=true
    elif [[ "$INTERACTIVE_MODE" == "auto" && -t 0 && -t 1 ]]; then
      use_interactive=true
    fi

    if $use_interactive; then
      interactive_select
    else
      SELECTED_TOOLS=()
      local t
      info "Scanning for installed tools..."
      for t in "${ALL_TOOLS[@]}"; do
        if is_detected "$t" 2>/dev/null; then
          SELECTED_TOOLS+=("$t")
          ok "detected: $(tool_label "$t")"
        fi
      done
    fi

    if [[ ${#SELECTED_TOOLS[@]} -eq 0 ]]; then
      warn "No tools selected or detected."
      echo "  Tip: ./scripts/install.sh --tool cursor ."
      exit 0
    fi
    return 0
  fi

  local valid=false t
  for t in "${ALL_TOOLS[@]}"; do
    [[ "$t" == "$TOOL" || ( "$TOOL" == "claude" && "$t" == "claude-code" ) ]] && valid=true && break
  done
  if ! $valid; then
    err "Unknown tool '$TOOL'. Valid: ${ALL_TOOLS[*]} all"
    exit 1
  fi
  [[ "$TOOL" == "claude" ]] && TOOL="claude-code"
  SELECTED_TOOLS=("$TOOL")
}

run_installs() {
  local t out_dir
  if [[ -n "${CLAWEC_INSTALL_WORKER:-}" ]]; then
    install_tool "${SELECTED_TOOLS[0]}"
    return $?
  fi

  info "Installing into project: $TARGET"
  info "Tools: ${SELECTED_TOOLS[*]}"
  echo ""

  if $USE_PARALLEL && [[ ${#SELECTED_TOOLS[@]} -gt 1 ]]; then
    local -a extra=()
    [[ "$RULES_ONLY" == true ]] && extra+=(--rules-only)
    [[ "$CLAUDE_GLOBAL" == true ]] && extra+=(--global)
    out_dir="$(mktemp -d)"
    printf '%s\n' "${SELECTED_TOOLS[@]}" | xargs -P "$PARALLEL_JOBS" -I {} \
      env CLAWEC_INSTALL_WORKER=1 CLAWEC_SKILLS_REPO="$REPO_ROOT" \
        bash "$SCRIPT_DIR/install.sh" --tool {} --no-interactive "${extra[@]}" "$TARGET" \
        > "$out_dir/{}" 2>&1 || true
    for t in "${SELECTED_TOOLS[@]}"; do
      [[ -f "$out_dir/$t" ]] && cat "$out_dir/$t"
    done
    rm -rf "$out_dir"
  else
    for t in "${SELECTED_TOOLS[@]}"; do
      echo ">> [$t]"
      install_tool "$t" || true
      echo ""
    done
  fi
}

# --- Main ---
require_agents
resolve_tools

if [[ -n "${CLAWEC_INSTALL_WORKER:-}" ]]; then
  install_tool "${SELECTED_TOOLS[0]}"
  exit $?
fi

if [[ ${#SELECTED_TOOLS[@]} -eq 1 ]]; then
  install_tool "${SELECTED_TOOLS[0]}"
  echo ""
  echo "Done — ${SELECTED_TOOLS[0]}:"
  tool_done_message "${SELECTED_TOOLS[0]}"
else
  run_installs
  echo ""
  echo "Done — installed: ${SELECTED_TOOLS[*]}"
  for t in "${SELECTED_TOOLS[@]}"; do
    tool_done_message "$t"
  done
fi

[[ -n "$CLEANUP_REPO" ]] && rm -rf "$CLEANUP_REPO"
