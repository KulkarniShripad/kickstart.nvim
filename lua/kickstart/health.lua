--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
    local verstr = tostring(v.version())
    if not v.version.ge then
        v.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
        return
    end

    if v.version.ge(v.version(), '0.11') then
        v.health.ok(string.format("Neovim version is: '%s'", verstr))
    else
        v.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    end
end

local check_external_reqs = function()
    -- Basic utils: `git`, `make`, `unzip`
    for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
        local is_executable = v.fn.executable(exe) == 1
        if is_executable then
            v.health.ok(string.format("Found executable: '%s'", exe))
        else
            v.health.warn(string.format("Could not find executable: '%s'", exe))
        end
    end

    return true
end

return {
    check = function()
        v.health.start 'kickstart.nvim'

        v.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

        local uv = v.uv or v.loop
        v.health.info('System Information: ' .. v.inspect(uv.os_uname()))

        check_version()
        check_external_reqs()
    end,
}
