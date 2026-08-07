--[[
    Nexus ABD Hub - Official Bootstrapper
    Developer: KillerMax537
]]

local getgenv = getgenv or function() return shared end
local GITHUB_REPO = "https://raw.githubusercontent.com/KillerMax537/Nexus/main/"

-- 1. Setup Global Nexus Environment
getgenv().Nexus = {
    Config = {
        Enabled = false,
        AutoCast = false,
        RecastDelay = 0.15 -- Ultra-fast recast delay
    },
    Connections = {}, -- Stores all loops to safely unload later
    Require = function(path)
        local url = GITHUB_REPO .. path
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if not success then
            warn("[Nexus ABD] Failed to load module: " .. path .. "\nError: " .. tostring(result))
        end
        return result
    end
}

local Nexus = getgenv().Nexus

-- 2. Load Core Libraries
Nexus.UI = Nexus.Require("src/Core/UILibrary.lua")
Nexus.Input = Nexus.Require("src/Core/Input.lua")

if not Nexus.UI then
    return warn("[Nexus ABD] UI Library failed to load. Check your GitHub paths!")
end

-- 3. Create Main UI Window
Nexus.Window = Nexus.UI:CreateWindow("NEXUS", "ABD")

-- ==========================================
-- 4. BUILD TABS & MENUS
-- ==========================================

-- [ TAB 1: Automations ] --
local TabFisher = Nexus.Window:CreateTab("Automations")

TabFisher:AddToggle("Enable Auto-Fisher", Nexus.Config.Enabled, function(state)
    Nexus.Config.Enabled = state
    
    -- Safety release if disabled while holding
    if not state and Nexus.Input.IsHolding() then
        Nexus.Input.SetHold(false)
    end
    
    Nexus.Notify("Auto-Fisher is now " .. (state and "ON" or "OFF"), 2)
end)

TabFisher:AddToggle("Enable Auto-Cast (0.15s)", Nexus.Config.AutoCast, function(state)
    Nexus.Config.AutoCast = state
    Nexus.Notify("Auto-Cast is now " .. (state and "ON" or "OFF"), 2)
end)

-- [ TAB 2: Settings ] --
local TabSettings = Nexus.Window:CreateTab("Settings")

TabSettings:AddButton("Unload Hub (Destroy)", function()
    Nexus.Notify("Unloading Nexus ABD...", 2)
    task.wait(0.5)

    -- 1. Release mouse if holding
    if Nexus.Input and Nexus.Input.IsHolding() then
        Nexus.Input.SetHold(false)
    end

    -- 2. Disconnect all backend loops (Heartbeat, Attributes)
    for _, conn in ipairs(Nexus.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    table.clear(Nexus.Connections)

    -- 3. Destroy UI
    if Nexus.Window then
        Nexus.Window:Destroy()
    end

    -- 4. Clear Global Variable
    getgenv().Nexus = nil
end)

-- ==========================================
-- 5. LOAD BACKEND FEATURES & START
-- ==========================================
Nexus.Require("src/Features/Fishing.lua")
Nexus.Require("src/Features/AutoCast.lua")

-- Initialize the Window (Highlights the first tab)
Nexus.Window:Init()

-- Welcome Messages
Nexus.Notify("Welcome to Nexus ABD Hub!", 3)
Nexus.Notify("Equip your fishing rod to start.", 4)