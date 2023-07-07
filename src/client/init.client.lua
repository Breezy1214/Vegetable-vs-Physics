local ReplicatedStorage = game:GetService("ReplicatedStorage")
--require(ReplicatedStorage.Shared:WaitForChild("TweenServicePlus"))
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllersDeep(ReplicatedStorage:WaitForChild("Controller"))
Knit.Start():catch(warn)
