local UILibrary = {}

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Wait for LocalPlayer safely
local player = Players.LocalPlayer
if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")

--// Mobile Detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled

--// Purple/Blue Gradient Theme
local theme = {
	Background = Color3.fromRGB(15, 15, 25),
	Sidebar = Color3.fromRGB(20, 18, 35),
	Header = Color3.fromRGB(25, 20, 40),
	Panel = Color3.fromRGB(28, 25, 45),
	Accent = Color3.fromRGB(138, 100, 255),
	AccentHover = Color3.fromRGB(158, 120, 255),
	AccentDim = Color3.fromRGB(100, 70, 200),
	AccentBlue = Color3.fromRGB(80, 150, 255),
	ButtonBg = Color3.fromRGB(35, 30, 55),
	ButtonHover = Color3.fromRGB(45, 40, 65),
	Text = Color3.fromRGB(230, 230, 240),
	TextDim = Color3.fromRGB(140, 135, 160),
	Border = Color3.fromRGB(60, 50, 90),
	Success = Color3.fromRGB(100, 220, 150),
	Warning = Color3.fromRGB(255, 200, 80),
	Error = Color3.fromRGB(255, 100, 120),
	Font = Enum.Font.Gotham
}

--// Helpers
local function create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	if props.Parent then
		obj.Parent = props.Parent
	end
	return obj
end

local function roundify(obj, radius)
	create("UICorner", {
		CornerRadius = UDim.new(0, radius or 4),
		Parent = obj
	})
end

local function addStroke(obj, color, thickness)
	create("UIStroke", {
		Color = color or theme.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = obj
	})
end

local function addGradient(obj, colors, rotation)
	local keypoints = {}
	for i, color in ipairs(colors) do
		table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color))
	end
	create("UIGradient", {
		Color = ColorSequence.new(keypoints),
		Rotation = rotation or 0,
		Parent = obj
	})
end

