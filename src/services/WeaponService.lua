local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Boulder = require(ServerScriptService.Classes.Boulder)
local House = require(ServerScriptService.Classes.House)

local WeaponService = Knit.CreateService({
	Name = "WeaponService",
	Client = {},
})

function WeaponService:KnitInit() end

function WeaponService:KnitStart()
	local boulderSpawnPart = workspace.SpawnBoulder
	local clickDectector = Instance.new("ClickDetector")
	clickDectector.MouseClick:Connect(function(playerWhoClicked)
		local house = House.GetHouseFromPlayer(playerWhoClicked)
		local positions = house.house.WeaponSpawner:GetChildren()

		for _, v in positions do
			local boulder = Boulder.new(v.WorldCFrame.Position)
			boulder:StartListeningForCollisions()
			task.delay(3, function()
				if boulder == nil then
					return
				end

				--boulder:Destroy()
			end)
		end
	end)

	clickDectector.Parent = boulderSpawnPart
end

return WeaponService
