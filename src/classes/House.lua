-- Importing services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Importing external modules
local Signal = require(ReplicatedStorage.Packages.signal)
local Janitor = require(ReplicatedStorage.Packages.janitor)

local Cache = {}

local House = {}
House.__index = House

-- Returns the house associated with a given player
function House.GetHouseFromPlayer(player)
	return Cache[player]
end

-- Returns all the houses in the cache
function House.GetAllHouses()
	return Cache
end

-- Constructor function for the House object
function House.new(player, house)
	local self = setmetatable({}, House)

	self.janitor = Janitor.new()
	self.house = self.janitor:Add(house:Clone(), "Destroy")
	self.janitor:LinkToInstance(self.house)
	self.health = 100
	self.maxHealth = self.health
	self.owner = player
	self.HealthChanged = Signal.new()

	-- Creating a health bar with BillboardGui
	self:CreateHealthBar()

	self.janitor:Add(function()
		self.HealthChanged:Destroy()
		Cache[self.owner] = nil
		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end, true)

	-- Hiding the enemy spawn and end points
	self:SetVisibilityForEnemyPoints(1)

	Cache[player] = self
	self.house.Parent = workspace.Houses
	return self
end

-- Function to create a health bar with BillboardGui
function House:CreateHealthBar()
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.MaxDistance = 300
	billboardGui.Size = UDim2.new(0, 500, 0, 50)
	billboardGui.Adornee = self.house.HealthBarPart

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

	billboardGui.Parent = self.house.HealthBarPart
end

-- Function to set visibility for enemy points
function House:SetVisibilityForEnemyPoints(transparency)
	for _, point in pairs(self.house.EnemySpawnPoints:GetChildren()) do
		point.Transparency = transparency
	end

	for _, point in pairs(self.house.EnemyEndPoints:GetChildren()) do
		point.Transparency = transparency
	end
end

-- Function to update the health GUI
function House:UpdateHealthGui()
	local goal = { Size = UDim2.new(math.clamp(self.health / self.maxHealth, 0, 1), 0, 1, 0) }
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.frame, tweenInfo, goal)

	self.janitor:Add(tween, "Destroy")
	tween:Play()
end

-- Function to damage the house
function House:Damage(amount)
	self.health -= amount
	self.HealthChanged:Fire()

	if self.health <= 0 then
		self:Destroy()
	end
end

-- Function to destroy the house
function House:Destroy()
	self.janitor:Destroy()
end

return House
