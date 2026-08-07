--[[
    Nexus ABD Hub - Official Bootstrapper
    Developer: KillerMax537
]]

local getgenv = getgenv or function() return shared end
local GITHUB_REPO = "https://raw.githubusercontent.com/KillerMax537/Nexus/main/"

getgenv().Nexus = {
    Config = {
        MasterActive = false,
        RecastDelay = 0.15
    },
    Connections = {},
    Require = function(path)
        local url = GITHUB_REPO .. path
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if not success then
            warn("[Nexus ABD] Failed to load module: " + tostring(path))
        end
        return result
    end
}

local Nexus = getgenv().Nexus

Nexus.UI = Nexus.Require("src/Core/UILibrary.lua")
Nexus.Input = Nexus.Require("src/Core/Input.lua")

if not Nexus.UI then
    return warn("[Nexus ABD] UI Library failed to load.")
end

Nexus.Window = Nexus.UI:CreateWindow("NEXUS")
Nexus.Window:CreateConsoleTab("Console", "🖥️")

local TabMain = Nexus.Window:CreateTab("Automations", "⚡")

TabMain:AddToggle("Master Auto-Fishing (Fisher + Cast)", Nexus.Config.MasterActive, function(state)
    Nexus.Config.MasterActive = state
    if not state and Nexus.Input.IsHolding() then
        Nexus.Input.SetHold(false)
    end
    Nexus.Notify("Master Auto-Fishing is " .. (state and "ACTIVE" or "OFF"), 2)
    if Nexus.Log then Nexus.Log("Master Toggle changed to: " .. tostring(state)) end
end)

local TabSettings = Nexus.Window:CreateTab("Settings", "⚙️")

TabSettings:AddButton("Unload Hub", function()
    Nexus.Notify("Unloading Nexus ABD...", 2)
    task.wait(0.5)

    if Nexus.Input and Nexus.Input.IsHolding() then
        Nexus.Input.SetHold(false)
    end

    for _, conn in ipairs(Nexus.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    table.clear(Nexus.Connections)

    if Nexus.Window then
        Nexus.Window:Destroy()
    end

    getgenv().Nexus = nil
end)

Nexus.Require("src/Features/MasterFishing.lua")

Nexus.Window:Init()
Nexus.Notify("Welcome to Nexus ABD Hub!", 3)
if Nexus.Log then Nexus.Log("Hub loaded successfully.") end