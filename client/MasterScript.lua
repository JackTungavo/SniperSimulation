local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
--// Variables
local Camera = workspace.CurrentCamera
repeat
	Camera.CameraType = Enum.CameraType.Scriptable
	wait()
until Camera.CameraType == Enum.CameraType.Scriptable
local mouse = game:GetService("Players").LocalPlayer:GetMouse()
local GameplayValues = script.Parent.Parent:WaitForChild("GameplayValues")
local GameplaySounds = script.Parent.Parent:WaitForChild("GameplaySounds")
local GunValues = game.Players.LocalPlayer:WaitForChild("PlrInfo"):WaitForChild("GunValues")
local Guis = script.Parent.Parent:WaitForChild("Guis")
local Assets = workspace:WaitForChild("Assets")
Assets.PlayerBasePart.Transparency = 0
local TargetPart = Assets:WaitForChild("TargetPart")
local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
repeat
	Camera.CameraType = Enum.CameraType.Scriptable
	wait()
until Camera.CameraType == Enum.CameraType.Scriptable


--//Functions
local function TweenCamera(targetCFrame,boolWait,TimeTaken)
	if TimeTaken == nil then
		local tweenInfo = TweenInfo.new(
			GameplayValues.AimSpeed.Value,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Camera,tweenInfo, {CFrame = targetCFrame})
		tween:Play()
		if boolWait == nil then
			wait(GameplayValues.AimSpeed.Value)
		end
	else
		local tweenInfo = TweenInfo.new(
			TimeTaken,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)
		local tween = TweenService:Create(Camera,tweenInfo, {CFrame = targetCFrame})
		tween:Play()
		if boolWait == nil then
			wait(TimeTaken)
		end
	end
end
local function TweenGui(Object,targetPosition,targetSize,TimeTaken)
	local tweenInfo = TweenInfo.new(
		TimeTaken,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)
	local tween = TweenService:Create(Object,tweenInfo, {Position = targetPosition,Size = targetSize})
	tween:Play()
	wait(TimeTaken)
