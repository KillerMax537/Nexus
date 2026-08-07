-- src/Tabs/Automations.lua
local Nexus = getgenv().Nexus
local Window = Nexus.Window

local Tab = Window:CreateTab("Automations")

Tab:AddToggle("Master Enable", Nexus.Config.MasterActive, function(state)
    Nexus.Config.MasterActive = state
    if not state then
        Nexus.Input.ForceRelease()
    end
    Nexus.Notify("Master " .. (state and "ON" or "OFF"), 2)
    Nexus.Log("Master toggled: " .. tostring(state))
end)

Tab:AddToggle("Auto-Fisher (Minigame)", Nexus.Config.AutoFisher, function(state)
    Nexus.Config.AutoFisher = state
    if not state then
        Nexus.Input.ForceRelease()
    end
    Nexus.Log("Auto-Fisher " .. (state and "ON" or "OFF"))
end)

Tab:AddToggle("Smart Auto-Cast", Nexus.Config.AutoCast, function(state)
    Nexus.Config.AutoCast = state
    Nexus.Log("Auto-Cast " .. (state and "ON" or "OFF"))
end)

return true