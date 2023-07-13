-- Import services
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local modelToEnemyMap = {}

-- Import external modules
local janitor = require(ReplicatedStorage.Packages.janitor)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Define enemy module
local Enemy = {}
Enemy.__index = Enemy

-- Function to perform a fast lookup in the modelToEnemyMap.
function Enemy.GetEnemyFromPart(part)
	return modelToEnemyMap[part.Parent]
end

-- Enemy constructor
function Enemy.new(house: ObjectValue, model: Model, speed: IntValue, health: IntValue, isBoss: boolean)
	local self = setmetatable({}, Enemy)

	-- Initialize enemy properties
	self.model = model
	self.speed = speed
	self.maxHealth = health
	self.health = self.maxHealth
	self.isBoss = isBoss or false
	self.janitor = janitor.new()
	self.owner = house.owner
	self.target = house
	self.shouldDamageHouse = false
	self.HealthChanged = Signal.new()
	self.moving = false
	self.destroyed = false

	-- Creating a health bar with BillboardGui
	self:CreateHealthBar()

	-- Add cleanup function
	self.janitor:Add(function()
		self.destroyed = true
		self.HealthChanged:Destroy()
		self.model:Destroy()
		self.shouldDamageHouse = false -- Stop damage coroutine
		modelToEnemyMap[self.model] = nil
		setmetatable(self, nil)
		table.clear(self)
	end, true)

	modelToEnemyMap[self.model] = self
	return self
end

-- Function to create a health bar with BillboardGui
function Enemy:CreateHealthBar()
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.MaxDistance = 100
	billboardGui.Size = UDim2.new(0, 100, 0, 10)
	billboardGui.Adornee = self.model.PrimaryPart
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(115, 0, 0)
	backgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	backgroundFrame.Parent = billboardGui

	local healthFrame = Instance.new("Frame")
	healthFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	healthFrame.AnchorPoint = Vector2.new(0, 0.5)
	healthFrame.Size = UDim2.new(1, 0, 1, 0)
	healthFrame.Position = UDim2.new(0, 0, 0.5, 0)
	healthFrame.Parent = backgroundFrame

	self.frame = healthFrame

	self.HealthChanged:Connect(function()
		self:UpdateHealthGui()
	end)

	billboardGui.Parent = self.model.PrimaryPart
end

-- Function to update the health GUI
function Enemy:UpdateHealthGui()
	local goal = { Size = UDim2.new(math.clamp(self.health / self.maxHealth, 0, 1), 0, 1, 0) }
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.frame, tweenInfo, goal)

	self.janitor:Add(tween, "Destroy")
	tween:Play()
end

-- Function to spawn the enemy at the designated spawn point
function Enemy:Spawn()
	local spawnLocation = self.target.house.EnemySpawnPoints[self.model.Name]
	self.model:PivotTo(CFrame.new(spawnLocation.Position))
	self.model.Parent = workspace
end

-- Function to reduce the enemy's health by a certain amount of damage
function Enemy:TakeDamage(damage)
	if self.moving == false and self.shouldDamageHouse == false then
		return
	end

	self.health -= damage
	self.HealthChanged:Fire()
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

			self.moving = false
			self:DamageHouse()
		end),
		"Disconnect"
	)

	tween:Play()
	self.moving = true
end

-- Function to destroy the enemy and clean up connections
function Enemy:Destroy()
	self.janitor:Destroy()
end

return Enemy
