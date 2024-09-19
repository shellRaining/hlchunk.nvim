local hlchunk = {}

---@class HlChunk.UserConf
---@field blank? HlChunk.UserBlankConf
---@field chunk? HlChunk.UserChunkConf
---@field indent? HlChunk.UserIndentConf
---@field line_num? HlChunk.UserLineNumConf

---@param userConf HlChunk.UserConf
hlchunk.setup = function(userConf)
    for mod_name, mod_conf in pairs(userConf) do
        if mod_conf.enable then
            local mod_path = "hlchunk.mods." .. mod_name
            local Mod = require(mod_path) --[[@as HlChunk.BaseMod]]
            local mod = Mod(mod_conf)
            mod:enable()
        end
    end
end

return hlchunk
