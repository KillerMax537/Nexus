-- src/Tabs/Settings.lua
local env = getgenv and getgenv() or shared
local Nexus = env.Nexus
local Window = Nexus.Window

local Tab = Window:CreateTab("Settings")

Tab:AddButton("Save Configs", function()
    if Nexus.SaveConfig then
        local success = Nexus.SaveConfig()
        Nexus.Log(success and "✅ Configs saved!" or "❌ Error saving configs.")
    else
        Nexus.Log("SaveConfig not available.")
    end
end)

Tab:AddButton("Unload & Exit", function()
    Nexus.Log("Unloading...")
    Nexus.Input.ForceRelease()

    for _, conn in ipairs(Nexus.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    table.clear(Nexus.Connections)

    if Nexus.Window then
        Nexus.Window:Destroy()
    end

    env.Nexus = nil
end)

return true