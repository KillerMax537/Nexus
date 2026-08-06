-- src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local isBreaking = false

-- Monitora os áudios do minigame de forma segura
local function MonitorAudioCues()
    local fishingUI = PlayerGui:FindFirstChild("FishingUI")
    if fishingUI then
        local sounds = fishingUI:FindFirstChild("Sounds")
        if sounds then
            local startSnd = sounds:FindFirstChild("BreakpointStart")
            local successSnd = sounds:FindFirstChild("BreakpointSuccess")
            
            if startSnd and not startSnd:GetAttribute("NexusHooked") then
                startSnd.Played:Connect(function() isBreaking = true end)
                startSnd:SetAttribute("NexusHooked", true)
            end
            if successSnd and not successSnd:GetAttribute("NexusHooked") then
                successSnd.Played:Connect(function() isBreaking = false end)
                successSnd:SetAttribute("NexusHooked", true)
            end
        end
    end
end

-- Mantém o estado sempre limpo quando os eventos do servidor disparam
local FishingEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Fishing")
local evtConn = FishingEvent.OnClientEvent:Connect(function(event)
    if event == "StartMinigame" then
        isBreaking = false
        MonitorAudioCues()
    elseif event == "Cancel" or event == "Success" or event == "Fail" then
        isBreaking = false
        Input.ForceRelease()
    end
end)
table.insert(Nexus.Connections, evtConn)

-- O Loop principal do Motor de Pesca
local loopConn = RunService.Heartbeat:Connect(function()
    if not Nexus.Config.Enabled then 
        Input.ForceRelease()
        return 
    end

    local fishingUI = PlayerGui:FindFirstChild("FishingUI")
    if not fishingUI or not fishingUI.Enabled then
        Input.ForceRelease()
        isBreaking = false
        return
    end

    MonitorAudioCues() -- Garante que estamos escutando

    -- Executa a Física
    if isBreaking then
        Input.SetHold(false)
        Input.FastClick()
    else
        Input.SetHold(true)
    end
end)
table.insert(Nexus.Connections, loopConn)

return true