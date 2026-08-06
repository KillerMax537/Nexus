-- src/Core/Environment.lua
-- Silencia o aviso do LSP criando um fallback falso para o corretor, mas que usa a função real no Executor.
local env = getgenv and getgenv() or shared
local HttpService = game:GetService("HttpService")

local Environment = {
    -- Variáveis globais do nosso script
    Config = {
        Enabled = false,
        AutoCast = false,
        RecastDelay = 2.0
    },
    Connections = {}, -- Guarda todos os loops para deletar depois
    FileName = "NexusFishing_Config.json"
}

-- Salva as configurações localmente no PC do usuário (na pasta workspace do Executor)
function Environment.SaveConfig()
    if writefile then
        local success, json = pcall(function()
            return HttpService:JSONEncode(Environment.Config)
        end)
        if success then
            writefile(Environment.FileName, json)
            return true
        end
    end
    return false
end

-- Carrega as configurações ao iniciar o script
function Environment.LoadConfig()
    if readfile and isfile and isfile(Environment.FileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(Environment.FileName))
        end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do
                Environment.Config[k] = v
            end
        end
    end
end

-- Sistema de descarregamento (Anti-Lag / Clean up)
function Environment.Unload()
    -- Desconecta todos os eventos e loops
    for _, connection in ipairs(Environment.Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    table.clear(Environment.Connections)

    -- Deleta a interface
    if env.Nexus and env.Nexus.Window then
        env.Nexus.Window:Destroy()
    end

    -- Limpa a global
    env.Nexus = nil
end

-- Registra a tabela no ambiente global do Executor
env.Nexus = Environment
env.Nexus.LoadConfig()

return Environment