local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local janitor = require(ReplicatedStorage.Packages.janitor)
local Enemy = {}
Enemy.__index = Enemy

local function followPath(destination) end

function Enemy.new(model: Model, type: string, speed: IntValue, health: IntValue, isBoss: boolean)
	local self = setmetatable({}, Enemy)
	self.model = model
	self.type = type
	self.speed = speed
	self.health = health
	self.isBoss = isBoss or false
	self.janitor = janitor.new()
	self.waypoints = nil
	self.nextWaypointIndex = nil
	self.reachedConnection = nil
	self.blockedConnection = nil

	self.janitor:Add(function()
		print(self.type .. "has been defeated")
		setmetatable(self, nil)
		table.clear(self)
		print("destroyed")
	end, true)

	return self
end

function Enemy:TakeDamage(damage)
	self.health -= damage
	if self.health <= 0 then
		self:Destroy()
	end
end

function Enemy:ComputePath(destination)
	local path = PathfindingService:CreatePath({
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = true,
		Costs = {
			Water = 20,
		},
	})

	-- Compute the path
	local success, errorMessage = pcall(function()
		path:ComputeAsync(self.model.PrimaryPart.Position, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		-- Get the path waypoints
		self.waypoints = path:GetWaypoints()

		-- Detect if path becomes blocked
		self.blockedConnection = self.janitor:Add(
			path.Blocked:Connect(function(blockedWaypointIndex)
				-- Check if the obstacle is further down the path
				if blockedWaypointIndex >= self.nextWaypointIndex then
					-- Stop detecting path blockage until path is re-computed
					self.janitor:Remove("BlockedConnection")
					-- Call function to re-compute new path
					self:ComputePath(destination)
				end
			end),
			"Disconnect",
			"BlockedConnection"
		)

		-- Detect when movement to next waypoint is complete
		if not self.reachedConnection then
			self.reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
				if reached and self.nextWaypointIndex < #self.waypoints then
					-- Increase waypoint index and move to next waypoint
					self.nextWaypointIndex += 1
					humanoid:MoveTo(self.waypoints[self.nextWaypointIndex].Position)
				else
                    self.janitor:RemoveList('BlockedConnection', 'ReachedConnection')
				end
			end)
		end

		-- Initially move to second waypoint (first waypoint is path start; skip it)
		self.nextWaypointIndex = 2
		humanoid:MoveTo(self.waypoints[self.nextWaypointIndex].Position)
	else
		warn("Path not computed!", errorMessage)
	end
end

function Enemy:Move(destination)
	------------------------------------
	local info = TweenInfo.new(1)
	local goal = { Position = x }
	local tween = TweenService:Create()
end

function Enemy:Destroy()
	self.janitor:Destroy()
end

return Enemy
