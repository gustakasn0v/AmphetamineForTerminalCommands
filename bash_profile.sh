# This will run Amphetamine before commands not in the exclusion list are executed.
function PreCommand() {
  # Don't run PreCommand as part of PostCommand!
  if [ -z "$AT_PROMPT" ]; then
    return
  fi
  unset AT_PROMPT

  excluded_commands=("ls" "cd" "pwd" "git" "vim" "PostCommand" "ssh" "mw" "history")
  # Convert the array to a pattern for 'grep'
  prefix_pattern=$(printf "|%s" "${excluded_commands[@]}")
  prefix_pattern=${prefix_pattern:1}  # Remove the leading '|'

  # Check if the variable is not in the set of excluded commands
  if echo "$BASH_COMMAND" | grep -v -q -E "^($prefix_pattern)"; then
    printf "\e[32mStarting amphetamine session for command $BASH_COMMAND...\e[m\n"
    osascript ~/.bin/start-amphetamine-session.scpt
    touch ~/.amphetamine_session_running
  fi
}
trap "PreCommand" DEBUG

# This will run after the execution of the previous full command line.  We don't
# want PostCommand to execute when first starting a bash session (i.e., at
# the first prompt).
FIRST_PROMPT=1
function PostCommand() {
  AT_PROMPT=1

  if [ -n "$FIRST_PROMPT" ]; then
    unset FIRST_PROMPT
    return
  fi

  if [ -f ~/.amphetamine_session_running ]; then
    printf "\e[32mEnding amphetamine session...\e[m\n"
    osascript ~/.bin/stop-amphetamine-session.scpt
    rm ~/.amphetamine_session_running
  fi
}
PROMPT_COMMAND="$PROMPT_COMMAND; PostCommand"
