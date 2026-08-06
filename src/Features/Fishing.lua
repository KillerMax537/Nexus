-- src/Features/Fishing.lua
local getgenv = getgenv or function() return shared end
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Nexus = getgenv().Nexus
local Input = Nexus.Input

-- Salvamos a conexão na tabela 'Connections' para poder desligá-la depois
local loopConnection = RunService.Heartbeat:Connect(function()
    if not Nexus.Config.Enabled then 
        Input.SetHold(false) 
        return 
    end

    local fishingUI = Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("FishingUI")
    if not fishingUI or not fishingUI.Enabled then
        Input.SetHold(false)
        return
    end

    local bpFolder = fishingUI:FindFirstChild("FishingFrame") 
        and fishingUI.FishingFrame:FindFirstChild("FishingRodMain") 
        and fishingUI.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")

    if bpFolder then
        local isObstacleVisible = false
        for _, bp in ipairs(bpFolder:GetChildren()) do
            if bp:IsA("Frame") and bp.Visible then
                isObstacleVisible = true
                break
            end
        end

        if isObstacleVisible then
            Input.SetHold(false)
            Input.FastClick()
        else
            Input.SetHold(true)
        end
    else
        Input.SetHold(false)
    end
end)

table.insert(Nexus.Connections, loopConnection)

return true