-- Roblox Hub UI Library
-- Modern, clean UI components for your hub

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UILibrary = {}
UILibrary.__index = UILibrary

-- Theme Configuration
local Theme = {
	Background = Color3.fromRGB(25, 25, 35),
	Secondary = Color3.fromRGB(35, 35, 50),
	Accent = Color3.fromRGB(88, 101, 242),
	AccentHover = Color3.fromRGB(108, 121, 255),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(180, 180, 180),
	Success = Color3.fromRGB(67, 181, 129),
	Danger = Color3.fromRGB(237, 66, 69),
	Border = Color3.fromRGB(50, 50, 70),
	CategoryBg = Color3.fromRGB(30, 30, 42)
}

-- Create Main Hub
function UILibrary.new(title)
	local self = setmetatable({}, UILibrary)
	
	-- Create ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "HubUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Main Frame
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, 700, 0, 500)
	self.MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	self.MainFrame.BackgroundColor3 = Theme.Background
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.Parent = self.ScreenGui
	
	-- Add corner rounding
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = self.MainFrame
	
	-- Title Bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.BackgroundColor3 = Theme.Secondary
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = self.MainFrame
	
	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 10)
	TitleCorner.Parent = TitleBar
	
	-- Title Text
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Size = UDim2.new(1, -100, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title or "Hub"
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.TextSize = 18
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TitleBar
	
	-- Close Button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 35, 0, 35)
	CloseButton.Position = UDim2.new(1, -40, 0.5, -17.5)
	CloseButton.BackgroundColor3 = Theme.Danger
	CloseButton.Text = "×"
	CloseButton.TextColor3 = Theme.Text
	CloseButton.TextSize = 24
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.BorderSizePixel = 0
	CloseButton.Parent = TitleBar
	
	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 6)
	CloseCorner.Parent = CloseButton
	
	CloseButton.MouseButton1Click:Connect(function()
		self:Toggle()
	end)
	
	-- Sidebar for categories
	self.Sidebar = Instance.new("Frame")
	self.Sidebar.Name = "Sidebar"
	self.Sidebar.Size = UDim2.new(0, 180, 1, -50)
	self.Sidebar.Position = UDim2.new(0, 10, 0, 50)
	self.Sidebar.BackgroundColor3 = Theme.CategoryBg
	self.Sidebar.BorderSizePixel = 0
	self.Sidebar.Parent = self.MainFrame
	
	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 8)
	SidebarCorner.Parent = self.Sidebar
	
	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = self.Sidebar
	
	local SidebarPadding = Instance.new("UIPadding")
	SidebarPadding.PaddingTop = UDim.new(0, 10)
	SidebarPadding.PaddingBottom = UDim.new(0, 10)
	SidebarPadding.PaddingLeft = UDim.new(0, 10)
	SidebarPadding.PaddingRight = UDim.new(0, 10)
	SidebarPadding.Parent = self.Sidebar
	
	-- Content Container
	self.Container = Instance.new("ScrollingFrame")
	self.Container.Name = "Container"
	self.Container.Size = UDim2.new(1, -210, 1, -60)
	self.Container.Position = UDim2.new(0, 200, 0, 50)
	self.Container.BackgroundTransparency = 1
	self.Container.BorderSizePixel = 0
	self.Container.ScrollBarThickness = 4
	self.Container.ScrollBarImageColor3 = Theme.Accent
	self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.Container.Parent = self.MainFrame
	
	-- Layout
	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = self.Container
	
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)
	
	-- Make draggable
	self:MakeDraggable(self.MainFrame, TitleBar)
	
	self.Visible = true
	self.Categories = {}
	self.CurrentCategory = nil
	
	-- Notification Container
	self.NotificationContainer = Instance.new("Frame")
	self.NotificationContainer.Name = "NotificationContainer"
	self.NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
	self.NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
	self.NotificationContainer.BackgroundTransparency = 1
	self.NotificationContainer.Parent = self.ScreenGui
	
	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.Padding = UDim.new(0, 10)
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.Parent = self.NotificationContainer
	
	return self
end

