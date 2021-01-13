
### BEGIN PROMPT
function ps_timer_start {
  ps_cmd_ts=${ps_cmd_ts:-$SECONDS}
}

# before every command is run, capture timestamp so we can track elapsed time
trap ps_timer_start DEBUG

set_prompt() {
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

  # tracked elapsed seconds
  local ps_last_cmd_elapsed=$(($SECONDS - $ps_cmd_ts))
  ps_last_cmd_elapsed="${ps_last_cmd_elapsed}s"
  unset ps_cmd_ts

  # If exit code of last command is non-zero, prepend this code to the prompt
  local ps_last_cmd_msg="\[$color_green_fg\]${ps_last_cmd_elapsed} ✔\[$reset\]"
  if [[ $exit_code -ne 0 ]]; then
    ps_last_cmd_msg="\[$color_red_fg\]${ps_last_cmd_elapsed} ✘\[$reset\]"
  fi

  PS1="\[$color_blue_fg\]\W ${ps_git_branch}${ps_last_cmd_msg} "
}

export PROMPT_COMMAND=set_prompt
export CLICOLOR=1
export BASH_SILENCE_DEPRECATION_WARNING=1
### END PROMPT

