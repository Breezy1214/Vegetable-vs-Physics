-- Importing required services and modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Setting up Remotes
local MoveEnemyEvent = ReplicatedStorage.Remotes:WaitForChild("MoveEnemyEvent")
local DamageHouseEvent = ReplicatedStorage.Remotes:WaitForChild("DamageHouseEvent")

-- Creating EnemyController using Knit framework
local EnemyController = Knit.CreateController({ Name = "EnemyController" })

-- Called when the controller starts up
function EnemyController:KnitStart()
	-- Event handler for when the server asks to move the enemy model
	MoveEnemyEvent.OnClientEvent:Connect(function(model, targetPosition, speed)
		-- Create a new tween to move the enemy's primary part to the target position
		local enemyTween = TweenService:Create(
			model.PrimaryPart,
			TweenInfo.new(speed, Enum.EasingStyle.Linear),
			{ Position = targetPosition }
		)

		-- Connection to respond to the completion of the tween and start damaging the house
		local damageConnection, updateTask
		damageConnection = enemyTween.Completed:Connect(function(state)
			-- If the tween didn't finish, don't damage the house
			if state ~= Enum.PlaybackState.Completed then
				return
			end

			-- Fire the event to start damaging the house
			DamageHouseEvent:FireServer(model)
			-- Disconnect the connection after the enemy has reached the target
			damageConnection:Disconnect()
			task.cancel(updateTask)
		end)

		-- Start the tween
		enemyTween:Play()

		-- Create a task that runs in the background, updating the server with the enemy's position every second
		updateTask = task.spawn(function()
			while true do
				task.wait(1)
				local primaryPart = model.PrimaryPart
				-- If the model was destroyed, stop updating
				if not primaryPart then
					break
				end
				MoveEnemyEvent:FireServer(model, primaryPart.Position)
			end
		end)
	end)
end

return EnemyController
