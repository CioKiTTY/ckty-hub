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

getgenv().CKTY_HUB = {
    version = "v0.0.1-unstable.1",
	path = "https://raw.githubusercontent.com/CioKiTTY/ckty-hub/v0.0.1-unstable.1",
}

----<< Game Loader >>----
-- [The Rake Remastered]
if game.PlaceId == 2413927524 then
	loadstring(game:HttpGet(getgenv().CKTY_HUB.path .. "/games/2413927524/main.luau"))()
end
