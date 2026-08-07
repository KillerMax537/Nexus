-- Main.lua
local getgenv = getgenv or function() return shared end

-- Carrega o ambiente primeiro (define Nexus e carrega configs)
local envModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/KillerMax537/Nexus/main/src/Core/Environment.lua"))()
if not envModule then return warn("Environment failed") end

local Nexus = getgenv().Nexus

-- Carrega os módulos core
Nexus.Input = loadstring(game:HttpGet("https://raw.githubusercontent.com/KillerMax537/Nexus/main/src/Core/Input.lua"))()
Nexus.UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/KillerMax537/Nexus/main/src/Core/UILibrary.lua"))()

if not Nexus.Input or not Nexus.UI then
    return warn("Core modules failed")
end

-- Cria a janela
Nexus.Window = Nexus.UI:CreateWindow("NEXUS")

-- Carrega as abas (a ordem importa para o console)
local tabs = {
    "src/Tabs/Logs.lua",
    "src/Tabs/Automations.lua",
    "src/Tabs/Settings.lua"
}
for _, path in ipairs(tabs) do
    local success, err = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/KillerMax537/Nexus/main/" .. path))()
    end)
    if not success then
        warn("Failed to load tab: " .. path .. " - " .. tostring(err))
    end
end

-- Inicia o módulo de pesca
local fishingOk = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/KillerMax537/Nexus/main/src/Features/MasterFishing.lua"))()
end)
if not fishingOk then
    Nexus.Log("Fishing module failed to load.")
else
    Nexus.Log("Fishing module loaded.")
end

-- Inicializa a primeira aba
Nexus.Window:Init()

Nexus.Notify("Nexus ABD Hub Loaded!", 3)
Nexus.Log("Hub initialized.")