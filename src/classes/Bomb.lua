local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Wave = require(ServerScriptService.Classes.Wave)

local Bomb = {}
Bomb.__index = Bomb

function Bomb.new(position: Vector3)
	local self = setmetatable({}, Bomb)

	self.part = ReplicatedStorage.Assets.Bomb:Clone()
	self.part.CollisionGroup = "Weapons"
	self.part.Position = position
	self.part.Parent = workspace
	self.janitor = Janitor.new()
	self.janitor:LinkToInstance(self.part)
	self.debounce = false

	self.janitor:Add(function()
		self.part:Destroy()
		setmetatable(self, nil)
		print("bomb is destroyed")
	end)

	return self
end

function Bomb:Explode(player)
	self.part.Anchored = true
	local playerWave = Wave.GetWaveFromPlayer(player)

	for _, enemy in playerWave.enemies do
		enemy:TakeDamage(100)
	end

	task.wait(0.5)
	self:Destroy()
end

function Bomb:Destroy()
	self.janitor:Destroy()
end

return Bomb
