local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local HouseClass = require(ReplicatedStorage.Shared.HouseClass)
local housePads = CollectionService:GetTagged("HousePad")

local HouseService = Knit.CreateService({
	Name = "HouseService",
	Client = {},
})

function HouseService:KnitInit()
	for _, pad in housePads do
		self:SetupPurchasePads(pad)
	end
end

function HouseService:SetupPurchasePads(pad)
	local connection
	connection = pad.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		local character = humanoid.Parent
		local player = Players:GetPlayerFromCharacter(character)
		connection:Disconnect()
		PurchaseHouse(player, pad.Parent)
	end)
end

function PurchaseHouse(player, model)
	local house = HouseClass.new(player, model)
	print(house.owner)
end

function HouseService:KnitStart() end

return HouseService
