-- Import necessary services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Import required modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Wave = require(ServerScriptService.Classes.Wave)
local House = require(ServerScriptService.Classes.House)

-- Create the GameService
local GameService = Knit.CreateService({
	Name = "GameService",
	Client = {},
})

-- Initialize the service
function GameService:KnitInit()
	-- Add an event for when a player is leaving the game
	Players.PlayerRemoving:Connect(function(player)
		-- Terminate the wave associated with the player
		local wave = Wave.GetWaveFromPlayer(player)
		if wave then
			wave.playerDisconnecting = true
			wave:EndGame()
		end

		-- Remove the house associated with the player
		local house = House.GetHouseFromPlayer(player)
		if house then
			house:Destroy()
		end
	end)
end

-- Function to start a new game for a player
function GameService:StartGame(player)
	-- Start the game in a separate thread to avoid blocking other operations
	task.spawn(function()
		task.wait(1)
		local wave = Wave.new(player)
		wave:StartGame()
	end)
end

return GameService