end
local function BulletTravel(Object,targetCFrame,TimeTaken)
	local rayParams = RaycastParams.new()
	local filterTable = {Object,TargetPart}
	for _,Part in pairs(workspace:GetDescendants()) do
		if Part:IsA("BasePart") or Part:IsA("MeshPart") or Part:IsA("UnionOperation") then
			if Part.CanCollide == false then
				filterTable[#filterTable + 1] = Part
			end
		end
	end
	rayParams.FilterDescendantsInstances = filterTable
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local tweenInfo = TweenInfo.new(
		TimeTaken,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out,
		0,
		false,
		0
	)

	local rayOrigin = Assets.ActiveCameraPart.Position
	local rayDirection = (TargetPart.Position - rayOrigin).Unit --Assets.ActiveCameraPart.CFrame.LookVector*5000--
	local TargetRay = workspace:Raycast(rayOrigin, rayDirection*5000, rayParams)
	local intersection = TargetRay and TargetRay.Position or rayOrigin + rayDirection
	local distance = (rayOrigin - intersection).Magnitude
	
	--CheckRayWorks
		--local VisualRay =Instance.new("Part",workspace)
		--VisualRay.Anchored = true
		--VisualRay.Size = Vector3.new(0.1,0.1,distance)
		--VisualRay.Material = Enum.Material.Neon
		--VisualRay.CFrame = CFrame.new(rayOrigin, intersection)*CFrame.new(0, 0, -distance/2)
	
	local position = TargetPart.Position

	if TargetRay and TargetRay.Instance.CanCollide == true then
		position = TargetRay.Position
	end
	--local _,position = workspace:FindPartOnRayWithIgnoreList(TargetRay, TargetPart)
	
	Object.CFrame = Assets.ActiveCameraPart.CFrame * CFrame.new(0,0,-2)
	local tween = TweenService:Create(Object,tweenInfo,{Position = position})--{CFrame = targetCFrame})
	Object.Changed:Connect(function(whatproperty)
		--print(whatproperty)
		if whatproperty ~= Object.Color then
			Camera.CFrame = CFrame.new(Object.Position + Object.CFrame.lookVector*-2+Vector3.new(2,0,-3), Object.Position)--Vector3.new(0,2,-5), Object.Position)
		end
		--[[
		if whatproperty ~= "Orientation" and whatproperty ~= "Rotation" then
			print(whatproperty)
			Object.CFrame = CFrame.new(Object.Position) * CFrame.Angles(math.rad(Object.Orientation.X + 10), 0, math.rad(Object.Orientation.Z + 10))
		else
			wait(0.0001)
		end
		]]--
	end)
	tween:Play()
	local finished = false
	local failed = false
	
	tween.Completed:Connect(function()
		local Hitbox = Instance.new("Part",Object.Parent)
		Hitbox.Name = "Hitbox"
		Hitbox.Material = Enum.Material.ForceField
		Hitbox.Transparency = 1
		Hitbox.Anchored = true
		Hitbox.Size = Vector3.new(0.2,0.2, 0.2)--Object.Size.Z + 5)--(Object.Size.X,Object.Size.Y, Object.Size.Z + 5)
		Hitbox.CFrame = Object.CFrame
		
		for _,Part in pairs(workspace:GetPartsInPart(Hitbox)) do
			local HumanoidFound = false
			local LoadedAnim = nil
			local isProp = Part:FindFirstAncestor("PROPS")
			if isProp then --IsAProp
				--	print("PropFound")
				if Part.CanCollide == true then
					--	print("PropCanCollide")
					GameplayValues.ObjectProp.Value = Part.Parent
					repeat wait(0.1) until GameplayValues.ObjectProp.Value == nil
				end
			else
				if Part.Parent then
					for _,secondcheck in pairs(Part.Parent:GetChildren()) do
						if secondcheck:IsA("Humanoid") and secondcheck ~= Character.Humanoid then
							if secondcheck.Parent.Parent.Name == "CIVILLIANS" then --CIVILLIAN HIT
								failed = true
							end
							LoadedAnim = secondcheck:LoadAnimation(script.Parent.Animations.EliminateAnim)
							HumanoidFound = true
							break
						end
					end
				end
				
			end
			
			if HumanoidFound == true then
				if isProp then
					

				else
					--NonPropKill
					GameplaySounds.HitShot:Play()
					Guis.SniperGui.ShotFeedback.Text = game.ReplicatedStorage.ShotFeedback:InvokeServer(Part.Name)
					local NewBlood = game.ReplicatedStorage.Blood:Clone()
					NewBlood.Parent = Part
					
					local PixelCensor = game.ReplicatedStorage.PixelCensor:Clone()
					PixelCensor.Parent = Part
					PixelCensor.Adornee = Part
					
					Object.Transparency = 1
					Camera.CFrame = CFrame.new(Part.Position + Part.CFrame.lookVector*-2+Vector3.new(3,3,-3), Part.Position)--Vector3.new(0,2,-5), Object.Position)

					if LoadedAnim ~= nil then
						LoadedAnim:Play()
						LoadedAnim.Stopped:Wait()
						if not LoadedAnim.IsPlaying then
							LoadedAnim:Play()
						end
						LoadedAnim:AdjustSpeed(0)
						LoadedAnim.TimePosition = (99 / 100) * LoadedAnim.Length
					end
				end
				
				--FlingCharacter
				Camera.CFrame = CFrame.new(Part.Parent.Head.Position + Part.CFrame.lookVector*-2+Vector3.new(3,6,-3), Part.Parent.Head.Position)
				--Part.Parent.HumanoidRootPart.Velocity = Vector3.new(50,50,50) * ((TargetPart.Position - rayOrigin).Unit*100)--direction
				
				
				local waittime = 0
				repeat
					waittime = waittime + 0.1
					if Part.Parent then
						Camera.CFrame = CFrame.new(Part.Parent.Head.Position + Part.CFrame.lookVector*-2+Vector3.new(3,6,-3), Part.Parent.Head.Position)
						wait(0.1)
					else
						continue
					end
				until waittime == 3 or waittime > 3
				Part.Parent:Destroy()
				break
			else
				if #workspace:GetPartsInPart(Hitbox) > 2 then
					--Object:Destroy()
					GameplaySounds.MissShot:Play()
				end
			end
			
		end
		--
		Hitbox:Destroy()
		--VisualRay:Destroy()
		--
		
		Guis.SniperGui.Bar1.Visible = true
		Guis.SniperGui.Bar2.Visible = true
		Guis.SniperGui.AimOn.Visible = false
		Guis.SniperGui.ZoomControl.Visible = false
		Guis.SniperGui.BACK.Visible = false
		Guis.SniperGui.Objective.Visible = false
		Guis.SniperGui.TargetDisplay.Visible = false
		Guis.SniperGui.TimeDisplay.Visible = false
		--
		finished = true
	end)
	repeat wait(0.1) until finished == true
	Guis.SniperGui.ShotFeedback.Text = ""
	Guis.SniperGui.Bar1.Visible = true
	Guis.SniperGui.Bar2.Visible = true
	Guis.SniperGui.AimOn.Visible = false
	Guis.SniperGui.ZoomControl.Visible = true
	Guis.SniperGui.BACK.Visible = true
	Guis.SniperGui.Objective.Visible = true
	Guis.SniperGui.TimeDisplay.Visible = true
	Guis.SniperGui.TargetDisplay.Visible = true
	return failed
