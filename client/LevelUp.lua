local Level = game.Players.LocalPlayer:WaitForChild("PlrInfo"):WaitForChild("Level")
local LevelChangeAnimationInProgress = false
local LevelUpFrame = script.Parent.Parent.Guis.MainMenu.LevelUp

local TweenService = game:GetService("TweenService")
local function doTween(object,position,size,TimeTaken,boolwait)
	local info = TweenInfo.new(
		TimeTaken,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)
	local tween = TweenService:Create(object,info,{Position = position,Size = size})
	tween:Play()
	if boolwait ~= nil then
		wait(TimeTaken)
	end
end

repeat wait(0.0001) until script.Parent.Parent.Guis.MainMenu.Visible == true --WaitToStartPlaying

local function LeveledUp()
	if LevelChangeAnimationInProgress == false then
		LevelChangeAnimationInProgress = true
		--
		repeat wait(0.0001) until script.Parent.Parent.Guis.MainMenu.Visible == true
		LevelUpFrame.Visible = true
		
		LevelUpFrame.LevelDisplay.Position = UDim2.new(0.496, 0,0.535, 0)
		LevelUpFrame.LevelDisplay.Size = UDim2.new(0.038, 0,0.068, 0)
		doTween(LevelUpFrame.LevelDisplay,UDim2.new(0.425, 0,0.341, 0),UDim2.new(0.147, 0,0.363, 0),2)
		wait(2)
		LevelUpFrame.Visible = false
		--
		LevelChangeAnimationInProgress = false
	end
end

Level:GetPropertyChangedSignal("Value"):Connect(function()
	LeveledUp()
end)