local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {},
})

function CoinService:KnitInit()
	for _, player in Players:GetChildren() do
		self:CreateLeaderStat(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:CreateLeaderStat(player)
	end)
end

function CoinService:CreateLeaderStat(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	leaderstats.Parent = player
end

function CoinService:GetCoins(player)
	return player.leaderstats.Coins.Value
end

function CoinService:ResetCoins(player)
	player.leaderstats.Coins.Value = 0
end

function CoinService:AddCoins(player, amount)
	if type(amount) ~= "number" then
		return
	end

	if amount < 0 then
		return
	end

	player.leaderstats.Coins.Value += amount
end

function CoinService:RemoveCoins(player, amount)
	if type(amount) ~= "number" then
		return
	end

	if amount < 0 then
		return
	end

	player.leaderstats.Coins.Value = math.max(0, player.leaderstats.Coins.Value - amount)
end

return CoinService
