local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ServerScriptService = game:GetService("ServerScriptService")
local Wave = require(ServerScriptService.Classes.Wave)
local Janitor = require(ReplicatedStorage.Packages.janitor)

local GameService = Knit.CreateService({
	Name = "GameService",
	janitor = Janitor.new()
})

function GameService:StartGame(player)
	task.spawn(function()
		task.wait(1)
		local wave = Wave.new(player)
		wave:StartGame()
	end)
end

return GameService
