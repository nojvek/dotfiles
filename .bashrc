function ps_timer_start {
  ps_cmd_ts=${ps_cmd_ts:-$SECONDS}
}

# before every command is run, capture timestamp so we can track elapsed time
trap ps_timer_start DEBUG

function set_prompt {
  # Capture exit code of last command (this needs to be first)
  local exit_code=$?

  #----------------------------------------------------------------------------#
  # Bash text colour specification:  \e[<STYLE>;<COLOUR>m
  # (Note: \e = \033 (oct) = \x1b (hex) = 27 (dec) = "Escape")
  # Styles:  0=normal, 1=bold, 2=dimmed, 4=underlined, 7=highlighted
  # Colours: 31=red, 32=green, 33=yellow, 34=blue, 35=purple, 36=cyan, 37=white
  #----------------------------------------------------------------------------#
  local color_blue_fg='\e[1;32m'
  local color_green_fg='\e[1;32m'
  local color_red_fg='\e[1;31m'
  local color_purple_fg='\e[2;35m'
  local reset='\e[0m'

  # Show git branch
  local ps_git_branch=""
  local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ ! -z $git_branch ]]; then
    ps_git_branch="\[$color_purple_fg\]($git_branch) \[$reset\]"
  fi

  # Show elapsed duration of last command
  local ps_last_cmd_elapsed=$(($SECONDS - $ps_cmd_ts))
  unset ps_cmd_ts
  local elapsed_secs=$((ps_last_cmd_elapsed%60))
  local elapsed_mins=$((ps_last_cmd_elapsed/60%60))
  local elapsed_hrs=$((ps_last_cmd_elapsed/3600))
  local elapsed_msg="${elapsed_secs}s"

  if [[ elapsed_mins -gt 0 ]]; then
    elapsed_msg="${elapsed_mins}m${elapsed_msg}"
  fi
  if [[ elapsed_hrs -gt 0 ]]; then
    elapsed_msg="${elapsed_hrs}h${elapsed_msg}"
  fi

  # If exit code of last command is non-zero, prepend this code to the prompt
  local ps_last_cmd_msg="\[$color_green_fg\]${elapsed_msg} ✔\[$reset\]"
  if [[ $exit_code -ne 0 ]]; then
    ps_last_cmd_msg="\[$color_red_fg\]${elapsed_msg} ✘\[$reset\]"
  fi

  PS1="\[$color_blue_fg\]\W ${ps_git_branch}${ps_last_cmd_msg} "
}

# prompt #
export PROMPT_COMMAND=set_prompt
export CLICOLOR=1
export BASH_SILENCE_DEPRECATION_WARNING=1

# history #
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# aliases #
alias gco="git checkout"
alias gcob="git checkout -B"
alias gcp="git cherry-pick"
alias gfe="git fetch"
alias gfeo="git fetch origin"
alias gfeom="git fetch origin main"
alias gfeod="git fetch origin development"
alias glo="git log"
alias gpul="git pull"
alias gpus="git push"
alias gre="git reset"
alias greh="git reset --hard"
alias grehom="git reset --hard origin/main"
alias grehod="git reset --hard origin/development"
alias gres="git reset --soft"

alias sl="screen -ls"
alias sr="screen -d -r"
alias ss="screen -S"
