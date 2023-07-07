-- Import services
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

-- Import external modules
local janitor = require(ReplicatedStorage.Packages.janitor)

-- Define enemy module
local Enemy = {}
Enemy.__index = Enemy

-- Enemy constructor
function Enemy.new(house: ObjectValue, model: Model, speed: IntValue, health: IntValue, isBoss: boolean)
	local self = setmetatable({}, Enemy)

	-- Initialize enemy properties
	self.model = model
	self.speed = speed
	self.health = health
	self.isBoss = isBoss or false
	self.janitor = janitor.new()
	self.owner = house.owner
	self.target = house
	self.shouldDamageHouse = false

	-- Add cleanup function
	self.janitor:Add(function()
		self.model:Destroy()
		self.shouldDamageHouse = false -- Stop damage coroutine
		setmetatable(self, nil)
		table.clear(self)
		print("Enemy has been destroyed")
	end, true)

	return self
end

-- Function to spawn the enemy at the designated spawn point
function Enemy:Spawn()
	local spawnLocation = self.target.house.EnemySpawnPoints[self.model.Name]
	self.model:PivotTo(CFrame.new(spawnLocation.Position))
	self.model.Parent = workspace
	warn("Enemy spawned")
end

-- Function to reduce the enemy's health by a certain amount of damage
function Enemy:TakeDamage(damage)
	self.health -= damage
	if self.health <= 0 then
		self:Destroy()
	end
end

-- Coroutine to damage the house every 3 seconds while the enemy is alive
function Enemy:DamageHouse()
	self.shouldDamageHouse = true
	task.defer(function()
		while self and self.shouldDamageHouse and self.health > 0 do
			self.target:Damage(1)
			task.wait(3)
		end
	end)
end

-- Function to move the enemy towards the end point using a tween
function Enemy:Move()
	local targetPosition = Vector3.new(
		self.target.house.EnemyEndPoints[self.model.Name].Position.X,
		self.model.PrimaryPart.Size.Y / 2,
		self.target.house.EnemyEndPoints[self.model.Name].Position.Z
	)
	local tween = TweenService:Create(
		self.model.PrimaryPart,
		TweenInfo.new(self.speed, Enum.EasingStyle.Linear),
		{ Position = targetPosition }
	)
	self.janitor:Add(tween, "Destroy", "CurrentTween")

	-- Connection to respond to the completion of the tween and start damaging the house
	self.janitor:Add(
		tween.Completed:Connect(function(state)
			if state ~= Enum.PlaybackState.Completed then
				return
			end

			self:DamageHouse()
		end),
		"Disconnect"
	)

	tween:Play()
end

-- Function to destroy the enemy and clean up connections
function Enemy:Destroy()
	self.janitor:Destroy()
end

return Enemy
