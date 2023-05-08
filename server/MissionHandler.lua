workspace:WaitForChild("Assets"):WaitForChild("TargetPart"):WaitForChild("StartCFrame").Value = workspace:WaitForChild("Assets"):WaitForChild("TargetPart").CFrame

local MissionLibrary = {
	["1"] = 7353262037,
	["2"] = 7353277095,
	["3"] = 7360771020,
	["4"] = 7412584651,
	["5"] = 7516738124,
	["6"] = 7517139472,
	--["7"] = 7811028037, --PropIntroduction
}

local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")
game.Players.PlayerAdded:Connect(function(Player)
	local Mission = Player:WaitForChild("PlrInfo"):WaitForChild("Mission")
	
	local MissionChangeInProgress = false
	local function LoadMission(MapID)
		workspace:WaitForChild("Assets"):WaitForChild("TargetPart").CFrame = workspace.Assets.TargetPart.StartCFrame.Value
		if MissionChangeInProgress == false then
			MissionChangeInProgress = true
			local Feedback = "NotDone"
			workspace.MissionWorkspace.Design:ClearAllChildren()
			workspace.MissionWorkspace.Variables.CIVILLIANS:ClearAllChildren()
			workspace.MissionWorkspace.Variables.TARGETS:ClearAllChildren()
			workspace.MissionWorkspace.Variables.PROPS:ClearAllChildren()
			workspace.MissionWorkspace.Variables.MaxTargets.Value = 0
			--MarketplaceService:GetProductInfo(MapID)
			local AssetID
			if MapID == nil then
				AssetID = MissionLibrary[tostring(Mission.Value)]
			else
				AssetID = MapID
			end


			workspace.Assets.AssetID.Value = 0
			workspace.Assets.CreatorID.Value = 0

			local success, model = pcall(InsertService.LoadAsset, InsertService, AssetID)
			if success and model then
				
				model.Parent = workspace
				--DeleteMaliciousParts
				for _,Part in pairs(model:GetDescendants()) do
					if Part:IsA("Script") then
						Part.Disabled = false
						Part:Destroy()
					elseif Part:IsA("Fire") then
						Part:Destroy()
					elseif Part:IsA("Animation") then --LoadNPCAnimations
						if Part.Parent:IsA("Humanoid") then
							local newAnim = Part.Parent:FindFirstChildWhichIsA("Animator"):LoadAnimation(Part)
							if newAnim then
								newAnim:Play()
							end
						end
					end
				end
				
				--ToPlaceParts
				model.Mission:SetPrimaryPartCFrame(workspace.Assets.PlayerBasePart.CFrame)
				workspace.MissionWorkspace.Variables.MissionName.Value = model.Mission.MissionName.Value
				workspace.MissionWorkspace.Variables.MissionDescription.Value = model.Mission.MissionDescription.Value
				--Props
				if model.Mission:FindFirstChild("PROPS") then
				else
					local Folder = Instance.new("Folder",model.Mission)
					Folder.Name = "PROPS"
				end
				
				for _,Part in pairs(model.Mission.PROPS:GetChildren()) do
					if game.ServerStorage.Props:FindFirstChild(Part.Name) then
						Part.Parent = workspace.MissionWorkspace.Variables.PROPS
						
						local newProperPart = game.ServerStorage.Props:FindFirstChild(Part.Name):Clone()
						newProperPart.Parent = workspace.MissionWorkspace.Variables.PROPS
						newProperPart:SetPrimaryPartCFrame(Part.PrimaryPart.CFrame)
						
						for _,PartCheck in pairs(newProperPart:GetChildren()) do
							if Part:FindFirstChild(PartCheck.Name) then
								--AlreadyInMainPart
							else
								--NotYetInMainPart
								PartCheck.Parent = Part
							end
						end
						
						newProperPart:Destroy()
					else
						--Not Valid Part of Prop
						Part:Destroy()
					end
				end
				
				--Prop:	CanCollide's
				for _,Part in pairs(workspace.MissionWorkspace.Variables.PROPS:GetDescendants()) do
					if Part.Parent.Name == "StreetLight" then
						if Part.Name ~= "ReleasePart" then
							Part.CanCollide = false
						end
					end
				end
				
				--Targets
				for _,Part in pairs(model.Mission.TARGETS:GetChildren()) do
					Part.Parent = workspace.MissionWorkspace.Variables.TARGETS
				end
				workspace.MissionWorkspace.Variables.MaxTargets.Value = #workspace.MissionWorkspace.Variables.TARGETS:GetChildren()
				--Civillians
				for _,Part in pairs(model.Mission.CIVILLIANS:GetChildren()) do
					Part.Parent = workspace.MissionWorkspace.Variables.CIVILLIANS
				end
				model.Mission.TARGETS:Destroy()
				model.Mission.CIVILLIANS:Destroy()
				model.Mission.PROPS:Destroy()
				model.Mission.MissionDescription:Destroy()
				model.Mission.MissionName:Destroy()
				model.Mission.PlayerBasePart:Destroy()
				for _,Part in pairs(model.Mission:GetChildren()) do
					Part.Parent = workspace.MissionWorkspace.Design
				end
				model:Destroy()

				--NetworkOwnership  --ToAllowFling  or ChangeMass

				for _,Part in pairs(workspace.MissionWorkspace.Variables.TARGETS:GetDescendants()) do
					if Part:IsA("BasePart") then
							--Part.Anchored = false
							--Part:SetNetworkOwner(Player)
					elseif Part:IsA("MeshPart") then
							--Part.Anchored = false
							--Part:SetNetworkOwner(Player)
					elseif Part:IsA("Humanoid") then
						--Part.PlatformStand = true
					end
				end
				for _,Part in pairs(workspace.MissionWorkspace.Variables.CIVILLIANS:GetDescendants()) do
					if Part:IsA("BasePart") then
						--Part.Anchored = false
						--Part:SetNetworkOwner(Player)
					elseif Part:IsA("MeshPart") then
						--Part.Anchored = false
						--Part:SetNetworkOwner(Player)
					elseif Part:IsA("Humanoid") then
						--Part.PlatformStand = true
					end
				end
				workspace.Assets.AssetID.Value = AssetID
				workspace.Assets.CreatorID.Value = MarketplaceService:GetProductInfo(AssetID).Creator.CreatorTargetId
				MissionChangeInProgress = false
			else
				warn("MissionFailedToLoad")
				MissionChangeInProgress = false
				LoadMission()
			end
		end
	end

	game.ReplicatedStorage.MissionLoad.OnServerEvent:Connect(function()
		LoadMission()
	end)

	game.ReplicatedStorage.MissionFinished.OnServerEvent:Connect(function()
		if workspace.Assets.CreatorID.Value == 5239387 then  --ZeroloftInteractiveID
			if MissionLibrary[tostring(Mission.Value)] == workspace.Assets.AssetID.Value then
				Player.PlrInfo.Money.Value = Player.PlrInfo.Money.Value + 1000
				Player.PlrInfo.XP.Value = Player.PlrInfo.XP.Value + 20
				Mission.Value = Mission.Value + 1
			else
				Player.PlrInfo.XP.Value = Player.PlrInfo.XP.Value + 10
				LoadMission()
			end
		else
			LoadMission()
		end
	end)
	
	
	game.ReplicatedStorage.CustomMap.OnServerInvoke = function(Player,MapID)
		LoadMission(MapID)
	end
	
	repeat wait(0.1) until Mission.Value ~= 0
	local NumOfMissions = 0
	for _,_ in pairs(MissionLibrary) do
		NumOfMissions = NumOfMissions + 1
	end
	Mission:GetPropertyChangedSignal("Value"):Connect(function()		
		Mission.Value = math.clamp(Mission.Value,1,NumOfMissions)
		LoadMission()
	end)
	
	LoadMission()
	
end)

