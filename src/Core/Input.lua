-- src/Core/Input.lua
local Input = {}
local VIM = game:GetService("VirtualInputManager")

local holding = false

function Input.SetHold(state)
    if holding == state then return end
    holding = state
    VIM:SendMouseButtonEvent(0, 0, 0, state, nil, 0)
end

function Input.Click()
    VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

function Input.WorldClick()
    VIM:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
end

function Input.IsHolding()
    return holding
end

function Input.ForceRelease()
    if holding then
        VIM:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
        holding = false
    end
end

return Input