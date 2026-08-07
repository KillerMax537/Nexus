-- Arquivo: src/Core/Input.lua
local Input = {}

local holding = false

function Input.SetHold(state)
    if holding == state then return end
    holding = state
    
    if state then
        -- Segura o botão esquerdo do mouse
        if mouse1press then mouse1press() end
    else
        -- Solta o botão esquerdo do mouse
        if mouse1release then mouse1release() end
    end
end

function Input.Click()
    -- Dá um clique perfeito
    if mouse1click then
        mouse1click()
    else
        -- Fallback seguro
        if mouse1press and mouse1release then
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end
    end
end

function Input.IsHolding() 
    return holding 
end

return Input