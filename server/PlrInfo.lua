local DATASTORE = game:GetService("DataStoreService")
local FinalPlrINFO = DATASTORE:GetDataStore("Attempt7")

local function onPlayerJoin(player)  -- Runs when players join
	local PlrInfo = Instance.new("Folder")
	PlrInfo.Name = "PlrInfo"
	PlrInfo.Parent = player
	
	local Money = Instance.new("IntValue")
	Money.Name = "Money"
	Money.Parent = player.PlrInfo

	local XP = Instance.new("IntValue")
	XP.Name = "XP"
	XP.Parent = player.PlrInfo
	
	local Level = Instance.new("IntValue")
	Level.Name = "Level"
	Level.Parent = player.PlrInfo
	
	local Mission = Instance.new("IntValue")
	Mission.Name = "Mission"
	Mission.Parent = player.PlrInfo
	
	local Bundles = Instance.new("StringValue")
	Bundles.Name = "Bundles"
	Bundles.Parent = player.PlrInfo
	
	--//GunValues
	local GunValues = Instance.new("Folder",PlrInfo)
	GunValues.Name = "GunValues"
	local BulletSpeed = Instance.new("IntValue",GunValues)
	BulletSpeed.Name = "BulletSpeed"
	local Range = Instance.new("IntValue",GunValues)
	Range.Name = "Range"
	local Stability = Instance.new("IntValue",GunValues)
	Stability.Name = "Stability"
	local Scope = Instance.new("IntValue",GunValues)
	Scope.Name = "Scope"
	
	--//SETTINGS
	local SETTINGS = Instance.new("Folder",PlrInfo)
	SETTINGS.Name = "SETTINGS"
	local Brightness = Instance.new("NumberValue",SETTINGS)
	Brightness.Name = "Brightness"
	local Contrast = Instance.new("NumberValue",SETTINGS)
	Contrast.Name = "Contrast"
	local Saturation = Instance.new("NumberValue",SETTINGS)
	Saturation.Name = "Saturation"
	local Blur = Instance.new("NumberValue",SETTINGS)
	Blur.Name = "Blur"
	local Bloom = Instance.new("NumberValue",SETTINGS)
	Bloom.Name = "Bloom"
	local MuteSoundEffects = Instance.new("BoolValue",SETTINGS)
	MuteSoundEffects.Name = "MuteSoundEffects"
	local MuteBackgroundMusic = Instance.new("BoolValue",SETTINGS)
	MuteBackgroundMusic.Name = "MuteBackgroundMusic"
	

	
	local playerUserId = "Player_" .. player.UserId  --Gets player ID
	local data = FinalPlrINFO:GetAsync(playerUserId)  --Checks if player has stored data
	
	if data then
		--LOAD DATA
		Money.Value = data['Money']
		Bundles.Value = data['Bundles']
		XP.Value = data['XP']
		Level.Value = data['Level']
		Mission.Value = data['Mission']
		BulletSpeed.Value = data['BulletSpeed']
		Range.Value = data['Range']
		Stability.Value = data['Stability']
		Scope.Value = data['Scope']
		Brightness.Value = data['Brightness']
		Contrast.Value = data['Contrast']
		Saturation.Value = data['Saturation']
		Blur.Value = data['Blur']
		Bloom.Value = data['Bloom']		
		MuteSoundEffects.Value = data['MuteSoundEffects']	
		MuteBackgroundMusic.Value = data['MuteBackgroundMusic']	
	else
		--NODATASET
		Money.Value = 500
		Bundles.Value = ""
		XP.Value = 10
		Level.Value = 1
		Mission.Value = 1
		BulletSpeed.Value = 1
		Range.Value = 1
		Stability.Value = 1
		Scope.Value = 1
		Brightness.Value = game.Lighting.ColorCorrection.Brightness
		Contrast.Value = game.Lighting.ColorCorrection.Contrast
		Saturation.Value = game.Lighting.ColorCorrection.Saturation
		Blur.Value = game.Lighting.Blur.Size
		Bloom.Value = game.Lighting.Bloom.Size	
		MuteSoundEffects.Value = false
		MuteBackgroundMusic.Value = false
	end
	
	--//ValueFunctions
	XP:GetPropertyChangedSignal("Value"):Connect(function()
		if XP.Value >= 100 then
			XP.Value = 100 - XP.Value
			Level.Value = Level.Value + 1
		end
	end)
end
local function create_table(player)
	local player_stats = {}
	for _, stat in pairs(player.PlrInfo:GetDescendants()) do
		if stat:IsA("Folder") then
		else
			player_stats[stat.Name] = stat.Value
		end
	end
	return player_stats
end
local function onPlayerExit(player)  --Runs when players exit
	local player_stats = create_table(player)
--FinalMeasureOfReliability
	local tries = 0
	local success
	repeat
		tries  = tries + 1
		success = pcall(function()
			local playerUserId = "Player_" .. player.UserId
			FinalPlrINFO:SetAsync(playerUserId, player_stats) --Saves player data
		end)
		if not success then wait(1) end
	until tries == 3 or success
	if not success then
		warn('Could not save data!')
	end
end
game.Players.PlayerAdded:Connect(onPlayerJoin)

game.Players.PlayerRemoving:Connect(onPlayerExit)

game:BindToClose(function() --IfGameIsShuttingDown
	for i, player in pairs(game.Players:GetPlayers()) do
		if player then
			player:Kick("GameIsShuttingDown")
		end
	end	
	wait(3)	
end)
