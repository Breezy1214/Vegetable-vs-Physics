local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ServerScriptService = game:GetService("ServerScriptService")
local Wave = require(ServerScriptService.Classes.Wave)

local GameService = Knit.CreateService({
	Name = "GameService",
})

function GameService:StartGame(player)
	local wave = Wave.new(player)
	wave:StartGame()
end

return GameService
