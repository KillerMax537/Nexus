-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Nexus = env.Nexus
local Input = Nexus.Input

-- Thread de Alta Prioridade (Auto-Curável)
task.spawn(function()
    while task.wait(0.01) do
        if not Nexus.Config.Enabled then continue end
        
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if not ui or not ui.Enabled then continue end
        
        -- Varredura visual direta (a mais precisa)
        local bpFolder = ui:FindFirstChild("FishingFrame") 
            and ui.FishingFrame:FindFirstChild("FishingRodMain") 
            and ui.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")
        
        local hasBreakpoint = false
        if bpFolder then
            for _, bp in ipairs(bpFolder:GetChildren()) do
                if bp:IsA("Frame") and bp.Visible then
                    hasBreakpoint = true
                    break
                end
            end
        end

        -- O "Segredo": A cada 0.01s ele força o estado.
        -- Se você clicar manualmente, este loop vai sobrescrever seu clique 10ms depois.
        if hasBreakpoint then
            if Input.IsHolding() then Input.SetHold(false) end
            Input.Click()
        else
            if not Input.IsHolding() then Input.SetHold(true) end
        end
    end
end)

return true