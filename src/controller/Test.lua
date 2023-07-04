local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Test = Knit.CreateController({ Name = "Test" })

function Test:KnitInit() end

function Test:KnitStart() end

return Test
