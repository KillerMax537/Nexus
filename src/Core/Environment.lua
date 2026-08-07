-- src/Core/Environment.lua
local env = getgenv and getgenv() or shared
local HttpService = game:GetService("HttpService")

local Environment = {
    Config = {
        MasterActive = false,
        AutoFisher = false,
        AutoCast = false,
        RecastDelay = 2.0
    },
    Connections = {},
    FileName = "NexusFishing_Config.json"
}

function Environment.SaveConfig()
    if writefile then
        local success, json = pcall(function()
            return HttpService:JSONEncode(Environment.Config)
        end)
        if success then
            writefile(Environment.FileName, json)
            return true
        end
    end
    return false
end

function Environment.LoadConfig()
    if readfile and isfile and isfile(Environment.FileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(Environment.FileName))
        end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do
                if Environment.Config[k] ~= nil then
                    Environment.Config[k] = v
                end
            end
        end
    end
end

function Environment.Unload()
    for _, connection in ipairs(Environment.Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    table.clear(Environment.Connections)

    if env.Nexus and env.Nexus.Window then
        env.Nexus.Window:Destroy()
    end

    env.Nexus = nil
end

env.Nexus = Environment
env.Nexus.LoadConfig()

return Environment