-- Make Frame Draggable
function UILibrary:MakeDraggable(frame, dragArea)
	local dragging, dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	
	dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	dragArea.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- Toggle Visibility
function UILibrary:Toggle()
	self.Visible = not self.Visible
	local tween = TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Position = self.Visible and UDim2.new(0.5, -350, 0.5, -250) or UDim2.new(0.5, -350, -0.5, 0)
	})
	tween:Play()
end

-- Add Category (Tab)
function UILibrary:AddCategory(name, icon)
	local CategoryButton = Instance.new("TextButton")
	CategoryButton.Name = name
	CategoryButton.Size = UDim2.new(1, 0, 0, 35)
	CategoryButton.BackgroundColor3 = Theme.Secondary
	CategoryButton.Text = (icon and icon .. "  " or "") .. name
	CategoryButton.TextColor3 = Theme.TextDark
	CategoryButton.TextSize = 14
	CategoryButton.Font = Enum.Font.Gotham
	CategoryButton.BorderSizePixel = 0
	CategoryButton.AutoButtonColor = false
	CategoryButton.TextXAlignment = Enum.TextXAlignment.Left
	CategoryButton.Parent = self.Sidebar
	
	local CategoryPadding = Instance.new("UIPadding")
	CategoryPadding.PaddingLeft = UDim.new(0, 10)
	CategoryPadding.Parent = CategoryButton
	
	local CategoryCorner = Instance.new("UICorner")
	CategoryCorner.CornerRadius = UDim.new(0, 6)
	CategoryCorner.Parent = CategoryButton
	
	-- Create container for this category
	local CategoryContainer = Instance.new("Frame")
	CategoryContainer.Name = name .. "Container"
	CategoryContainer.Size = UDim2.new(1, 0, 1, 0)
	CategoryContainer.BackgroundTransparency = 1
	CategoryContainer.Visible = false
	CategoryContainer.Parent = self.Container
	
	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = CategoryContainer
	
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Container.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)
	
	-- Store category info
	self.Categories[name] = {
		Button = CategoryButton,
		Container = CategoryContainer
	}
	
	-- Set first category as active
	if not self.CurrentCategory then
		self:SwitchCategory(name)
	end
	
	CategoryButton.MouseButton1Click:Connect(function()
		self:SwitchCategory(name)
	end)
	
	CategoryButton.MouseEnter:Connect(function()
		if self.CurrentCategory ~= name then
			TweenService:Create(CategoryButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Border}):Play()
		end
	end)
	
	CategoryButton.MouseLeave:Connect(function()
		if self.CurrentCategory ~= name then
			TweenService:Create(CategoryButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
		end
	end)
	
	return CategoryContainer
end

-- Switch Category
function UILibrary:SwitchCategory(name)
	if not self.Categories[name] then return end
	
	-- Hide all categories
	for catName, catData in pairs(self.Categories) do
		catData.Container.Visible = false
		TweenService:Create(catData.Button, TweenInfo.new(0.2), {
			BackgroundColor3 = Theme.Secondary,
			TextColor3 = Theme.TextDark
		}):Play()
	end
	
	-- Show selected category
	self.Categories[name].Container.Visible = true
	TweenService:Create(self.Categories[name].Button, TweenInfo.new(0.2), {
		BackgroundColor3 = Theme.Accent,
		TextColor3 = Theme.Text
	}):Play()
	
	self.CurrentCategory = name
	self.Container.CanvasPosition = Vector2.new(0, 0)
end

-- Add Button
function UILibrary:AddButton(text, callback, parent)
	parent = parent or self.Container
	
	-- If parent is a string, find the category container
	if type(parent) == "string" and self.Categories[parent] then
		parent = self.Categories[parent].Container
	end
	local Button = Instance.new("TextButton")
	Button.Name = "Button"
	Button.Size = UDim2.new(1, 0, 0, 40)
	Button.BackgroundColor3 = Theme.Secondary
	Button.Text = text
	Button.TextColor3 = Theme.Text
	Button.TextSize = 15
	Button.Font = Enum.Font.Gotham
	Button.BorderSizePixel = 0
	Button.AutoButtonColor = false
	Button.Parent = parent
	
	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 6)
	ButtonCorner.Parent = Button
	
	Button.MouseEnter:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
	end)
	
	Button.MouseLeave:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
	end)
	
	Button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
	
	return Button