end
local function TravelBullet()
	--workspace.Assets.BackupCameraAim.CFrame.Position
	GameplayValues.EagleVision.Value = false
	GameplayValues.BulletTravelling.Value = true
	GameplaySounds.SniperShot:Play()
	Guis.SniperGui.Visible = true
	Guis.SniperGui.Bar1.Visible = true
	Guis.SniperGui.Bar2.Visible = true
	Guis.SniperGui.AimOn.Visible = false
	Guis.SniperGui.ZoomControl.Visible = false
	Guis.SniperGui.BACK.Visible = false
	Guis.SniperGui.Objective.Visible = false
	Guis.SniperGui.TargetDisplay.Visible = false
	Guis.SniperGui.TimeDisplay.Visible = false
	local NewBullet = Instance.new("Part",workspace)
	NewBullet.Shape = "Ball"
	NewBullet.Size = Vector3.new(0.5,0.5,0.5)
	NewBullet.Color = Color3.fromRGB(45, 45, 45)
	NewBullet.Material = Enum.Material.Glass
	NewBullet.Anchored = true
	NewBullet.CanTouch = true
	NewBullet.CanCollide = false
	NewBullet.Material = Enum.Material.DiamondPlate
	NewBullet.CFrame = Assets.ActiveCameraPart.CFrame * CFrame.new(0,0,-2)
	GameplayValues.ZoomLevel.Value = 10
	--local checkRay = Ray.new()
	
	local target = Assets.TargetPart.CFrame
	local Failed = BulletTravel(NewBullet,target,(6 - GunValues.BulletSpeed.Value)/4)
	NewBullet:Destroy()
	if Failed == true then
		Guis.SniperGui.Visible = false
		GameplayValues.MissionActive.Value = false
		GameplayValues.BulletTravelling.Value = false
		Guis.MissionFeedback.Feedback.TextColor3 = Color3.fromRGB(255, 0, 0)
		Guis.MissionFeedback.Feedback.Text = "MISSION FAILED"
		Guis.MissionFeedback.Visible = true
		TweenCamera(Assets.MFCameraPart.CFrame,false,2)
		wait(4)
		Guis.MissionFeedback.Visible = false
		Guis.MissionFeedback.Feedback.Text = ""
		game.ReplicatedStorage.MissionLoad:FireServer()
		Guis.MainMenu.Visible = true
		Guis.MainMenu.ButtonHolders.Visible = true
	else
		if #workspace.MissionWorkspace.Variables.TARGETS:GetChildren() == 0 then --MissionComplete
			Guis.SniperGui.Visible = false
			GameplayValues.MissionActive.Value = false
			GameplayValues.BulletTravelling.Value = false
			Guis.MissionFeedback.Feedback.TextColor3 = Color3.fromRGB(255, 255, 255)
			Guis.MissionFeedback.Feedback.Text = "MISSION COMPLETE"
			Guis.MissionFeedback.Visible = true
			TweenCamera(Assets.MFCameraPart.CFrame,false,2)
			wait(4)
			Guis.MissionFeedback.Visible = false
			Guis.MissionFeedback.Feedback.Text = ""
			game.ReplicatedStorage.MissionFinished:FireServer()
			Guis.MainMenu.Visible = true
			Guis.MainMenu.ButtonHolders.Visible = true
		else	
			Guis.SniperGui.Visible = true
			GameplayValues.BulletTravelling.Value = false
		end
	end
