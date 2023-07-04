local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllersDeep(ReplicatedStorage:WaitForChild("Controller"))
Knit.Start():catch(warn)
