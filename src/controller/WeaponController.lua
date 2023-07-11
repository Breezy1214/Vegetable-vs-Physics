local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local gui = nil

local WeaponController = Knit.CreateController({ Name = "WeaponController" })

function WeaponController:KnitInit()
	local WeaponService = Knit.GetService("WeaponService")
	WeaponService.CreateGuiSignal:Connect(function()
		self:CreateGui()
	end)
end

function WeaponController:UpdateWeaponList()
	local WeaponService = Knit.GetService("WeaponService")
	WeaponService:GetWeaponList():andThen(function(weapons)
		print(weapons)
		for weapon, cost in weapons do
			local newButton = gui.Template:Clone()
			newButton.Name = weapon
			newButton.Cost.Text = tostring(cost) .. " coins"
			newButton.Visible = true
			newButton.Parent = gui.ScrollingFrame
		end
	end)
end

function WeaponController:CreateGui()
	gui = {
		ScreenGui = Instance.new("ScreenGui"),
		Frame = Instance.new("Frame"),
		ScrollingFrame = Instance.new("ScrollingFrame"),
		Template = Instance.new("ImageLabel"),
		Cost = Instance.new("TextLabel"),
		UIListLayout = Instance.new("UIListLayout"),
	}

	gui.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ScreenGui.Name = "WeaponGui"

	gui.Frame.AnchorPoint = Vector2.new(0.5, 1)
	gui.Frame.BorderSizePixel = 0
	gui.Frame.Size = UDim2.new(0.492507, 0, 0.245742, 0)
	gui.Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	gui.Frame.Position = UDim2.new(0.5, 0, 1, 0)
	gui.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	gui.Frame.Parent = gui.ScreenGui

	gui.ScrollingFrame.Active = true
	gui.ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
	gui.ScrollingFrame.BorderSizePixel = 0
	gui.ScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	gui.ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	gui.ScrollingFrame.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	gui.ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	gui.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	gui.ScrollingFrame.BackgroundTransparency = 1
	gui.ScrollingFrame.ScrollBarThickness = 5
	gui.ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
	gui.ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	gui.ScrollingFrame.Parent = gui.Frame

	gui.Template.BorderSizePixel = 0
	gui.Template.ScaleType = Enum.ScaleType.Fit
	gui.Template.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	gui.Template.Image = "rbxassetid://184273353"
	gui.Template.Size = UDim2.new(0.219858, 0, 1, 0)
	gui.Template.BorderColor3 = Color3.fromRGB(0, 0, 0)
	gui.Template.Name = "Template"
	gui.Template.Position = UDim2.new(-4.32873e-08, 0, 0, 0)
	gui.Template.Visible = false
	gui.Template.Parent = gui.ScrollingFrame

	gui.Cost.TextWrapped = true
	gui.Cost.BorderSizePixel = 0
	gui.Cost.TextScaled = true
	gui.Cost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	gui.Cost.FontFace =
		Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	gui.Cost.TextSize = 14
	gui.Cost.Position = UDim2.new(0, 0, 0.897297, 0)
	gui.Cost.Size = UDim2.new(1, 0, 0.102703, 0)
	gui.Cost.Name = "Cost"
	gui.Cost.TextColor3 = Color3.fromRGB(0, 0, 0)
	gui.Cost.BorderColor3 = Color3.fromRGB(0, 0, 0)
	gui.Cost.Text = "100 Coins"
	gui.Cost.Parent = gui.Template

	gui.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gui.UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	gui.UIListLayout.Padding = UDim.new(0, 10)
	gui.UIListLayout.Parent = gui.ScrollingFrame

	self:UpdateWeaponList()
	gui.ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
end

return WeaponController
