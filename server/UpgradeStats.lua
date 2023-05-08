local UpgradeCosts = {
	["1"] = 0,
	["2"] = 1500,
	["3"] = 4500,
	["4"] = 9500,
	["5"] = 13000,
}

local function GetCost(player,DesiredStats)
	local Cost = 0	
	for _,CurrentStat in pairs(player.PlrInfo.GunValues:GetChildren()) do
		local DesiredStat = DesiredStats[CurrentStat.Name]
		for i = CurrentStat.Value,DesiredStat,1 do
			if CurrentStat.Value ~= DesiredStat then
				Cost = Cost + UpgradeCosts[tostring(i)]
			end	
		end
	end
	return Cost
end

game.ReplicatedStorage.CalculatingCost.OnServerInvoke = function(player,DesiredStats)
	local Cost = GetCost(player,DesiredStats)
	return Cost
end
game.ReplicatedStorage.UpgradeStats.OnServerInvoke = function(player,DesiredStats)
	local PurchaseSuccessful = false
	local Cost = GetCost(player,DesiredStats)
	local Money = player.PlrInfo.Money
	
	if Money.Value >= Cost then
		Money.Value = Money.Value - Cost
		for _,CurrentStat in pairs(player.PlrInfo.GunValues:GetChildren()) do
			local DesiredStat = DesiredStats[CurrentStat.Name]
			CurrentStat.Value = DesiredStat
		end
		PurchaseSuccessful = "Purchase Successful"
	else
		PurchaseSuccessful = "Not Enough Money"
	end
	return PurchaseSuccessful
end

--//Settings
game.ReplicatedStorage.Settings.OnServerInvoke = function(player,stat,Increment)
	if player.PlrInfo.SETTINGS[stat]:IsA("NumberValue") then
		player.PlrInfo.SETTINGS[stat].Value = player.PlrInfo.SETTINGS[stat].Value + Increment
	elseif player.PlrInfo.SETTINGS[stat]:IsA("BoolValue") then
		player.PlrInfo.SETTINGS[stat].Value = Increment
	end
end

--//ShotFeedback
game.ReplicatedStorage.ShotFeedback.OnServerInvoke = function(player,PartHit)
	local feedback
	local ValueToAdd = 0
	if PartHit == "Head" then
		ValueToAdd = 5
		feedback = "HEADSHOT"
	else
		ValueToAdd = 1
		feedback = string.upper(PartHit)
	end
	
	if player.PlrInfo.GamepassValues["''DoubleXP''"].Value == true then
		ValueToAdd = ValueToAdd * 2
	end
	
	player.PlrInfo.XP.Value = player.PlrInfo.XP.Value + ValueToAdd
	feedback = feedback.." +"..tostring(ValueToAdd)
	
	if player.PlrInfo.GamepassValues["''DoubleXP''"].Value == true then
		feedback = feedback.." :(DOUBLE XP)"
	end
	
	return feedback
end
