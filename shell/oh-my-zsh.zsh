ZSH="$HOME/.oh-my-zsh"
# ZSH_CUSTOM=/path/to/new-custom-folder

# oh-my-zsh settings
# COMPLETION_WAITING_DOTS="true"
# DISABLE_AUTO_TITLE="true"
# DISABLE_LS_COLORS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# ENABLE_CORRECTION="true"  # command auto-correction
# HIST_STAMPS="mm/dd/yyyy"
ZSH_THEME="sporty_256"  # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

zstyle ':omz:update' frequency 14  # update oh-my-zsh every 2 weeks

# Completion settings
export CASE_SENSITIVE="false"  # case-sensitive completion
export HYPHEN_SENSITIVE="false"  # hyphen-insensitive completion

# Plugins
# plugins=(git virtualenvwrapper)
plugins=(git)
