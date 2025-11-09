-- Load UI Library from GitHub
local HttpService = game:GetService("HttpService")

-- Your GitHub raw URL (replace with your actual URL)
local GITHUB_URL = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/UILibrary.lua"

-- Function to load the library
local function loadUILibrary()
	local success, result = pcall(function()
		return game:HttpGet(GITHUB_URL)
	end)
	
	if success then
		local loadSuccess, UILib = pcall(function()
			return loadstring(result)()
		end)
		
		if loadSuccess then
			return UILib
		else
			warn("Failed to load UI Library:", UILib)
			return nil
		end
	else
		warn("Failed to fetch UI Library from GitHub:", result)
		return nil
	end
end

-- Load and use the library
local UILib = loadUILibrary()

if UILib then
	-- Create your hub
	local Hub = UILib.new("My Hub")
	
	-- Add your components
	Hub:AddLabel("Loaded from GitHub!")
	
	Hub:AddButton("Test Button", function()
		print("Button works!")
	end)
	
	Hub:AddToggle("Enable Feature", false, function(state)
		print("Toggle:", state)
	end)
	
	Hub:AddSlider("Speed", 16, 100, 50, function(value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
	end)
	
	print("UI Library loaded successfully!")
else
	warn("Failed to load UI Library. Make sure the GitHub URL is correct and the game has HTTP requests enabled.")
end
