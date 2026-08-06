-- src/Tabs/Settings.lua
local getgenv = getgenv or function() return shared end
local Nexus = getgenv().Nexus
local Window = Nexus.Window

local Tab = Window:CreateTab("Settings")

Tab:AddButton("Save Configuration", function()
    local success = Nexus.SaveConfig()
    if success then
        Nexus.Log("✅ Configurações salvas no computador!")
    else
        Nexus.Log("❌ Erro ao salvar configurações.")
    end
end)

Tab:AddButton("Unload Script (Close)", function()
    Nexus.Log("Desligando script e limpando memória...")
    task.wait(0.5)
    Nexus.Unload()
end)

return true