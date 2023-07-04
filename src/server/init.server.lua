local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ServerScriptService = game:GetService("ServerScriptService")

Knit.AddServicesDeep(ServerScriptService:WaitForChild("Services"))
Knit.Start():catch(warn)
