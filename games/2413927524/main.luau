--[[
        ,o888888o.    8 8888     ,88' 8888888 8888888888 `8.`8888.      ,8' 8 8888        8 8 8888      88 8 888888888o   
       8888     `88.  8 8888    ,88'        8 8888        `8.`8888.    ,8'  8 8888        8 8 8888      88 8 8888    `88. 
    ,8 8888       `8. 8 8888   ,88'         8 8888         `8.`8888.  ,8'   8 8888        8 8 8888      88 8 8888     `88 
    88 8888           8 8888  ,88'          8 8888          `8.`8888.,8'    8 8888        8 8 8888      88 8 8888     ,88 
    88 8888           8 8888 ,88'           8 8888           `8.`88888'     8 8888        8 8 8888      88 8 8888.   ,88' 
    88 8888           8 8888 88'            8 8888            `8. 8888      8 8888        8 8 8888      88 8 8888888888   
    88 8888           8 888888<             8 8888             `8 8888      8 8888888888888 8 8888      88 8 8888    `88. 
    `8 8888       .8' 8 8888 `Y8.           8 8888              8 8888      8 8888        8 ` 8888     ,8P 8 8888      88 
       8888     ,88'  8 8888   `Y8.         8 8888              8 8888      8 8888        8   8888   ,d8P  8 8888    ,88' 
        `8888888P'    8 8888     `Y8.       8 8888              8 8888      8 8888        8    `Y88888P'   8 888888888P   

    The Rake Remastered  |  2413927524  | ckty-hub

    This script is not intended to be executed apart from the hub

    Author: CioKiTTY
    GitHub: https://github.com/CioKiTTY/ckty-hub
    License: GNU General Public License v3.0
]]

----<< Services >>----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

----<< Checks >>----
local checkFunc = getgenv().CKTY_HUB.methods.checkFunc
checkFunc(hookfunction, "hookfunction")
checkFunc(hookmetamethod, "hookmetamethod")
checkFunc(getloadedmodules, "getloadedmodules")
checkFunc(getnamecallmethod, "getnamecallmethod")
checkFunc(getconnections, "getconnections")

if Players.LocalPlayer.Character == nil or not Players.LocalPlayer.Character then
	warn("Unable to find localplayer character. Yielding...")
	Players.LocalPlayer.CharacterAdded:Wait()
	Players.LocalPlayer.Character:WaitForChild("Humanoid")
	Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	print("Localplayer character found!")
end

----<< Libraries >>----
local ESPController = loadstring(game:HttpGet(getgenv().CKTY_HUB.path .. "/libraries/ESPController.luau"))()
local GUILibrary = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.51/main.lua"))() -- WindUI v1.6.51
local AdditionalGUI =
	loadstring(game:HttpGet(getgenv().CKTY_HUB.path .. "/games/2413927524/libraries/AdditionalGUI.luau"))()

----<< Variables >>----
local espObjects = {
	players = {},
	rake = nil,
	flareGun = nil,
	scraps = {},
	waypoints = {},
	supplyCrates = {},
	traps = {},
}

local supplyCrateConnections = {}
local doorKnockConnection
local isQuickRunning = false

----<< Game Objects >>----
local localPlayer = Players.LocalPlayer

local folders
folders = {
	Filter = workspace:WaitForChild("Filter"),
	Debris = workspace:WaitForChild("Debris"),
	Map = workspace:WaitForChild("Map"),
}

local scrapSpawns = folders.Filter:WaitForChild("ScrapSpawns")
local locationPoints = folders.Filter:WaitForChild("LocationPoints"):GetChildren()
local supplyCrates = folders.Debris:WaitForChild("SupplyCrates")
local trapsFolder = folders.Debris:WaitForChild("Traps")

local invisibleWalls = folders.Filter:WaitForChild("InvisibleWalls"):GetChildren()
local currentLightingProperties = ReplicatedStorage:WaitForChild("CurrentLightingProperties")
local dayProperties = ReplicatedStorage:WaitForChild("DayProperties"):GetChildren()
local nightProperties = ReplicatedStorage:WaitForChild("NightProperties"):GetChildren()
local bloodHourColor = Lighting:WaitForChild("BloodHourColor")
local nightValue = ReplicatedStorage:WaitForChild("Night")
local turningToDay = ReplicatedStorage:WaitForChild("TurningToDay")

----<< Configuration >>----
local config = {
	movement = {
		noStaminaDrain = true,
		noFallDamage = true,
	},
	render = {
		players = {
			nametag = {
				visible = true,
				textSize = 12,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(0, 1, 0), 0.8 },
				offset = Vector3.new(0, 2, 0),
			},
			cham = {
				visible = true,
				color = { Color3.new(1, 1, 1), 0.9 },
				outlineColor = { Color3.new(0, 1, 0), 0 },
			},
		},
		rake = {
			nametag = {
				visible = true,
				textSize = 12,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(1, 0, 0), 0.5 },
				offset = Vector3.new(0, 2, 0),
			},
			cham = {
				visible = true,
				color = { Color3.new(1, 1, 1), 0.9 },
				outlineColor = { Color3.new(1, 0, 0), 0 },
			},
			notification = true,
		},
		flareGun = {
			nametag = {
				visible = true,
				textSize = 12,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(0, 0, 0), 0.5 },
				offset = Vector3.new(0, 2, 0),
			},
			cham = {
				visible = true,
				color = { Color3.new(1, 1, 1), 0.9 },
				outlineColor = { Color3.new(1, 0, 1), 0 },
			},
			notification = true,
		},
		scraps = {
			nametag = {
				visible = true,
				textSize = 10,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(0, 0, 0), 0.5 },
				offset = Vector3.new(0, 2, 0),
			},
			cham = {
				visible = true,
				color = { Color3.new(1, 1, 1), 0.9 },
				outlineColor = { Color3.new(1, 1, 0), 0 },
			},
		},
		waypoints = {
			nametag = {
				visible = true,
				textSize = 14,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(0, 0.5, 1), 0.7 },
				offset = Vector3.new(0, 6, 0),
			},
			cham = {
				visible = false,
			},
		},
		supplyCrates = {
			nametag = {
				visible = true,
				textSize = 12,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(0, 0, 0), 0.5 },
				offset = Vector3.new(0, 2, 0),
			},
			cham = {
				visible = true,
				color = { Color3.new(1, 1, 1), 0.9 },
				outlineColor = { Color3.new(1, 1, 0), 0 },
			},
			notification = true,
		},
		traps = {
			nametag = {
				visible = false,
				textSize = 10,
				color = { Color3.new(1, 1, 1), 0 },
				outlineColor = { Color3.new(0, 0, 0), 0.5 },
				offset = Vector3.new(0, 2, 0),
			},
			cham = {
				visible = true,
				color = { Color3.new(1, 1, 1), 0.9 },
				outlineColor = { Color3.new(1, 0, 0), 0 },
			},
		},
	},
	world = {
		borders = {
			canCollide = true,
			visible = false,
		},
		noFog = false,
		sky = {
			alwaysDay = false,
			alwaysNight = false,
			noBloodHour = false,
		},
		modifyDoorKnock = false,
	},
	misc = {
		timeNPower = true,
		bypassSupplyCrateLock = true,
	},
}

----<< Functions >>----

-- [Movement]
local function hookStaminaDrain()
	for _, v in pairs(getloadedmodules()) do
		if v.Name == "M_H" then
			local module = require(v)
			local original
			original = hookfunction(module.TakeStamina, function(something, amount)
				if amount > 0 and config.movement.noStaminaDrain then
					return original(something, -1)
				end

				return original(something, amount)
			end)
		end
	end
end

local function hookFallDamage()
	local original
	original = hookmetamethod(game, "__namecall", function(...)
		if getnamecallmethod() == "FireServer" and config.movement.noFallDamage then
			if tostring(...) == "FD_Event" then
				return
			end
		end

		return original(...)
	end)
end

-- [Render]
local function updateTrackers(category: string)
	if category == "rake" or category == "flareGun" then
		if espObjects[category] ~= nil then
			espObjects[category]:Update(espObjects.Render[category])
		end
		return
	end

	for _, espObject in ipairs(espObjects[category]) do
		espObject:Update(config.render[category])
	end
end

-- [Players]
local function trackPlayer(player: Player)
	local character: Model = player.Character

	local opt = config.render.players

	local text = player.DisplayName
	if character.Name ~= player.DisplayName then
		text = text .. " - " .. character.Name
	end

	local espObject = ESPController.new(character, {
		nametag = {
			visible = opt.nametag.visible,
			text = text .. " - {distance} studs - {health} hp",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			table.remove(espObjects.players, table.find(espObjects.players, espObject))
		end,
	})

	if espObject then
		table.insert(espObjects.players, espObject)
	end
end

local function trackAllPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		if player == localPlayer or not player.Character or player.Character == nil then
			continue
		end

		trackPlayer(player)
	end
end

-- [Rake]
local function trackRake()
	local rake: Model = workspace:FindFirstChild("Rake")

	if not rake then
		return
	end

	local opt = config.render.rake

	local espObject = ESPController.new(rake, {
		nametag = {
			visible = opt.nametag.visible,
			text = "The Rake - {distance} studs - {health} hp",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			espObjects.rake = nil
		end,
	})

	if espObject then
		espObjects.rake = espObject

		if opt.notification then
			GUILibrary:Notify({
				Title = "The Rake",
				Content = "The rake has emerged from its cave",
				Duration = 3,
			})
		end
	end
end

-- [Flare Gun]
local function trackFlareGun()
	local flareGun = workspace:FindFirstChild("FlareGunPickUp")

	if not flareGun then
		return
	end

	local opt = config.render.flareGun

	local espObject = ESPController.new(flareGun, {
		nametag = {
			visible = opt.nametag.visible,
			text = "The Rake - {distance} studs - {health} hp",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			espObjects.flareGun = nil
		end,
	})

	if espObject then
		espObjects.flareGun = espObject

		if opt.notification then
			GUILibrary:Notify({
				Title = "Flare Gun",
				Content = "Flare gun has been summoned",
				Duration = 3,
			})
		end
	end
end

-- [Scraps]
local function getAllScraps()
	local list = {}

	for _, spawner in ipairs(scrapSpawns:GetChildren()) do
		if not spawner:FindFirstChildWhichIsA("Model") then
			continue
		end

		if spawner:FindFirstChildWhichIsA("Model"):FindFirstChild("Scrap") then
			table.insert(list, spawner:FindFirstChildWhichIsA("Model"):FindFirstChild("Scrap"))
		end
	end

	return list
end

local function trackScrap(scrap)
	if not scrap then
		return
	end

	local opt = config.render.scraps

	local levelVal: NumberValue = scrap.Parent:WaitForChild("LevelVal")

	local espObject = ESPController.new(scrap, {
		nametag = {
			visible = opt.nametag.visible,
			text = "Scrap - Lv." .. levelVal.Value .. " - {distance} studs",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			table.remove(espObjects.scraps, table.find(espObjects.scraps, espObject))
		end,
	})

	if espObject then
		table.insert(espObjects.scraps, espObject)
	end
end

local function trackAllScraps()
	for _, scrap in ipairs(getAllScraps()) do
		trackScrap(scrap)
	end
end

-- [Waypoints]
local function trackWaypoint(locationPoint: Part)
	if not locationPoint then
		return
	end

	local opt = config.render.waypoints

	local text
	if locationPoint.Name:find("Station") then
		text = "Power Station"
	else
		text = locationPoint.Name:gsub("MSG", ""):gsub("(%l)(%u)", "%1 %2")
	end

	local espObject = ESPController.new(locationPoint, {
		nametag = {
			visible = opt.nametag.visible,
			Text = "The " .. text .. " - {distance} studs",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			table.remove(espObjects.waypoints, table.find(espObjects.waypoints, espObject))
		end,
	})

	if espObject then
		table.insert(espObjects.waypoints, espObject)
	end
end

local function trackAllWaypoints()
	for _, LocationPoint in ipairs(locationPoints) do
		trackWaypoint(LocationPoint)
	end
end

-- [Supply Crates]
local function setSupplyCrateConnection(bool, box)
	for _, connection in ipairs(getconnections(box.GUIPart.ProximityPrompt.Triggered)) do
		if bool then
			connection:Enable()
			continue
		end
		connection:Disable()
	end
end

local function modifySupplyCratePrompt(box: Model)
	if not box:FindFirstChild("GUIPart") then -- Supply box is falling. After falling, it will call another child added event. Then back to this.
		return
	end

	setSupplyCrateConnection(false, box)

	box.GUIPart.ProximityPrompt.Triggered:Connect(function(trigger)
		if trigger == localPlayer and not box.DB_Folder:FindFirstChild(localPlayer.Name) then
			local ItemsFolder = box.Items_Folder

			for _, item in ipairs(ItemsFolder:GetChildren()) do
				local modifierConnection = AdditionalGUI.SupplyDropGUI:AddItem(item, function()
					ReplicatedStorage.SupplyClientEvent:FireServer("Collect", item.Name)
				end)

				if modifierConnection then
					table.insert(supplyCrateConnections, modifierConnection)
				end
			end

			AdditionalGUI.SupplyDropGUI:Open()
		end
	end)
end

local function trackSupplyCrate(box: Model)
	if not box then
		return
	end

	local opt = config.render.supplyCrates

	if config.misc.bypassSupplyCrateLock then
		modifySupplyCratePrompt(box)
	else
		setSupplyCrateConnection(true, box)
		for _, connection in ipairs(supplyCrateConnections) do
			connection:Disconnect()
		end
	end

	local espObject = ESPController.new(box, {
		nametag = {
			visible = opt.nametag.visible,
			Text = "Supply Crate - {distance} studs",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			table.remove(espObjects.supplyCrates, table.find(espObjects.supplyCrates, espObject))
		end,
	})

	if espObject then
		table.insert(espObjects.supplyCrates, espObject)

		if opt.notification then
			GUILibrary:Notify({
				Title = "Supply Crate",
				Content = "Supply crate has been dropped",
				Duration = 3,
			})
		end
	end
end

local function trackAllSupplyCrates()
	for _, box in ipairs(supplyCrates:GetChildren()) do
		trackSupplyCrate(box)
	end
end

-- [Traps]
local function trackTrap(trap: Model)
	if not trap then
		return
	end

	local opt = config.render.traps

	local espObject = ESPController.new(trap, {
		nametag = {
			visible = opt.nametag.visible,
			Text = "Trap - {distance} studs",
			textSize = opt.nametag.textSize,
			color = opt.nametag.color,
			outlineColor = opt.nametag.outlineColor,
			offset = opt.nametag.offset,
		},
		cham = {
			visible = opt.cham.visible,
			color = opt.cham.color,
			outlineColor = opt.cham.outlineColor,
		},
		onDestroy = function(espObject)
			table.remove(espObjects.traps, table.find(espObjects.traps, espObject))
		end,
	})

	if espObject then
		table.insert(espObjects.traps, espObject)
	end
end

local function trackAllTraps()
	for _, trap in ipairs(trapsFolder:GetChildren()) do
		trackTrap(trap)
	end
end

-- [Tool Modifier]
local function modifyStunStick()
	local tool: Tool = localPlayer.Backpack:FindFirstChild("StunStick")
		or localPlayer.Character:FindFirstChild("StunStick")

	if not tool then
		return
	end

	if tool:GetAttribute("Modified") then
		return
	end

	task.wait(1)
	localPlayer.Character.Humanoid:EquipTool(tool)
	task.wait(1)

	for _, connection in ipairs(getconnections(tool.Activated)) do
		connection:Disable()
	end

	tool.Activated:Connect(function()
		local Animation = localPlayer.Character.Humanoid:LoadAnimation(tool.SwingAnim)
		Animation:Play()

		tool.Event:FireServer("S")

		if workspace:FindFirstChild("Rake") then
			if workspace:FindFirstChild("Rake"):FindFirstChild("Torso") then
				for i = 1, 20, 1 do
					pcall(function()
						tool.Event:FireServer("H", workspace:FindFirstChild("Rake"):FindFirstChild("Torso"))
					end)
				end
			end
		end
	end)

	tool:SetAttribute("Modified", true)
end

-- [World Modifiers]
local function updateBorders()
	for _, border in ipairs(invisibleWalls) do
		if border:IsA("BasePart") or border:IsA("Part") then
			border.CanCollide = config.world.borders.canCollide
			border.Transparency = config.world.borders.visible and 0.8 or 1
			border.Color = Color3.fromRGB(255, 0, 0)
		end
	end
end

local function eraseFog()
	Lighting.FogEnd = 9999
	currentLightingProperties.FogEnd.Value = 9999
end

local function updateToDay()
	for _, value in ipairs(dayProperties) do
		Lighting[value.Name] = value.Value
		if currentLightingProperties:FindFirstChild(value.Name) then
			currentLightingProperties[value.Name].Value = value.Value
		end
	end
end

local function updateToNight()
	for _, value in ipairs(nightProperties) do
		Lighting[value.Name] = value.Value
		if currentLightingProperties:FindFirstChild(value.Name) then
			currentLightingProperties[value.Name].Value = value.Value
		end
	end
end

local function setKnockConnection(bool)
	for _, connection in ipairs(getconnections(folders.Map.SafeHouse.Door.Door.DoorGUIPart.ProximityPrompt.Triggered)) do
		if bool then
			if doorKnockConnection then
				doorKnockConnection:Disconnect()
			end

			connection:Enable()
			continue
		end

		connection:Disable()
	end
end

local function modifyDoorKnock()
	setKnockConnection(false)

	doorKnockConnection = folders.Map.SafeHouse.Door.Door.DoorGUIPart.ProximityPrompt.Triggered:Connect(
		function(trigger)
			if trigger == localPlayer then
				folders.Map.SafeHouse.Door.RemoteEvent:FireServer("Door")
			end
		end
	)
end

-- [Others]
local setupDeathDetection

local function handleDeath()
	coroutine.wrap(function()
		repeat
			RunService.Heartbeat:Wait()
		until localPlayer:WaitForChild("Started").Value == false -- Waiting until player is truly dead

		repeat
			RunService.Heartbeat:Wait()
		until localPlayer:WaitForChild("Started").Value == true -- Waiting for player to press start

		task.wait(3) -- Waiting for play sequence to complete

		hookStaminaDrain()
		setupDeathDetection()
	end)()
end

setupDeathDetection = function()
	localPlayer.Character.Humanoid.Died:Connect(function()
		handleDeath()
	end)
end

----<< GUI >>----
-- [Main GUI]
local Window = GUILibrary:CreateWindow({
	Title = "CKTY Hub",
	Icon = "cat",
	Author = "by CioKiTTY",
	Folder = "ckty-hub",
})

Window:Tag({
	Title = getgenv().CKTY_HUB.version,
	Color = Color3.fromHex("#30ff6a"),
	Radius = 13,
})

local Tabs = {
	Movement = Window:Tab({
		Title = "Movement",
		Icon = "footprints",
	}),
	Render = Window:Tab({
		Title = "Render",
		Icon = "radar",
	}),
	Utility = Window:Tab({
		Title = "Utility",
		Icon = "pencil-ruler",
	}),
	World = Window:Tab({
		Title = "World",
		Icon = "globe",
	}),
	Misc = Window:Tab({
		Title = "Misc",
		Icon = "candy",
	}),
	Settings = Window:Tab({
		Title = "Settings",
		Icon = "bolt",
	}),
	Credits = Window:Tab({
		Title = "Credits",
		Icon = "copyright",
	}),
}

-- Movement
do
	local Tab = Tabs.Movement

	do
		local Section = Tab:Section({
			Title = "Blatant",
		})
		local opt = config.movement

		Section:Toggle({
			Title = "No Stamina Drain",
			Desc = "Your staminal will not drain but increase instead",
			Default = opt.noStaminaDrain,
			Callback = function(state)
				opt.noStaminaDrain = state
			end,
		})

		Section:Toggle({
			Title = "No Fall Damage",
			Desc = "Falling will not deal damage to you",
			Default = opt.noFallDamage,
			Callback = function(state)
				opt.noFallDamage = state
			end,
		})

		Section:Keybind({
			Title = "Quick Run",
			Desc = "Immediately gets up to speed and allows you to run backwards",
			Value = "Q",
			Callback = function(v)
				print(v)
				isQuickRunning = not isQuickRunning
			end,
		})
	end
end

-- Render
do
	local Tab = Tabs.Render

	-- Players
	do
		local Section = Tab:Section({
			Title = "Players",
		})
		local opt = config.render.players

		Section:Toggle({
			Title = "Players Nametag Enabled",
			Desc = "Shows players name, distance, and health",
			Default = opt.nametag.visible,
			Callback = function(state)
				opt.nametag.visible = state
				updateTrackers("players")
			end,
		})

		Section:Toggle({
			Title = "Players Cham Enabled",
			Desc = "Shows highlight of the players",
			Default = opt.cham.visible,
			Callback = function(state)
				opt.cham.visible = state
				updateTrackers("players")
			end,
		})
	end

	-- Rake
	do
		local Section = Tab:Section({
			Title = "Rake",
		})
		local opt = config.render.rake

		Section:Toggle({
			Title = "Rake Nametag Enabled",
			Desc = "Shows the rake's distance and health",
			Default = opt.nametag.visible,
			Callback = function(state)
				opt.nametag.visible = state
				updateTrackers("rake")
			end,
		})

		Section:Toggle({
			Title = "Rake Cham Enabled",
			Desc = "Shows highlight of the rake",
			Default = opt.cham.visible,
			Callback = function(state)
				opt.cham.visible = state
				updateTrackers("rake")
			end,
		})

		Section:Toggle({
			Title = "Rake Notifier",
			Desc = "Send a notification when it spawns",
			Default = opt.notification,
			Callback = function(bool)
				opt.notification = bool
			end,
		})
	end

	-- Flare Gun
	do
		local Section = Tab:Section({
			Title = "Flare Gun",
		})
		local opt = config.render.flareGun

		Section:Toggle({
			Title = "Flare Gun Nametag Enabled",
			Desc = "Shows the flare gun distance",
			Default = opt.nametag.visible,
			Callback = function(state)
				opt.nametag.visible = state
				updateTrackers("flareGun")
			end,
		})

		Section:Toggle({
			Title = "Flare Gun Cham Enabled",
			Desc = "Shows highlight of the flare gun",
			Default = opt.cham.visible,
			Callback = function(state)
				opt.cham.visible = state
				updateTrackers("flareGun")
			end,
		})

		Section:Toggle({
			Title = "Flare Gun Notifier",
			Desc = "Send a notification when it spawns",
			Default = opt.notification,
			Callback = function(state)
				opt.notification = state
			end,
		})
	end

	-- Scraps
	do
		local Section = Tab:Section({
			Title = "Scraps",
		})
		local opt = config.render.scraps

		Section:Toggle({
			Title = "Scrap Nametag Enabled",
			Desc = "Shows the scrap level and distance",
			Default = opt.nametag.visible,
			Callback = function(state)
				opt.nametag.visible = state
				updateTrackers("scraps")
			end,
		})

		Section:Toggle({
			Title = "Scrap Cham Enabled",
			Desc = "Shows highlight of the scrap",
			Default = opt.cham.visible,
			Callback = function(state)
				opt.cham.visible = state
				updateTrackers("scraps")
			end,
		})
	end

	-- Waypoints
	do
		local Section = Tab:Section({
			Title = "Waypoints",
		})
		local opt = config.render.waypoints

		Section:Toggle({
			Title = "Waypoint Nametag Enabled",
			Desc = "Shows the waypoint distance",
			Default = opt.nametag.visible,
			Callback = function(bool)
				opt.nametag.visible = bool
				updateTrackers("waypoints")
			end,
		})
	end

	-- Supply Crates
	do
		local Section = Tab:Section({
			Title = "Supply Crates",
		})
		local opt = config.render.supplyCrates

		Section:Toggle({
			Title = "Supply Crate Nametag Enabled",
			Desc = "Shows the supply crate distance",
			Default = opt.nametag.visible,
			Callback = function(state)
				opt.nametag.visible = state
				updateTrackers("supplyCrates")
			end,
		})

		Section:Toggle({
			Title = "Supply Crate Cham Enabled",
			Desc = "Shows highlight of the supply crate",
			Default = opt.cham.visible,
			Callback = function(state)
				opt.cham.visible = state
				updateTrackers("supplyCrates")
			end,
		})

		Section:Toggle({
			Title = "Supply Crate Notifier",
			Desc = "Send a notification when it drops",
			Default = opt.notification,
			Callback = function(state)
				opt.notification = state
			end,
		})
	end

	-- Traps
	do
		local Section = Tab:Section({
			Title = "Traps",
		})
		local opt = config.render.traps

		Section:Toggle({
			Title = "Trap Nametag Enabled",
			Desc = "Shows the trap distance",
			Default = opt.nametag.visible,
			Callback = function(state)
				opt.nametag.visible = state
				updateTrackers("traps")
			end,
		})

		Section:Toggle({
			Title = "Trap Cham Enabled",
			Desc = "Shows highlight of the trap",
			Default = opt.cham.visible,
			Callback = function(state)
				opt.cham.visible = state
				updateTrackers("traps")
			end,
		})
	end
end

-- Utility
do
	local Tab = Tabs.Utility

	do
		local Section = Tab:Section({
			Title = "Tool Modification",
		})

		Section:Button({
			Title = "Modify Stun Stick",
			Desc = "Bigger and better hitbox",
			Callback = function()
				modifyStunStick()
			end,
		})
	end
end

-- World
do
	local Tab = Tabs.World

	Tab:Paragraph({
		Title = "Everything below are client sided, which meant effects are happening only to you",
	})

	-- Map Modification
	do
		local Section = Tab:Section({
			Title = "Map Modification",
		})
		local opt = config.world.borders

		Section:Toggle({
			Title = "Borders Collision Enabled",
			Desc = "Set to false if you want to go outside the map borders",
			Default = opt.canCollide,
			Callback = function(state)
				opt.canCollide = state
				updateBorders()
			end,
		})

		Section:Toggle({
			Title = "Show Borders",
			Desc = "Make the map borders visible to your eyes",
			Default = opt.visible,
			Callback = function(state)
				opt.visible = state
				updateBorders()
			end,
		})

		Section:Toggle({
			Title = "No Fog",
			Desc = "Get rid of those fogs that limits your visibiliy",
			Default = config.world.noFog,
			Callback = function(state)
				config.world.noFog = state

				if not state then
					if not nightValue.Value or turningToDay.Value then
						updateToDay()
					elseif nightValue.Value and not turningToDay.Value then
						updateToNight()
					end
				end
			end,
		})
	end

	-- Sky Modification
	do
		local Section = Tab:Section({
			Title = "Sky Modification",
		})
		local opt = config.world.sky

		local identity = false

		local dayTimeToggle
		local nightTimeToggle

		dayTimeToggle = Section:Toggle({
			Title = "Always Day Time",
			Desc = "No more darkness",
			Default = opt.alwaysDay,
			Callback = function(state)
				opt.alwaysDay = state

				if state then
					if not identity and opt.alwaysNight then
						identity = true
						nightTimeToggle:Set(false)
						identity = false
					end
				else
					if not nightValue.Value or turningToDay.Value then
						updateToDay()
					elseif nightValue.Value and not turningToDay.Value then
						updateToNight()
					end
				end
			end,
		})

		nightTimeToggle = Section:Toggle({
			Title = "Always Night Time",
			Desc = "Indefinite darkness until it all consumes everything",
			Default = opt.alwaysNight,
			Callback = function(state)
				opt.alwaysNight = state

				if state then
					if not identity and opt.alwaysDay then
						identity = true
						dayTimeToggle:Set(false)
						identity = false
					end
				else
					if not nightValue.Value or turningToDay.Value then
						updateToDay()
					elseif nightValue.Value and not turningToDay.Value then
						updateToNight()
					end
				end
			end,
		})

		Section:Toggle({
			Title = "No Blood Hour Ambient",
			Desc = "Turn this on if you don't like everything turning red",
			Default = opt.noBloodHour,
			Callback = function(bool)
				opt.noBloodHour = bool
				bloodHourColor.Enabled = not bool
			end,
		})
	end

	Tab:Paragraph({
		Title = "Everything below are server sided, which meant effects are happening to everyone",
	})

	-- Map Modification
	do
		local Section = Tab:Section({
			Title = "Map Modification",
		})
		local opt = config.world

		Section:Keybind({
			Title = "Open The Safehouse Door",
			Desc = "You must be near the house to do this",
			Value = "R",
			Callback = function()
				folders.Map.SafeHouse.Door.RemoteEvent:FireServer("Door")
			end,
		})

		Section:Keybind({
			Title = "Modify Door Knocking",
			Desc = "Your door knocks will always open the door",
			Default = opt.modifyDoorKnock,
			Callback = function(state)
				opt.modifyDoorKnock = state

				if state then
					modifyDoorKnock()
				else
					setKnockConnection(true)
				end
			end,
		})
	end
end

-- Misc
do
	local Tab = Tabs.Misc
	local opt = config.misc

	Tab:Toggle({
		Title = "Time & Power GUI",
		Desc = "Displays the time and power level",
		Default = opt.timeNPower,
		Callback = function(state)
			opt.timeNPower = state

			if AdditionalGUI.Constructed then
				if state then
					AdditionalGUI.TimePowerGUI:Open()
				else
					AdditionalGUI.TimePowerGUI:Close()
				end
			end
		end,
	})

	Tab:Toggle({
		Title = "Bypass Supply Crate Lock",
		Desc = "Immediately open the supply crate without unlocking it first",
		Default = opt.bypassSupplyCrateLock,
		Callback = function(bool)
			opt.bypassSupplyCrateLock = bool
			trackAllSupplyCrates()
		end,
	})
end

-- Settings
do
	local Tab = Tabs.Settings

	Tab:Keybind({
		Title = "Toggle GUI",
		Misc = "Keybind to show and hide the GUI",
		Value = "Home",
		Callback = function(keybind)
			Window:SetToggleKey(Enum.KeyCode[keybind])
		end,
	})
end

-- Credits
do
    local Tab = Tabs.Credits

    Tab:Paragraph({
        Title = "Credits",
        Desc = "Scripter = CioKiTTY \nGUI = WindUI\n"
    })
end

-- [Additional GUI]
AdditionalGUI:Construct()
do
	if config.misc.timeNPower then
		AdditionalGUI.TimePowerGUI:Open()
	end
end

----<< Initialize >>----
for _, border in ipairs(invisibleWalls) do
	if border:IsA("BasePart") or border:IsA("Part") then
		border.Material = Enum.Material.Neon
	end
end

trackAllPlayers()
trackRake()
trackFlareGun()
trackAllScraps()
trackAllWaypoints()
trackAllSupplyCrates()
trackAllTraps()

task.spawn(function()
	task.wait(3)

	hookStaminaDrain()
	hookFallDamage()
	setupDeathDetection()
end)

----<< Events >>----
workspace.ChildAdded:Connect(function(child)
	if child.Name == "Rake" then
		child:WaitForChild("HumanoidRootPart")
		trackRake()
	elseif child.Name == "FlareGunPickUp" then
		trackFlareGun()
	end
end)

for _, spawner in ipairs(scrapSpawns:GetChildren()) do
	spawner.ChildAdded:Connect(function(child)
		trackScrap(child:WaitForChild("Scrap"))
	end)
end

supplyCrates.ChildAdded:Connect(function(child)
	trackSupplyCrate(child)
end)

trapsFolder.ChildAdded:Connect(function(child)
	trackTrap(child)
end)

local TimerValue = ReplicatedStorage:WaitForChild("Timer")
TimerValue:GetPropertyChangedSignal("Value"):Connect(function()
	if config.misc.timeNPower and AdditionalGUI.Constructed then
		AdditionalGUI.TimePowerGUI:UpdateTime(TimerValue.Value)
	end
end)

local PowerLevel = ReplicatedStorage:WaitForChild("PowerValues"):WaitForChild("PowerLevel")
PowerLevel:GetPropertyChangedSignal("Value"):Connect(function()
	if config.misc.timeNPower and AdditionalGUI.Constructed then
		AdditionalGUI.TimePowerGUI:UpdatePower(PowerLevel.Value)
	end
end)

task.spawn(function()
	while task.wait(5) do
		trackAllPlayers()
	end
end)

----------<< Loop >>----------
RunService.Heartbeat:Connect(function()
	if config.world.sky.alwaysDay then
		updateToDay()
	end

	if config.world.sky.alwaysNight then
		updateToNight()
	end

	if config.world.noFog then
		eraseFog()
	end
end)

RunService.RenderStepped:Connect(function()
	if isQuickRunning then
		localPlayer.Character.Humanoid.WalkSpeed = 24
	end
end)
