# -------------------------------
# 1. PATH & Environment
# -------------------------------
# Base PATH additions
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.local/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:"$HOME/.juliaup/bin":*)
        ;;

    *)
        export PATH="$HOME/.juliaup/bin${PATH:+:${PATH}}"
        ;;
esac

# <<< juliaup initialize <<<


# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"
