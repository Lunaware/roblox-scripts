---@diagnostic disable: undefined-global

--[[

	>> -- Apollo Client -- << Created by Lunaware >> --

	didn't bother obfuscating due to performance issues

--]]

-- Constants
local BUILD_ID			= "C0eF43"

-- Services
local Drawing			= Drawing

local CoreGui			= gethui and gethui() or cloneref(game:GetService("CoreGui"))

local HttpService		= cloneref(game:GetService("HttpService"))
local RunService		= cloneref(game:GetService("RunService"))
local Players			= cloneref(game:GetService("Players"))
local ReplicatedStorage	= cloneref(game:GetService("ReplicatedStorage"))
local Lighting			= cloneref(game:GetService("Lighting"))
local UserInputService	= cloneref(game:GetService("UserInputService"))
local StarterGui		= cloneref(game:GetService("StarterGui"))

-- Variables
if not game.IsLoaded then
	game.Loaded:Wait()
end

local Connections		= {}
local ActivePlayers		= {}
local Camera			= workspace.CurrentCamera

local LocalPlayer		= Players.LocalPlayer or Players.PlayerAdded:Wait()
local LocalIdentifier	= LocalPlayer.Name
local LocalData			= LocalPlayer:WaitForChild("PlayerData")
local LocalBackpack		do
	LocalBackpack = LocalPlayer:FindFirstChildOfClass("Backpack")

	-- Listener
	LocalPlayer.ChildAdded:Connect(function(child)
		if child.ClassName == "Backpack" then
			LocalBackpack = child
		end
	end)
end

local PlayerGui			= LocalPlayer:WaitForChild("PlayerGui")
local Client			= PlayerGui:WaitForChild("Client")
local ProgressBar		= Client.ProgressBar

-- Animations
local Animations = ReplicatedStorage:WaitForChild("Animations")

local ToolAnimations = Animations:WaitForChild("Tools")

local PistolFireAnim = ToolAnimations:WaitForChild("PistolFire")

-- Events
local Events = ReplicatedStorage:WaitForChild("Events")

local NoteEvent = Events:WaitForChild("Note")
local ToolsEvent = Events:WaitForChild("ToolsEvent")
local MenuAcitonEvent = Events:WaitForChild("MenuAcitonEvent")
local MenuActionEvent = Events:WaitForChild("MenuActionEvent")
local MenuEvent = Events:WaitForChild("MenuEvent")

-- Mounting
if shared.ApolloLoaded then
	NoteEvent:Fire("Apollo Client", "User Interface is already mounted.", "Error")
	return
end

shared.ApolloLoaded = true

-- Module Imports
local author, project, branch = "Lunaware", "roblox-scripts", "main"

local function moduleImport(file)
    local success, result = pcall(loadstring(game:HttpGetAsync(string.format("https://raw.githubusercontent.com/%s/%s/%s/%s.lua", author, project, branch, file)), file.. ".lua"))
    return (success and result) or result and warn("Engine Import Failure: ".. result)
end

-- Load Libraries
local linoria_lib	= moduleImport("libraries/user-interface/linoria/library")
local save_manager	= moduleImport("libraries/user-interface/linoria/save-manager")
local theme_manager	= moduleImport("libraries/user-interface/linoria/theme-manager")
local contact		= moduleImport("public/contact")
local blacklists	= moduleImport("libraries/apollo/blacklists")

-- Blacklists
if table.find(blacklists, LocalPlayer.UserId) then
	NoteEvent:Fire("Apollo Client", "You have been blacklisted from Apollo.", "Error")
	NoteEvent:Fire("Appeal Information", "If you want to appeal, contact ".. contact)
	return
end

-- Load User Interface
local Window = linoria_lib:CreateWindow({
	Title = "<b>Apollo Client</b> [build id: <b>".. BUILD_ID.. "</b>]",
	Center = true,
	AutoShow = false
})

local Tabs = {
	Character	= Window:AddTab("Character"),
	World		= Window:AddTab("World"),
	Combat		= Window:AddTab("Combat"),
	Players		= Window:AddTab("Players"),
	Settings	= Window:AddTab("Settings")
}

-- >> Settings << --

theme_manager:SetLibrary(linoria_lib)
save_manager:SetLibrary(linoria_lib)

save_manager:IgnoreThemeSettings()
save_manager:SetIgnoreIndexes({'MenuKeybind'})

theme_manager:SetFolder('Apollo Client')
save_manager:SetFolder('Apollo Client/Electric State DarkRP')

save_manager:BuildConfigSection(Tabs.Settings)
theme_manager:ApplyToTab(Tabs.Settings)

-- Credits
local Credits = Tabs.Settings:AddRightGroupbox("Credits")
Credits:AddLabel("Created by <b>Lunaware</b>")
Credits:AddButton("Discord", function()
	setclipboard(contact)

	linoria_lib:Notify("My discord has been copied to your clipboard!", 5)
end):AddTooltip(contact)

-- >> Character << --

-- Legit --
local Legit = Tabs.Character:AddLeftGroupbox("Legit")

Legit:AddToggle("BypassSpyChecks", {Text = "Bypass Spy Checks", Default = false, Tooltip = "Bypasses checks commonly used by Spy Watches."})

Legit:AddToggle("InfEnergy", {Text = "Infinite Energy", Default = false, Tooltip = "Grants you infinite energy."})
Legit:AddToggle("InfHunger", {Text = "Infinite Hunger", Default = false, Tooltip = "Grants you infinite hunger."})

Legit:AddToggle("HideItems", {Text = "Hide Items", Default = false, Tooltip = "Prevents items from holstering."})

-- Blatant --
local Blatant = Tabs.Character:AddLeftGroupbox("Blatant")

Blatant:AddToggle("InstantCraft", {Text = "Instant Craft", Default = false, Tooltip = "Instantly crafts items instead of waiting for the progress bar."})
Blatant:AddToggle("InstantBatteringRam", {Text = "Instant Battering Ram", Default = false, Tooltip = "Instantly breaks down doors with the battering ram."})

-- Entity Speed --
local EntitySpeed = Tabs.Character:AddLeftGroupbox("Entity Speed")

EntitySpeed:AddToggle("EntitySpeed_Enabled", {Text = "Enabled", Default = false, Tooltip = "Enables entity speed."})

EntitySpeed:AddSlider("EntitySpeed_Slider", {Text = "Speed", Default = 1, Min = 1, Max = 15, Rounding = 2, Compact = true})
local EntitySpeed_Slider = Options.EntitySpeed_Slider
EntitySpeed_Slider:SetValue(1.05)

EntitySpeed:AddLabel('Keybind'):AddKeyPicker('EntitySpeed_Keybind', {Default = 'LeftShift', Mode = 'Hold', NoUI = true})

-- Utility --
local Utility = Tabs.Character:AddLeftGroupbox("Utility")

Utility:AddButton("Enable Backpack", function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end)
Utility:AddButton("Enable Leaderboard", function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end)

Utility:AddToggle("LoopEnableBackpack", {Text = "Loop Enable Backpack", Default = false, Tooltip = "Loop enables your backpack."})

do -- NoCameraShake
	local Globals = getrenv()._G

	local CSH = rawget(Globals, "CSH")
	local FakeCSH = function() end

	-- Toggle
	Utility:AddToggle("NoCameraShake", {Text = "Disable Camera Shake", Default = false, Tooltip = "Disables the default camera shake."})

	-- Listener
	local NoCameraShake = Toggles.NoCameraShake
	NoCameraShake:OnChanged(function()
		rawset(Globals, "CSH", NoCameraShake.Value and FakeCSH or CSH)
	end)
end

-- >> World << --

-- Legit --
local Legit = Tabs.World:AddLeftGroupbox("Legit")

