-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local isBreaking = false

-- 1. Fica escutando os áudios oficiais do Minigame (A forma mais infalível)
task.spawn(function()
    while task.wait(1) do
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if ui then
            local sounds = ui:FindFirstChild("Sounds")
            if sounds then
                local startSnd = sounds:FindFirstChild("BreakpointStart")
                local successSnd = sounds:FindFirstChild("BreakpointSuccess")
                
                -- Se o som de obstáculo tocou, entra no modo Quebrar!
                if startSnd and not startSnd:GetAttribute("Hooked") then
                    startSnd.Played:Connect(function() 
                        if Nexus.Config.Enabled then isBreaking = true end
                    end)
                    startSnd:SetAttribute("Hooked", true)
                end
                
                -- Se o som de quebrado tocou, sai do modo Quebrar!
                if successSnd and not successSnd:GetAttribute("Hooked") then
                    successSnd.Played:Connect(function() 
                        isBreaking = false 
                    end)
                    successSnd:SetAttribute("Hooked", true)
                end
            end
        end
    end
end)

-- 2. Limpa o estado quando o minigame inicia ou termina
local FishingEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Fishing")
local evtConn = FishingEvent.OnClientEvent:Connect(function(event)
    if event == "StartMinigame" or event == "Cancel" or event == "Success" or event == "Fail" then
        isBreaking = false
        Input.SetHold(false)
    end
end)
table.insert(Nexus.Connections, evtConn)

-- 3. Loop Físico em Thread Dedicada (Não trava o jogo)
task.spawn(function()
    while task.wait(0.01) do
        if not Nexus.Config.Enabled then continue end
        
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if not ui or not ui.Enabled then continue end
        
        if isBreaking then
            -- Tem obstáculo! Solta a vara e atira cliques.
            Input.SetHold(false)
            task.wait(0.01) 
            Input.Click()
            task.wait(0.02)
        else
            -- Sem obstáculo! Segura a vara para a barra subir.
            Input.SetHold(true)
        end
    end
end)

return true