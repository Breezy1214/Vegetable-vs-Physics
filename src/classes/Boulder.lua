local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Enemy = require(ServerScriptService.Classes.Enemy)

local Boulder = {}
Boulder.__index = Boulder

function Boulder.new(position: Vector3)
	local self = setmetatable({}, Boulder)

	self.part = Instance.new("Part")
	self.part.CollisionGroup = "Weapons"
	self.part.Shape = Enum.PartType.Ball
	self.part.Position = position
	self.part.BrickColor = BrickColor.new("Dark stone grey")
	self.part.Material = Enum.Material.Concrete
	self.part.TopSurface = Enum.SurfaceType.Smooth
	self.part.BottomSurface = Enum.SurfaceType.Smooth
	self.part.Size = Vector3.new(11, 11, 11)
	self.part.Anchored = false
	self.part.CanCollide = true
	self.part.Parent = workspace
	self.part.AssemblyLinearVelocity = Vector3.new(0, 0, 8)
	self.janitor = Janitor.new()
	self.janitor:LinkToInstance(self.part)
	self.debounce = false

	self.janitor:Add(function()
		self.part:Destroy()
		setmetatable(self, nil)
		print("boulder is destroyed")
	end)

	return self
end

function Boulder:StartListeningForCollisions()
	self.janitor:Add(
		self.part.Touched:Connect(function(hit)
			local enemy = Enemy.GetEnemyFromPart(hit)
			if not enemy then
				return
			end

			if self.debounce == true then
				return
			end

			self.debounce = true
			enemy:TakeDamage(50)
			self:Destroy()
		end),
		"Disconnect"
	)
end

function Boulder:Destroy()
	self.janitor:Destroy()
end

return Boulder
