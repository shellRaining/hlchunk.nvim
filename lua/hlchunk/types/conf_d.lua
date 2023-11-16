---@alias StyleType string | table<string, string> | table<string, table<string, string>>

---@class BaseConf
---@field enable boolean
---@field style StyleType
---@field excludeFiletypes table<string, boolean>
---@field supportFiletypes table<string>
---@field notify boolean