local BypassNLR do -- BypassNLR
	-- Toggle
	Legit:AddToggle("BypassNLR", {Text = "Bypass NLR", Default = false, Tooltip = "Bypass the New Life Rule."})
	BypassNLR = Toggles.BypassNLR

	-- Listener
	BypassNLR:OnChanged(function()
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "NL" then
				child:Destroy()
			end
		end
	end)
end

-- Farming --
local Farming = Tabs.World:AddLeftGroupbox("Farming")

Farming:AddToggle("AureusFarm_Enabled", {Text = "Aureus Farm", Default = false, Tooltip = "Automatically scavenges for you when you stand near a station."})

-- >> ESP << --

-- ESP Settings
local esp_settings	= Tabs.World:AddLeftTabbox("ESP Settings")

local esp_main		= esp_settings:AddTab("Main")
local esp_colors	= esp_settings:AddTab("Colors")

-- ESP Main Settings
local ESP_Enabled do -- ESP_Enabled
	-- Toggle
	esp_main:AddToggle("ESP_Enabled", {Text = "Enabled", Default = false, Tooltip = "Enables ESP."}):AddKeyPicker('ESP_Keybind', {Mode = "Toggle", NoUI = true})
	ESP_Enabled = Toggles.ESP_Enabled

	-- Listener
	local ESP_Keybind do
		ESP_Keybind = Options.ESP_Keybind
		
		ESP_Keybind:OnClick(function()
			if UserInputService:GetFocusedTextBox() then
				return
			end

			ESP_Enabled:SetValue(not ESP_Enabled.Value)
		end)
	end
end

esp_main:AddDivider()

esp_main:AddToggle("ESP_Players", {Text = "Players", Default = false})
esp_main:AddToggle("ESP_Printers", {Text = "Printers", Default = false})
esp_main:AddToggle("ESP_Entities", {Text = "Entities", Default = false})
esp_main:AddToggle("ESP_Shipments", {Text = "Shipments", Default = false})

esp_main:AddDivider()

esp_main:AddToggle("ESP_Tracers", {Text = "Tracers", Default = false})
esp_main:AddToggle("ESP_MouseTracers", {Text = "Tracers Follow Mouse", Default = false})

-- ESP Color Settings
esp_colors:AddLabel("Neutral Roles"):AddColorPicker("ESP_Neutral", {Default = Color3.fromRGB(216, 216, 216)})
esp_colors:AddLabel("Government Roles"):AddColorPicker("ESP_Government", {Default = Color3.fromRGB(98, 145, 255)})
esp_colors:AddLabel("Flagged"):AddColorPicker("ESP_Flagged", {Default = Color3.fromRGB(255, 130, 41)})
esp_colors:AddLabel("Hostile"):AddColorPicker("ESP_Hostile", {Default = Color3.fromRGB(255, 0, 0)})

esp_colors:AddDivider()

esp_colors:AddLabel("Advanced Printers"):AddColorPicker("ESP_AdvancedPrinters", {Default = Color3.fromRGB(255, 70, 70)})
esp_colors:AddLabel("Basic Printers"):AddColorPicker("ESP_BasicPrinters", {Default = Color3.fromRGB(255, 222, 130)})
esp_colors:AddLabel("Entities"):AddColorPicker("ESP_EntityColor", {Default = Color3.fromRGB(75, 255, 99)})
esp_colors:AddLabel("Shipments"):AddColorPicker("ESP_ShipmentColor", {Default = Color3.fromRGB(210, 121, 255)})

-- Weather --
local Weather = Tabs.World:AddRightGroupbox("Weather")

