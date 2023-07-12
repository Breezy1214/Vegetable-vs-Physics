-- Import services and modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Boulder = require(ServerScriptService.Classes.Boulder)
local Bomb = require(ServerScriptService.Classes.Bomb)
local House = require(ServerScriptService.Classes.House)

-- Create the WeaponService
local WeaponService = Knit.CreateService({
	Name = "WeaponService",
	Client = {
		CreateGuiSignal = Knit.CreateSignal(), -- Create GUI signal
		ButtonPressed = Knit.CreateSignal(), -- Button pressed signal
	},
})

-- Define weapons
WeaponService.Weapons = { ["Boulder"] = 20, ["Bomb"] = 100 }

-- Define actions
WeaponService.Actions = {
	["Boulder"] = function(self, player)
		self:SpawnBoulder(player)
	end,

	["Bomb"] = function(self, player)
		self:SpawnBomb(player)
	end,
	-- Add other actions as needed
}

-- Initialization function
function WeaponService:KnitInit()
	-- Connect the ButtonPressed event
	self.Client.ButtonPressed:Connect(function(player, buttonName)
		local CoinService = Knit.GetService("CoinService")
		local coins = CoinService:GetCoins(player)
		local amount = self.Weapons[buttonName]

		if coins < amount then
			return
		end

		CoinService:RemoveCoins(player, amount)
		local action = self.Actions[buttonName]
		if action then
			action(self, player)
		end
	end)
end

-- Function to create GUI
function WeaponService:CreateGui(player)
	self.Client.CreateGuiSignal:Fire(player)
end

-- Function to get the weapon list (client-side)
function WeaponService.Client:GetWeaponList()
	return self.Server.Weapons
end

-- Function to spawn a boulder
function WeaponService:SpawnBoulder(player)
	local house = House.GetHouseFromPlayer(player) -- Get the player's house
	local positions = house.house.WeaponSpawner:GetChildren() -- Get the weapon spawner positions

	for _, v in positions do
		local boulder = Boulder.new(v.WorldCFrame.Position) -- Create a new boulder
		boulder:StartListeningForCollisions() -- Start listening for collisions

		task.delay(20, function()
			-- Check if boulder exists before trying to destroy it
			if boulder == nil then
				return
			end
			boulder:Destroy()
		end)
	end
end

-- Function to spawn a bomb
function WeaponService:SpawnBomb(player)
	local house = House.GetHouseFromPlayer(player) -- Get the player's house
	local middleAttachment = house.house.WeaponSpawner.Middle -- Get the weapon spawner middle position
	local bomb = Bomb.new(middleAttachment.WorldCFrame.Position) -- Create a new bomb

	task.delay(2, function()
		-- Check if bomb exists before trying to explode it just incase. Should always exist though
		if bomb == nil then
			return
		end
		bomb:Explode()
	end)
end

-- Function to start the service
function WeaponService:KnitStart()
	local boulderSpawnPart = workspace.SpawnBoulder -- Get the boulder spawn part
	local clickDectector = Instance.new("ClickDetector") -- Create a new ClickDetector

	-- Connect the MouseClick event to spawn a boulder
	clickDectector.MouseClick:Connect(function(playerWhoClicked)
		self:SpawnBoulder(playerWhoClicked)
	end)

	-- Set the parent of the ClickDetector
	clickDectector.Parent = boulderSpawnPart
end

-- Return the service
return WeaponService
