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

--// Modern Dark Theme (inspired by the image)
local theme = {
	Background = Color3.fromRGB(20, 20, 25),
	Sidebar = Color3.fromRGB(30, 30, 35),
	Header = Color3.fromRGB(25, 25, 30),
	Panel = Color3.fromRGB(35, 35, 40),
	Accent = Color3.fromRGB(230, 60, 90),
	AccentHover = Color3.fromRGB(250, 80, 110),
	AccentDim = Color3.fromRGB(180, 50, 70),
	ButtonBg = Color3.fromRGB(40, 40, 45),
	ButtonHover = Color3.fromRGB(50, 50, 55),
	Text = Color3.fromRGB(220, 220, 225),
	TextDim = Color3.fromRGB(140, 140, 150),
	Border = Color3.fromRGB(45, 45, 50),
	Success = Color3.fromRGB(80, 200, 120),
	Warning = Color3.fromRGB(255, 180, 50),
	Error = Color3.fromRGB(230, 60, 90),
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
	local corner = create("UICorner", {
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

local function tween(obj, props, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.3,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	TweenService:Create(obj, info, props):Play()
end

--// Main Window Creator
function UILibrary:CreateWindow(config)
	local title = config.Title or config.title or "mspaint v4"
	local size = config.Size or Vector2.new(700, 500)
	local keybind = config.Keybind or config.keybind or Enum.KeyCode.RightShift

	--// Screen GUI
	local ScreenGui = create("ScreenGui", {
		Name = "ModernUI_" .. title,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
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
	roundify(Container, 8)
	addStroke(Container, theme.Border, 1)

	--// Header
	local Header = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = theme.Header,
		BorderSizePixel = 0,
		Parent = Container
	})
	roundify(Header, 8)

	local HeaderBottom = create("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = theme.Header,
		BorderSizePixel = 0,
		Parent = Header
	})

	-- Logo/Icon
	local Logo = create("TextLabel", {
		Name = "Logo",
		Size = UDim2.new(0, 35, 0, 35),
		Position = UDim2.new(0, 15, 0, 7.5),
		BackgroundColor3 = theme.Sidebar,
		Text = "🎨",
		TextColor3 = theme.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		Parent = Header
	})
	roundify(Logo, 6)

	local TitleLabel = create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -150, 1, 0),
		Position = UDim2.new(0, 60, 0, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Header
	})

	-- Search Icon (decorative)
	local SearchIcon = create("TextLabel", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -80, 0, 10),
		BackgroundTransparency = 1,
		Text = "🔍",
		TextColor3 = theme.TextDim,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		Parent = Header
	})

	--// Close Button
	local CloseBtn = create("TextButton", {
		Name = "CloseBtn",
		Size = UDim2.new(0, 35, 0, 35),
		Position = UDim2.new(1, -45, 0, 7.5),
		BackgroundColor3 = theme.ButtonBg,
		Text = "×",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		AutoButtonColor = false,
		Parent = Header
	})
	roundify(CloseBtn, 6)

	CloseBtn.MouseEnter:Connect(function()
		tween(CloseBtn, {BackgroundColor3 = theme.Error}, 0.2)
	end)
	CloseBtn.MouseLeave:Connect(function()
		tween(CloseBtn, {BackgroundColor3 = theme.ButtonBg}, 0.2)
	end)
	CloseBtn.MouseButton1Click:Connect(function()
		open = false
		Container.Visible = false
		ModalBtn.Visible = false
	end)

	--// Dragging
	local dragging, dragInput, dragStart, startPos

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Container.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
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

	--// Category Sidebar (Left side like the image)
	local Sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 120, 1, -50),
		Position = UDim2.new(0, 0, 0, 50),
		BackgroundColor3 = theme.Sidebar,
		BorderSizePixel = 0,
		Parent = Container
	})

	local SidebarList = create("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Sidebar
	})

	local SidebarPadding = create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		Parent = Sidebar
	})

	--// Content Area (Right side)
	local ContentFrame = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -135, 1, -65),
		Position = UDim2.new(0, 128, 0, 58),
		BackgroundTransparency = 1,
		Parent = Container
	})

	--// Toggle Button (Bottom right)
	local ToggleBtn = create("TextButton", {
		Name = "ToggleBtn",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -70, 1, -70),
		BackgroundColor3 = theme.Accent,
		Text = "",
		AutoButtonColor = false,
		Parent = ScreenGui
	})
	roundify(ToggleBtn, 10)
	addStroke(ToggleBtn, theme.AccentDim, 2)

	local ToggleIcon = create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "🎨",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		Parent = ToggleBtn
	})

	local open = false

	local function toggleUI()
		open = not open
		Container.Visible = open
		ModalBtn.Visible = open

		if open then
			Container.Size = UDim2.new(0, 0, 0, 0)
			tween(Container, {
				Size = UDim2.new(0, size.X, 0, size.Y)
			}, 0.3, Enum.EasingStyle.Back)
		else
			tween(Container, {
				Size = UDim2.new(0, 0, 0, 0)
			}, 0.25)
			task.wait(0.25)
			Container.Visible = false
		end
	end

	ToggleBtn.MouseButton1Click:Connect(toggleUI)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == keybind then
			toggleUI()
		end
	end)

	ToggleBtn.MouseEnter:Connect(function()
		tween(ToggleBtn, {
			BackgroundColor3 = theme.AccentHover,
			Size = UDim2.new(0, 55, 0, 55)
		}, 0.2)
	end)
	ToggleBtn.MouseLeave:Connect(function()
		tween(ToggleBtn, {
			BackgroundColor3 = theme.Accent,
			Size = UDim2.new(0, 50, 0, 50)
		}, 0.2)
	end)

	--// Notification Container
	local NotifContainer = create("Frame", {
		Name = "Notifications",
		Size = UDim2.new(0, 320, 1, -20),
		Position = UDim2.new(1, -330, 0, 10),
		BackgroundTransparency = 1,
		Parent = ScreenGui
	})

	local NotifLayout = create("UIListLayout", {
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

		--// Category Button (Pink highlight when selected)
		local CategoryBtn = create("TextButton", {
			Name = name,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = theme.ButtonBg,
			Text = "",
			AutoButtonColor = false,
			Parent = Sidebar
		})
		roundify(CategoryBtn, 5)

		-- Pink highlight bar (initially hidden)
		local HighlightBar = create("Frame", {
			Name = "Highlight",
			Size = UDim2.new(0, 3, 1, -8),
			Position = UDim2.new(0, 2, 0, 4),
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			Parent = CategoryBtn
		})
		roundify(HighlightBar, 2)

		local IconLabel = create("TextLabel", {
			Size = UDim2.new(0, 24, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text = icon or "📁",
			TextColor3 = theme.TextDim,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Parent = CategoryBtn
		})

		local CategoryLabel = create("TextLabel", {
			Size = UDim2.new(1, -45, 1, 0),
			Position = UDim2.new(0, 40, 0, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = theme.TextDim,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = CategoryBtn
		})

		--// Category Content
		local ScrollFrame = create("ScrollingFrame", {
			Name = name .. "Content",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = theme.Border,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = ContentFrame
		})

		local UIList = create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ScrollFrame
		})

		local UIPadding = create("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 10),
			Parent = ScrollFrame
		})

		categoryData.ScrollFrame = ScrollFrame
		categoryData.Button = CategoryBtn
		categoryData.HighlightBar = HighlightBar
		categoryData.IconLabel = IconLabel
		categoryData.CategoryLabel = CategoryLabel

		--// Category Selection
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
			IconLabel.TextColor3 = theme.Text
			CategoryLabel.TextColor3 = theme.Text
			Window.CurrentCategory = categoryData
		end)

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

		table.insert(Window.Categories, categoryData)

		--// Auto-select first category
		if #Window.Categories == 1 then
			for _, cat in pairs(Window.Categories) do
				cat.ScrollFrame.Visible = false
				cat.Button.BackgroundColor3 = theme.ButtonBg
				cat.HighlightBar.Visible = false
			end
			ScrollFrame.Visible = true
			CategoryBtn.BackgroundColor3 = theme.Panel
			HighlightBar.Visible = true
			IconLabel.TextColor3 = theme.Text
			CategoryLabel.TextColor3 = theme.Text
			Window.CurrentCategory = categoryData
		end

		--// Category API
		local Category = {}
		Category.ScrollFrame = ScrollFrame

		function Category:Button(name, callback)
			local Button = create("TextButton", {
				Name = "Button",
				Size = UDim2.new(1, -10, 0, 38),
				BackgroundColor3 = theme.Accent,
				Text = "",
				AutoButtonColor = false,
				Parent = ScrollFrame
			})
			roundify(Button, 5)

			local ButtonLabel = create("TextLabel", {
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.new(0, 10, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.GothamSemibold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = Button
			})

			Button.MouseEnter:Connect(function()
				tween(Button, {BackgroundColor3 = theme.AccentHover}, 0.2)
			end)
			Button.MouseLeave:Connect(function()
				tween(Button, {BackgroundColor3 = theme.Accent}, 0.2)
			end)

			Button.MouseButton1Click:Connect(function()
				tween(Button, {Size = UDim2.new(1, -10, 0, 35)}, 0.1)
				task.wait(0.1)
				tween(Button, {Size = UDim2.new(1, -10, 0, 38)}, 0.1)

				if callback then
					task.spawn(callback)
				end
			end)

			return Button
		end

		function Category:Toggle(name, default, callback)
			local enabled = default or false

			local ToggleFrame = create("Frame", {
				Name = "Toggle",
				Size = UDim2.new(1, -10, 0, 38),
				BackgroundColor3 = theme.Panel,
				Parent = ScrollFrame
			})
			roundify(ToggleFrame, 5)

			local ToggleLabel = create("TextLabel", {
				Size = UDim2.new(1, -65, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ToggleFrame
			})

			local ToggleButton = create("TextButton", {
				Name = "Switch",
				Size = UDim2.new(0, 40, 0, 20),
				Position = UDim2.new(1, -48, 0.5, -10),
				BackgroundColor3 = enabled and theme.Accent or theme.ButtonBg,
				Text = "",
				AutoButtonColor = false,
				Parent = ToggleFrame
			})
			roundify(ToggleButton, 10)

			local ToggleCircle = create("Frame", {
				Name = "Circle",
				Size = UDim2.new(0, 14, 0, 14),
				Position = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = ToggleButton
			})
			roundify(ToggleCircle, 7)

			ToggleButton.MouseButton1Click:Connect(function()
				enabled = not enabled

				tween(ToggleButton, {
					BackgroundColor3 = enabled and theme.Accent or theme.ButtonBg
				}, 0.2)

				tween(ToggleCircle, {
					Position = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
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

			local closedHeight = 38
			local openHeight = closedHeight + (#options * 30) + 8

			local DropdownFrame = create("Frame", {
				Name = "Dropdown",
				Size = UDim2.new(1, -10, 0, closedHeight),
				BackgroundColor3 = theme.Panel,
				ClipsDescendants = true,
				Parent = ScrollFrame
			})
			roundify(DropdownFrame, 5)

			local DropdownHeader = create("TextButton", {
				Name = "Header",
				Size = UDim2.new(1, 0, 0, closedHeight),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = DropdownFrame
			})

			local DropdownLabel = create("TextLabel", {
				Size = UDim2.new(1, -45, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = DropdownHeader
			})

			local Arrow = create("TextLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(1, -28, 0.5, -10),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = theme.TextDim,
				Font = Enum.Font.Gotham,
				TextSize = 10,
				Parent = DropdownHeader
			})

			local OptionsFrame = create("Frame", {
				Name = "Options",
				Size = UDim2.new(1, -8, 1, -closedHeight - 8),
				Position = UDim2.new(0, 4, 0, closedHeight + 4),
				BackgroundTransparency = 1,
				Parent = DropdownFrame
			})

			local OptionsList = create("UIListLayout", {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = OptionsFrame
			})

			for _, optionName in ipairs(options) do
				local OptionButton = create("TextButton", {
					Name = optionName,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = theme.ButtonBg,
					Text = "",
					AutoButtonColor = false,
					Parent = OptionsFrame
				})
				roundify(OptionButton, 4)

				local OptionLabel = create("TextLabel", {
					Size = UDim2.new(1, -30, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text = optionName,
					TextColor3 = theme.Text,
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = OptionButton
				})

				local Checkmark = create("TextLabel", {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(1, -22, 0.5, -8),
					BackgroundColor3 = theme.ButtonBg,
					Text = "",
					TextColor3 = theme.Accent,
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					Parent = OptionButton
				})
				roundify(Checkmark, 3)
				addStroke(Checkmark, theme.Border, 1)

				OptionButton.MouseEnter:Connect(function()
					tween(OptionButton, {BackgroundColor3 = theme.ButtonHover}, 0.2)
				end)

				OptionButton.MouseLeave:Connect(function()
					tween(OptionButton, {BackgroundColor3 = theme.ButtonBg}, 0.2)
				end)

				OptionButton.MouseButton1Click:Connect(function()
					if selectedOptions[optionName] then
						selectedOptions[optionName] = nil
						Checkmark.Text = ""
						tween(Checkmark, {BackgroundColor3 = theme.ButtonBg}, 0.2)
					else
						selectedOptions[optionName] = true
						Checkmark.Text = "✓"
						tween(Checkmark, {BackgroundColor3 = theme.Accent}, 0.2)
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
				Size = UDim2.new(1, -10, 0, 30),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = theme.TextDim,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Parent = ScrollFrame
			})

			return Label
		end

		function Category:Slider(name, min, max, default, callback)
			local value = default or min

			local SliderFrame = create("Frame", {
				Name = "Slider",
				Size = UDim2.new(1, -10, 0, 52),
				BackgroundColor3 = theme.Panel,
				Parent = ScrollFrame
			})
			roundify(SliderFrame, 5)

			local SliderLabel = create("TextLabel", {
				Size = UDim2.new(1, -60, 0, 22),
				Position = UDim2.new(0, 12, 0, 6),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = SliderFrame
			})

			local SliderValue = create("TextLabel", {
				Size = UDim2.new(0, 50, 0, 22),
				Position = UDim2.new(1, -58, 0, 6),
				BackgroundTransparency = 1,
				Text = tostring(value),
				TextColor3 = theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = SliderFrame
			})

			local SliderBar = create("Frame", {
				Size = UDim2.new(1, -24, 0, 4),
				Position = UDim2.new(0, 12, 1, -14),
				BackgroundColor3 = theme.ButtonBg,
				BorderSizePixel = 0,
				Parent = SliderFrame
			})
			roundify(SliderBar, 2)

			local SliderFill = create("Frame", {
				Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
				BackgroundColor3 = theme.Accent,
				BorderSizePixel = 0,
				Parent = SliderBar
			})
			roundify(SliderFill, 2)

			local dragging = false

			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					value = math.floor(min + (max - min) * pos)

					SliderValue.Text = tostring(value)
					SliderFill.Size = UDim2.new(pos, 0, 1, 0)

					if callback then
						task.spawn(callback, value)
					end
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

		local Notif = create("Frame", {
			Name = "Notification",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = theme.Panel,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = NotifContainer
		})
		roundify(Notif, 6)
		addStroke(Notif, theme.Border, 1)

		local NotifAccent = create("Frame", {
			Size = UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = colors[notifType] or colors.Info,
			BorderSizePixel = 0,
			Parent = Notif
		})
		roundify(NotifAccent, 6)

		local NotifLabel = create("TextLabel", {
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = theme.Text,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = Notif
		})

		tween(Notif, {Size = UDim2.new(1, 0, 0, 60)}, 0.3, Enum.EasingStyle.Back)

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
		tween(Container, {
			Size = UDim2.new(0, size.X, 0, size.Y)
		}, 0.3, Enum.EasingStyle.Back)
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