end

-- Add Toggle
function UILibrary:AddToggle(text, default, callback, parent)
	parent = parent or self.Container
	
	-- If parent is a string, find the category container
	if type(parent) == "string" and self.Categories[parent] then
		parent = self.Categories[parent].Container
	end
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Name = "Toggle"
	ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
	ToggleFrame.BackgroundColor3 = Theme.Secondary
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = self.Container
	
	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 6)
	ToggleCorner.Parent = ToggleFrame
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -60, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.TextSize = 15
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame
	
	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 45, 0, 25)
	ToggleButton.Position = UDim2.new(1, -55, 0.5, -12.5)
	ToggleButton.BackgroundColor3 = default and Theme.Success or Theme.Border
	ToggleButton.Text = ""
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Parent = ToggleFrame
	
	local ToggleBtnCorner = Instance.new("UICorner")
	ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
	ToggleBtnCorner.Parent = ToggleButton
	
	local Circle = Instance.new("Frame")
	Circle.Size = UDim2.new(0, 19, 0, 19)
	Circle.Position = default and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
	Circle.BackgroundColor3 = Theme.Text
	Circle.BorderSizePixel = 0
	Circle.Parent = ToggleButton
	
	local CircleCorner = Instance.new("UICorner")
	CircleCorner.CornerRadius = UDim.new(1, 0)
	CircleCorner.Parent = Circle
	
	local toggled = default or false
	
	ToggleButton.MouseButton1Click:Connect(function()
		toggled = not toggled
		
		TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
			BackgroundColor3 = toggled and Theme.Success or Theme.Border
		}):Play()
		
		TweenService:Create(Circle, TweenInfo.new(0.2), {
			Position = toggled and UDim2.new(1, -22, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
		}):Play()
		
		if callback then callback(toggled) end
	end)
	
	return ToggleFrame
end

-- Add Slider
function UILibrary:AddSlider(text, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Name = "Slider"
	SliderFrame.Size = UDim2.new(1, 0, 0, 60)
	SliderFrame.BackgroundColor3 = Theme.Secondary
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = self.Container
	
	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 6)
	SliderCorner.Parent = SliderFrame
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -20, 0, 20)
	Label.Position = UDim2.new(0, 10, 0, 5)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.TextSize = 15
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame
	
	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.new(0, 50, 0, 20)
	ValueLabel.Position = UDim2.new(1, -60, 0, 5)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Text = tostring(default)
	ValueLabel.TextColor3 = Theme.Accent
	ValueLabel.TextSize = 15
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = SliderFrame
	
	local SliderBack = Instance.new("Frame")
	SliderBack.Size = UDim2.new(1, -20, 0, 6)
	SliderBack.Position = UDim2.new(0, 10, 1, -20)
	SliderBack.BackgroundColor3 = Theme.Border
	SliderBack.BorderSizePixel = 0
	SliderBack.Parent = SliderFrame
	
	local SliderBackCorner = Instance.new("UICorner")
	SliderBackCorner.CornerRadius = UDim.new(1, 0)
	SliderBackCorner.Parent = SliderBack
	
	local SliderFill = Instance.new("Frame")
	SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	SliderFill.BackgroundColor3 = Theme.Accent
	SliderFill.BorderSizePixel = 0
	SliderFill.Parent = SliderBack
	
	local SliderFillCorner = Instance.new("UICorner")
	SliderFillCorner.CornerRadius = UDim.new(1, 0)
	SliderFillCorner.Parent = SliderFill
	
	local dragging = false
	
	local function update(input)
		local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * pos)
		
		SliderFill.Size = UDim2.new(pos, 0, 1, 0)
		ValueLabel.Text = tostring(value)
		
		if callback then callback(value) end
	end
	
	SliderBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(input)
		end
	end)
	
	SliderBack.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
	
	return SliderFrame
end