end
local function ZoomButtonScale(whatDevice)
	local ZoomControl = Guis.SniperGui.ZoomControl
	if whatDevice == "Mobile" then
		ZoomControl.Size = UDim2.new(0.334, 0,0.234, 0)
		ZoomControl.Position = UDim2.new(-0.19, 0,0.793, 0)
	elseif whatDevice == "PC" then
		ZoomControl.Size = UDim2.new(0.195, 0,0.124, 0)
		ZoomControl.Position = UDim2.new(-0.102, 0,0.876, 0)
	end
end

Guis.SniperGui.ZoomControl["+"].MouseButton1Click:Connect(function()
	if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
		GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value + 20
	end
end)
Guis.SniperGui.ZoomControl["-"].MouseButton1Click:Connect(function()
	if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
		GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value - 20
	end
end)
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local keyPressed = input.KeyCode
		if keyPressed == Enum.KeyCode.E then
			if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
				GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value - 20
			end
		elseif keyPressed == Enum.KeyCode.Q then
			if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
				GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value + 20
			end
		end
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then  --//CONSOLE//
		if input.KeyCode == Enum.KeyCode.DPadUp then
			if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
				GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value - 20
			end
		elseif input.KeyCode == Enum.KeyCode.DPadDown then
			if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
				GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value + 20
			end
		end
	end
end)
GameplayValues.ZoomLevel:GetPropertyChangedSignal("Value"):Connect(function()
	GameplayValues.ZoomLevel.Value = math.clamp(GameplayValues.ZoomLevel.Value,10,70)
	if GameplayValues.ZoomLevel.Value >= 20 then
		GameplaySounds.Zoom:Play()
		GameplayValues.isAiming.Value = true
		Camera.FieldOfView = GameplayValues.SniperZoomLevel.Value - GameplayValues.ZoomLevel.Value
	elseif GameplayValues.ZoomLevel.Value <= 20 then
		GameplaySounds.Zoom:Play()
		GameplayValues.isAiming.Value = false
		Camera.FieldOfView = GameplayValues.SniperZoomLevel.Value - GameplayValues.ZoomLevel.Value
	end
end)
GameplayValues.isAiming:GetPropertyChangedSignal("Value"):Connect(function()
	if GameplayValues.isAiming.Value == true then
		TweenCamera(Assets.ActiveCameraPart.CFrame,false,0.1)
		Guis.SniperGui.AimOn.Position = UDim2.new(0.987, 0,0.973, 0)
		Guis.SniperGui.AimOn.Position = UDim2.new(0.013, 0,0.027, 0)
		Guis.SniperGui.BACK.Visible = false
		Guis.SniperGui.AimOn.Visible = true
		Guis.SniperGui.Bar1.Visible = false
		Guis.SniperGui.Bar2.Visible = false
		TweenGui(Guis.SniperGui.AimOn,UDim2.new(0,0,0,0),UDim2.new(1,0,1,0),0.3)
	elseif GameplayValues.isAiming.Value == false then
		repeat wait(0.01) until GameplayValues.BulletTravelling.Value == false
		if Guis.SniperGui.Visible == true then
			TweenCamera(Assets.PassiveCameraPart.CFrame,false,0.1)
			Guis.SniperGui.BACK.Visible = true
			Guis.SniperGui.AimOn.Visible = true
			Guis.SniperGui.Bar1.Visible = true
			Guis.SniperGui.Bar2.Visible = true
			TweenGui(Guis.SniperGui.AimOn,UDim2.new(0.987, 0,0.973, 0),UDim2.new(0.013, 0,0.027, 0),0.3)
			Guis.SniperGui.AimOn.Visible = false
		end
	end
end)

