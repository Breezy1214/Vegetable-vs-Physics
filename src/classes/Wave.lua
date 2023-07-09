-- Import services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Import external modules
local Enemy = require(ServerScriptService.Classes.Enemy)
local Janitor = require(ReplicatedStorage.Packages.janitor)
local House = require(ServerScriptService.Classes.House)

-- Define Wave module
local Wave = {}
Wave.__index = Wave

-- Constants
local ENEMY_SPEED = 10

-- Wave constructor
function Wave.new(player)
	local self = setmetatable({}, Wave)

	-- Initialize wave properties
	self.currentState = "IDLE"
	self.currentWave = 0
	self.enemies = {}
	self.janitor = Janitor.new()
	self.player = player
	self.house = House.GetHouseFromPlayer(player)
	self.enemiesAlive = 0

	-- Connection to handle house destruction
	self.janitor:Add(
		self.house.house.Destroying:Connect(function()
			self:EndGame()
		end),
		"Disconnect"
	)

	-- Cleanup function
	self.janitor:Add(function()
		for _, enemy in pairs(self.enemies) do
			enemy:Destroy()
		end

		table.clear(self.enemies) -- Clear enemies table
		setmetatable(self, nil) -- Clear metatable
		table.clear(self) -- Clear self
		print("Wave ended then cleaned up.")
	end, true)

	return self
end

-- Function to start the game
function Wave:StartGame()
	self.currentState = "RUNNING"
	self:NextWave()
end

-- Function to end the game
function Wave:EndGame()
	self.currentState = "ENDED"
	self.janitor:Destroy()
end

-- Function to spawn enemies for the wave
function Wave:SpawnEnemies(speed, health)
	for count = 1, self.currentWave do
		for i = 1, 10 do
			local enemy = Enemy.new(self.house, ServerStorage.Enemies.Vegetable:Clone(), speed, health)
			enemy.model.Name = tostring(i)
			enemy:Spawn()
			self.enemiesAlive += 1
			local id = #self.enemies + 1 -- Generate a unique id for each enemy
			self.enemies[id] = enemy
			self:OnEnemiesDefeated(enemy, id)

			-- Delay the enemy's move if it's within the first 5 enemies
			if i <= 5 then
				self.janitor:Add(
					task.defer(function()
						task.wait(3)
						enemy:Move()
					end),
					true
				)
			else
				enemy:Move()
			end
			task.wait(0.1)
		end

		task.wait(2)
	end
end

function Wave:OnEnemiesDefeated(enemy, id)
	enemy.model.Destroying:Connect(function()
		if not self and not self.enemies and not self.enemiesAlive then
			return
		end

		self.enemies[id] = nil
		self.enemiesAlive -= 1

		if self.enemiesAlive <= 0 then
			self:NextWave()
		end
	end)
end

-- Function to start the next wave
function Wave:NextWave()
	if self.currentState == "ENDED" then
		return
	end

	for i = 1, 3 do
		print(i)
		task.wait(1)
	end

	self.currentWave += 1
	print("Wave " .. self.currentWave .. " is starting!")

	-- Configure enemy properties
	local health = self.currentWave * 100

	self:SpawnEnemies(ENEMY_SPEED, health)
end

return Wave
