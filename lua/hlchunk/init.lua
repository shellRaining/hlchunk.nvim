local hlchunk = {}

hlchunk.setup = function(userConf)
    for mod_name, mod_conf in pairs(userConf) do
        if mod_conf.enable then
            -- mod_name = underscoreToCamelCase(mod_name)
            local mod_path = "hlchunk.mods." .. mod_name
            local Mod = require(mod_path) --[[@as BaseMod]]
            local mod = Mod(mod_conf)
            mod:enable()
        end
    end
end

return hlchunk
