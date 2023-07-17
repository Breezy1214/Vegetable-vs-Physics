-- Import services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Import external modules
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Setup Remote Events
local moveEnemyEvent = Instance.new("RemoteEvent", ReplicatedStorage.Remotes)
moveEnemyEvent.Name = "MoveEnemyEvent"

local damageHouseEvent = Instance.new("RemoteEvent", ReplicatedStorage.Remotes)
damageHouseEvent.Name = "DamageHouseEvent"

-- Enemy Module
local Enemy = {}
Enemy.__index = Enemy

-- Map for quick model to enemy lookup
local modelToEnemyMap = {}

-- Fetch enemy instance from given part
function Enemy.GetEnemyFromPart(part)
	if part then
		return modelToEnemyMap[part.Parent]
	end
end

-- Initialize new enemy instance
function Enemy.new(house, model, speed, health, isBoss)
	-- Instantiate enemy
	local self = setmetatable({}, Enemy)

	-- Assign properties
	self.target = house
	self.model = model
	self.speed = speed
	self.maxHealth = health
	self.health = self.maxHealth
	self.isBoss = isBoss or false
	self.janitor = Janitor.new()
	self.shouldDamageHouse = false

	-- Setup flags
	self.destroyed = false
	self.moving = false

	-- Setup health change signal
	self.healthChanged = Signal.new()

	-- Create health bar
	self:CreateHealthBar()

	-- Register cleanup task
	self.janitor:Add(function()
		self.destroyed = true
		self.healthChanged:Destroy()
		self.model:Destroy()
		modelToEnemyMap[self.model] = nil
	end, true)

	-- Register enemy
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

	self.healthChanged:Connect(function()
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
	self.healthChanged:Fire()
	if self.health <= 0 then
		self:Destroy()
	end
end

-- Coroutine to damage the house every 3 seconds while the enemy is alive
function Enemy:DamageHouse()
	self.shouldDamageHouse = true
	self.moving = false

	task.defer(function()
		while self and self.shouldDamageHouse and self.health > 0 do
			if self.destroyed == false then
				self.target:Damage(1)
			end
			task.wait(3)
		end
	end)
end

-- Attach server events
damageHouseEvent.OnServerEvent:Connect(function(player, model)
	if model == nil then
		return
	end

	local enemy = Enemy.GetEnemyFromPart(model.PrimaryPart)
	if enemy then
		enemy:DamageHouse()
	end
end)

moveEnemyEvent.OnServerEvent:Connect(function(player, model, position)
	if model.PrimaryPart then
		model.PrimaryPart.Position = position
	end
end)

-- Function to move the enemy towards the end point using a tween
function Enemy:Move()
	local endPosition = self.target.house.EnemyEndPoints[self.model.Name].Position
	local targetPosition = Vector3.new(endPosition.X, self.model.PrimaryPart.Position.Y, endPosition.Z)

	moveEnemyEvent:FireAllClients(self.model, targetPosition, self.speed)
	self.moving = true
end

-- Function to destroy the enemy and clean up connections
function Enemy:Destroy()
	self.janitor:Destroy()
end

return Enemy
