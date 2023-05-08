local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

local productFunctions = {}
--
productFunctions[1207651822] = function(receipt, player) --1000Money
	local Money = player:FindFirstChild("PlrInfo"):WaitForChild("Money")
	if Money then
		Money.Value = Money.Value + 1000
		return true
	end
end



--
local function processReceipt(receiptInfo)
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local handler = productFunctions[receiptInfo.ProductId]

	local success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end


	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