local Conditions = {
	["Day"] = {
		Condition = "Day",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {
			Intensity = 0.25,
			Spread = 1,
			Enabled = true
		},

		Lighting = {
			ClockTime = 12,
			Ambient = Color3.fromRGB(78, 80, 89),
			OutdoorAmbient = Color3.fromRGB(185, 178, 167),
			Colorshift_Bottom = Color3.fromRGB(95, 114, 138),
			Colorshift_Top = Color3.fromRGB(195, 195, 195),
			FogColor = Color3.fromRGB(255, 247, 234),
			Brightness = 1.8,
			FogEnd = 4000,
			FogStart = 0,
			GeographicLatitude = 13
		},

		Sky = {
			SkyboxBk = "rbxassetid://497798770",
			SkyboxDn = "rbxassetid://489495201",
			SkyboxFt = "rbxassetid://497793238",
			SkyboxLf = "rbxassetid://497798734",
			SkyboxRt = "rbxassetid://497798714",
			SkyboxUp = "rbxassetid://489495183"
		}
	},
	["Evening"] = {
		Condition = "Night",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {
			Intensity = 0.25,
			Spread = 1,
			Enabled = true
		},

		Lighting = {
			ClockTime = 17,
			Ambient = Color3.fromRGB(),
			OutdoorAmbient = Color3.fromRGB(124, 92, 114),
			Colorshift_Bottom = Color3.fromRGB(95, 114, 138),
			Colorshift_Top = Color3.fromRGB(),
			FogColor = Color3.fromRGB(253, 198, 189),
			Brightness = 0.69,
			FogEnd = 2000,
			FogStart = 0,
			GeographicLatitude = 50
		},

		Sky = {
			SkyboxBk = "rbxassetid://271042516",
			SkyboxDn = "rbxassetid://271077243",
			SkyboxFt = "rbxassetid://271042556",
			SkyboxLf = "rbxassetid://271042310",
			SkyboxRt = "rbxassetid://271042467",
			SkyboxUp = "rbxassetid://271077958"
		}
	},
	["Night"] = {
		Condition = "Night",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {
			Intensity = 0.03,
			Spread = 1.2,
			Enabled = true
		},

		Lighting = {
			ClockTime = 12,
			Ambient = Color3.fromRGB(42, 46, 49),
			OutdoorAmbient = Color3.fromRGB(101, 124, 173),
			Colorshift_Bottom = Color3.fromRGB(95, 114, 138),
			Colorshift_Top = Color3.new(),
			FogColor = Color3.fromRGB(62, 76, 107),
			Brightness = 0,
			FogEnd = 2000,
			FogStart = 0,
			GeographicLatitude = 20
		},

		Sky = {
			SkyboxBk = "rbxassetid://243156190",
			SkyboxDn = "rbxassetid://213221473",
			SkyboxFt = "rbxassetid://243156218",
			SkyboxLf = "rbxassetid://243156199",
			SkyboxRt = "rbxassetid://243156177",
			SkyboxUp = "rbxassetid://243156241"
		},

		AtmosphereAmb = {
			Color = Color3.fromRGB(255, 255, 255),
			Decay = Color3.fromRGB(255, 255, 255),
			Density = 0.34,
			Glare = 1,
			Haze = 2.2
		}
	},
	["Better Night"] = {
		Condition = "Night",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {
			Intensity = 0.03,
			Spread = 1.2,
			Enabled = true
		},

		Lighting = {
			ClockTime = 12,
			Ambient = Color3.fromRGB(42, 46, 49),
			OutdoorAmbient = Color3.fromRGB(101, 124, 173),
			Colorshift_Bottom = Color3.fromRGB(95, 114, 138),
			Colorshift_Top = Color3.fromRGB(),
			FogColor = Color3.fromRGB(62, 76, 107),
			Brightness = 0,
			FogEnd = 2000,
			FogStart = 0,
			GeographicLatitude = 20
		},

		Sky = {
			SkyboxBk = "rbxassetid://220789535",
			SkyboxDn = "rbxassetid://213221473",
			SkyboxFt = "rbxassetid://220789557",
			SkyboxLf = "rbxassetid://220789543",
			SkyboxRt = "rbxassetid://220789524",
			SkyboxUp = "rbxassetid://220789575"
		},

		AtmosphereAmb = {
			Color = Color3.fromRGB(255, 255, 255),
			Decay = Color3.fromRGB(255, 255, 255),
			Density = 0.34,
			Glare = 1,
			Haze = 2.2
		}
	},
	["Morning"] = {
		Condition = "Night",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = 0,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {
			Intensity = 0.03,
			Spread = 1.2,
			Enabled = true
		},

		Lighting = {
			ClockTime = 6.69,
			Ambient = Color3.fromRGB(),
			OutdoorAmbient = Color3.fromRGB(35, 45, 61),
			Colorshift_Bottom = Color3.fromRGB(1, 2, 3),
			Colorshift_Top = Color3.fromRGB(244, 173, 85),
			FogColor = Color3.fromRGB(81, 107, 112),
			Brightness = 0.25,
			FogEnd = 2000,
			FogStart = 0,
			GeographicLatitude = 337
		},

		Sky = {
			SkyboxBk = "rbxassetid://253027015",
			SkyboxDn = "rbxassetid://253027058",
			SkyboxFt = "rbxassetid://253027039",
			SkyboxLf = "rbxassetid://253027029",
			SkyboxRt = "rbxassetid://253026999",
			SkyboxUp = "rbxassetid://253027050"
		}
	},
	["Nuclear Winter"] = {
		Condition = "Snowstorm",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = -0.34,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {},

		Lighting = {
			ClockTime = 12,
			Ambient = Color3.fromRGB(),
			OutdoorAmbient = Color3.fromRGB(195, 195, 195),
			FogColor = Color3.fromRGB(195, 195, 195),
			Brightness = 0,
			FogEnd = 300,
			FogStart = 0
		},

		Sky = {
			SkyboxBk = "rbxassetid://226025278",
			SkyboxDn = "rbxassetid://226025278",
			SkyboxFt = "rbxassetid://226025278",
			SkyboxLf = "rbxassetid://226025278",
			SkyboxRt = "rbxassetid://226025278",
			SkyboxUp = "rbxassetid://226025278"
		}
	},
	["Sandstorm"] = {
		Condition = "Sandstorm",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = -0.2,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {},

		Lighting = {
			ClockTime = 12,
			Ambient = Color3.fromRGB(),
			OutdoorAmbient = Color3.fromRGB(162, 130, 91),
			Colorshift_Bottom = Color3.fromRGB(95, 114, 138),
			Colorshift_Top = Color3.fromRGB(),
			FogColor = Color3.fromRGB(248, 222, 147),
			Brightness = 0,
			FogEnd = 250,
			FogStart = 0
		},

		Sky = {
			SkyboxBk = "rbxassetid://8946325034",
			SkyboxDn = "rbxassetid://8946325034",
			SkyboxFt = "rbxassetid://8946325034",
			SkyboxLf = "rbxassetid://8946325034",
			SkyboxRt = "rbxassetid://8946325034",
			SkyboxUp = "rbxassetid://8946325034"
		}
	},
	["War"] = {
		Condition = "Rain",

		ColorCorrection = {
			Brightness = 0,
			Contract = 0,
			Saturation = -0.2,
			TintColor = Color3.fromRGB(255, 255, 255),
			Enabled = true
		},

		SunRays = {
			Enabled = false
		},

		Lighting = {
			ClockTime = 17,
			Ambient = Color3.fromRGB(),
			OutdoorAmbient = Color3.fromRGB(118, 115, 113),
			Colorshift_Bottom = Color3.fromRGB(95, 114, 138),
			Colorshift_Top = Color3.fromRGB(),
			FogColor = Color3.fromRGB(145, 144, 138),
			Brightness = 0,
			FogEnd = 1500,
			FogStart = 0
		},

		Sky = {
			SkyboxBk = "rbxassetid://2506974318",
			SkyboxDn = "rbxassetid://2506974575",
			SkyboxFt = "rbxassetid://2506974238",
			SkyboxLf = "rbxassetid://2506974390",
			SkyboxRt = "rbxassetid://2506974153",
			SkyboxUp = "rbxassetid://2506974467"
		}
	}
}

for Condition, Data in pairs(Conditions) do
	Weather:AddButton(Condition, function()
		for _, child in ipairs(Lighting:GetChildren()) do
			if child.Name == "AtmosphereAmb" then
				child:Destroy()
			end
		end

		Lighting.Condition.Value = Data.Condition

		if Data.Lighting then
			for property in pairs(getproperties(Lighting)) do
				local newValue = Data[Lighting.Name][property]
				if newValue then
					Lighting[property] = newValue
				end
			end
		end

		for _, instance in pairs(Lighting:GetChildren()) do
			if Data[instance.Name] then
				for property in pairs(getproperties(instance)) do
					local newValue = Data[instance.Name][property]
					if newValue then
						instance[property] = newValue
					end
				end
			end
		end

		if Data.AtmosphereAmb then
			local newAtmosphere = Instance.new("Atmosphere")
			newAtmosphere.Name = "AtmosphereAmb"

			for property, value in pairs(Data.AtmosphereAmb) do
				newAtmosphere[property] = value
			end

			newAtmosphere.Parent = Lighting

			-- Yield until skybox change
			Lighting.Sky:GetPropertyChangedSignal("SkyboxBk"):Wait()

			newAtmosphere:Destroy()
		end
	end)
end

-- >> Combat << --

-- Legit --
local Legit = Tabs.Combat:AddLeftGroupbox("Legit")

Legit:AddToggle("AutoBuyAmmo", {Text = "Auto Buy Ammo", Default = false, Tooltip = "Automatically buys ammo for you."})

-- Silent Aim --
local SilentAim = Tabs.Combat:AddLeftGroupbox("Silent Aim")

SilentAim:AddToggle("SilentAim_Enabled", {Text = "Enabled", Default = false, Tooltip = "Enables silent aim."})
SilentAim:AddToggle("SilentAim_Wallcheck", {Text = "Wallcheck", Default = true, Tooltip = "Enables Wallchecking."})
SilentAim:AddToggle("SilentAim_FOVCircle", {Text = "FOV Circle", Default = false, Tooltip = "Enables the FOV Circle."})
SilentAim:AddSlider("SilentAim_FOVSize", {Text = "FOV Size", Default = 125, Min = 0, Max = 350, Rounding = 1, Compact = true})

-- Auto Heal --
local AutoHeal = Tabs.Combat:AddLeftGroupbox("Auto Heal")
AutoHeal:AddToggle("AutoHeal_Enabled", {Text = "Enabled", Default = false, Tooltip = "[REQUIRES BLOXY COLA] Automatically heals you with cola."})
AutoHeal:AddSlider("AutoHeal_Slider", {Text = "Minimum Health", Default = 45, Min = 1, Max = 100, Rounding = 1, Compact = true})

-- Heal Aura --
local HealAura = Tabs.Combat:AddRightGroupbox("Heal Aura")
HealAura:AddToggle("HealAura_Enabled", {Text = "Enabled", Default = false, Tooltip = "Automatically heals the people around you at a fast pace."})
HealAura:AddDropdown("HealAura_Whitelist", {Values = ActivePlayers, Multi = true, Text = "Whitelist", Tooltip = "Whitelists people for Heal Aura."})

-- >> Players << --

-- Player List --
local Player = Tabs.Players:AddLeftGroupbox("<b>Player List</b>")

Player:AddDropdown("Player_Selection", {Values = ActivePlayers, Text = ""})

-- Data Viewer --
local DataViewer = Tabs.Players:AddRightGroupbox("Data Viewer")

