local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catapult = {}
Catapult.__index = Catapult
local Janitor = require(ReplicatedStorage.Packages.janitor)
local catapult = ReplicatedStorage.Assets.Catapult

local part = Instance.new("Part")
part.Shape = Enum.PartType.Ball
part.Size = Vector3.new(4, 4, 4)
part.CollisionGroup = "Weapons"

function Catapult.new(position: Vector3)
	local self = setmetatable({}, Catapult)
	self.janitor = Janitor.new()
	self.catapult = self.janitor:Add(catapult:Clone(), "Destroy")
	self.catapult:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(180), 0))
	self.catapult.Parent = workspace

	self.janitor:Add(function()
		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end, true)

	return self
end

function Catapult:Fire()
	local newPart = part:Clone()
end

function Catapult:Destroy()
	self.janitor:Destroy()
end

return Catapult
