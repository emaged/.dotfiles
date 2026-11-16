return {
    entry = function()
        local output, err = Command("git"):arg("status"):stderr(Command.PIPED):output()
        if not output or not output.status.success then
            ya.notify({
                title = "lazygit",
                content = output and output.stderr or ("Unable to run git: " .. tostring(err)),
                level = "warn",
                timeout = 5,
            })
            return
        end

        local permit = ui.hide()
        local child
        child, err = Command("lazygit"):stdin(Command.INHERIT):stdout(Command.INHERIT):stderr(Command.PIPED):spawn()
        if child then
            output, err = child:wait_with_output()
        else
            output = nil
        end
        permit:drop()

        if not output then
            ya.notify({
                title = "Failed to run lazygit command",
                content = tostring(err),
                level = "error",
                timeout = 5,
            })
        elseif not output.status.success then
            ya.notify({
                title = "lazygit failed, exit code " .. tostring(output.status.code),
                content = output.stderr,
                level = "error",
                timeout = 5,
            })
        end
    end,
}
