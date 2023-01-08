-- WARNING: This function may decrease performance and there is no gurantee that all models will be rendered.
---@diagnostic disable: undefined-global

local HttpService		= game:GetService("HttpService")
local RunService		= game:GetService("RunService")
local Players			= game:GetService("Players")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")

if not game.IsLoaded then game.Loaded:Wait() end
repeat task.wait() until Players.LocalPlayer
LocalPlayer = Players.LocalPlayer

sethiddenproperty(workspace, "StreamOutBehavior", Enum.StreamOutBehavior.Opportunistic)
sethiddenproperty(workspace, "StreamingIntegrityMode", Enum.StreamingIntegrityMode.Disabled)
sethiddenproperty(workspace, "StreamingTargetRadius", 1e9)
sethiddenproperty(workspace, "StreamingMinRadius", 1e9)

if not workspace.StreamingEnabled then
	warn("Lunaware Engine: Streaming is already disabled in this experience.")
	return end

function requestStream (Instance)
	task.spawn(function()
		if not Instance then return end

		if Instance:IsA("Model") or Instance:IsA("Actor") then
			Instance.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled
	
			LocalPlayer:RequestStreamAroundAsync(Instance:GetPivot().Position)
		end
	end)
end

workspace.DescendantAdded:Connect(function(Descendant)
	pcall(requestStream, Descendant)
end)

for _, Descendant in pairs(workspace:GetDescendants()) do
	pcall(requestStream, Descendant)
end

warn("Lunaware Engine: Disabled Streaming.")