local DataViewerLabels = {
	Selected = DataViewer:AddLabel("<b>Selected:</b> none | none", true),
	UserId = DataViewer:AddLabel("<b>UserId:</b>", true),

	_ = DataViewer:AddDivider(),

	Karma = DataViewer:AddLabel("<b>Karma:</b>", true),
	Cash = DataViewer:AddLabel("<b>Cash:</b>", true),
	Aureus = DataViewer:AddLabel("<b>Aureus:</b>", true),
	Playtime = DataViewer:AddLabel("<b>Playtime:</b>", true),

	_ = DataViewer:AddDivider(),

	Hotbar = DataViewer:AddLabel("<b>Hotbar:</b>", true),
	Inventory = DataViewer:AddLabel("<b>Inventory:</b>", true),
	Bank = DataViewer:AddLabel("<b>Bank:</b>", true)
}

-- Player Options --
local PlayerOptions = Tabs.Players:AddLeftGroupbox("<b>Options</b>")

local Buildings = workspace:WaitForChild("Buildings")

-- Options
local Player_Selection = Options.Player_Selection
local function copyNode() -- Node Copier Chunk
	local playerSelection = Player_Selection.Value
	if not playerSelection then
		linoria_lib:Notify("Please select a player.", 10)
		return
	end

	local selectedPlayer = Players:FindFirstChild(playerSelection)
	if not selectedPlayer then
		linoria_lib:Notify("Selected player is not valid!", 10)
		return
	end

	local playerBuilding = Buildings:FindFirstChild(playerSelection)
	if not playerBuilding then
		linoria_lib:Notify("This player does not have a node placed down.", 10)
		return
	end

	local playerNode = playerBuilding:FindFirstChild("Node")
	if not playerNode then
		linoria_lib:Notify("This player does not have a node placed down.", 10)
		return
	end

	warn("Apollo Client: Attempting to save ".. playerSelection .."'s Node.")

	-- Initialize Node Copier
	local saveDirectory = playerSelection.. "_Node_" ..tostring(math.random(0, 1e9)).. ".txt"

	warn("Node will be saved to `".. saveDirectory.. "` in your workspace folder.")

	-- Grab furniture
	local playerFurniture do
		for _, instance in pairs(getnilinstances()) do
			if instance.Name == "Furniture" then
				playerFurniture = instance:GetChildren()
				break
			end
		end
	end

	local nodePivot = tostring(playerNode:GetPivot())

	local compiled_string = string.format("-- Apollo Client Node Copier --\n-- WARNING: May not work as intended, if there is an error placing down a prop, search for it and delete anything below it until you meet a new line.\n-- Prop Count: %s\n\n", (#playerBuilding:GetChildren()) - 1)
	compiled_string = compiled_string.. "local LocalPlayer = game:GetService(\"Players\").LocalPlayer\nlocal ReplicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal Furniture = require(ReplicatedStorage.Directory).furni\nlocal Events = ReplicatedStorage.Events\nlocal Building = workspace.Buildings:FindFirstChild(LocalPlayer.Name) and workspace.Buildings[LocalPlayer.Name]\nlocal Node = (Building and Building:FindFirstChild(\"Node\")) and Building.Node:WaitForChild(\"Node\")\n\n"

	-- Functions
	local function CheckSize(p1, p2)
		local id1, id2 = Vector3.zero, Vector3.zero

		-- Grab primary parts
		local p1Primary, p2Primary = p1.PrimaryPart, p2.PrimaryPart

		-- Get rid of primary parts
		local p1Children, p2Children = p1:GetChildren(), p2:GetChildren()
		table.remove(p1Children, table.find(p1Children, p1Primary))
		table.remove(p2Children, table.find(p2Children, p2Primary))

		local sizeMultiplier = p1Primary.Size.X

		for _, child in ipairs(p1Children) do
			if child:IsA("BasePart") then
				id1 = id1 + child.Size
			end
		end

		for _, child in ipairs(p2Children) do
			if child:IsA("BasePart") then
				id2 = id2 + child.Size * sizeMultiplier
			end
		end

		return id1 == id2
	end

	-- Create Node
	compiled_string = compiled_string.. string.format("-- >> Spawn Node << --\nif not Node then\n\tEvents.BuildingEvent:FireServer(1, \"Node\", CFrame.new(%s))\n\tBuilding = workspace.Buildings:WaitForChild(LocalPlayer.Name)\n\tNode = Building:WaitForChild(\"Node\"):WaitForChild(\"Node\")\nend\n", nodePivot)

	warn("Apollo Client: Compiled Node.")

	-- Create Props
	for index, prop in pairs(playerBuilding:GetChildren()) do
		(function()
			local resize, material, color = nil, Enum.Material.WoodPlanks, BrickColor.White().Color

			local propIdentifier = prop.Name
			if propIdentifier ~= "Node" then
				warn("Apollo Client: Compiling Prop Number.. ".. index)
	
				-- Find Material & Color
				for _, child in pairs(prop:GetChildren()) do
					if child.Name == "cc" and child:FindFirstChild("Value") then
						material = child.Material
						color = child.Color
						break
					end
				end
	
				-- Resizable Wall
				if propIdentifier == "Resizable Wall" then
					compiled_string = compiled_string.. string.format("\n-- >> Spawn Resizable Wall << --\nEvents.BuildingEvent:FireServer(1, \"Resizable Wall\", Node:GetPivot():ToWorldSpace(CFrame.new(%s):ToObjectSpace(CFrame.new(%s))), nil, BrickColor.new(\"%s\"), nil, nil, \"%s\", nil, Vector3.new(%s))", nodePivot, tostring(prop.PrimaryPart.CFrame), tostring(BrickColor.new(color).Name), material.Name, tostring(prop:WaitForChild("cc").Size)).. "\nNode:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\n"
					return
				end
	
				-- Billboard Signs
				if string.find(propIdentifier, "Billboard") then
					compiled_string = compiled_string.. string.format("\n-- >> Spawn %s << --\nEvents.BuildingEvent:FireServer(1, \"%s\", Node:GetPivot():ToWorldSpace(CFrame.new(%s):ToObjectSpace(CFrame.new(%s))))", propIdentifier, propIdentifier, nodePivot, tostring(prop.PrimaryPart.CFrame)).. string.format("\nProp = Node:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\nEvents.MenuActionEvent:FireServer(7, Prop, {[[%s]], Color3.new(0.94902, 0.952941, 0.952941)})", prop:WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("1").Text).. string.format("\nEvents.BuildingEvent:FireServer(7, Prop, Prop:GetPivot(), nil, %s)\nNode:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\n", tostring(prop.PrimaryPart.Size.X))
					return
				end
	
				-- Picture Signs
				if string.find(propIdentifier, "Picture") then
					compiled_string = compiled_string.. string.format("\n-- >> Spawn %s << --\nEvents.BuildingEvent:FireServer(1, \"%s\", Node:GetPivot():ToWorldSpace(CFrame.new(%s):ToObjectSpace(CFrame.new(%s))))", propIdentifier, propIdentifier, nodePivot, tostring(prop.PrimaryPart.CFrame)).. string.format("\nProp = Node:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\nEvents.MenuActionEvent:FireServer(29, Prop, {%s, Color3.new(0.94902, 0.952941, 0.952941)})", string.sub(prop:WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("1").Image, 14)).. string.format("\nEvents.BuildingEvent:FireServer(7, Prop, Prop:GetPivot(), nil, %s)\nNode:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\n", tostring(prop.PrimaryPart.Size.X))
					return
				end
	
				-- Hat Display Cases
				if propIdentifier == "Hat Display Case" then
					compiled_string = compiled_string.. string.format("\n-- >> Spawn Hat Display Case << --\nif string.find(LocalPlayer.PlayerData.PInvetory.Value, Furniture[\"%s\"][9].. \",\") then\n\tEvents.BuildingEvent:FireServer(1, \"%s\", Node:GetPivot():ToWorldSpace(CFrame.new(%s):ToObjectSpace(CFrame.new(%s))), nil, BrickColor.new(\"%s\"), nil, nil, \"%s\")", propIdentifier, propIdentifier, nodePivot, tostring(prop.PrimaryPart.CFrame), tostring(BrickColor.new(color).Name), material.Name).. string.format("\n\tProp = Node:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\nEvents.MenuActionEvent:FireServer(81, Prop, \"%s\")\n", prop:WaitForChild("Data"):GetAttribute("HatID")).. string.format("\n\tEvents.BuildingEvent:FireServer(7, Prop, Prop:GetPivot(), nil, %s)\n\tNode:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\nend\n", tostring(prop.PrimaryPart.Size.X))
					return
				end
	
				for _, item in ipairs(playerFurniture) do
					local itemIdentifier = item.Name
	
					local isEqual = CheckSize(prop, item)
	
					if isEqual or propIdentifier == itemIdentifier then
						if string.find(itemIdentifier, "Trophy") then
							break
						end
	
						compiled_string = compiled_string.. string.format("\n-- >> Spawn %s << --\nif not Furniture[\"%s\"] or (Furniture[\"%s\"] and not Furniture[\"%s\"][9]) or (Furniture[\"%s\"] and string.find(LocalPlayer.PlayerData.PInvetory.Value, Furniture[\"%s\"][9].. \",\")) then\n\tEvents.BuildingEvent:FireServer(1, \"%s\", Node:GetPivot():ToWorldSpace(CFrame.new(%s):ToObjectSpace(CFrame.new(%s))), nil, BrickColor.new(\"%s\"), nil, nil, %s)", itemIdentifier, itemIdentifier, itemIdentifier, itemIdentifier, itemIdentifier, itemIdentifier, itemIdentifier, nodePivot, tostring(prop.PrimaryPart.CFrame), tostring(BrickColor.new(color).Name), material.Name ~= "Neon" and ("\"".. material.Name.. "\"") or "nil").. string.format("\n\tProp = Node:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\n\tEvents.BuildingEvent:FireServer(7, Prop, Prop:GetPivot(), nil, %s)\n\tNode:FindFirstAncestor(LocalPlayer.Name).ChildAdded:Wait()\nend\n", tostring(prop.PrimaryPart.Size.X))
					end
				end
			end
		end)()
	end

	warn("Apollo Client: Saved node to `".. saveDirectory.. "`")

	writefile(saveDirectory, compiled_string)
end

local function copyOutfit()
	local playerSelection = Player_Selection.Value
	if not playerSelection then
		linoria_lib:Notify("Please select a player.", 10)
		return
	end

	local selectedPlayer = Players:FindFirstChild(playerSelection)
	if not selectedPlayer then
		linoria_lib:Notify("Selected player is not valid!", 10)
		return
	end

	local playerData = selectedPlayer:WaitForChild("PlayerData", 1/0)
	local outfitData = playerData:WaitForChild("Outfit", 1/0)

	setclipboard(outfitData.Value)

	linoria_lib:Notify("Copied ".. playerSelection .."'s outfit id to your clipboard.", 10)
end

local function copyJukeboxAudio()
	local playerSelection = Player_Selection.Value
	if not playerSelection then
		linoria_lib:Notify("Please select a player.", 10)
		return
	end

	local selectedPlayer = Players:FindFirstChild(playerSelection)
	if not selectedPlayer then
		linoria_lib:Notify("Selected player is not valid!", 10)
		return
	end

	local playerBuilding = Buildings:FindFirstChild(playerSelection)
	if not playerBuilding then
		linoria_lib:Notify("This player does not have a node placed down.", 10)
		return
	end

	local jukebox = playerBuilding:FindFirstChild("Jukebox")
	if not jukebox then
		linoria_lib:Notify("This player does not have a jukebox placed down.", 10)
		return
	end

	local jukeboxAudio = jukebox:FindFirstChild("Sound", true)
	if jukeboxAudio then -- Add error handling if you want
		setclipboard(jukeboxAudio.SoundId)

		linoria_lib:Notify("Copied audio to clipboard.", 10)
	end
end

-- Options --
PlayerOptions:AddButton("Copy Node <b>[Beta]</b>", copyNode)
PlayerOptions:AddButton("Copy Outfit", copyOutfit)
PlayerOptions:AddButton("Copy Jukebox Audio", copyJukeboxAudio)

-- >> Functionality << --

-- Update Data Viewer
local function UpdateDataViewer()
	local playerSelection = Player_Selection.Value
	if not playerSelection then
		return
	end

	local selectedPlayer = Players:FindFirstChild(playerSelection)
	if not selectedPlayer then
		return
	end

	local playerData = selectedPlayer:WaitForChild("PlayerData", 1/0)

	local playerUID = selectedPlayer.UserId
	local playerIdentifier = selectedPlayer.Name
	local playerDisplayIdentifier = selectedPlayer.DisplayName

	-- Basic
	DataViewerLabels.Selected:SetText("<b>Selected:</b> ".. playerIdentifier ..(playerIdentifier == playerDisplayIdentifier and "" or (" | ".. playerDisplayIdentifier)))
	DataViewerLabels.UserId:SetText("<b>UserId:</b> ".. playerUID)
	DataViewerLabels.Karma:SetText("<b>Karma:</b> ".. playerData.Karma.Value)
	DataViewerLabels.Cash:SetText("<b>Cash:</b> ".. playerData.Currency.Value)
	DataViewerLabels.Aureus:SetText("<b>Aureus:</b> ".. playerData.PCurrency.Value)
	DataViewerLabels.Playtime:SetText("<b>Playtime:</b> ".. playerData.PlayTime.Value)

	-- Hotbar
	local items = {}
	for _, item in ipairs(selectedPlayer:WaitForChild("Backpack"):GetChildren()) do
		table.insert(items, item.Name)
	end

	local compiled = table.concat(items, ", ")
	DataViewerLabels.Hotbar:SetText("<b>Hotbar:</b> ".. compiled)

	-- Inventory
	local compiled = table.concat(string.split(playerData.Inventory.Value, ","), ", ")
	DataViewerLabels.Inventory:SetText("\n<b>Inventory:</b> ".. compiled)

	-- Bank
	local compiled = table.concat(string.split(playerData.Bank.Value, ","), ", ")
	DataViewerLabels.Bank:SetText("\n<b>Bank:</b> ".. compiled)
end

-- Update Dropdowns
-- Options
local HealAura_Whitelist = Options.HealAura_Whitelist
local function UpdateDropdowns()
	-- Heal Aura Whitelist
	HealAura_Whitelist:SetValues(ActivePlayers)

	-- Player Selection List
	Player_Selection:SetValues(ActivePlayers)
end

-- ESP Library
local esp_objects = {}

-- Toggles
local ESP_Players = Toggles.ESP_Players
local ESP_Printers = Toggles.ESP_Printers
local ESP_Entities = Toggles.ESP_Entities
local ESP_Shipments = Toggles.ESP_Shipments
local function isEspEnabled(esp_object)
	if not ESP_Enabled.Value then
		return false
	end

	local object_type = esp_object.Type

	local enabled = false

	if object_type == "Player" then
		enabled = ESP_Players.Value
	elseif object_type == "Printer" then
		enabled = ESP_Printers.Value
	elseif object_type == "Entity" then
		enabled = ESP_Entities.Value
	elseif object_type == "Shipment" then
		enabled = ESP_Shipments.Value
	end

	return enabled
end

local HostileColor = Color3.fromRGB(255, 33, 33)
local function isHostile(character)
	local playerObject = Players:GetPlayerFromCharacter(character)

	if playerObject then
		local nameTag = character:FindFirstChild("NameTag")
		local tagLabel = nameTag and nameTag:FindFirstChild("TextLabel")
		if tagLabel and tagLabel.TextColor3 == HostileColor then
			return true
		end
	end

	return false
end

local function isFlagged(playerObject)
	if playerObject then
		local flaggedValue = playerObject:FindFirstChild("Flagged")

		return flaggedValue and flaggedValue.Value
	end

	return false
end

local function RemoveObjectEsp(object)
	if not object then
		error("invalid argument #1, is it null?", 2)
		return
	end

	for index, esp_object in pairs(esp_objects) do
		if index == object then
			esp_object.Highlight:Destroy()

			esp_object.Name:Remove()
			esp_object.Info:Remove()
			esp_object.Tracer:Remove()

			-- Allow gc
			esp_objects[index] = nil
			
			break
		end
	end
end

local MoneyPrinters = workspace:WaitForChild("MoneyPrinters")
local Entities = workspace:WaitForChild("Entities")
local function AddObjectEsp(object)
	if not object then
		error("invalid argument #1, is it null?", 2)
		return
	end

	if object == LocalPlayer then
		return
	end

	if object.Parent ~= nil then
		local esp = {
			Highlight = Instance.new("Highlight"),
			Name = Drawing.new("Text"),
			Info = Drawing.new("Text"),
			Tracer = Drawing.new("Line"),
			Type = (object.ClassName == "Player" and "Player") or (object:IsDescendantOf(MoneyPrinters) and "Printer") or ((object:IsDescendantOf(Entities) and object.Name == "Gun") and "Entity") or ((object:IsDescendantOf(Entities) and string.find(object.Name, "Shipment")) and "Shipment") or nil
		}

		if esp.Type == nil then
			return
		end

		-- Information
		esp.Info.Color = Color3.fromRGB(204, 204, 204)
		esp.Info.Outline = true
		esp.Info.Size = 16
		esp.Info.Center = true

		-- Name
		esp.Name.Outline = true
		esp.Name.Size = 16
		esp.Name.Center = true

		-- Highlight
		esp.Highlight.OutlineTransparency = 1
		esp.Highlight.FillTransparency = 0.5
		esp.Highlight.Parent = CoreGui

		esp_objects[object] = esp
	end
end

-- Toggles
local ESP_Tracers = Toggles.ESP_Tracers
local ESP_MouseTracers = Toggles.ESP_MouseTracers

-- Options
local ESP_AdvancedPrinters = Options.ESP_AdvancedPrinters
local ESP_BasicPrinters = Options.ESP_BasicPrinters

local ESP_ShipmentColor = Options.ESP_ShipmentColor
local ESP_EntityColor = Options.ESP_EntityColor

local ESP_Hostile = Options.ESP_Hostile
local ESP_Flagged = Options.ESP_Flagged
local ESP_Government = Options.ESP_Government
local ESP_Neutral = Options.ESP_Neutral
local function UpdateEsp()
	for index, esp_object in pairs(esp_objects) do
		local can_update = true

		if not index or not index.Parent then
			esp_object.Highlight:Destroy()

			esp_object.Name:Remove()
			esp_object.Info:Remove()
			esp_object.Tracer:Remove()

			esp_objects[index] = nil

			can_update = false
		end

		local object_type = esp_object.Type

		if can_update then
			if isEspEnabled(esp_object) == false then
				can_update = false
			elseif object_type == "Player" and not index.Character then
				can_update = false
			elseif (object_type == "Printer" or object_type == "Entity" or object_type == "Shipment") and not index:FindFirstChild("Int") then
				can_update = false
			end
		end

		if can_update == false then
			esp_object.Name.Visible = false
			esp_object.Info.Visible = false
			esp_object.Tracer.Visible = false
			esp_object.Highlight.Enabled = false
		else
			local character, humanoid
			if object_type == "Player" then
				character = index.Character
				humanoid = character and character:FindFirstChildOfClass("Humanoid")
			end
	
			local esp_pivot = character and character:GetPivot() or index:GetPivot()
			local pivot_position = esp_pivot.Position
	
			local vector, isOnScreen = Camera:WorldToViewportPoint(pivot_position)
			local vectorX, vectorY = vector.X, vector.Y
			local vector2D = Vector2.new(vectorX, vectorY)
	
			-- Hide dead players
			if humanoid and humanoid.Health <= 0 then
				isOnScreen = false
			end
	
			if isOnScreen then
					local indexIdentifier = index.Name
	
					local esp_info = ""
					local esp_name = indexIdentifier
					local esp_color = Color3.fromRGB()
	
					if character then
						--- Info ---
	
						-- health
						local health, maxHealth = 0, 0
						if humanoid then
							health, maxHealth = math.ceil(humanoid.Health), math.floor(humanoid.MaxHealth)
						end
						-- karma
						local playerData = index:FindFirstChild("PlayerData")
						local karmaValue = playerData and playerData:FindFirstChild("Karma")
						local karma = karmaValue and tostring(karmaValue.Value) or "nil"
						-- tool
						local tool = character:FindFirstChildOfClass("Tool")
						local toolIdentifier = tool and tool.Name or "nil"
						-- format
						esp_info = string.format("Health: %s/%s | Karma: %s | Tool: %s", health, maxHealth, karma, toolIdentifier)
	
						--- Name ---
	
						-- variables
						local distance = math.floor(LocalPlayer:DistanceFromCharacter(pivot_position))
						local job = index:FindFirstChild("Job")
						-- format
						local jobTag = job and "[".. job.Value .."] " or ""
						local distancePostfix = " [".. distance .."]"
						esp_name = jobTag.. indexIdentifier ..distancePostfix
	
						--- Color ---
	
						-- variables
						local currentJob = job and job.Value
						-- possible colors
						local useHostileColor = isHostile(character)
						local useFlaggedColor = isFlagged(index)
						local useGovernmentColor = currentJob and (currentJob == "Soldier" or currentJob == "Detective" or currentJob == "Mayor")
						-- format
						esp_color = useHostileColor and ESP_Hostile.Value or useFlaggedColor and ESP_Flagged.Value or useGovernmentColor and ESP_Government.Value or ESP_Neutral.Value
					elseif object_type == "Printer" then
						--- Info ---
	
						-- variables
						local int = index:FindFirstChild("Int")
						-- value objects
						local money = int:FindFirstChild("Money")
						local uses = int:FindFirstChild("Uses")
						local owner = int:FindFirstChild("TrueOwner")
						-- values
						local realMoney = money and  money.Value
						local realUses = uses and uses.Value
						local realOwner = owner and tostring(owner.Value) or "nil"
						-- format
						esp_info = string.format("Money: %s | Uses: %s | Owner: %s", realMoney, realUses, realOwner)
	
						--- Color ---
	
						-- format
						local isAdvanced = string.find(indexIdentifier, "Advanced")
						esp_color = isAdvanced and ESP_AdvancedPrinters.Value or ESP_BasicPrinters.Value
					elseif object_type == "Shipment" then
						--- Info ---
	
						-- variables
						local int = index:FindFirstChild("Int")
						-- value objects
						local uses = int:FindFirstChild("Uses")
						local owner = int:FindFirstChild("TrueOwner")
						-- values
						local realUses = uses and uses.Value
						local realOwner = owner and tostring(owner.Value) or "nil"
						-- format
						esp_info = string.format("Uses: %s | Owner: %s", realUses, realOwner)
	
						--- Color ---
	
						-- format
						esp_color = ESP_ShipmentColor.Value
					elseif object_type == "Entity" then
						--- Name ---
	
						-- variables
						local int = index:FindFirstChild("Int")
						-- format
						esp_name = int and int.Value or "nil"
	
						--- Color ---
	
						-- format
						esp_color = ESP_EntityColor.Value
					end
	
					esp_object.Info.Text = esp_info
					esp_object.Name.Text = esp_name
					esp_object.Name.Color = esp_color
					esp_object.Tracer.Color = esp_color or Color3.fromRGB()
					esp_object.Highlight.FillColor = esp_color or Color3.fromRGB()
	
				esp_object.Info.Position = vector2D
				esp_object.Name.Position = Vector2.new(vectorX, vectorY - esp_object.Info.TextBounds.Y)
				esp_object.Tracer.To = vector2D
				esp_object.Tracer.From = (ESP_MouseTracers.Value and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 100))
				esp_object.Highlight.Adornee = character or index
			end
	
			esp_object.Name.Visible = isOnScreen
			esp_object.Info.Visible = isOnScreen
			esp_object.Tracer.Visible = isOnScreen and ESP_Tracers.Value
			esp_object.Highlight.Enabled = isOnScreen
		end
	end
end

-- Silent Aim
local FOVCircle = Drawing.new("Circle")
FOVCircle.NumSides = 200
FOVCircle.Color = Color3.fromRGB()
FOVCircle.Thickness = 1.5
FOVCircle.Visible = false

local function GetRandomPart(player)
	if not player then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local parts = {}

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(parts, child)
		end
	end

	if #parts == 0 then
		return
	end

	return parts[math.random(#parts)]
end

local Vehicles = workspace:WaitForChild("Vehicles")

-- Toggles
local SilentAim_Enabled = Toggles.SilentAim_Enabled
local SilentAim_Wallcheck = Toggles.SilentAim_Wallcheck

local SilentAim_FOVCircle = Toggles.SilentAim_FOVCircle

-- Options
local SilentAim_FOVSize = Options.SilentAim_FOVSize
local function ClosestToMouseWithinFOV()
	local lastDistance = 225
	local closestPlayer

	local localCharacter = LocalPlayer.Character

	for _, player in ipairs(Players:GetPlayers()) do
		if LocalPlayer ~= player then
			local character = player.Character
			if character then
				local characterPos = character:GetPivot().Position
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				local head = character:FindFirstChild("Head")
				if (humanoid and humanoid.Health > 0) and LocalPlayer:DistanceFromCharacter(characterPos) and (head and head.Transparency < 0.1) then
					local vector, isOnScreen = Camera:WorldToViewportPoint(characterPos)
					if isOnScreen then
						local mouseLocation = UserInputService:GetMouseLocation()

						local mouseLocation2D = Vector2.new(mouseLocation.X, mouseLocation.Y)
						local vector2D = Vector2.new(vector.X, vector.Y)

						local distance = (mouseLocation2D - vector2D).Magnitude

						if distance < lastDistance and distance <= SilentAim_FOVSize.Value then
							if (SilentAim_Wallcheck.Value and #Camera:GetPartsObscuringTarget({characterPos}, {localCharacter, character, Vehicles}) < 1) or not SilentAim_Wallcheck.Value then
								lastDistance = distance
								closestPlayer = player
							end
						end
					end
				end
			end
		end
	end

	return closestPlayer
end

-- Connections
for _, Player in ipairs(Players:GetPlayers()) do
	table.insert(ActivePlayers, Player.Name)

	AddObjectEsp(Player)
end

Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
	table.insert(ActivePlayers, player.Name)

	AddObjectEsp(player)
end)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
	RemoveObjectEsp(player)

	--------------------------------------

	local index = table.find(ActivePlayers, player.Name)
	
	if index then
		table.remove(ActivePlayers, index)
	end
end)

Connections.WorkspaceAdded = workspace.ChildAdded:Connect(function(child)
	if BypassNLR.Value and child.Name == "NL" then
		task.wait()

		child:Destroy()
	end
end)

-- ESP Connections
for _, Child in ipairs(Entities:GetChildren()) do AddObjectEsp(Child) end
Connections.EntityAdded = Entities.ChildAdded:Connect(AddObjectEsp)

for _, Child in ipairs(MoneyPrinters:GetChildren()) do AddObjectEsp(Child) end
Connections.PrinterAdded = MoneyPrinters.ChildAdded:Connect(AddObjectEsp)

-- Toggles
local EntitySpeed_Enabled = Toggles.EntitySpeed_Enabled

-- Options
local EntitySpeed_Keybind = Options.EntitySpeed_Keybind
local function characterAdded(character)
	local rootPart = character:WaitForChild("HumanoidRootPart")

	-- Entity Speed
	rootPart.ChildAdded:Connect(function(child)
		if child.Name == "FlightVelocity" then
			child:GetPropertyChangedSignal("Velocity"):Connect(function()
				if EntitySpeed_Enabled.Value and EntitySpeed_Keybind:GetState() == true then
					child.Velocity = child.Velocity * (EntitySpeed_Slider.Value / 20 + 1)
				end
			end)
		end
	end)
end

local Character = LocalPlayer.Character if Character then characterAdded(Character) end
Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(characterAdded)

local farmLoopTime = os.clock()
local healLoopTime = os.clock()

local espRefreshRate = os.clock()
local dropdownRefreshRate = os.clock()

local isHealing = false

local Drones = workspace:WaitForChild("Drones")

-- Toggles
local LoopEnableBackpack =  Toggles.LoopEnableBackpack

local HealAura_Enabled = Toggles.HealAura_Enabled
local AureusFarm_Enabled = Toggles.AureusFarm_Enabled
local AutoHeal_Enabled = Toggles.AutoHeal_Enabled

-- Options
local AutoHeal_Slider = Options.AutoHeal_Slider
Connections.RenderStepped = RunService.RenderStepped:Connect(function(deltaTime)
	if os.clock() - espRefreshRate > 0.025 then espRefreshRate = os.clock() UpdateEsp() end
	if os.clock() - dropdownRefreshRate > 1 then dropdownRefreshRate = os.clock() UpdateDropdowns() end

	UpdateDataViewer()

	-- Loop Enable Backpack
	if LoopEnableBackpack.Value then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	end

	-- Silent Aim FOV
	local mouseLocation = UserInputService:GetMouseLocation()

	FOVCircle.Visible	= SilentAim_FOVCircle.Value
	FOVCircle.Radius	= SilentAim_FOVSize.Value
	FOVCircle.Position	= Vector2.new(mouseLocation.X, mouseLocation.Y)
	FOVCircle.Color		= linoria_lib.AccentColor

	-- Humanoid assertion
	local localCharacter = LocalPlayer.Character
	local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
	if not localHumanoid then
		return
	end

	-- Heal Aura
	if HealAura_Enabled.Value and os.clock() - healLoopTime > 0.1  then
		healLoopTime = os.clock()

		local mediGun = localCharacter:FindFirstChild("MediGun") or localCharacter:FindFirstChild("[Doctor] MediGun")
		if mediGun and not isHealing then
			for _, player in ipairs(Players:GetPlayers()) do
				if LocalPlayer ~= player and HealAura_Whitelist.Value[player.Name] then
					local character = player.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					if humanoid and LocalPlayer:DistanceFromCharacter(character:GetPivot().Position) <= 20 then
						if localHumanoid.Health ~= 0 and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
							isHealing = true

							----------------------------

							local _conn

							local animation = localHumanoid:LoadAnimation(PistolFireAnim)
							animation:Play(0.2)

							_conn = mediGun.Unequipped:Connect(function()
								animation:Stop(0.2)
							end)

							local handle = mediGun:FindFirstChild("Handle")
							local sound = handle and handle:FindFirstChildOfClass("Sound")

							if sound then
								sound:Play()
							end

							----------------------------

							for i = 1, 35 do
								ToolsEvent:FireServer(5, humanoid)

								task.wait(0.043)

								ToolsEvent:FireServer(5, mediGun)
							end

							animation:Stop(0.4)

							_conn:Disconnect()

							isHealing = false
						end
					end
				end
			end
		end
	end

	-- Aureus Farm
	if AureusFarm_Enabled.Value and os.clock() - farmLoopTime > 2 then
		farmLoopTime = os.clock()

		for _, building in ipairs(Buildings:GetChildren()) do
			for _, prop in ipairs(building:GetChildren()) do
				if prop.Name == "Scavenge Station" then
					local propPivot = prop:GetPivot()

					if LocalPlayer:DistanceFromCharacter(propPivot.Position) <= 10 and os.time() - LocalData.DScavenge.Value > 0 then
						MenuAcitonEvent:FireServer(1, prop)

						local localDrone = Drones:WaitForChild(LocalIdentifier, 1/0)

						local shipment = workspace:WaitForChild("DroneShipment", 1/0)
						local shipmentPivot = shipment:GetPivot()

						localDrone:PivotTo(shipmentPivot + shipmentPivot.UpVector * 1.5)

						repeat
							MenuAcitonEvent:FireServer(3)
							task.wait(0.1)
						until shipment.Parent ~= workspace

						localDrone:PivotTo(propPivot + propPivot.UpVector * 2)

						repeat
							MenuAcitonEvent:FireServer(4)
							task.wait(0.1)
						until localDrone.Parent ~= Drones
					end
				end
			end
		end
	end

	-- Auto Heal
	if AutoHeal_Enabled.Value then
		local Cola = (LocalBackpack:FindFirstChild("Mythic Bloxy Cola") or LocalBackpack:FindFirstChild("Diet Bloxy Cola") or LocalBackpack:FindFirstChild("Bloxy Cola"))
		if Cola and localHumanoid.Health <= AutoHeal_Slider.Value then
			ToolsEvent:FireServer(4, Cola)
		end
	end
end)

-- Toggles
local AutoBuyAmmo = Toggles.AutoBuyAmmo
Connections["Rifle Ammo"] = LocalData:WaitForChild("Rifle Ammo").Changed:Connect(function(newValue)
	if newValue <= 120 and AutoBuyAmmo.Value then
		MenuEvent:FireServer(2, "Rifle Ammo (30x)", nil, 8)
	end
end)

Connections["Pistol Ammo"] = LocalData:WaitForChild("Pistol Ammo").Changed:Connect(function(newValue)
	if newValue <= 150 and AutoBuyAmmo.Value then
		MenuEvent:FireServer(2, "Pistol Ammo (30x)", nil, 8)
	end
end)

Connections["Heavy Ammo"] = LocalData:WaitForChild("Heavy Ammo").Changed:Connect(function(newValue)
	if newValue <= 2 and AutoBuyAmmo.Value then
		MenuEvent:FireServer(2, "Heavy Ammo (10x)", nil, 8)
	end
end)

Connections["SMG Ammo"] = LocalData:WaitForChild("SMG Ammo").Changed:Connect(function(newValue)
	if newValue <= 260 and AutoBuyAmmo.Value then
		MenuEvent:FireServer(2, "SMG Ammo (60x)", nil, 8)
	end
end)

local __namecall, __index

-- Toggles
local InstantCraft = Toggles.InstantCraft
--local InstantLockpick = Toggles.InstantLockpick
local InstantBatteringRam = Toggles.InstantBatteringRam

local BypassSpyChecks = Toggles.BypassSpyChecks

local HideItems = Toggles.HideItems

__namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local instance = tostring(self)

	local args = {...}

	local callingscript = getcallingscript()
	local method = getnamecallmethod()
	local isTrustedCall = checkcaller()

	-- Disable Anti-Cheat Remotes
	if method == "FireServer" and instance == "MenuActionEvent" then
		local index = args[2]
		if index == 26 or index == 25 then
			return
		end
	end

	-- Instant Craft
	if InstantCraft.Value then
		if method == "TweenSize" and args[1] == ProgressBar.Frame.Frame and ProgressBar.TextLabel.Text == "Crafting..." then
			args[5] = 0.001

			return __namecall(self, unpack(args))
		end
	end

	-- Instant Battering Ram
	if InstantBatteringRam.Value then
		if method == "TweenSize" and args[1] == ProgressBar.Frame.Frame and ProgressBar.TextLabel.Text == "Ramming Door" then
			args[5] = 0.001

			return __namecall(self, unpack(args))
		end
	end

	-- Bypass Spy Checks
	if BypassSpyChecks.Value and method == "LoadAnimation" and instance == "Humanoid" and args[1].Name == "SpyWatchIdle" then
		return
	end

	-- Hide Items
	if HideItems.Value and method == "FireServer" and instance == "WeaponBackEvent" then
		args[2] = true

		return __namecall(self, unpack(args))
	end

	-- Preventing Death
	if not isTrustedCall and method == "Destroy" and instance == "Humanoid" then
		return
	end

	return __namecall(self, ...)
end, true)

-- Toggles
local InfHunger = Toggles.InfHunger
local InfEnergy = Toggles.InfEnergy

__index = hookmetamethod(game, "__index", function(self, key)
	local instance = tostring(self)

	local __return = __index(self, key)

	local callingscript = getcallingscript()
	local isTrustedCall = checkcaller()

	if not isTrustedCall then
		-- Bypass Spy Checks
		if BypassSpyChecks.Value == true and key == "Transparency" and instance == "Head" and __return > 1 then
			if callingscript.Parent and string.find(callingscript.Parent.Name, "Spy Watch") then
				return __return
			end

			return 0
		end

		if BypassSpyChecks.Value == true and key == "Unequipped" and callingscript.Parent and string.find(callingscript.Parent.Name, "Spy Watch") then
			return
		end

		-- Silent Aim
		if SilentAim_Enabled.Value and key == "Hit" and self == LocalPlayer:GetMouse() and (callingscript.Parent and callingscript.Parent.ClassName == "Tool") then
			local closestPlayer = ClosestToMouseWithinFOV()
			local randomPart = GetRandomPart(closestPlayer)
			if closestPlayer and randomPart then
				return randomPart:GetPivot()
			end
		end

		-- Infinite Hunger & Energy
		if key == "Value" then
			if InfHunger.Value and instance == "Hunger" then
				return 100
			end

			if InfEnergy.Value and instance == "GadgetFuel" then
				return 1000
			end
		end

		-- Entity Speed
		if EntitySpeed_Enabled.Value and key == "Velocity" and string.find(self:GetFullName(), "Vehicles") then
			if __return.Magnitude > 500 then
				return Vector3.zero
			end

			local localCharacter = LocalPlayer.Character
			local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")

			local seat = localHumanoid and localHumanoid.SeatPart
			if seat and string.find(seat:GetFullName(), "Vehicles") and EntitySpeed_Keybind:GetState() == true then
				local mainPart = seat.Parent:FindFirstChild("Main")
				mainPart:ApplyImpulse(mainPart:GetPivot().LookVector * EntitySpeed_Slider.Value / 10 * ((UserInputService:IsKeyDown(Enum.KeyCode.W) and 1000) or (UserInputService:IsKeyDown(Enum.KeyCode.S) and -1000) or 1))
			end
		end
	end

	return __return
end, true)

linoria_lib:Notify("Apollo Client has loaded, press Right Ctrl to open the gui.", 10)

-- Configurations
save_manager:LoadAutoloadConfig()