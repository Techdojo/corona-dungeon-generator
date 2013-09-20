--[[--------------------------------------------------------------------------------------
	Corona Dungeon Generator
	
	Corona SDK version used: 2012.971
	
	File: main.lua
	
	Description: 
	
	Date: 
	
	Authors: Aidan Smyth
	
	Notes: 
	
-----------------------------------------------------------------------------------------]]

-- ######################################################################################
-- GLOBAL APPLICATION SETTINGS
-- ######################################################################################

-- set default screen background color to white
display.setDefault( "background", 255, 255, 255 )


-- Inital Settings
-----------------------------------------------------------------------------------------

--Remove status bar
display.setStatusBar( display.HiddenStatusBar ) -- Hide status bar from the beginning

-- Import modules
local appGlobals = require("globalData")
local json = require ("json")						-- Load JSON
local storyboard = require ("storyboard")			-- Load Storyboard

-- Set scenes to purge automatically.
storyboard.purgeOnSceneChange = true

-- os.execute("cls") -- Clear the Corona SDK terminal on restart




-- GLOBAL FUNCTION TO PRINT TABLE
--------------------------------------------------------------------------------
-- Print contents of a table
function tprint(tbl, indent)
	--print("Printing contents of table")
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep(" ", indent) .. k ..": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent+1)
		else
			print(formatting .. tostring(v))
		end
	end
end

-- GLOBAL FUNCTION TO DEEP COPY A TABLE
--------------------------------------------------------------------------------
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



-- ######################################################################################
-- START APP
-- ######################################################################################

-- go to file "menu.lua" use "fade" and take 400ms
storyboard.gotoScene( "scenetemplate", "fade", 200 )
