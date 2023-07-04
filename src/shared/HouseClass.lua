local HouseClass = {}
HouseClass.__index = HouseClass
local Cache = {}

function HouseClass.GetHouseFromPlayer(player: Player)
	
end

function HouseClass.new(player: Player, house: Model)
	local self = setmetatable({}, HouseClass)
	self.house = house
	self.health = 100
	self.model = house
	self.owner = player

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

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	frame.AnchorPoint = Vector2.new(0, 0.5)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0.5, 0)
	frame.Parent = backgroundFrame

	local new
	billboardGui.Parent = house.PrimaryPart
	table.insert(Cache, self)
	return self
end

function HouseClass:Damage(amount: IntValue)
	if self.health <= 0 then
		return
	end

	self.health -= amount

	if self.health <= 0 then
		self:Destroy()
	end
end

function HouseClass:Destroy()
	self.model:Destroy()
	table.remove(Cache, self)
	print(Cache)
	setmetatable(self, nil)
	table.clear(self)
end

return HouseClass
