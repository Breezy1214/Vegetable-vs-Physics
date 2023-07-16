local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ServerScriptService = game:GetService("ServerScriptService")
local Wave = require(ServerScriptService.Classes.Wave)
local Janitor = require(ReplicatedStorage.Packages.janitor)
local House = require(ServerScriptService.Classes.House)

local GameService = Knit.CreateService({
	Name = "GameService",
	janitor = Janitor.new(),
})

function GameService:KnitInit()
	Players.PlayerRemoving:Connect(function(player)
		local wave = Wave.GetWaveFromPlayer(player)
		if wave then
			wave.playerDisconnecting = true
			wave:EndGame()
			wave = nil
		end

		local house = House.GetHouseFromPlayer(player)
		if house then
			house:Destroy()
		end
	end)
end

function GameService:StartGame(player)
	task.spawn(function()
		task.wait(1)
		local wave = Wave.new(player)
		wave:StartGame()
	end)
end

return GameService
