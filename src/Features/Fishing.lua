-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

RunService.Heartbeat:Connect(function()
    if not Nexus.Config.Enabled then 
        Input.SetHold(false) 
        return 
    end

    local ui = PlayerGui:FindFirstChild("FishingUI")
    if not ui or not ui.Enabled then
        Input.SetHold(false)
        return
    end

    local bpFolder = ui:FindFirstChild("FishingFrame") 
        and ui.FishingFrame:FindFirstChild("FishingRodMain") 
        and ui.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")

    if bpFolder then
        local targetBP = nil
        
        -- Busca o breakpoint mais urgente (o primeiro que aparecer visível)
        for _, bp in ipairs(bpFolder:GetChildren()) do
            if bp:IsA("Frame") and bp.Visible then
                targetBP = bp
                break
            end
        end

        if targetBP then
            -- Temos um breakpoint! Solta a linha e clica EXATAMENTE no centro dele
            Input.SetHold(false)
            local pos = targetBP.AbsolutePosition + (targetBP.AbsoluteSize / 2)
            Input.DirectClick(pos.X, pos.Y)
        else
            -- Sem breakpoints: Puxa o peixe
            if not Input.IsHolding() then
                Input.SetHold(true)
            end
        end
    end
end)

return true