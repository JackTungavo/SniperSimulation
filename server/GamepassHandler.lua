local MarketplaceService = game:GetService("MarketplaceService")
local GamepassTable = {
	[22861848] = "" --DoubleXP
}

game.Players.PlayerAdded:Connect(function(Player)
	local PlrInfo = Player:WaitForChild("PlrInfo")
	
	--//GamepassValues
	local GamepassValues = Instance.new("Folder",PlrInfo)
	GamepassValues.Name = "GamepassValues"

	for Key,Value in pairs(GamepassTable) do
		local NewValue = Instance.new("BoolValue",GamepassValues)
		Value = MarketplaceService:GetProductInfo(Key,Enum.InfoType.GamePass).Name
		NewValue.Name = MarketplaceService:GetProductInfo(Key,Enum.InfoType.GamePass).Name
		NewValue.Value = false
	end
	
	local function CheckGamepasses()
		for Key,Value in pairs(GamepassTable) do
			if GamepassValues:FindFirstChild(Value) then
				--Found Value, Now Check Ownership
				if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Key) then
					GamepassValues[Value].Value = true
				else
					GamepassValues[Value].Value = false
				end
			end
		end
	end
	
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(checkPlayer)
		if checkPlayer == Player then
			CheckGamepasses()
		end
	end)
	
	CheckGamepasses()
	
end)
