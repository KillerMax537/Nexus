-- Arquivo: src/Tabs/Automations.lua
local Nexus = getgenv().Nexus
local Window = Nexus.Window

local Tab = Window:CreateTab("Automations")

Tab:AddToggle("Enable Auto-Fisher", Nexus.Config.Enabled, function(state)
    Nexus.Config.Enabled = state
    if not state then Nexus.Input.SetHold(false) end
    Nexus.Log("Auto-Fisher " .. (state and "Ativado" or "Desativado"))
end)

Tab:AddToggle("Smart Auto-Cast", Nexus.Config.AutoCast, function(state)
    Nexus.Config.AutoCast = state
    Nexus.Log("Auto-Cast " .. (state and "Ativado" or "Desativado"))
end)

return true