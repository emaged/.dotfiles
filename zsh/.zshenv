# Other dotfiles installations keep their existing agent unless this package is installed.
[[ -r "$HOME/.ssh/agent-routing.py" ]] || return

# Keep local shells on 1Password and preserve the socket supplied by SSH.
# Explicit choices are inherited by child shells, including Herdr terminals.
if [[ -z ${DOTFILES_AGENT_CHOICE:-} && -n ${SSH_CONNECTION:-} && -S ${SSH_AUTH_SOCK:-} &&
      ${DOTFILES_REGISTERED_AGENT:-} != ${SSH_AUTH_SOCK:-} ]]; then
    if /usr/bin/python3 "$HOME/.ssh/agent-routing.py" register >/dev/null 2>&1; then
        export DOTFILES_REGISTERED_AGENT="$SSH_AUTH_SOCK"
    fi
fi

case ${DOTFILES_AGENT_CHOICE:-} in
    local)
        export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
        unset SSH_AGENT_PID
        ;;
    omarchy|devtop)
        export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent-routing/${DOTFILES_AGENT_CHOICE}.sock"
        unset SSH_AGENT_PID
        ;;
    '')
        if [[ -z ${SSH_CONNECTION:-} ]]; then
            export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
            unset SSH_AGENT_PID
        fi
        ;;
esac

agent-use() {
    local agent_target agent_socket
    if (( $# == 0 )); then
        agent_target=${DOTFILES_AGENT_CHOICE:-local}
        [[ -z ${DOTFILES_AGENT_CHOICE:-} && -n ${SSH_CONNECTION:-} ]] && agent_target='incoming SSH'
        print -r -- "Approval source: $agent_target"
        print -r -- "Agent socket: ${SSH_AUTH_SOCK:-not set}"
        return
    fi
    if (( $# != 1 )); then
        print -u2 -- 'Usage: agent-use desktop|laptop|local'
        return 2
    fi
    case $1 in
        desktop|devtop) agent_target=devtop ;;
        laptop|omarchy) agent_target=omarchy ;;
        local) agent_target=local ;;
        *) print -u2 -- 'Usage: agent-use desktop|laptop|local'; return 2 ;;
    esac
    [[ $agent_target == ${HOST%%.*} ]] && agent_target=local
    agent_socket=$(/usr/bin/python3 "$HOME/.ssh/agent-routing.py" path "$agent_target") || return
    if [[ $agent_target != local && ! -S $agent_socket ]]; then
        print -u2 -- 'Agent routing service is unavailable. Check: systemctl --user status ssh-agent-routing'
        return 1
    fi
    export DOTFILES_AGENT_CHOICE="$agent_target" SSH_AUTH_SOCK="$agent_socket"
    unset SSH_AGENT_PID
    print -r -- "Approval source: $agent_target ($SSH_AUTH_SOCK)"
}

agent-status() {
    /usr/bin/python3 "$HOME/.ssh/agent-routing.py" status
}