GameplayValues.MissionActive:GetPropertyChangedSignal("Value"):Connect(function()
	if GameplayValues.MissionActive.Value == true then
		local TargetName = ""
		for _,Child in pairs(workspace.MissionWorkspace.Variables.TARGETS:GetChildren()) do
			TargetName = Child.Name
			break
		end
		
		if TargetName == "" then
			Guis.SniperGui.Objective.Text = ""
		else
			Guis.SniperGui.Objective.Text = " Eliminate "..TargetName--"OBJECTIVE: Eliminate "..TargetName
		end
		
		GameplayValues.ZoomLevel.Value = 10
		TweenCamera(Assets.PassiveCameraPart.CFrame,false,0.3)
		Guis.SniperGui.Visible = true
		GameplayValues.TimeElapsed.Value = 1
	end
end)

--//ShootFunction
GameplayValues.TimeElapsed:GetPropertyChangedSignal("Value"):Connect(function()
	local minutes = math.floor(GameplayValues.TimeElapsed.Value/60)
	local seconds = tostring(GameplayValues.TimeElapsed.Value%60)
	if #seconds == 1 then
		seconds = "0"..seconds
	end
	script.Parent.Parent.Guis.SniperGui.TimeDisplay.Text = tostring(minutes)..":"..tostring(seconds)
	if GameplayValues.MissionActive.Value == true then
		if GameplayValues.TimeElapsed.Value ~= 0 then
			wait(1)
			GameplayValues.TimeElapsed.Value = GameplayValues.TimeElapsed.Value + 1
		end
	elseif GameplayValues.MissionActive.Value == false then
		GameplayValues.TimeElapsed.Value = 0
	end
end)

Guis.SniperGui.BACK.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	Guis.SniperGui.Visible = false
	GameplayValues.MissionActive.Value = false
	GameplayValues.BulletTravelling.Value = false
	game.ReplicatedStorage.MissionLoad:FireServer()
	Guis.MainMenu.ButtonHolders.Visible = true
	Guis.MainMenu.Visible = true
end)

mouse.Button1Down:Connect(function() --//SHOOT
	if GameplayValues.isAiming.Value == true and GameplayValues.BulletTravelling.Value == false then
		if Guis.SniperGui.AimOn.MobileShoot.Visible == false then
			TravelBullet()
		end
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Gamepad1 then
		if input.KeyCode == Enum.KeyCode.ButtonR2 then
			if GameplayValues.isAiming.Value == true and GameplayValues.BulletTravelling.Value == false then
				TravelBullet()
			end
		end
	end
end)

Guis.SniperGui.AimOn.MobileShoot.MouseButton1Click:Connect(function()
	if GameplayValues.isAiming.Value == true and GameplayValues.BulletTravelling.Value == false then
		TravelBullet()
	end
end)

--// Move cam

--MobileMove
local lastTouchTranslation = nil
local function TouchMoveCam(touchPositions, totalTranslation, velocity, state)--touchPositions, totalTranslation, velocity, state)
	if GameplayValues.isAiming.Value == true then
		local x,y,z = Camera.CFrame:ToEulerAnglesXYZ()
		--local rotation = Vector2.new(x,y)
		if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
			--[[
			if #touchPositions > 0 then
				local mainposition = touchPositions[#touchPositions]
				local firstray = Camera:ViewportPointToRay(mainposition.X,mainposition.Y)
				local checkray = Ray.new(firstray.Origin, firstray.Direction * 5000)
				local hitPart, worldPosition = workspace:FindPartOnRay(checkray)	
				workspace.Assets.BackupCameraAim.Position = worldPosition
				workspace.Assets.BackupCameraAim.CFrame = CFrame.new(worldPosition)
				TweenCamera(CFrame.lookAt(Camera.CFrame.Position,workspace.Assets.BackupCameraAim.CFrame.Position))
			end
			]]--
			
			--[[ROTATING CAMERA
			local difference = totalTranslation - lastTouchTranslation
			local CameraAngles = CFrame.Angles(x+(difference.x),y+(difference.y),z)
			local Target = CameraAngles + cameraPosition + CameraAngles*Vector3.new(0, 0, 0)--1)
			--cameraRotation = cameraRotation + Vector2.new(-difference*0.1,0)*math.rad(0.1*0.1)--cameraTouchRotateSpeed
			]]--
			
			--MovingTargetPart
			local TargetPart = Assets.TargetPart
			local difference = totalTranslation - lastTouchTranslation
			TargetPart.Position = TargetPart.Position + Vector3.new(difference.X, 0, difference.Y)
		end
		lastTouchTranslation = totalTranslation
	end
