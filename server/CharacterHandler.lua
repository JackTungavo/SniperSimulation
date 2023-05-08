--[[
game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(Character)
		local Assets = workspace:WaitForChild("Assets")
		Character:WaitForChild("HumanoidRootPart").Anchored = true
		Character:WaitForChild("HumanoidRootPart").CFrame = Assets.HumanoidRootPart.CFrame
	end)
end)
]]--
function hasProperty(object, propertyName)
	local success, _ = pcall(function() 
		object[propertyName] = object[propertyName]
	end)
	return success
end

local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local BundleTable = {
	["115"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, --Rogue Space Assassin
	["592"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["589"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["339"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["338"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["242"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["221"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["222"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
	["76"] = {["Price"] = 500, ["Name"] = "", ["ImageID"] = 0, ["Items"] = {}}, 
}
for i,v in pairs(BundleTable) do
	local itemAsync = AssetService:GetBundleDetailsAsync(tonumber(i))
	BundleTable[i]["Items"] = itemAsync.Items
	BundleTable[i]["Name"] = itemAsync.Name
	for Check,_ in pairs(BundleTable[i]["Items"]) do
		if BundleTable[i]["Items"][Check].Type == "UserOutfit" then
			BundleTable[i]["ImageID"] = BundleTable[i]["Items"][Check].Id
			break
		end
	end
end

local function ApplyItemsToDescription(BundleID,Description,BodyParts)
	local BodyPartCheck = {
		["HEAD"] = {"Head","Face","HairAccessory","FaceAccessory"},
		["TORSO"] = {"Torso","FrontAccessory","BackAccessory","WaistAccessory"},
		["ARMS"] = {"RightArm","LeftArm","ShoulderAccessory"},
		["LEGS"] = {"LeftLeg","RightLeg"},
		
	}
	
	for i,v in pairs(BundleTable[tostring(BundleID)]["Items"]) do
		local success, Asset = pcall(MarketplaceService.GetProductInfo, MarketplaceService, tostring(v.Id))
		if success then	
			local AssetType --= AssetEnum[Asset.AssetTypeId]
			if Asset.AssetTypeId == 8 then
				AssetType = "Hat"
			elseif Asset.AssetTypeId == 17 then
				AssetType = "Head"
			elseif Asset.AssetTypeId == 18 then
				AssetType = "Face"
			elseif Asset.AssetTypeId == 27 then
				AssetType = "Torso"
			elseif Asset.AssetTypeId == 28 then
				AssetType = "RightArm"
			elseif Asset.AssetTypeId == 29 then
				AssetType = "LeftArm"
			elseif Asset.AssetTypeId == 30 then
				AssetType = "LeftLeg"
			elseif Asset.AssetTypeId == 31 then
				AssetType = "RightLeg"
			elseif Asset.AssetTypeId == 41 then
				AssetType = "HairAccessory"
			elseif Asset.AssetTypeId == 42 then
				AssetType = "FaceAccessory"
			elseif Asset.AssetTypeId == 43 then
				AssetType = "NeckAccessory"
			elseif Asset.AssetTypeId == 44 then
				AssetType = "ShoulderAccessory"
			elseif Asset.AssetTypeId == 45 then
				AssetType = "FrontAccessory"
			elseif Asset.AssetTypeId == 46 then
				AssetType = "BackAccessory"
			elseif Asset.AssetTypeId == 47 then
				AssetType = "WaistAccessory"
			end

			if hasProperty(Description,AssetType) == true then
				if BodyParts == nil  then
					Description[AssetType] = tostring(Asset.AssetId)
				else --OnlyCertainBodyParts
					local partofbodypart = false
					for _,v in pairs(BodyPartCheck[BodyParts]) do
						if v == AssetType then
							partofbodypart = true
						end		
					end
					if partofbodypart == true then
						Description[AssetType] = tostring(Asset.AssetId)
					end
				end
			end
		end
	end
	
	return Description
end

game.ReplicatedStorage.LoadCharacterItems.Ready.Value = true

game.ReplicatedStorage.LoadCharacterItems.OnServerInvoke = function(player,Request,ItemID)
	if Request == "BundleTable" then
		return BundleTable
	elseif Request == "Purchase" then
		local BundleFolder = player:WaitForChild("PlrInfo"):WaitForChild("Bundles")
		local ownsItem = false
		if string.find(BundleFolder.Value,tostring(ItemID)) then
			ownsItem = true
		end
		if ownsItem == false then
			--makePurchase
			local Money = player:WaitForChild("PlrInfo"):WaitForChild("Money")
			local Price = BundleTable[tostring(ItemID)]["Price"]
			if Money.Value >= Price then
				Money.Value = Money.Value - Price
				BundleFolder.Value = BundleFolder.Value.."'"..tostring(ItemID).."',"
			end
		elseif ownsItem == true then
			--GiveOutfit
			local Humanoid
			for _,Part in pairs(player.Character:GetDescendants()) do
				if Part:IsA("Humanoid") then
					Humanoid = Part
					break
				end
			end
			
			local Description = ApplyItemsToDescription(ItemID,Humanoid:GetAppliedDescription())
			
			if Description and Humanoid then
				Humanoid:ApplyDescription(Description)
				game.ReplicatedStorage.ReloadSniper:FireAllClients()
			end
			
		end
	end
end

game.ReplicatedStorage.GivePlayerItem.OnServerInvoke = function(player,BodyParts,ItemID)
	local BundleFolder = player:WaitForChild("PlrInfo"):WaitForChild("Bundles")
	local OwnsPart = string.find(BundleFolder.Value,ItemID)
	
	if OwnsPart then
		local GUI = player.PlayerGui.Guis.MainMenu.CustomAppearance
		GUI.LOADING.Visible = true
		local Humanoid
		for _,Part in pairs(player.Character:GetDescendants()) do
			if Part:IsA("Humanoid") then
				Humanoid = Part
				break
			end
		end

		local Description = ApplyItemsToDescription(ItemID,Humanoid:GetAppliedDescription(),BodyParts)
		GUI.LOADING.Visible = false
		if Description and Humanoid then
			Humanoid:ApplyDescription(Description)
			game.ReplicatedStorage.ReloadSniper:FireAllClients()
		end
	end
end
