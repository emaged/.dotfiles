# -------------------------------
# 1. PATH & Environment
# -------------------------------

# Base PATH additions
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export PATH="/usr/lib/llvm-20/bin:$PATH"
export PATH="$HOME/.local/luas/5.1/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"


. "$HOME/.local/share/../bin/env"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/emiel/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/emiel/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<


# Added by Toolbox App
export PATH="$PATH:/home/emiel/.local/share/JetBrains/Toolbox/scripts"
