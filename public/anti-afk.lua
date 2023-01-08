---@diagnostic disable: undefined-global

if not game.IsLoaded then game.Loaded:Wait() end

local VirtualUser   = game:GetService("VirtualUser")
local Players       = game:GetService("Players")

repeat task.wait() until Players.LocalPlayer

Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
end)

warn("Lunaware Engine: Loaded Anti-AFK")
