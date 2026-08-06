-- Arquivo: src/Tabs/Settings.lua
local env = getgenv and getgenv() or shared
local Nexus = env.Nexus
local Window = Nexus.Window

local Tab = Window:CreateTab("Settings")

Tab:AddButton("Save Configs", function()
    if Nexus.SaveConfig then
        local success = Nexus.SaveConfig()
        Nexus.Log(success and "✅ Configs saved!" or "❌ Error saving configs.")
    end
end)

Tab:AddButton("Unload & Exit (Desligar)", function()
    Nexus.Log("Desligando...")
    
    -- 1. Solta o mouse se estiver segurando
    if Nexus.Input and Nexus.Input.ForceRelease then
        Nexus.Input.ForceRelease()
    end

    -- 2. Destrói os loops (Heartbeat)
    if Nexus.Connections then
        for _, conn in ipairs(Nexus.Connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
    end
    
    -- 3. Destrói a Interface Gráfica
    if Nexus.Window then
        Nexus.Window:Destroy()
    end
    
    -- 4. Limpa a variável
    env.Nexus = nil
end)

Tab:AddSlider("UI Scale", 0.5, 1.5, 1, function(val) Nexus.Window:SetScale(val) end)

return true