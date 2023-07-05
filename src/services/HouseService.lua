local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local House = require(ServerScriptService.Classes.House)
local housePads = CollectionService:GetTagged("HousePad")

local damagehousepart = workspace.DamageHouse

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
		pad.Parent = nil
	end)
end

function PurchaseHouse(player, model)
	local house = House.new(player, model)
end

function HouseService:KnitStart()
	local clickDectector = Instance.new('ClickDetector')
	clickDectector.MouseClick:Connect(function(playerWhoClicked)
		local house = House.GetHouseFromPlayer(playerWhoClicked)
		house:Damage(10)
	end)
	clickDectector.Parent = damagehousepart
end

return HouseService
