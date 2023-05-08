local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local maxAttempts = 999999

for i = 1, maxAttempts, 1 do
	local success, message = pcall(function()
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		starterGui:SetCore("ResetButtonCallback", false)
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	end)
	if success then
		break
	else
		--warn(message)
	end
	runService.RenderStepped:Wait()
end