local function tween(obj, props, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.3,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	TweenService:Create(obj, info, props):Play()
end

--// Mobile-specific sizing helper
local function getMobileSize()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local baseSize = Vector2.new(700, 500)
	
	if isMobile then
		return Vector2.new(
			math.min(viewportSize.X * 0.95, 450),
			math.min(viewportSize.Y * 0.85, 600)
		)
	elseif isTablet then
		return Vector2.new(
			math.min(viewportSize.X * 0.8, 600),
			math.min(viewportSize.Y * 0.75, 550)
		)
	else
		return baseSize
	end
end

--// Main Window Creator
function UILibrary:CreateWindow(config)
	local title = config.Title or config.title or "mspaint v4"
	local size = config.Size or getMobileSize()
	local keybind = config.Keybind or config.keybind or Enum.KeyCode.RightShift

	--// Screen GUI
	local ScreenGui = create("ScreenGui", {
		Name = "ModernUI_" .. title,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = playerGui
	})

	--// Invisible Modal Button
	local ModalBtn = create("TextButton", {
		Name = "ModalButton",
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		Modal = true,
		Visible = false,
		Parent = ScreenGui
	})

	--// Main Container
	local Container = create("Frame", {
		Name = "Container",
		Size = UDim2.new(0, size.X, 0, size.Y),
		Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		Visible = false,
		Parent = ScreenGui
	})
	roundify(Container, isMobile and 16 or 12)
	addStroke(Container, theme.Border, 1.5)

	if isMobile or isTablet then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local newSize = getMobileSize()
			size = newSize
			Container.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
			Container.Position = UDim2.new(0.5, -newSize.X/2, 0.5, -newSize.Y/2)
		end)
	end

	--// Header
	local headerHeight = isMobile and 50 or 60
	local Header = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, headerHeight),
		BackgroundColor3 = theme.Header,
		BorderSizePixel = 0,
		Parent = Container
	})
	roundify(Header, isMobile and 16 or 12)
	addGradient(Header, {theme.Accent, theme.AccentBlue}, 45)

	local HeaderBottom = create("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = theme.Header,
		BorderSizePixel = 0,
		Parent = Header
	})

	local logoSize = isMobile and 32 or 40
	local Logo = create("TextLabel", {
		Name = "Logo",
		Size = UDim2.new(0, logoSize, 0, logoSize),
		Position = UDim2.new(0, 10, 0, (headerHeight - logoSize) / 2),
		BackgroundColor3 = Color3.fromRGB(138, 100, 255),
		BackgroundTransparency = 0.3,
		Text = "⚡",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = isMobile and 18 or 22,
		Parent = Header
	})
	roundify(Logo, 8)
	addStroke(Logo, Color3.fromRGB(180, 140, 255), 2)

	local TitleLabel = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -150, 1, 0),
		Position = UDim2.new(0, logoSize + 18, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = isMobile and 15 or 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Header
	})

	if not isMobile or size.X > 400 then
		create("TextLabel", {
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(1, -85, 0, (headerHeight - 30) / 2),
			BackgroundTransparency = 1,
			Text = "🔍",
			TextColor3 = Color3.fromRGB(200, 200, 220),
			Font = Enum.Font.Gotham,
			TextSize = isMobile and 14 or 16,
			Parent = Header
		})
	end

	--// Close Button
	local closeBtnSize = isMobile and 32 or 38
	local CloseBtn = create("TextButton", {
		Name = "CloseBtn",
		Size = UDim2.new(0, closeBtnSize, 0, closeBtnSize),
		Position = UDim2.new(1, -closeBtnSize - 8, 0, (headerHeight - closeBtnSize) / 2),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		Text = "×",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = isMobile and 20 or 24,
		AutoButtonColor = false,
		Parent = Header
	})
	roundify(CloseBtn, 8)

	local function addTouchFeedback(button, hoverColor, normalColor)
		if isMobile then
			button.MouseButton1Down:Connect(function()
				tween(button, {BackgroundTransparency = 0.7, BackgroundColor3 = hoverColor or theme.Error}, 0.1)
			end)
			button.MouseButton1Up:Connect(function()
				tween(button, {BackgroundTransparency = 0.9, BackgroundColor3 = normalColor or Color3.fromRGB(255, 255, 255)}, 0.1)
			end)
		else
			button.MouseEnter:Connect(function()
				tween(button, {BackgroundTransparency = 0.7, BackgroundColor3 = hoverColor or theme.Error}, 0.2)
			end)
			button.MouseLeave:Connect(function()
				tween(button, {BackgroundTransparency = 0.9, BackgroundColor3 = normalColor or Color3.fromRGB(255, 255, 255)}, 0.2)
			end)
		end
	end

	addTouchFeedback(CloseBtn, theme.Error, Color3.fromRGB(255, 255, 255))

	local open = false
	CloseBtn.MouseButton1Click:Connect(function()
		open = false
		Container.Visible = false
		ModalBtn.Visible = false
	end)

	--// Dragging
	local dragging, dragInput, dragStart, startPos

	local function startDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = Container.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end

		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			Container.Position = UDim2.new(
				startPos.X.Scale, 
				startPos.X.Offset + delta.X,
				startPos.Y.Scale, 
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	--// Sidebar
	local sidebarWidth = isMobile and 100 or 130
	local Sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, sidebarWidth, 1, -headerHeight),
		Position = UDim2.new(0, 0, 0, headerHeight),
		BackgroundColor3 = theme.Sidebar,
		BorderSizePixel = 0,
		Parent = Container
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Sidebar
	})

	local sidebarPadding = isMobile and 6 or 10
	create("UIPadding", {
		PaddingTop = UDim.new(0, sidebarPadding),
		PaddingLeft = UDim.new(0, sidebarPadding),
		PaddingRight = UDim.new(0, sidebarPadding),
		PaddingBottom = UDim.new(0, sidebarPadding),
		Parent = Sidebar
	})

	--// Content Area
	local contentOffset = isMobile and 8 : 13
	local ContentFrame = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -(sidebarWidth + contentOffset + 7), 1, -(headerHeight + contentOffset)),
		Position = UDim2.new(0, sidebarWidth + contentOffset, 0, headerHeight + contentOffset),
		BackgroundTransparency = 1,
		Parent = Container
	})

	--// Toggle Button
	local toggleSize = isMobile and 50 or 55
	local toggleOffset = isMobile and 15 : 20
	local ToggleBtn = create("TextButton", {
		Name = "ToggleBtn",
		Size = UDim2.new(0, toggleSize, 0, toggleSize),
		Position = UDim2.new(1, -toggleSize - toggleOffset, 1, -toggleSize - toggleOffset),
		BackgroundColor3 = theme.Accent,
		Text = "",
		AutoButtonColor = false,
		Parent = ScreenGui
	})
	roundify(ToggleBtn, 12)
	addStroke(ToggleBtn, Color3.fromRGB(180, 140, 255), 2)
	addGradient(ToggleBtn, {theme.Accent, theme.AccentBlue}, 45)

	create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "⚡",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = isMobile and 24 or 28,
		Parent = ToggleBtn
	})

	local function toggleUI()
		open = not open
		Container.Visible = open
		ModalBtn.Visible = open

		if open then
			Container.Size = UDim2.new(0, 0, 0, 0)
			tween(Container, {Size = UDim2.new(0, size.X, 0, size.Y)}, 0.35, Enum.EasingStyle.Back)
		else
			tween(Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
			task.wait(0.25)
			Container.Visible = false
		end
	end

	ToggleBtn.MouseButton1Click:Connect(toggleUI)

	if not isMobile then
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == keybind then
				toggleUI()
			end
		end)
	end

	if isMobile then
		ToggleBtn.MouseButton1Down:Connect(function()
			tween(ToggleBtn, {Size = UDim2.new(0, toggleSize + 5, 0, toggleSize + 5)}, 0.1)
		end)
		ToggleBtn.MouseButton1Up:Connect(function()
			tween(ToggleBtn, {Size = UDim2.new(0, toggleSize, 0, toggleSize)}, 0.1)
		end)
	else
		ToggleBtn.MouseEnter:Connect(function()
			tween(ToggleBtn, {Size = UDim2.new(0, 60, 0, 60)}, 0.2)
		end)
		ToggleBtn.MouseLeave:Connect(function()
			tween(ToggleBtn, {Size = UDim2.new(0, 55, 0, 55)}, 0.2)
		end)
	end

	--// Notification Container
	local notifWidth = isMobile and 280 or 320
	local notifOffset = isMobile and 10 : 10
	local NotifContainer = create("Frame", {
		Name = "Notifications",
		Size = UDim2.new(0, notifWidth, 1, -20),
		Position = UDim2.new(1, -(notifWidth + notifOffset), 0, notifOffset),
		BackgroundTransparency = 1,
		Parent = ScreenGui
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = NotifContainer
	})

	--// Window API
	local Window = {}
	Window.Categories = {}
	Window.CurrentCategory = nil

	function Window:CreateCategory(name, icon)
		local categoryData = {
			Name = name,
			Icon = icon or "📁",
			ScrollFrame = nil,
			Button = nil
		}

		local categoryBtnHeight = isMobile and 36 or 40
		local CategoryBtn = create("TextButton", {
			Name = name,
			Size = UDim2.new(1, 0, 0, categoryBtnHeight),
			BackgroundColor3 = theme.ButtonBg,
			Text = "",
			AutoButtonColor = false,
			Parent = Sidebar
		})
		roundify(CategoryBtn, 8)

		local HighlightBar = create("Frame", {
			Name = "Highlight",
			Size = UDim2.new(0, isMobile and 3 or 4, 1, -10),
			Position = UDim2.new(0, 3, 0, 5),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			Parent = CategoryBtn
		})
		roundify(HighlightBar, 3)
		addGradient(HighlightBar, {theme.Accent, theme.AccentBlue}, 90)

		local iconSize = isMobile and 20 or 26
		local iconOffset = isMobile and 8 : 14
		local IconLabel = create("TextLabel", {
			Size = UDim2.new(0, iconSize, 1, 0),
			Position = UDim2.new(0, iconOffset, 0, 0),
			BackgroundTransparency = 1,
			Text = icon or "📁",
			TextColor3 = theme.TextDim,
			Font = Enum.Font.Gotham,
			TextSize = isMobile and 14 or 16,
			Parent = CategoryBtn
		})

		local CategoryLabel = create("TextLabel", {
			Size = UDim2.new(1, -(iconOffset + iconSize + 10), 1, 0),
			Position = UDim2.new(0, iconOffset + iconSize + 5, 0, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = theme.TextDim,
			Font = Enum.Font.GothamSemibold,
			TextSize = isMobile and 12 or 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = CategoryBtn
		})

		local ScrollFrame = create("ScrollingFrame", {
			Name = name .. "Content",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = isMobile and 4 or 5,
			ScrollBarImageColor3 = theme.Accent,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = ContentFrame
		})

		create("UIListLayout", {
			Padding = UDim.new(0, isMobile and 8 or 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ScrollFrame
		})

		local scrollPadding = isMobile and 3 : 5
		create("UIPadding", {
			PaddingLeft = UDim.new(0, scrollPadding),
			PaddingRight = UDim.new(0, isMobile and 8 or 10),
			Parent = ScrollFrame
		})

		categoryData.ScrollFrame = ScrollFrame
		categoryData.Button = CategoryBtn
		categoryData.HighlightBar = HighlightBar
		categoryData.IconLabel = IconLabel
		categoryData.CategoryLabel = CategoryLabel

		CategoryBtn.MouseButton1Click:Connect(function()
			for _, cat in pairs(Window.Categories) do
				cat.ScrollFrame.Visible = false
				cat.Button.BackgroundColor3 = theme.ButtonBg
				cat.HighlightBar.Visible = false
				cat.IconLabel.TextColor3 = theme.TextDim
				cat.CategoryLabel.TextColor3 = theme.TextDim
			end

			ScrollFrame.Visible = true
			CategoryBtn.BackgroundColor3 = theme.Panel
			HighlightBar.Visible = true
			IconLabel.TextColor3 = theme.Accent
			CategoryLabel.TextColor3 = theme.Text
			Window.CurrentCategory = categoryData
		end)

		if isMobile then
			CategoryBtn.MouseButton1Down:Connect(function()
				if Window.CurrentCategory ~= categoryData then
					CategoryBtn.BackgroundColor3 = theme.Panel
				end
			end)
		else
			CategoryBtn.MouseEnter:Connect(function()
				if Window.CurrentCategory ~= categoryData then
					tween(CategoryBtn, {BackgroundColor3 = theme.Panel}, 0.2)
				end
			end)
			CategoryBtn.MouseLeave:Connect(function()
				if Window.CurrentCategory ~= categoryData then
					tween(CategoryBtn, {BackgroundColor3 = theme.ButtonBg}, 0.2)
				end
			end)
		end

		table.insert(Window.Categories, categoryData)

		if #Window.Categories == 1 then
			ScrollFrame.Visible = true
			CategoryBtn.BackgroundColor3 = theme.Panel
			HighlightBar.Visible = true
			IconLabel.TextColor3 = theme.Accent
			CategoryLabel.TextColor3 = theme.Text
			Window.CurrentCategory = categoryData
		end

		--// Category API
		local Category = {}
		Category.ScrollFrame = ScrollFrame

		function Category:Button(name, callback)
			local buttonHeight = isMobile and 38 or 42
			local Button = create("TextButton", {
				Name = "Button",
				Size = UDim2.new(1, -10, 0, buttonHeight),
				BackgroundColor3 = theme.Accent,
				Text = "",
				AutoButtonColor = false,
				Parent = ScrollFrame
			})
			roundify(Button, 8)
			addGradient(Button, {theme.Accent, theme.AccentBlue}, 45)

			create("TextLabel", {
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamBold,
				TextSize = isMobile and 13 or 15,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = Button
			})

			if isMobile then
				Button.MouseButton1Down:Connect(function()
					Button.BackgroundColor3 = theme.AccentHover
				end)
				Button.MouseButton1Up:Connect(function()
					Button.BackgroundColor3 = theme.Accent
				end)
			else
				Button.MouseEnter:Connect(function()
					tween(Button, {BackgroundColor3 = theme.AccentHover}, 0.2)
				end)
				Button.MouseLeave:Connect(function()
					tween(Button, {BackgroundColor3 = theme.Accent}, 0.2)
				end)
			end

			Button.MouseButton1Click:Connect(function()
				tween(Button, {Size = UDim2.new(1, -10, 0, buttonHeight - 4)}, 0.1)
				task.wait(0.1)
				tween(Button, {Size = UDim2.new(1, -10, 0, buttonHeight)}, 0.1)

				if callback then
					task.spawn(callback)
				end
			end)

			return Button
		end

		function Category:Toggle(name, default, callback)
			local enabled = default or false
			local toggleHeight = isMobile and 38 or 42

			local ToggleFrame = create("Frame", {
				Name = "Toggle",
				Size = UDim2.new(1, -10, 0, toggleHeight),
				BackgroundColor3 = theme.Panel,
				Parent = ScrollFrame
			})
			roundify(ToggleFrame, 8)

			create("TextLabel", {
				Size = UDim2.new(1, -70, 1, 0),
				Position = UDim2.new(0, isMobile and 10 or 14, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamSemibold,
				TextSize = isMobile and 12 or 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = ToggleFrame
			})

			local switchWidth = isMobile and 40 or 44
			local switchHeight = isMobile and 20 or 22
			local ToggleButton = create("TextButton", {
				Name = "Switch",
				Size = UDim2.new(0, switchWidth, 0, switchHeight),
				Position = UDim2.new(1, -(switchWidth + 8), 0.5, -switchHeight/2),
				BackgroundColor3 = enabled and theme.Accent or theme.ButtonBg,
				Text = "",
				AutoButtonColor = false,
				Parent = ToggleFrame
			})
			roundify(ToggleButton, switchHeight/2)
			if enabled then
				addGradient(ToggleButton, {theme.Accent, theme.AccentBlue}, 45)
			end

			local circleSize = isMobile and 14 or 16
			local circleOffset = isMobile and 2.5 or 3
			local ToggleCircle = create("Frame", {
				Name = "Circle",
				Size = UDim2.new(0, circleSize, 0, circleSize),
				Position = enabled and UDim2.new(1, -(circleSize + circleOffset), 0.5, -circleSize/2) or UDim2.new(0, circleOffset, 0.5, -circleSize/2),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = ToggleButton
			})
			roundify(ToggleCircle, circleSize/2)

			ToggleButton.MouseButton1Click:Connect(function()
				enabled = not enabled

				if enabled then
					tween(ToggleButton, {BackgroundColor3 = theme.Accent}, 0.2)
					addGradient(ToggleButton, {theme.Accent, theme.AccentBlue}, 45)
				else
					tween(ToggleButton, {BackgroundColor3 = theme.ButtonBg}, 0.2)
					for _, child in pairs(ToggleButton:GetChildren()) do
						if child:IsA("UIGradient") then
							child:Destroy()
						end
					end
				end

				tween(ToggleCircle, {
					Position = enabled and UDim2.new(1, -(circleSize + circleOffset), 0.5, -circleSize/2) or UDim2.new(0, circleOffset, 0.5, -circleSize/2)
				}, 0.2, Enum.EasingStyle.Quad)

				if callback then
					task.spawn(callback, enabled)
				end
			end)

			return ToggleFrame
		end

		function Category:Dropdown(name, options, callback)
			local selectedOptions = {}
			local isOpen = false

			local closedHeight = isMobile and 38 or 42
			local optionHeight = isMobile and 28 or 32
			local openHeight = closedHeight + (#options * (optionHeight + 3)) + 8

			local DropdownFrame = create("Frame", {
				Name = "Dropdown",
				Size = UDim2.new(1, -10, 0, closedHeight),
				BackgroundColor3 = theme.Panel,
				ClipsDescendants = true,
				Parent = ScrollFrame
			})
			roundify(DropdownFrame, 8)

			local DropdownHeader = create("TextButton", {
				Name = "Header",
				Size = UDim2.new(1, 0, 0, closedHeight),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = DropdownFrame
			})

			create("TextLabel", {
				Size = UDim2.new(1, -50, 1, 0),
				Position = UDim2.new(0, isMobile and 10 or 14, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamSemibold,
				TextSize = isMobile and 12 or 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = DropdownHeader
			})

			local Arrow = create("TextLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(1, -30, 0.5, -10),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = isMobile and 10 or 11,
				Parent = DropdownHeader
			})

			local OptionsFrame = create("Frame", {
				Name = "Options",
				Size = UDim2.new(1, -10, 1, -closedHeight - 8),
				Position = UDim2.new(0, 5, 0, closedHeight + 4),
				BackgroundTransparency = 1,
				Parent = DropdownFrame
			})

			create("UIListLayout", {
				Padding = UDim.new(0, 3),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = OptionsFrame
			})

			for _, optionName in ipairs(options) do
				local OptionButton = create("TextButton", {
					Name = optionName,
					Size = UDim2.new(1, 0, 0, optionHeight),
					BackgroundColor3 = theme.ButtonBg,
					Text = "",
					AutoButtonColor = false,
					Parent = OptionsFrame
				})
				roundify(OptionButton, 6)

				create("TextLabel", {
					Size = UDim2.new(1, -35, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					BackgroundTransparency = 1,
					Text = optionName,
					TextColor3 = theme.Text,
					Font = Enum.Font.Gotham,
					TextSize = isMobile and 11 or 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					Parent = OptionButton
				})

				local checkSize = isMobile and 16 or 18
				local Checkmark = create("TextLabel", {
					Size = UDim2.new(0, checkSize, 0, checkSize),
					Position = UDim2.new(1, -(checkSize + 6), 0.5, -checkSize/2),
					BackgroundColor3 = theme.ButtonBg,
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamBold,
					TextSize = isMobile and 11 or 13,
					Parent = OptionButton
				})
				roundify(Checkmark, 4)
				addStroke(Checkmark, theme.Border, 1)

				if isMobile then
					OptionButton.MouseButton1Down:Connect(function()
						OptionButton.BackgroundColor3 = theme.ButtonHover
					end)
					OptionButton.MouseButton1Up:Connect(function()
						OptionButton.BackgroundColor3 = theme.ButtonBg
					end)
				else
					OptionButton.MouseEnter:Connect(function()
						tween(OptionButton, {BackgroundColor3 = theme.ButtonHover}, 0.2)
					end)
					OptionButton.MouseLeave:Connect(function()
						tween(OptionButton, {BackgroundColor3 = theme.ButtonBg}, 0.2)
					end)
				end

				OptionButton.MouseButton1Click:Connect(function()
					if selectedOptions[optionName] then
						selectedOptions[optionName] = nil
						Checkmark.Text = ""
						tween(Checkmark, {BackgroundColor3 = theme.ButtonBg}, 0.2)
						for _, child in pairs(Checkmark:GetChildren()) do
							if child:IsA("UIGradient") then
								child:Destroy()
							end
						end
					else
						selectedOptions[optionName] = true
						Checkmark.Text = "✓"
						tween(Checkmark, {BackgroundColor3 = theme.Accent}, 0.2)
						addGradient(Checkmark, {theme.Accent, theme.AccentBlue}, 45)
					end

					if callback then
						task.spawn(callback, selectedOptions)
					end
				end)
			end

			DropdownHeader.MouseButton1Click:Connect(function()
				isOpen = not isOpen

				if isOpen then
					tween(DropdownFrame, {Size = UDim2.new(1, -10, 0, openHeight)}, 0.3)
					tween(Arrow, {Rotation = 180}, 0.3)
				else
					tween(DropdownFrame, {Size = UDim2.new(1, -10, 0, closedHeight)}, 0.3)
					tween(Arrow, {Rotation = 0}, 0.3)
				end
			end)

			return DropdownFrame
		end

		function Category:Label(text)
			local Label = create("TextLabel", {
				Name = "Label",
				Size = UDim2.new(1, -10, 0, isMobile and 28 or 32),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = theme.TextDim,
				Font = Enum.Font.Gotham,
				TextSize = isMobile and 11 or 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = ScrollFrame
			})

			return Label
		end

		function Category:Slider(name, min, max, default, callback)
			local value = default or min

			local sliderHeight = isMobile and 54 or 58
			local SliderFrame = create("Frame", {
				Name = "Slider",
				Size = UDim2.new(1, -10, 0, sliderHeight),
				BackgroundColor3 = theme.Panel,
				Parent = ScrollFrame
			})
			roundify(SliderFrame, 8)

			create("TextLabel", {
				Size = UDim2.new(1, -65, 0, 24),
				Position = UDim2.new(0, isMobile and 10 or 14, 0, isMobile and 6 or 8),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				Font = Enum.Font.GothamSemibold,
				TextSize = isMobile and 12 or 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = SliderFrame
			})

			local SliderValue = create("TextLabel", {
				Size = UDim2.new(0, 55, 0, 24),
				Position = UDim2.new(1, -63, 0, isMobile and 6 or 8),
				BackgroundTransparency = 1,
				Text = tostring(value),
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = isMobile and 12 or 14,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = SliderFrame
			})

			local barHeight = isMobile and 5 or 6
			local SliderBar = create("Frame", {
				Size = UDim2.new(1, -(isMobile and 20 or 28), 0, barHeight),
				Position = UDim2.new(0, isMobile and 10 or 14, 1, -(isMobile and 14 or 16)),
				BackgroundColor3 = theme.ButtonBg,
				BorderSizePixel = 0,
				Parent = SliderFrame
			})
			roundify(SliderBar, barHeight/2)

			local SliderFill = create("Frame", {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Parent = SliderBar
			})
			roundify(SliderFill, barHeight/2)
			addGradient(SliderFill, {theme.Accent, theme.AccentBlue}, 45)

			local dragging = false

			local function updateSlider(input)
				local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * pos)

				SliderValue.Text = tostring(value)
				SliderFill.Size = UDim2.new(pos, 0, 1, 0)

				if callback then
					task.spawn(callback, value)
				end
			end

			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateSlider(input)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateSlider(input)
				end
			end)

			return SliderFrame
		end

		return Category
	end

	function Window:Notify(config)
		local text = type(config) == "string" and config or config.Text or config.text
		local duration = type(config) == "table" and (config.Duration or config.duration) or 3
		local notifType = type(config) == "table" and (config.Type or config.type) or "Info"

		local colors = {
			Info = theme.Accent,
			Success = theme.Success,
			Warning = theme.Warning,
			Error = theme.Error
		}

		local notifHeight = isMobile and 55 or 65
		local Notif = create("Frame", {
			Name = "Notification",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = theme.Panel,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = NotifContainer
		})
		roundify(Notif, 8)
		addStroke(Notif, theme.Border, 1.5)

		local NotifAccent = create("Frame", {
			Size = UDim2.new(0, isMobile and 4 or 5, 1, 0),
			BackgroundColor3 = colors[notifType] or colors.Info,
			BorderSizePixel = 0,
			Parent = Notif
		})
		roundify(NotifAccent, 8)
		if notifType == "Info" then
			addGradient(NotifAccent, {theme.Accent, theme.AccentBlue}, 90)
		end

		create("TextLabel", {
			Size = UDim2.new(1, -(isMobile and 18 or 24), 1, 0),
			Position = UDim2.new(0, isMobile and 12 or 16, 0, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = theme.Text,
			Font = Enum.Font.Gotham,
			TextSize = isMobile and 12 or 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = Notif
		})

		tween(Notif, {Size = UDim2.new(1, 0, 0, notifHeight)}, 0.35, Enum.EasingStyle.Back)

		local Sound = Instance.new("Sound")
		Sound.Parent = game.SoundService
		Sound.SoundId = "rbxassetid://4590662766"
		Sound.PlayOnRemove = true
		Sound:Destroy()

		task.delay(duration, function()
			tween(Notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
			task.wait(0.25)
			Notif:Destroy()
		end)
	end

	function Window:Show()
		open = true
		Container.Visible = true
		ModalBtn.Visible = true
		Container.Size = UDim2.new(0, 0, 0, 0)
		UserInputService.MouseIconEnabled = true
		tween(Container, {Size = UDim2.new(0, size.X, 0, size.Y)}, 0.35, Enum.EasingStyle.Back)
	end

	function Window:Hide()
		open = false
		ModalBtn.Visible = false
		UserInputService.MouseIconEnabled = false
		tween(Container, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
		task.wait(0.25)
		Container.Visible = false
	end

	return Window
end

return UILibrary