end

local function touchInWorld(position, processedByUI)
	if processedByUI then return end
	local unitRay = Camera:ViewportPointToRay(position.X, position.Y)
	local ray = Ray.new(unitRay.Origin, unitRay.Direction * 5000)
	local hitPart, worldPosition = workspace:FindPartOnRayWithIgnoreList(ray, TargetPart)
	if hitPart then
		TargetPart.Position = worldPosition
	end
end

--AddPinchAswell; for ZOOM
local zoomInProgress = false
local function TouchZoom(touchPositions, scale, velocity, state)
	if state == Enum.UserInputState.Change or state == Enum.UserInputState.End then
		if zoomInProgress == false then
			zoomInProgress = true
			if scale < 1 then --decreasefieldofview
				if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
					GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value - 20
				end
			elseif scale > 1 then --increasefieldofview
				if GameplayValues.BulletTravelling.Value == false and GameplayValues.MissionActive.Value == true then
					GameplayValues.ZoomLevel.Value = GameplayValues.ZoomLevel.Value + 20
				end
			end
			zoomInProgress = false
		end
	end
end

UserInputService.TouchTapInWorld:Connect(touchInWorld)
UserInputService.TouchPan:Connect(TouchMoveCam)
UserInputService.TouchPinch:Connect(TouchZoom)

RunService.RenderStepped:Connect(function()
	local TargetPart = Assets.TargetPart
	if GameplayValues.isAiming.Value == true then
		repeat wait(0.001) until Guis.SniperGui.AimOn.Size == UDim2.new(1,0,1,0)
		if (UserInputService.TouchEnabled) then --//MOBILE
			ZoomButtonScale("Mobile")
			Guis.SniperGui.ZoomControl["+"].KEY.Text = ""
			Guis.SniperGui.ZoomControl["-"].KEY.Text = ""
			Guis.SniperGui.AimOn.MobileShoot.Visible = true
			TweenCamera(CFrame.lookAt(Camera.CFrame.Position,TargetPart.CFrame.Position))
		elseif (UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1) then --//CONSOLE
			ZoomButtonScale("PC")
			Guis.SniperGui.ZoomControl["+"].KEY.Text = "DPADUP"
			Guis.SniperGui.ZoomControl["-"].KEY.Text = "DPADDOWN"
			Guis.SniperGui.AimOn.MobileShoot.Visible = false
			TweenCamera(CFrame.lookAt(Camera.CFrame.Position,TargetPart.CFrame.Position))
		elseif (UserInputService:GetLastInputType() == Enum.UserInputType.MouseMovement) then  --//PC
			ZoomButtonScale("PC")
			Guis.SniperGui.ZoomControl["+"].KEY.Text = "Q"
			Guis.SniperGui.ZoomControl["-"].KEY.Text = "E"
			Guis.SniperGui.AimOn.MobileShoot.Visible = false
			TargetPart.CFrame = mouse.Hit
			TweenCamera(CFrame.lookAt(Camera.CFrame.Position,TargetPart.CFrame.Position))
		elseif (UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard) then
			ZoomButtonScale("PC")
			Guis.SniperGui.ZoomControl["+"].KEY.Text = "Q"
			Guis.SniperGui.ZoomControl["-"].KEY.Text = "E"
			Guis.SniperGui.AimOn.MobileShoot.Visible = false
			TargetPart.CFrame = mouse.Hit
			TweenCamera(CFrame.lookAt(Camera.CFrame.Position,TargetPart.CFrame.Position))
		end
	end
end)