-- Add Label
function UILibrary:AddLabel(text)
	local Label = Instance.new("TextLabel")
	Label.Name = "Label"
	Label.Size = UDim2.new(1, 0, 0, 30)
	Label.BackgroundColor3 = Theme.Secondary
	Label.Text = text
	Label.TextColor3 = Theme.TextDark
	Label.TextSize = 14
	Label.Font = Enum.Font.Gotham
	Label.BorderSizePixel = 0
	Label.Parent = self.Container
	
	local LabelCorner = Instance.new("UICorner")
	LabelCorner.CornerRadius = UDim.new(0, 6)
	LabelCorner.Parent = Label
	
	return Label
end

-- Add Notification
function UILibrary:Notify(text, duration, notifType)
	duration = duration or 3
	notifType = notifType or "info" -- "info", "success", "warning", "error"
	
	local colors = {
		info = Theme.Accent,
		success = Theme.Success,
		warning = Color3.fromRGB(250, 166, 26),
		error = Theme.Danger
	}
	
	local NotifFrame = Instance.new("Frame")
	NotifFrame.Name = "Notification"
	NotifFrame.Size = UDim2.new(1, 0, 0, 70)
	NotifFrame.BackgroundColor3 = Theme.Secondary
	NotifFrame.BorderSizePixel = 0
	NotifFrame.ClipsDescendants = true
	NotifFrame.Parent = self.NotificationContainer
	
	-- Start off-screen
	NotifFrame.Position = UDim2.new(1, 50, 0, 0)
	
	local NotifCorner = Instance.new("UICorner")
	NotifCorner.CornerRadius = UDim.new(0, 8)
	NotifCorner.Parent = NotifFrame
	
	-- Colored accent bar
	local AccentBar = Instance.new("Frame")
	AccentBar.Size = UDim2.new(0, 4, 1, 0)
	AccentBar.BackgroundColor3 = colors[notifType]
	AccentBar.BorderSizePixel = 0
	AccentBar.Parent = NotifFrame
	
	-- Icon
	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(0, 40, 0, 40)
	Icon.Position = UDim2.new(0, 15, 0.5, -20)
	Icon.BackgroundColor3 = colors[notifType]
	Icon.Text = notifType == "success" and "✓" or notifType == "error" and "✕" or notifType == "warning" and "⚠" or "ⓘ"
	Icon.TextColor3 = Theme.Text
	Icon.TextSize = 20
	Icon.Font = Enum.Font.GothamBold
	Icon.BorderSizePixel = 0
	Icon.Parent = NotifFrame
	
	local IconCorner = Instance.new("UICorner")
	IconCorner.CornerRadius = UDim.new(1, 0)
	IconCorner.Parent = Icon
	
	-- Text
	local TextLabel = Instance.new("TextLabel")
	TextLabel.Size = UDim2.new(1, -70, 1, -20)
	TextLabel.Position = UDim2.new(0, 60, 0, 10)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = text
	TextLabel.TextColor3 = Theme.Text
	TextLabel.TextSize = 14
	TextLabel.Font = Enum.Font.Gotham
	TextLabel.TextWrapped = true
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextYAlignment = Enum.TextYAlignment.Top
	TextLabel.Parent = NotifFrame
	
	-- Progress bar
	local ProgressBack = Instance.new("Frame")
	ProgressBack.Size = UDim2.new(1, -20, 0, 3)
	ProgressBack.Position = UDim2.new(0, 10, 1, -8)
	ProgressBack.BackgroundColor3 = Theme.Border
	ProgressBack.BorderSizePixel = 0
	ProgressBack.Parent = NotifFrame
	
	local ProgressFill = Instance.new("Frame")
	ProgressFill.Size = UDim2.new(1, 0, 1, 0)
	ProgressFill.BackgroundColor3 = colors[notifType]
	ProgressFill.BorderSizePixel = 0
	ProgressFill.Parent = ProgressBack
	
	-- Animate in
	TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
	
	-- Progress bar animation
	local progressTween = TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 1, 0)
	})
	progressTween:Play()
	
	-- Remove notification
	task.delay(duration, function()
		local removeTween = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, 50, 0, 0)
		})
		removeTween:Play()
		removeTween.Completed:Connect(function()
			NotifFrame:Destroy()
		end)
	end)
end

return UILibrary
