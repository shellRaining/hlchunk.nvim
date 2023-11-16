---@class BaseMod
---@field meta MetaInfo
---@field conf BaseConf
---@field init fun(self: BaseMod, meta: MetaInfo, conf: BaseConf)
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod, range?: Scope)
---@field clear fun(self: BaseMod, range?: Scope)
---@field createUsercmd fun(self: BaseMod)
---@field createAutocmd fun(self: BaseMod)
---@field clearAutocmd fun(self: BaseMod)
---@field setHl fun(self: BaseMod)
---@field clearHl fun(self: BaseMod)
---@field notify fun(self: BaseMod, msg: string, level?: string, opts?: table)

---@alias StyleType string | table<string, string> | table<string, table<string, string>>

---@class BaseConf
---@field enable boolean
---@field style StyleType
---@field excludeFiletypes table<string, boolean>
---@field supportFiletypes table<string>
---@field notify boolean
---@field priority number

---@class MetaInfo
---@field name string
---@field augroupName string
---@field hlBaseName string
---@field nsId number
