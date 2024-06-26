-- Importing Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Importing required modules
local Janitor = require(ReplicatedStorage.Packages.janitor)
local Enemy = require(ServerScriptService.Classes.Enemy)

-- Boulder Class
local Boulder = {}
Boulder.__index = Boulder

-- Boulder Class Constructor
function Boulder.new(position: Vector3)
	local self = setmetatable({}, Boulder)

	-- Initializing Boulder part
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
	self.destroyed = false

	self.janitor = Janitor.new()
	self.debounce = false

	self.janitor:Add(
		self.part.Destroying:Connect(function()
			self:Destroy()
		end),
		"Disconnect"
	)

	self.janitor:Add(function()
		self.destroyed = true
		if self.part then
			self.part:Destroy()
		end
		setmetatable(self, nil)
		table.clear(self)
		self = nil
	end)

	return self
end

-- Begin Listening for Collisions
function Boulder:StartListeningForCollisions()
	self.janitor:Add(
		self.part.Touched:Connect(function(hit)
			if self.debounce then
				return
			end

			local enemy = Enemy.GetEnemyFromPart(hit)
			if enemy then
				self.debounce = true
				enemy:TakeDamage(50)
				self:Destroy()
			end
		end),
		"Disconnect"
	)
end

-- Destroy the Boulder
function Boulder:Destroy()
	self.janitor:Destroy()
end

return Boulder
