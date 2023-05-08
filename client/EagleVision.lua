--EagleVision
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local EagleVision = script.Parent.Parent:WaitForChild("GameplayValues").EagleVision
local TARGETFOLDER = workspace.MissionWorkspace.Variables.TARGETS
local Viewport = script.Parent.Parent.Guis.SniperGui.ViewportFrame
Viewport.Visible = true
Viewport.ImageTransparency = 1
Viewport.CurrentCamera = workspace.CurrentCamera

--[[
TARGETFOLDER.ChildAdded:Connect(function()
	Viewport:ClearAllChildren()
	for _,Part in pairs(TARGETFOLDER:GetChildren()) do
		local EnemyClone = Part:Clone()
		EnemyClone.Parent = Viewport
	end	
end)
TARGETFOLDER.ChildRemoved:Connect(function()
	Viewport:ClearAllChildren()
	for _,Part in pairs(TARGETFOLDER:GetChildren()) do
		local EnemyClone = Part:Clone()
		EnemyClone.Parent = Viewport
	end	
end)
]]--

local function DoTween(EnterOrExit)
	local P= TweenInfo.new(
		0.3,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)
	if EnterOrExit == "ENTER" then
		local Tween = TweenService:Create(Viewport,P,{ImageTransparency = 0})
		Tween:Play()
		wait(0.3)
	elseif EnterOrExit == "EXIT" then
		local Tween = TweenService:Create(Viewport,P,{ImageTransparency = 1})
		Tween:Play()
		wait(0.3)
	end
end

UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then --RightButtonDown
		EagleVision.Value = true
	end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType  == Enum.UserInputType.MouseButton2 then --RightButtonUp
		EagleVision.Value = false
	end
end)

EagleVision:GetPropertyChangedSignal("Value"):Connect(function()
	if EagleVision.Value == true then
		DoTween("ENTER")
	else
		DoTween("EXIT")
	end
end)

while true do
	wait(0.1)
	Viewport:ClearAllChildren()
	for _,Part in pairs(TARGETFOLDER:GetChildren()) do
		local EnemyClone = Part:Clone()
		EnemyClone.Parent = Viewport
	end	
end
