#!/bin/bash

# Main status line for Claude Code
# Receives JSON via stdin with session context
# Calls statusline-git.sh which outputs 2 lines:
#   Line 1: branch (Upstream: origin/...) (synced Xd ago)
#   Line 2: [Shortcut: link |] Staged/Unstaged stats [or "No pending changes"]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/colors.sh"

# --- Parse JSON input (single jq call, one value per line) ---
input=$(cat)
{
  read -r model_name
  read -r cwd
  read -r context_size
  read -r used_percentage
  read -r current_input
  read -r current_cache_create
  read -r current_cache_read
  read -r current_output
  read -r rate_five_pct
  read -r rate_seven_pct
  read -r rate_five_reset
  read -r rate_seven_reset
} < <(echo "$input" | jq -r '
  .model.display_name,
  .workspace.current_dir,
  (.context_window.context_window_size // 200000),
  (.context_window.used_percentage // 0),
  (.context_window.current_usage.input_tokens // 0),
  (.context_window.current_usage.cache_creation_input_tokens // 0),
  (.context_window.current_usage.cache_read_input_tokens // 0),
  (.context_window.current_usage.output_tokens // 0),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.resets_at // "")
')

current_folder="${cwd/#$HOME/~}"

# --- Context window display ---
# Renders a 20-char progress bar with color-coded percentage
# Colors: 0-50% green, 50-70% yellow, 70-85% orange, 85%+ red
build_context_display() {
  local pct="$1" size="$2" initialized="$3"
  local bar_length=20

  local size_display
  if [ "$size" -ge 1000 ]; then
    size_display="$((size / 1000))k"
  else
    size_display="$size"
  fi

  if [ "$initialized" = false ]; then
    local bar=$(printf "%${bar_length}s" | tr ' ' '░')
    echo -e "${LIGHT_GREY}${bar}${RESET}"
    return
  fi

  local pct_int=${pct%.*}
  local filled=$((pct_int * bar_length / 100))
  [ "$filled" -gt "$bar_length" ] && filled=$bar_length
  local empty=$((bar_length - filled))
  local bar=$(printf "%${filled}s" | tr ' ' '█')$(printf "%${empty}s" | tr ' ' '░')

  local tokens=$((size * pct_int / 100))
  local tokens_display
  if [ "$tokens" -ge 1000 ]; then
    tokens_display="$((tokens / 1000))k"
  else
    tokens_display="$tokens"
  fi

  local color
  if [ "$pct_int" -lt 50 ]; then
    color="$GREEN"
  elif [ "$pct_int" -lt 70 ]; then
    color="$YELLOW"
  elif [ "$pct_int" -lt 85 ]; then
    color="$ORANGE"
  else
    color="$RED"
  fi

  echo -e "${color}${bar}${RESET} ${WHITE}Context:${RESET} ${color}${pct_int}% (${tokens_display}/${size_display})${RESET}"
}

# Determine if context has been initialized (current_usage is null before first API call)
context_initialized=true
if [ "$current_input" -eq 0 ] && [ "$current_cache_create" -eq 0 ] && [ "$current_cache_read" -eq 0 ] && [ "$current_output" -eq 0 ]; then
  context_initialized=false
fi

# Ensure percentage is integer for bash arithmetic
used_percentage=${used_percentage%.*}

# Fallback: calculate percentage from current_usage (input-only, matching how used_percentage is calculated)
if [ "$used_percentage" -le 0 ] 2>/dev/null && [ "$context_initialized" = true ]; then
  tokens_in_context=$((current_input + current_cache_create + current_cache_read))
  if [ "$context_size" -gt 0 ] && [ "$tokens_in_context" -gt 0 ]; then
    used_percentage=$((tokens_in_context * 100 / context_size))
  fi
fi

context_display=$(build_context_display "$used_percentage" "$context_size" "$context_initialized")

# Format token counts for display (e.g. 42000 -> "42k")
format_tokens() {
  local t="$1"
  if [ "$t" -ge 1000 ]; then
    echo "$((t / 1000))k"
  else
    echo "$t"
  fi
}

# Current context window token counts (from most recent API call)
context_in=$((current_input + current_cache_create + current_cache_read))
tokens_in_display=$(format_tokens "$context_in")
tokens_out_display=$(format_tokens "$current_output")

# --- Subscription rate limit display ---
# Shows 5-hour and/or 7-day usage when available (subscribers only, after first API call)
# Colors: 0-70% green, 70-85% yellow, 85%+ red
rate_limit_color() {
  local pct_int="$1"
  if [ "$pct_int" -lt 70 ]; then
    echo "$GREEN"
  elif [ "$pct_int" -lt 85 ]; then
    echo "$YELLOW"
  else
    echo "$RED"
  fi
}

# Format a reset timestamp (ISO 8601) for display
# For 5h window: "2:50 PM"
# For 7d window: "4/3/25 5:50 PM"
format_reset_time() {
  local epoch="$1"
  local window="$2"  # "5h" or "7d"
  [ -z "$epoch" ] && return

  if [ "$window" = "5h" ]; then
    date -r "$epoch" +"%-I:%M %p" 2>/dev/null
  else
    date -r "$epoch" +"%-m/%-d/%y %-I:%M %p" 2>/dev/null
  fi
}

rate_limits_display=""
if [ -n "$rate_five_pct" ] || [ -n "$rate_seven_pct" ]; then
  rate_parts=()
  if [ -n "$rate_five_pct" ]; then
    pct_int=$(printf "%.0f" "$rate_five_pct")
    color=$(rate_limit_color "$pct_int")
    reset_label=$(format_reset_time "$rate_five_reset" "5h")
    if [ -n "$reset_label" ]; then
      rate_parts+=("⏱️ ${color}${pct_int}% 5h (${reset_label})${RESET}")
    else
      rate_parts+=("⏱️ ${color}${pct_int}% 5h${RESET}")
    fi
  fi
  if [ -n "$rate_seven_pct" ]; then
    pct_int=$(printf "%.0f" "$rate_seven_pct")
    color=$(rate_limit_color "$pct_int")
    reset_label=$(format_reset_time "$rate_seven_reset" "7d")
    if [ -n "$reset_label" ]; then
      rate_parts+=("📅 ${color}${pct_int}% 7d (${reset_label})${RESET}")
    else
      rate_parts+=("📅 ${color}${pct_int}% 7d${RESET}")
    fi
  fi
  # Join parts with " | "
  rate_limits_display="${rate_parts[0]}"
  if [ "${#rate_parts[@]}" -gt 1 ]; then
    rate_limits_display="${rate_limits_display} | ${rate_parts[1]}"
  fi
  rate_limits_display="${rate_limits_display} | "
fi

# --- Git info (2 lines: branch+sync, stats) ---
git_output=$("$SCRIPT_DIR/statusline-git.sh" "$cwd")
git_branch_line=$(echo "$git_output" | sed -n '1p')
git_stats_line=$(echo "$git_output" | sed -n '2p')

# --- Output ---
echo ""
echo -e "${CYAN}${model_name}${RESET} | ${rate_limits_display}${context_display} • ${LIGHT_GREY}In: ${tokens_in_display}${RESET} • ${LIGHT_GREY}Out: ${tokens_out_display}${RESET}"
echo -e "📁 ${current_folder} | 🌳 ${git_branch_line}"
if [ -n "$git_stats_line" ]; then
  echo -e "${git_stats_line}"
fi
