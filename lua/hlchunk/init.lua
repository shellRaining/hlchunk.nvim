local hlchunk = {}

hlchunk.setup = function(userConf)
    require("hlchunk.utils.string")
    for mod_name, mod_conf in pairs(userConf) do
        if mod_conf.enable then
            local mod_path = "hlchunk.mods." .. mod_name
            local Mod = require(mod_path) --[[@as BaseMod]]
            local mod = Mod(mod_conf)
            -- mod.conf = vim.tbl_deep_extend("force", mod.conf, mod_conf or {})
            mod:enable()
            -- vim.notify(vim.inspect(mod))
        end
    end
end

return hlchunk
