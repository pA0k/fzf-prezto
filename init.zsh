#
# Fuzzy file finder module for zim
#
# Authors:
#   Greg Anders <greg.p.anders@gmail.com>
#   Byungsu SEO <pa0k.su@gmail.com>
#


local fzf_base fzf_shell fzfdirs dir

##############################################################################
# taken from oh-my-zsh.
test -d "${FZF_BASE}" && fzf_base="${FZF_BASE}"

if [[ -z "${fzf_base}" ]]; then
  fzfdirs=(
    "${HOME}/.fzf"
    "/usr/local/opt/fzf"
    "/usr/share/fzf"
  )
  for dir in ${fzfdirs}; do
      if [[ -d "${dir}" ]]; then
          fzf_base="${dir}"
          break
      fi
  done

  if [[ -z "${fzf_base}" ]]; then
      if (( ${+commands[brew]} )) && dir="$(brew --prefix fzf 2>/dev/null)"; then
          if [[ -d "${dir}" ]]; then
              fzf_base="${dir}"
          fi
      fi
  fi
fi

if [[ "${fzf_base}" == "/usr/share/fzf" ]]; then
    fzf_shell="${fzf_base}"
else
    fzf_shell="${fzf_base}/shell"
fi

if ! (( ${+commands[fzf]} )) && [[ ! "$PATH" == *${fzf_base}/bin* ]]; then
    path=(${fzf_base}/bin $path)
fi
##############################################################################

if (( ! ${+commands[fzf]} )); then
    return 1
fi

if ! zstyle -t ':zim:fzf' disable-completion; then
    [[ $- == *i* ]] && source "${fzf_shell}/completion.zsh" 2>/dev/null
fi

if ! zstyle -t ':zim:fzf' disable-key-bindings; then
    source "${fzf_shell}/key-bindings.zsh"
fi

export FZF_DEFAULT_OPTS=""

# Set height of fzf results
zstyle -s ':zim:fzf' height FZF_HEIGHT

# Open fzf in a tmux pane if using tmux
if zstyle -t ':zim:fzf' tmux && [ -n "$TMUX_PANE" ]; then
  export FZF_TMUX=1
  export FZF_TMUX_HEIGHT=${FZF_HEIGHT:-40%}
  alias fzf="fzf-tmux -d${FZF_TMUX_HEIGHT}"
else
  export FZF_TMUX=0
  if [ ! -z "$FZF_HEIGHT" ]; then
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --height ${FZF_HEIGHT} --reverse"
  fi
fi

__fzf_prog() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] \
    && echo "fzf-tmux -d${FZF_TMUX_HEIGHT}" || echo "fzf"
}

# Use ripgrep or ag if available
if (( $+commands[rg] )); then
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
  _fzf_compgen_path() {
    rg --files "$1"
  }
elif (( $+commands[ag] )); then
  export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
  _fzf_compgen_path() {
    ag --no-color -g '' "$1"
  }
fi

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Uncomment to use --inline-info option
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --inline-info"

# Set colors defined by user
source "${0:h}/colors.zsh"
zstyle -s ':zim:fzf' colorscheme FZF_COLOR
if [[ ! -z "$FZF_COLOR" && ${fzf_colors["$FZF_COLOR"]} ]]; then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --color ${fzf_colors["$FZF_COLOR"]}"
fi

# Use preview window with Ctrl-T
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"

# If tree command is installed, show directory contents in preview pane when
# using ALT-C
if (( $+commands[tree] )); then
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
fi

# If fasd is loaded, pipe output to fzf
# Note that the `fzf-tmux` command works regardless of whether or not the user is
# in a tmux session. If no tmux session is detected, it acts just like `fzf`
if zstyle -t ':zim:fasd' loaded; then
  unalias j 2>/dev/null
  __fzf_cd() {
    local dir fzf
    fzf=$(__fzf_prog)
    dir="$(fasd -Rdl "$1" | ${=fzf} -1 -0 --no-sort +m)" && cd "${dir}" || return 1
  }
  alias j='__fzf_cd'
fi
