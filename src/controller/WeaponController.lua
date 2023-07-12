-- Import services and modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local WeaponController = Knit.CreateController({ Name = "WeaponController" })

-- Helper function to create new GUI objects
local function createGuiObject(type, properties)
	local newObject = Instance.new(type)
	for propertyName, value in pairs(properties) do
		newObject[propertyName] = value
	end
	return newObject
end

-- Function to initialize WeaponController
function WeaponController:KnitInit()
	local WeaponService = Knit.GetService("WeaponService")
	WeaponService.CreateGuiSignal:Connect(function()
		self:CreateGui()
	end)
end

-- Function to create the GUI
function WeaponController:CreateGui()
	-- Define the GUI elements and their properties
	self.gui = {
		ScreenGui = createGuiObject("ScreenGui", { ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Name = "WeaponGui" }),
		Frame = createGuiObject("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BorderSizePixel = 0,
			Size = UDim2.new(0.492507, 0, 0.245742, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Position = UDim2.new(0.5, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		}),
		ScrollingFrame = createGuiObject("ScrollingFrame", {
			Active = true,
			ScrollingDirection = Enum.ScrollingDirection.X,
			BorderSizePixel = 0,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(170, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 5,
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			Position = UDim2.new(0.5, 0, 0.5, 0),
		}),
		Template = createGuiObject("TextButton", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "Template",
			TextScaled = true,
			Size = UDim2.new(0.219858, 0, 1, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Name = "Template",
			Position = UDim2.new(-4.32873e-08, 0, 0, 0),
			Visible = false,
		}),
		Cost = createGuiObject("TextLabel", {
			TextWrapped = true,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.Regular,
				Enum.FontStyle.Normal
			),
			TextSize = 14,
			Position = UDim2.new(0, 0, 0.897297, 0),
			Size = UDim2.new(1, 0, 0.102703, 0),
			Name = "Cost",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Text = "100 Coins",
		}),
		UIListLayout = createGuiObject("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
		}),
	}

	-- Set up the GUI hierarchy
	self.gui.Frame.Parent = self.gui.ScreenGui
	self.gui.ScrollingFrame.Parent = self.gui.Frame
	self.gui.Template.Parent = self.gui.ScrollingFrame
	self.gui.Cost.Parent = self.gui.Template
	self.gui.UIListLayout.Parent = self.gui.ScrollingFrame

	-- Update the list of weapons and add the GUI to the player's screen
	self:UpdateWeaponList()
	self.gui.ScreenGui.Parent = Players.LocalPlayer.PlayerGui
end

-- Function to update the list of weapons
function WeaponController:UpdateWeaponList()
	local WeaponService = Knit.GetService("WeaponService")
	WeaponService:GetWeaponList():andThen(function(weapons)
		for weapon, cost in pairs(weapons) do
			self:AddWeaponButton(WeaponService, weapon, cost)
		end
	end)
end

-- Function to create a new weapon button in the GUI
function WeaponController:AddWeaponButton(WeaponService, weapon, cost)
	local newButton = self.gui.Template:Clone()
	newButton.Name = weapon
	newButton.Cost.Text = tostring(cost) .. " coins"
	newButton.Text = weapon
	newButton.Visible = true
	newButton.Parent = self.gui.ScrollingFrame

	newButton.MouseButton1Click:Connect(function()
		WeaponService.ButtonPressed:Fire(newButton.Name)
	end)
end

return WeaponController
