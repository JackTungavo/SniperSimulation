local player = game.Players.LocalPlayer
local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()
Controls:Disable()

repeat wait() until player.PlayerGui:FindFirstChild("TouchGui") and player.PlayerGui.TouchGui.TouchControlFrame:FindFirstChild("JumpButton")
player.PlayerGui.TouchGui.TouchControlFrame:FindFirstChild("JumpButton").ImageTransparency = 1
player.PlayerGui.TouchGui.TouchControlFrame:FindFirstChild("JumpButton").Visible = false
player.PlayerGui.TouchGui.TouchControlFrame:FindFirstChild("DynamicThumbstickFrame").Visible = false
