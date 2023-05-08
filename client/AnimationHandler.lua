local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

local function PlaceCharacterInPlace()
	--RemoveCurrentSnipers
	for _,Part in pairs(Character:GetChildren()) do
		if Part.Name == "Sniper" then
			Part:Destroy()
		end
	end
	
	--StopCurrentAnimations
	local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator")
	for _,Anim in pairs(Animator:GetPlayingAnimationTracks()) do
		Anim:Stop()
	end
	
	--PlaceCharacter
	local Assets = workspace:WaitForChild("Assets")
	Character:WaitForChild("HumanoidRootPart").Anchored = true
	Character:WaitForChild("HumanoidRootPart").CFrame = Assets.HumanoidRootPart.CFrame
	
	--NewSniper
	local Sniper = game.ReplicatedStorage.Sniper:Clone()
	Sniper.Parent = Character
	Character:WaitForChild("RightHand",900)--("RightHand")
	local NewMotor6D = Instance.new("Motor6D",Sniper)
	NewMotor6D.Part0 = Sniper
	NewMotor6D.Part1 = Character.RightHand--RightHand
	Sniper.Anchored = false
	
	--DoAnimation
	local Standing = Animator:LoadAnimation(script.SniperPoseStanding)
	local speed = Standing.Length / 10
	Standing:AdjustSpeed(speed)
	Standing.Looped = true
	Standing:Play()
end

game.ReplicatedStorage.ReloadSniper.OnClientEvent:Connect(function()
	PlaceCharacterInPlace()
end)

PlaceCharacterInPlace()

