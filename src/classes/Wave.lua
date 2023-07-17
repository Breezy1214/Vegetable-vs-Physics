-- Import services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Import external modules
local Enemy = require(ServerScriptService.Classes.Enemy)
local Janitor = require(ReplicatedStorage.Packages.janitor)
local House = require(ServerScriptService.Classes.House)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

-- Constants
local ENEMY_SPEED = 20
local START_COINS = 99

-- Player to wave instance mapping
local PlayerWaves = {}

-- Wave Module
local Wave = {}
Wave.__index = Wave

-- Fetch the wave instance of a player
function Wave.GetWaveFromPlayer(player)
	return PlayerWaves[player]
end

-- Wave Constructor
function Wave.new(player)
	local self = setmetatable({}, Wave)

	self.currentState = "IDLE"
	self.currentWave = 0
	self.enemies = {}
	self.janitor = Janitor.new()
	self.player = player
	self.house = House.GetHouseFromPlayer(player)
	self.enemiesAlive = 0
	self.waveLock = false
	self.waveCompletedSignal = Signal.new()
	self.playerDisconnecting = false

	self.waveCompletedSignal:Connect(function()
		self:NextWave()
	end)

	self:CreateGui()
	self:ConfigureJanitor()

	return self
end

-- Function to create the GUI for the wave
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

-- Function for the countdown before a wave starts
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

-- Janitor configuration for resource management and cleanup
function Wave:ConfigureJanitor()
	self.janitor:Add(
		self.house.house.Destroying:Connect(function()
			self:EndGame()
		end),
		"Disconnect"
	)

	self.janitor:Add(function()
		for _, enemy in self.enemies do
			enemy:Destroy()
		end

		self.waveCompletedSignal:Destroy()
		table.clear(self.enemies)

		if self.playerDisconnecting == false then
			local CoinService = Knit.GetService("CoinService")
			CoinService:ResetCoins(self.player)
			self.player:LoadCharacter()
		end

		setmetatable(self, nil)
		table.clear(self)
		self = nil

		print("Wave ended and cleaned up.")
	end, true)
end

-- Start the game
function Wave:StartGame()
	self.currentState = "RUNNING"
	local CoinService = Knit.GetService("CoinService")
	CoinService:AddCoins(self.player, START_COINS)
	PlayerWaves[self.player] = self
	self:NextWave()
end

-- Start the next wave
function Wave:NextWave()
	if self.currentState == "ENDED" or not self.player then
		return
	end

	if self.enemiesAlive > 0 or self.waveLock then
		return
	end

	self.waveLock = true
	self.currentWave = self.currentWave + 1
	self:CountDown()

	local health = 100

	if self ~= nil and self.player ~= nil then
		self:SpawnEnemies(ENEMY_SPEED, health)
	end
end

-- End the game
function Wave:EndGame()
	if self.currentState == "ENDED" then
		warn("Destroying already in place")
		return
	end

	self.currentState = "ENDED"
	PlayerWaves[self.player] = nil
	self.janitor:Destroy()
end

-- Spawn enemies for the wave
function Wave:SpawnEnemies(speed, health)
	if self.currentState == "ENDED" or not self.player then
		return
	end

	for count = 1, self.currentWave do
		for i = 1, 10 do
			if not self or self.currentState == "ENDED" or not self.player then
				break
			end

			local enemyModel = ServerStorage.Enemies.Vegetable:Clone()
			local enemy = Enemy.new(self.house, enemyModel, speed, health)
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
						if enemy ~= nil and enemy.destroyed == false then
							enemy:Move()
						end
					end),
					true
				)
			else
				if enemy == nil or enemy.destroyed == true then
					return
				end
				task.wait(1)
				enemy:Move()
			end

			-- Random delay between 1 and 3 seconds
			local delayTime = math.random(1, 3)
			task.wait(delayTime)
		end

		if not self or not self.player then
			break
		end

		-- Random delay between 1 and 5 seconds
		local delayTime = math.random(1, 5)
		task.wait(delayTime)
	end

	self.waveLock = false

	if not self or not self.waveCompletedSignal then
		return
	end

	--technically the line above should be enough
	-- but i found rare edge cases where when the player loses at a certain time,
	-- self.waveCompletedSignal was set to nil in between the check and the Fire call.
	-- hence another check

	if self.waveCompletedSignal then
		self.waveCompletedSignal:Fire()
	end
end

-- Handle enemy defeat
function Wave:OnEnemiesDefeated(enemy)
	self.janitor:Add(
		enemy.model.Destroying:Connect(function()
			if not self or not self.enemies or not self.enemiesAlive then
				return
			end

			self.enemies[enemy] = nil
			self.enemiesAlive = self.enemiesAlive - 1

			local CoinService = Knit.GetService("CoinService")
			CoinService:AddCoins(self.player, 10)

			self:NextWave()
		end),
		"Disconnect"
	)
end

return Wave
