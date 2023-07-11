local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ServerScriptService = game:GetService("ServerScriptService")

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		for _, part in char:GetDescendants() do
			if part:IsA("BasePart") then
				part.CollisionGroup = "Player"
			end
		end
	end)
end)

Knit.AddServicesDeep(ServerScriptService:WaitForChild("Services"))
Knit.Start():catch(warn)
