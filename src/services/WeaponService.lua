-- Import services and modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Boulder = require(ServerScriptService.Classes.Boulder)
local Bomb = require(ServerScriptService.Classes.Bomb)
local House = require(ServerScriptService.Classes.House)
local Catapult = require(ServerScriptService.Classes.Catapult)

-- Create the WeaponService
local WeaponService = Knit.CreateService({
	Name = "WeaponService",
	Client = {
		CreateGuiSignal = Knit.CreateSignal(), -- Create GUI signal
		ButtonPressed = Knit.CreateSignal(), -- Button pressed signal
		ExplosionSignal = Knit.CreateSignal(),
	},
})

-- Define weapons
WeaponService.Weapons = { ["Boulder"] = 20, ["Bomb"] = 100, ["Catapult"] = 30 }

-- Define actions
WeaponService.Actions = {
	["Boulder"] = function(self, player)
		self:SpawnBoulder(player)
	end,

	["Bomb"] = function(self, player)
		self:SpawnBomb(player)
	end,

	["Catapult"] = function(self, player)
		self:Catapult(player)
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
		if v.Name == "BottomMiddle" then
			continue
		end

		local boulder = Boulder.new(v.WorldCFrame.Position) -- Create a new boulder

		boulder:StartListeningForCollisions() -- Start listening for collisions

		task.delay(20, function()
			-- Check if boulder exists before trying to destroy it
			if boulder == nil or boulder.destroyed == nil or boulder.destroyed == true then
				boulder = nil
				return
			end

			boulder:Destroy()
			boulder = nil
		end)
	end
end

-- Function to spawn a bomb
function WeaponService:SpawnBomb(player)
	local house = House.GetHouseFromPlayer(player) -- Get the player's house
	local topMiddleAttachment = house.house.WeaponSpawner.TopMiddle -- Get the weapon spawner middle position
	local bomb = Bomb.new(topMiddleAttachment.WorldCFrame.Position)

	task.delay(2, function()
		self.Client.ExplosionSignal:Fire(player, bomb.part)
		bomb:Explode(player)
	end)
end

-- Function to spawn a catapult
function WeaponService:Catapult(player)
	-- player should only be able to spawn one at a time
	-- can be changed later on but i prefer this for now
	if workspace:FindFirstChild(player.Name .. "Catapult") then
		return
	end

	local house = House.GetHouseFromPlayer(player) -- Get the player's house
	local bottomMiddleAttachment = house.house.WeaponSpawner.BottomMiddle -- Get the weapon spawner middle position
	local catapult = Catapult.new(player.Name, bottomMiddleAttachment.WorldCFrame.Position)
	local thread

	thread = task.defer(function()
		while true do
			task.wait(1)
			catapult:Fire()
			task.wait(1)
			self.Client.ExplosionSignal:Fire(player, catapult.Ammo)
		end
	end)

	task.delay(30, function()
		task.cancel(thread)
		catapult:Destroy()
	end)
end

-- Return the service
return WeaponService
