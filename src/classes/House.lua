local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Cache = {}
local Signal = require(ReplicatedStorage.Packages.signal)
local janitor = require(ReplicatedStorage.Packages.janitor)

local House = {}
House.__index = House

function House.GetHouseFromPlayer(player: Player)
	return Cache[player]
end

function House.new(player: Player, house: Model)
	local self = setmetatable({}, House)
	self.house = house
	self.health = 100
	self.maxHealth = self.health
	self.owner = player
	self.signal = Signal.new()
	self.janitor = janitor.new()

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.MaxDistance = 300
	billboardGui.Size = UDim2.new(0, 500, 0, 50)
	billboardGui.Adornee = Instance.PrimaryPart

	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.BackgroundColor3 = Color3.fromRGB(115, 0, 0)
	backgroundFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	backgroundFrame.Parent = billboardGui

	self.frame = Instance.new("Frame")
	self.frame.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	self.frame.AnchorPoint = Vector2.new(0, 0.5)
	self.frame.Size = UDim2.new(1, 0, 1, 0)
	self.frame.Position = UDim2.new(0, 0, 0.5, 0)
	self.frame.Parent = backgroundFrame

	self.signal:Connect(function()
		self:UpdateHealthGui()
	end)

	billboardGui.Parent = house.PrimaryPart

	self.janitor:Add(function()
		self.house:Destroy()
		self.signal:Destroy()

		if Cache[self.owner] ~= nil then
			Cache[self.owner] = nil
		end

		setmetatable(self, nil)
		table.clear(self)
		print('house is destroyed')
	end, true)

	self:UpdateHealthGui()

	Cache[player] = self
	return self
end

function House:UpdateHealthGui()
	local goal = { Size = UDim2.new(math.clamp(self.health / self.maxHealth, 0, 1), 0, 1, 0) }
	local info = TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.frame, info, goal)
	self.janitor:Add(tween, "Destroy", "Tween")
	tween:Play()
end

function House:Damage(amount: IntValue)
	self.health -= amount
	print(self.health .. "/" .. self.maxHealth)
	self.signal:Fire()

	if self.health <= 0 then
		self:Destroy()
	end
end

function House:Destroy()
	self.janitor:Destroy()
end

return House