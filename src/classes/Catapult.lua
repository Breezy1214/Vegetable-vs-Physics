local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Catapult = {}
Catapult.__index = Catapult
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Enemy = require(ServerScriptService.Classes.Enemy)
local catapult = ReplicatedStorage.Assets.Catapult

local part = Instance.new("Part")
part.Shape = Enum.PartType.Ball
part.Size = Vector3.new(4, 4, 4)
part.Material = Enum.Material.CrackedLava
part.Color = Color3.fromRGB(255, 0, 0)

function Catapult.new(playerName: StringValue, position: Vector3)
	local self = setmetatable({}, Catapult)
	self.janitor = Janitor.new()
	self.catapult = self.janitor:Add(catapult:Clone(), "Destroy")
	self.catapult:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(180), 0))
	self.angle = 80
	self.speed = 5
	self.hinge = self.catapult.HPart.HingeConstraint
	self.hinge.AngularSpeed = self.speed
	self.catapult.Name = playerName .. "Catapult"
	self.catapult.Parent = workspace

	self.janitor:Add(function()
		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end, true)

	return self
end

function Catapult:DamageEnemy(newPart)
	local overlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = 'Enemies'
	local size = Vector3.new(60, 4, 30)
	local cframe = CFrame.new(newPart.CFrame.Position)
	local enemiesArray = workspace:GetPartBoundsInBox(cframe, size, overlapParams)

	-- local hitbox = Instance.new("Part")
	-- hitbox.Size = size
	-- hitbox.CFrame = cframe
	-- hitbox.CanCollide = false
	-- hitbox.CanQuery = false
	-- hitbox.Transparency = 0.5
	-- hitbox.Anchored = true
	-- hitbox.Parent = workspace
	-- task.delay(2, function()
	-- 	hitbox:Destroy()
	-- end)

	for _, v in enemiesArray do
		local enemy = Enemy.GetEnemyFromPart(v)
		if not enemy then
			continue
		end
		enemy:TakeDamage(100)
	end
end

function Catapult:Fire()
	local newPart = part:Clone()
	newPart.Position = self.catapult.Teleport.Position
	newPart.Name = "Ammo"
	newPart.Parent = self.catapult
	task.wait(1)
	self.hinge.TargetAngle = self.angle * -1
	task.wait(2)
	newPart.Anchored = true
	self:DamageEnemy(newPart)
	newPart:Destroy()
	self.hinge.AngularSpeed = 1
	self.hinge.TargetAngle = 0
	self.hinge.AngularSpeed = self.speed
	task.wait(2)
end

function Catapult:Destroy()
	self.janitor:Destroy()
end

return Catapult