--// Set Intro Cam
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = Assets.IntroCameraPart.CFrame
Guis.Intro.Intro.Play.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	Guis.Intro.Intro.Visible = false
	Guis.MainMenu.Visible = true
	Guis.MainMenu.ButtonHolders.Visible = true
end)
Guis.MainMenu:GetPropertyChangedSignal("Visible"):Connect(function()
	if Guis.MainMenu.Visible == true then
		TweenCamera(Assets.MenuCameraPart.CFrame,false,0.8)
	end
end)
Guis.MainMenu.ButtonHolders.APPEARANCE.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	TweenCamera(Assets.AppearanceCameraPart.CFrame,false,0.4)
	Guis.MainMenu.CustomAppearance.Visible = true
	Guis.MainMenu.ButtonHolders.Visible = false
end)
Guis.MainMenu.ButtonHolders.MISSIONS.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	TweenCamera(Assets.MissionMenuCameraPart.CFrame,false,0.4)
	Guis.MainMenu.Visible = true
	Guis.MainMenu.ButtonHolders.Visible = false
end)
Guis.MainMenu.ButtonHolders.UPGRADES.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	TweenCamera(Assets.UpgradeCameraPart.CFrame,false,0.4)
	Guis.MainMenu.Upgrades.Visible = true
	Guis.MainMenu.ButtonHolders.Visible = false
end)
Guis.MainMenu.ButtonHolders.STORE.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	TweenCamera(Assets.StoreCameraPart.CFrame,false,0.4)
	Guis.MainMenu.Store.Visible = true
	Guis.MainMenu.ButtonHolders.Visible = false
end)
Guis.MainMenu.ButtonHolders.SETTINGS.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	TweenCamera(Assets.SettingsCameraPart.CFrame,false,0.4)
	Guis.MainMenu.Settings.Visible = true
	Guis.MainMenu.ButtonHolders.Visible = false
end)
Guis.MissionGui.Frame.PLAY.MouseButton1Click:Connect(function()
	GameplaySounds.Click:Play()
	Guis.MainMenu.Visible = false
	Guis.MainMenu.ButtonHolders.Visible = false
	GameplayValues.MissionActive.Value = true
end)

--//GunValues
local Stability = GunValues:WaitForChild("Stability")
Stability:GetPropertyChangedSignal("Value"):Connect(function()
	GameplayValues.AimSpeed.Value = Stability.Value*0.25
end)
local Range = GunValues:WaitForChild("Range")
Range:GetPropertyChangedSignal("Value"):Connect(function()
	Assets.ActiveCameraPart.Position = Assets.ActiveCameraPart.OriginalPos.Value
	Assets.ActiveCameraPart.CFrame = Assets.ActiveCameraPart.CFrame * CFrame.new(0,0,-Range.Value*7)
end)
Assets.ActiveCameraPart.Position = Assets.ActiveCameraPart.OriginalPos.Value
Assets.ActiveCameraPart.CFrame = Assets.ActiveCameraPart.CFrame * CFrame.new(0,0,-Range.Value*7)
local Scope = GunValues:WaitForChild("Scope")
Scope:GetPropertyChangedSignal("Value"):Connect(function()
	for _,Frame in pairs(Guis.SniperGui.AimOn:GetChildren()) do
		if Frame.Name == tostring(Scope.Value) then
			Frame.Visible = true
		else
			if Frame.Name ~= "ZoomIndicator" then
				Frame.Visible = false
			end
		end
	end
end)
for _,Frame in pairs(Guis.SniperGui.AimOn:GetChildren()) do
	if Frame.Name == tostring(Scope.Value) then
		Frame.Visible = true
	else
		if Frame.Name ~= "ZoomIndicator" then
			Frame.Visible = false
		end
	end
end
