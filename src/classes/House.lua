-- Importing required services and modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Signal = require(ReplicatedStorage.Packages.signal)
local Janitor = require(ReplicatedStorage.Packages.janitor)

-- Cache to store created houses
local Cache = {}

-- House class
local House = {}
House.__index = House

-- Fetches house instance associated with the player
function House.GetHouseFromPlayer(player)
	return Cache[player]
end

-- Fetches all the houses in the cache
function House.GetAllHouses()
	return Cache
end

-- Constructor function for the House class
function House.new(player, houseModel)
	local self = setmetatable({}, House)

	-- Instantiate a new Janitor for this house instance
	self.janitor = Janitor.new()

	-- Create a copy of the house model and assign to this house
	self.house = self.janitor:Add(houseModel:Clone(), "Destroy")

	-- Set initial house attributes
	self.maxHealth = 100
	self.health = self.maxHealth
	self.owner = player

	-- Signal to indicate health change
	self.HealthChanged = Signal.new()

	-- Create a GUI to show the health status of the house
	self:CreateHealthBar()

	-- Register a clean up function to run when the house is destroyed
	self.janitor:Add(function()
		self.HealthChanged:Destroy()
		Cache[self.owner] = nil
		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end, true)

	-- Hide enemy spawn and end points by default
	self:SetVisibilityForEnemyPoints(1)

	-- Add the house to the cache and workspace
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
	for _, point in (self.house.EnemySpawnPoints:GetChildren()) do
		point.Transparency = transparency
	end

	for _, point in (self.house.EnemyEndPoints:GetChildren()) do
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
	-- Decrease the house's health
	self.health = math.max(self.health - amount, 0)

	-- Fire health changed event
	self.HealthChanged:Fire()

	-- Destroy the house if health drops to zero
	if self.health <= 0 then
		self:Destroy()
	end
end

-- Function to destroy the house
function House:Destroy()
	self.janitor:Destroy()
end

return House
