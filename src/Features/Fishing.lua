-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local activeBreakpoints = 0

-- 1. Monitora os Áudios do Minigame para saber EXATAMENTE quantos breakpoints existem
task.spawn(function()
    while task.wait(0.5) do
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if ui then
            local sounds = ui:FindFirstChild("Sounds")
            if sounds then
                local startSnd = sounds:FindFirstChild("BreakpointStart")
                local successSnd = sounds:FindFirstChild("BreakpointSuccess")
                
                if startSnd and not startSnd:GetAttribute("NexusHooked") then
                    startSnd.Played:Connect(function() 
                        if Nexus.Config.Enabled then 
                            activeBreakpoints = activeBreakpoints + 1 
                        end
                    end)
                    startSnd:SetAttribute("NexusHooked", true)
                end
                
                if successSnd and not successSnd:GetAttribute("NexusHooked") then
                    successSnd.Played:Connect(function() 
                        activeBreakpoints = math.max(0, activeBreakpoints - 1) 
                    end)
                    successSnd:SetAttribute("NexusHooked", true)
                end
            end
        end
    end
end)

-- 2. Limpa o contador se o minigame acabar ou cancelar
local FishingEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Fishing")
local evtConn = FishingEvent.OnClientEvent:Connect(function(event)
    if event == "StartMinigame" or event == "Cancel" or event == "Success" or event == "Fail" then
        activeBreakpoints = 0
        Input.SetHold(false)
    end
end)
table.insert(Nexus.Connections, evtConn)

-- 3. Loop Físico em Thread Limpa
task.spawn(function()
    while task.wait(0.01) do
        if not Nexus.Config.Enabled then continue end
        
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if not ui or not ui.Enabled then continue end
        
        if activeBreakpoints > 0 then
            -- TEM OBSTÁCULO: Solta a linha e metralha
            if Input.IsHolding() then
                Input.SetHold(false)
                task.wait(0.02) -- Tempo para o servidor registrar o "soltar"
            end
            
            Input.Click()
            task.wait(0.03) -- Bate nos 6 cliques rapidamente sem crashar
        else
            -- SEM OBSTÁCULO: Puxa o peixe
            if not Input.IsHolding() then
                Input.SetHold(true)
            end
        end
    end
end)

return true