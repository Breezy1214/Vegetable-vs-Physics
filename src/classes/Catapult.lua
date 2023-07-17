-- Importing Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Importing required modules
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Enemy = require(ServerScriptService.Classes.Enemy)

-- Defining constants
local catapultTemplate = ReplicatedStorage.Assets.Catapult
local PART_SIZE = Vector3.new(4, 4, 4)
local PART_COLOR = Color3.fromRGB(255, 0, 0)
local OVERLAP_SIZE = Vector3.new(60, 4, 30)
local ENEMY_DAMAGE_AMOUNT = 100

-- Catapult Class
local Catapult = {}
Catapult.__index = Catapult

-- Catapult Class Constructor
function Catapult.new(playerName: StringValue, position: Vector3)
	local self = setmetatable({}, Catapult)

	self.janitor = Janitor.new()

	-- Creating and positioning catapult instance
	self.catapult = self.janitor:Add(catapultTemplate:Clone(), "Destroy")
	self.catapult:PivotTo(CFrame.new(position) * CFrame.Angles(0, math.rad(180), 0))
	self.catapult.Name = playerName .. "Catapult"
	self.catapult.Parent = workspace

	self.angle = 80
	self.speed = 5
	self.hinge = self.catapult.HPart.HingeConstraint
	self.hinge.AngularSpeed = self.speed

	-- Clean up function to run when the Catapult is destroyed
	self.janitor:Add(function()
		setmetatable(self, nil)
		self = nil
	end, true)

	return self
end

-- Creates a new part for the catapult to fire
local function createPart()
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = PART_SIZE
	part.Material = Enum.Material.CrackedLava
	part.Color = PART_COLOR

	return part
end

-- Damages enemies hit by the catapult
function Catapult:DamageEnemy(newPart)
	local overlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = "Enemies"

	local cframe = CFrame.new(newPart.CFrame.Position)
	local hitParts = workspace:GetPartBoundsInBox(cframe, OVERLAP_SIZE, overlapParams)

	for _, part in (hitParts) do
		local enemy = Enemy.GetEnemyFromPart(part)
		if enemy then
			enemy:TakeDamage(ENEMY_DAMAGE_AMOUNT)
		end
	end
end

-- Fires the catapult
function Catapult:Fire()
	local newPart = createPart()
	newPart.Position = self.catapult.Teleport.Position
	newPart.Name = "Ammo"
	newPart.Parent = self.catapult

	task.wait(1)
	self.hinge.TargetAngle = -self.angle

	task.wait(2)
	newPart.Anchored = true
	self:DamageEnemy(newPart)
	newPart:Destroy()

	self.hinge.AngularSpeed = 1
	self.hinge.TargetAngle = 0
	self.hinge.AngularSpeed = self.speed

	task.wait(2)
end

-- Destroys the catapult
function Catapult:Destroy()
	self.janitor:Destroy()
end

return Catapult
