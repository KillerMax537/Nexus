-- loader.lua
local getgenv = getgenv or function() return shared end
local GITHUB_REPO = "https://raw.githubusercontent.com/KillerMax537/Nexus/main/"

local function requireModule(path)
    local url = GITHUB_REPO .. path
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then warn("[NexusHub] Erro ao carregar: " .. path, result) end
    return result
end

-- 1. Inicia o Ambiente e carrega configs salvas no JSON
requireModule("src/Core/Environment.lua")
local Nexus = getgenv().Nexus
Nexus.Require = requireModule

-- 2. Carrega Sistemas Core
Nexus.UI = Nexus.Require("src/Core/UILibrary.lua")
Nexus.Input = Nexus.Require("src/Core/Input.lua")

-- 3. Cria a Interface
Nexus.Window = Nexus.UI:CreateWindow("NEXUS", "FISHING HUB")

-- 4. Injeta as Abas
Nexus.Require("src/Tabs/Automations.lua")
Nexus.Require("src/Tabs/Logs.lua")
Nexus.Require("src/Tabs/Settings.lua") -- Aba nova de configurações

-- 5. Inicializa Interface e Lógicas
Nexus.Window:Init()
Nexus.Require("src/Features/Fishing.lua")
Nexus.Require("src/Features/AutoCast.lua")

Nexus.Log("Hub Inicializado. Configurações carregadas.")