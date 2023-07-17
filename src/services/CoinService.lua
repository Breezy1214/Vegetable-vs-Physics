-- Import Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import Knit framework
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Create a new service for managing player coins
local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {},
})

-- Initialize the service
function CoinService:KnitInit()
	-- Iterate over existing players and create leader stats for each
	for _, player in (Players:GetChildren()) do
		self:CreateLeaderStat(player)
	end

	-- Attach listener to PlayerAdded event to create leader stats for new players
	Players.PlayerAdded:Connect(function(player)
		self:CreateLeaderStat(player)
	end)
end

-- Function to create a leader stat for a given player
function CoinService:CreateLeaderStat(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	leaderstats.Parent = player
end

-- Function to get a player's current coin total
function CoinService:GetCoins(player)
	return player.leaderstats.Coins.Value
end

-- Function to reset a player's coin total
function CoinService:ResetCoins(player)
	player.leaderstats.Coins.Value = 0
end

-- Function to add coins to a player's total
function CoinService:AddCoins(player, amount)
	if type(amount) ~= "number" or amount < 0 then
		return
	end

	player.leaderstats.Coins.Value += amount
end

-- Function to remove coins from a player's total
function CoinService:RemoveCoins(player, amount)
	if type(amount) ~= "number" or amount < 0 then
		return
	end

	player.leaderstats.Coins.Value = math.max(0, player.leaderstats.Coins.Value - amount)
end

return CoinService
