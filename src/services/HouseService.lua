-- Import services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

-- Import external modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local House = require(ServerScriptService.Classes.House)
local Promise = require(Knit.Util.Promise)

-- Define constants
local housePads = CollectionService:GetTagged("HousePad")
local houseFolder = ServerStorage.Houses

local HouseService = Knit.CreateService({
	Name = "HouseService",
	Client = {},
})

-- Function to initialize HouseService
function HouseService:KnitInit()
	for _, pad in ipairs(housePads) do
		pad:SetAttribute("IsOwned", false)
		self:SetupPurchasePads(pad)
	end
end

-- Function to set up purchase pads
function HouseService:SetupPurchasePads(pad)
	pad.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or pad:GetAttribute("IsOwned") then
			return
		end

		local player = Players:GetPlayerFromCharacter(humanoid.Parent)
		if not player then
			return
		end

		pad:SetAttribute("IsOwned", true)

		-- Purchase the house
		self:PurchaseHouse(player, pad.Name)
			:andThen(function(house)
				house.house.Destroying:Connect(function()
					pad:SetAttribute("IsOwned", false)
					pad.Parent = workspace.PurchasePads
				end)

				pad.Parent = nil
			end)
			:catch(function(err)
				warn(err)
				pad:SetAttribute("IsOwned", false)
			end)
	end)
end

-- Function to purchase a house
function HouseService:PurchaseHouse(player, houseName)
	return Promise.new(function(resolve, reject)
		local playerOldHouse = House.GetHouseFromPlayer(player)

		-- Check if the player already has a house
		if playerOldHouse then
			reject("Player already has a house.")
			return
		end

		print("Creating new house")
		-- Create a new house
		local house = House.new(player, houseFolder[houseName])

		-- Signal the WeaponService to create GUI for the player
		local WeaponService = Knit.GetService("WeaponService")
		WeaponService:CreateGui(player)
		print("Created GUI")

		-- Signal the GameService to start the game
		local GameService = Knit.GetService("GameService")
		GameService:StartGame(player)
		print("Started game")

		resolve(house)
	end)
end

-- Function to start HouseService
function HouseService:KnitStart()
	local damagehousepart = workspace.DamageHouse
	local clickDectector = Instance.new("ClickDetector")
	clickDectector.MouseClick:Connect(function(playerWhoClicked)
		local house = House.GetHouseFromPlayer(playerWhoClicked)
		if not house then
			return
		end

		-- Damage the house
		house:Damage(50)
	end)

	clickDectector.Parent = damagehousepart
end

return HouseService
