-- Import Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Import necessary modules
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Wave = require(ServerScriptService.Classes.Wave)

-- Define Bomb class
local Bomb = {}
Bomb.__index = Bomb

-- Constructor for Bomb
function Bomb.new(position: Vector3)
	local self = setmetatable({}, Bomb)

	-- Clone the Bomb asset and set its properties
	self.part = ReplicatedStorage.Assets.Bomb:Clone()
	self.part.CollisionGroup = "Weapons"
	self.part.Position = position
	self.part.Parent = workspace

	-- Create a janitor instance to manage object cleanup
	self.janitor = Janitor.new()

	-- Link the part instance to the janitor
	self.janitor:LinkToInstance(self.part)

	-- Create a debounce to prevent multiple triggers
	self.debounce = false

	-- Add a cleanup function to the janitor
	self.janitor:Add(function()
		if self.part then
			self.part:Destroy()
		end
		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end)

	return self
end

-- Method to handle the Bomb's explosion
function Bomb:Explode(player)
	-- Prevent the part from moving during explosion
	self.part.Anchored = true

	-- Fetch the player's Wave
	local playerWave = Wave.GetWaveFromPlayer(player)

	-- If the player has a Wave and there are enemies, damage them
	if playerWave and playerWave.enemies then
		for _, enemy in playerWave.enemies do
			enemy:TakeDamage(100)
		end
	end

	-- Wait for half a second before destroying the bomb
	task.wait(0.5)
	self:Destroy()
end

-- Method to handle the Bomb's destruction
function Bomb:Destroy()
	self.janitor:Destroy()
end

return Bomb
