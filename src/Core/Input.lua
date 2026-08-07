local Input = {}
local VIM = game:GetService("VirtualInputManager")

local holding = false

function Input.SetHold(state)
    if holding == state then return end
    holding = state
    VIM:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

function Input.Click()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function Input.WorldClick()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function Input.IsHolding() return holding end
return Input