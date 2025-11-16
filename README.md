# XaLib UI Library

A modern, feature-rich UI library for Roblox with a sleek dark theme and smooth animations.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Roblox](https://img.shields.io/badge/platform-Roblox-red)

## ✨ Features

- **Modern Design**: Beautiful dark theme with customizable accent colors
- **Smooth Animations**: Powered by TweenService for fluid transitions
- **Category System**: Organized sidebar navigation with icon support
- **Component Library**: Buttons, toggles, sliders, dropdowns, and labels
- **Notification System**: Built-in notification system with multiple types
- **Draggable Windows**: Easy-to-move interface with header dragging
- **Keybind Toggle**: Show/hide the UI with a customizable keybind
- **Responsive**: Adapts to different screen sizes

## 📦 Installation

### Method 1: LoadString (Recommended)
```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/XasonYTB/XaLib/refs/heads/main/UILibrary.lua"))()
```

### Method 2: Manual Installation
1. Download `UILibrary.lua` from this repository
2. Insert it into your Roblox game as a ModuleScript
3. Require it in your script:
```lua
local UILibrary = require(game.ReplicatedStorage.UILibrary)
```

## 🚀 Quick Start

### Creating a Window

```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/XasonYTB/XaLib/refs/heads/main/UILibrary.lua"))()

local Window = UILibrary:CreateWindow({
    Title = "My Custom UI",
    Size = Vector2.new(700, 500),
    Keybind = Enum.KeyCode.RightShift
})
```

### Creating Categories

```lua
local MainCategory = Window:CreateCategory("Main", "🏠")
local SettingsCategory = Window:CreateCategory("Settings", "⚙️")
```

## 📚 Components

### Button

Creates a clickable button that executes a callback function.

```lua
MainCategory:Button("Click Me", function()
    print("Button clicked!")
end)
```

### Toggle

Creates a toggle switch with on/off states.

```lua
MainCategory:Toggle("Enable Feature", false, function(state)
    print("Toggle state:", state)
end)
```

**Parameters:**
- `name` (string): Display name of the toggle
- `default` (boolean): Initial state (true/false)
- `callback` (function): Function called when toggled, receives state as parameter

### Slider

Creates a draggable slider for numeric input.

```lua
MainCategory:Slider("Speed", 0, 100, 50, function(value)
    print("Slider value:", value)
end)
```

**Parameters:**
- `name` (string): Display name of the slider
- `min` (number): Minimum value
- `max` (number): Maximum value
- `default` (number): Initial value
- `callback` (function): Function called when value changes

### Dropdown

Creates a multi-select dropdown menu.

```lua
MainCategory:Dropdown("Select Options", {"Option 1", "Option 2", "Option 3"}, function(selected)
    for option, isSelected in pairs(selected) do
        print(option, isSelected)
    end
end)
```

**Parameters:**
- `name` (string): Display name of the dropdown
- `options` (table): Array of option names
- `callback` (function): Function called when selection changes, receives table of selected options

### Label

Creates a text label for displaying information.

```lua
MainCategory:Label("This is a descriptive label")
```

## 🔔 Notifications

### Basic Notification

```lua
Window:Notify("This is a notification")
```

### Advanced Notification

```lua
Window:Notify({
    Text = "Operation completed successfully!",
    Duration = 5,
    Type = "Success"
})
```

**Notification Types:**
- `"Info"` - Blue accent (default)
- `"Success"` - Green accent
- `"Warning"` - Orange accent
- `"Error"` - Red accent

**Parameters:**
- `Text` (string): The notification message
- `Duration` (number): How long to display (in seconds), default: 3
- `Type` (string): Notification type (Info/Success/Warning/Error)

## 🎨 Customization

### Theme Colors

The library uses a modern dark theme with customizable colors. You can modify the theme table at the top of the library:

```lua
local theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(230, 60, 90),
    -- ... more colors
}
```

### Window Configuration

```lua
local Window = UILibrary:CreateWindow({
    Title = "Custom Title",          -- Window title
    Size = Vector2.new(700, 500),    -- Window dimensions
    Keybind = Enum.KeyCode.RightShift -- Toggle keybind
})
```

## 🎯 Complete Example

```lua
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/XasonYTB/XaLib/refs/heads/main/UILibrary.lua"))()

-- Create window
local Window = UILibrary:CreateWindow({
    Title = "My Script Hub",
    Size = Vector2.new(700, 500),
    Keybind = Enum.KeyCode.RightShift
})

-- Create categories
local Main = Window:CreateCategory("Main", "🏠")
local Player = Window:CreateCategory("Player", "👤")
local Settings = Window:CreateCategory("Settings", "⚙️")

-- Add components to Main category
Main:Button("Execute Action", function()
    Window:Notify({
        Text = "Action executed!",
        Type = "Success"
    })
end)

Main:Toggle("Auto Farm", false, function(state)
    if state then
        print("Auto Farm enabled")
    else
        print("Auto Farm disabled")
    end
end)

Main:Slider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Add components to Player category
Player:Dropdown("Teleport Location", {
    "Spawn",
    "Secret Area",
    "Boss Arena"
}, function(selected)
    for location, isSelected in pairs(selected) do
        if isSelected then
            print("Teleporting to:", location)
        end
    end
end)

Player:Label("Use the dropdown to teleport")

-- Show the window
Window:Show()
```

## 📖 API Reference

### Window Methods

| Method | Description |
|--------|-------------|
| `CreateCategory(name, icon)` | Creates a new category tab |
| `Notify(config)` | Shows a notification |
| `Show()` | Displays the window with animation |
| `Hide()` | Hides the window with animation |

### Category Methods

| Method | Description |
|--------|-------------|
| `Button(name, callback)` | Creates a button |
| `Toggle(name, default, callback)` | Creates a toggle switch |
| `Slider(name, min, max, default, callback)` | Creates a slider |
| `Dropdown(name, options, callback)` | Creates a dropdown menu |
| `Label(text)` | Creates a text label |

## 🎮 Controls

- **Toggle UI**: Press your configured keybind (default: Right Shift)
- **Drag Window**: Click and drag the header bar
- **Close Window**: Click the X button in the top-right corner
- **Toggle Button**: Click the floating button in the bottom-right

## 🔧 Requirements

- Roblox Executor with HttpGet support
- LocalScript environment (runs on client)

## ⚠️ Notes

- Modal button enables cursor movement in first-person view when UI is open
- Search icon in header is decorative only
- Requires executor with TweenService access

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📧 Support

If you need help or have questions:
- Open an issue on GitHub
- Contact the developer: XasonYTB

## 🌟 Credits

Developed by **XasonYTB**

---

⭐ If you like this library, consider giving it a star on GitHub!
