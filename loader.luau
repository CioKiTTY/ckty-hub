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

    v0.0.1-unstable.1  |  2025-09-27  |  Script Hub for Roblox

    Author: CioKiTTY
    GitHub: https://github.com/CioKiTTY/ckty-hub
    License: GNU General Public License v3.0
]]

local version = "v0.0.1-unstable.1"
if getgenv().CKTY_HUB_VERSION then
	version = getgenv().CKTY_HUB_VERSION or 'v0.0.1-unstable.1'
end

getgenv().CKTY_HUB = {
	version = version,
	path = "https://raw.githubusercontent.com/CioKiTTY/ckty-hub/" .. version,
	methods = {},
}

----<< Functions >>----
local function notify(title, text, duration)
	title = title or "Notification"
	text = text or ""
	duration = duration or 5

	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration,
		})
	end)
end

local function checkFunc(func, name)
	if type(func) ~= "function" then
		notify("Functions missing", "Function `" .. tostring(name) .. "` expected")
		return false
	end
	return true
end

getgenv().CKTY_HUB.methods.notify = notify
getgenv().CKTY_HUB.methods.checkFunc = checkFunc

----<< Game Loader >>----
-- [The Rake Remastered]
if game.PlaceId == 2413927524 then
	loadstring(game:HttpGet(getgenv().CKTY_HUB.path .. "/games/2413927524/main.luau"))()
end
