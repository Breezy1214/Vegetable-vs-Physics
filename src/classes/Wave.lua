-- Import services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Import external modules
local Enemy = require(ServerScriptService.Classes.Enemy)
local Janitor = require(ReplicatedStorage.Packages.janitor)
local House = require(ServerScriptService.Classes.House)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Cache = {}

-- Define Wave module
local Wave = {}
Wave.__index = Wave

-- Constants
local ENEMY_SPEED = 20

-- Function to return wave instance for a player
function Wave.GetWaveFromPlayer(player)
	return Cache[player]
end

-- Function to create a new wave instance
function Wave.new(player)
	local self = setmetatable({}, Wave)

	-- Initialize wave properties
	self.currentState = "IDLE"
	self.spawning = false
	self.currentWave = 0
	self.enemies = {}
	self.janitor = Janitor.new()
	self.player = player
	self.house = House.GetHouseFromPlayer(player)
	self.enemiesAlive = 0
	self:CreateGui()
	self:ConfigureJanitor()

	Cache[player] = self
	return self
end

-- Function to configure the janitor for cleanup
function Wave:ConfigureJanitor()
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

		Cache[self.player] = nil
		table.clear(self.enemies) -- Clear enemies table
		local CoinService = Knit.GetService("CoinService")
		CoinService:ResetCoins(self.player)
		self.player:LoadCharacter()
		setmetatable(self, nil) -- Clear metatable
		table.clear(self) -- Clear self
		print("Wave ended then cleaned up.")
	end, true)
end

-- Function to create the wave gui
function Wave:CreateGui()
	self.gui = {
		ScreenGui = self.janitor:Add(Instance.new("ScreenGui")),
		Frame = self.janitor:Add(Instance.new("Frame")),
		TextLabel = self.janitor:Add(Instance.new("TextLabel")),
		UITextSizeConstraint = self.janitor:Add(Instance.new("UITextSizeConstraint")),
		UIAspectRatioConstraint = self.janitor:Add(Instance.new("UIAspectRatioConstraint")),
	}

	self.gui.ScreenGui.Name = "WaveGui"
	self.gui.ScreenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	self.gui.ScreenGui.IgnoreGuiInset = true
	self.gui.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.gui.ScreenGui.Enabled = false

	self.gui.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.gui.Frame.BorderSizePixel = 0
	self.gui.Frame.Size = UDim2.new(1, 0, 0.312652, 0)
	self.gui.Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	self.gui.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.gui.Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	self.gui.Frame.Parent = self.gui.ScreenGui

	self.gui.TextLabel.TextWrapped = true
	self.gui.TextLabel.BorderSizePixel = 0
	self.gui.TextLabel.TextScaled = true
	self.gui.TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	self.gui.TextLabel.FontFace =
		Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	self.gui.TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	self.gui.TextLabel.TextSize = 14
	self.gui.TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.gui.TextLabel.Size = UDim2.new(1, 0, 1, 0)
	self.gui.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	self.gui.TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	self.gui.TextLabel.Text = "WAVE 1 STARTING IN 3"
	self.gui.TextLabel.BackgroundTransparency = 1
	self.gui.TextLabel.Parent = self.gui.Frame

	self.gui.UITextSizeConstraint.Parent = self.gui.TextLabel

	self.gui.UIAspectRatioConstraint.AspectRatio = 1.87105
	self.gui.UIAspectRatioConstraint.Parent = self.gui.ScreenGui
	self.gui.ScreenGui.Parent = self.player.PlayerGui
end

function Wave:CountDown()
	self.gui.ScreenGui.Enabled = true
	for i = 3, 0, -1 do
		if not self or self.currentState == "ENDED" or not self.player then
			break
		end

		self.gui.TextLabel.Text = "WAVE " .. tostring(self.currentWave) .. " STARTING IN " .. tostring(i)
		task.wait(1)
	end

	if not self or self.currentState == "ENDED" or not self.player then
		return
	end

	self.gui.ScreenGui.Enabled = false
	self.gui.TextLabel.Text = "WAVE 1 STARTING IN 3"
end

-- Function to start the game
function Wave:StartGame()
	self.currentState = "RUNNING"
	self:NextWave()
end

-- Function to start the next wave
function Wave:NextWave()
	if not self or self.currentState == "ENDED" or not self.player then
		return
	end

	self.currentWave += 1
	self:CountDown()
	-- Configure enemy properties
	local health = 100 -- might need to update this to match the wave for more difficulty later

	if not self or self.currentState == "ENDED" or not self.player then
		return
	end

	self:SpawnEnemies(ENEMY_SPEED, health)
end

-- Function to end the game
function Wave:EndGame()
	self.currentState = "ENDED"
	self.janitor:Destroy()
end

-- Function to spawn enemies for the wave
function Wave:SpawnEnemies(speed, health)
	if not self or self.currentState == "ENDED" or not self.player then
		return
	end

	self.spawning = true
	for count = 1, self.currentWave do
		for i = 1, 10 do
			if not self or self.currentState == "ENDED" or not self.player then
				break
			end

			local enemy = Enemy.new(self.house, ServerStorage.Enemies.Vegetable:Clone(), speed, health)
			enemy.model.Name = tostring(i)
			enemy:Spawn()
			self.enemiesAlive += 1
			self.enemies[enemy] = enemy
			self:OnEnemiesDefeated(enemy)

			-- Delay the enemy's move if it's within the first 5 enemies
			if i <= 5 then
				self.janitor:Add(
					task.defer(function()
						task.wait(3)
						if not enemy or enemy.destroyed then
							return
						end
						enemy:Move()
					end),
					true
				)
			else
				if not enemy or enemy.destroyed then
					return
				end
				enemy:Move()
			end

			-- Random delay between 1 and 3 seconds
			local delayTime = math.random(1, 3)
			task.wait(delayTime)
		end

		if not self or not self.player then
			break
		end

		task.wait(5)
	end
	self.spawning = false
end

function Wave:OnEnemiesDefeated(enemy)
	enemy.model.Destroying:Connect(function()
		if not self and not self.enemies and not self.enemiesAlive then
			return
		end

		self.enemies[enemy] = nil
		self.enemiesAlive -= 1
		local CoinService = Knit.GetService("CoinService")
		CoinService:AddCoins(self.player, 10)

		task.wait(0.5)

		if self.enemiesAlive <= 0 then
			print(self.enemiesAlive)
			print(self.spawning)
		end

		if self.enemiesAlive <= 0 and self.spawning == false then
			self:NextWave()
		end
	end)
end

return Wave
